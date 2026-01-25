import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cekreklamemobile/core/utils/file_cache_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk HapticFeedback
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraController? _controller;
  FlashMode _currentFlashMode = FlashMode.off;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  // Guard agar init tidak dipanggil berkali-kali secara tidak sengaja
  bool _isInitializing = false;
  CameraController? get controller => _controller;

  CameraCubit() : super(CameraInitial());

  // ===============================================================
  // 1. ENTRY POINT & INITIALIZATION
  // ===============================================================
  Future<void> start() async {
    if (_isInitializing) return;
    _isInitializing = true;

    emit(CameraLoading());

    try {
      // ✅ FIX 1: PERMISSION DEFENSIVE CHECK
      // Cek status dulu, jangan asal request agar tidak ganggu UX jika sudah granted.
      final cameraStatus = await Permission.camera.status;
      final locationStatus = await Permission.locationWhenInUse.status;

      if (!cameraStatus.isGranted || !locationStatus.isGranted) {
        // Hanya request jika belum granted
        final camReq = await Permission.camera.request();
        final locReq = await Permission.locationWhenInUse.request();

        if (!camReq.isGranted || !locReq.isGranted) {
          if (camReq.isPermanentlyDenied || locReq.isPermanentlyDenied) {
            emit(CameraPermissionPermanentlyDenied());
          } else {
            emit(CameraPermissionDenied());
          }
          _isInitializing = false;
          return;
        }
      }

      await _initCamera();
    } catch (e) {
      emit(CameraFailure('Gagal mempersiapkan kamera: $e'));
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> retry() async {
    await start();
  }

  // ===============================================================
  // 2. ZOOM & FOCUS LOGIC
  // ===============================================================
  void onScaleStart() {
    _baseZoom = _currentZoom;
  }

  Future<void> onScaleUpdate(double scale) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    // Clamp sesuai min/max hardware
    final newZoom = (_baseZoom * scale).clamp(_minZoom, _maxZoom);

    try {
      await _controller!.setZoomLevel(newZoom);
      _currentZoom = newZoom;
      // Emit ready agar UI update
      emit(CameraReady(_controller!, _currentFlashMode, _currentZoom));
    } catch (_) {}
  }

  Future<void> onTapToFocus({
    required Offset tapPosition,
    required Size previewSize,
  }) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final x = tapPosition.dx / previewSize.width;
    final y = tapPosition.dy / previewSize.height;
    final focusPoint = Offset(x, y);

    try {
      await _controller!.setFocusPoint(focusPoint);
      await _controller!.setExposurePoint(focusPoint);

      // Emit state Focused (untuk memunculkan kotak kuning di UI)
      emit(
        CameraFocused(
          controller: _controller!,
          focusPoint: tapPosition,
          flashMode: _currentFlashMode,
          zoom: _currentZoom,
        ),
      );

      // Delay 500ms agar kotak kuning terlihat, lalu kembali ke Ready (kotak hilang)
      await Future.delayed(const Duration(milliseconds: 500));

      if (!isClosed) {
        emit(CameraReady(_controller!, _currentFlashMode, _currentZoom));
      }
    } catch (_) {}
  }

  // ===============================================================
  // 3. CAPTURE FLOW (CRITICAL PARITY FIX)
  // ===============================================================
  Future<void> capture() async {
    // 1. Cek Safety Awal
    if (isClosed) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state is CameraCapturing) return;

    // Haptic Feedback
    HapticFeedback.mediumImpact();

    // Gunakan safe emit
    _safeEmit(CameraCapturing());

    try {
      // Step A: Take Picture
      final file = await _controller!.takePicture();

      // 🛑 SAFETY CHECK: Jika user back saat shutter bunyi
      if (isClosed) return;

      // Step B: Check GPS
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw "GPS_DISABLED";

      if (isClosed) return; // 🛑 Cek lagi

      // Step C: Crop
      // Note: ImageCropper membuka Activity baru.
      // Saat user cancel/done di cropper, app kita resume.
      final safeFile = await _cropAndCache(file);

      if (isClosed) return; // 🛑 Cek lagi

      // Step D: Processing UI
      _safeEmit(CameraProcessing("Menyiapkan Foto..."));
      await Future.delayed(const Duration(milliseconds: 1200));

      if (isClosed) return; // 🛑 Cek lagi

      _safeEmit(CameraProcessing("Mencari Titik GPS..."));
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      if (isClosed) return; // 🛑 Cek lagi
      await Future.delayed(const Duration(milliseconds: 800));

      // Step E: Success
      _safeEmit(
        CameraCaptureSuccess(
          imagePath: safeFile.path,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      // 🛑 PENTING: Jangan emit failure jika cubit sudah tutup
      // Karena user tidak peduli errornya kalau dia sudah keluar aplikasi
      if (isClosed) return;

      if (e.toString().contains("GPS_DISABLED")) {
        _safeEmit(CameraFailure("GPS_DISABLED"));
      } else if (e is TimeoutException) {
        _safeEmit(CameraFailure("Gagal mendapatkan lokasi: Waktu habis."));
      } else if (e.toString().contains("Capture dibatalkan")) {
        // Balik ke ready
        if (_controller != null) {
          _safeEmit(CameraReady(_controller!, _currentFlashMode, _currentZoom));
        }
      } else {
        _safeEmit(CameraFailure(e.toString()));
      }
    }
  }

  // ===============================================================
  // 4. PRIVATE & UTILS
  // ===============================================================

  Future<void> _initCamera() async {
    if (_controller != null) await _controller!.dispose();

    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception("Kamera tidak ditemukan");

    // ✅ FIX 3: Prioritas Kamera Belakang
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // ✅ FIX 4: ImageFormatGroup untuk stabilitas Android & iOS
    _controller = CameraController(
      camera,
      ResolutionPreset.high, // ✅ FIX 2: Resolusi MAX (Tajam)
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.jpeg
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    // ✅ FIX 4: Safe Hardware Config (Granular Try-Catch)
    // Supaya kalau satu fitur gagal, kamera tetap jalan
    try {
      await _controller!.setFlashMode(_currentFlashMode);
    } catch (_) {}
    try {
      await _controller!.setFocusMode(FocusMode.auto);
    } catch (_) {}
    try {
      await _controller!.setExposureMode(ExposureMode.auto);
    } catch (_) {}

    try {
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
    } catch (_) {
      _minZoom = 1.0;
      _maxZoom = 1.0;
    }

    if (!isClosed) {
      emit(CameraReady(_controller!, _currentFlashMode, _currentZoom));
    }
  }

  Future<File> _cropAndCache(XFile file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Foto',
          toolbarColor: const Color(0xFF1976D2),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Reklame'),
      ],
    );

    if (cropped == null) {
      throw Exception("Capture dibatalkan"); // Signal untuk cancel flow
    }
    return FileCacheHelper.saveToCache(File(cropped.path));
  }

  Future<void> toggleFlashMode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    FlashMode newMode;
    if (_currentFlashMode == FlashMode.off) {
      newMode = FlashMode.auto;
    } else if (_currentFlashMode == FlashMode.auto) {
      newMode = FlashMode.always;
    } else {
      newMode = FlashMode.off;
    }

    try {
      await _controller!.setFlashMode(newMode);
      _currentFlashMode = newMode;
      // Emit state baru untuk update icon flash di UI
      emit(CameraReady(_controller!, _currentFlashMode, _currentZoom));
    } catch (_) {}
  }

  Future<void> onAppPaused() async {
    // Logic pause: dispose controller tapi simpan state
    await _controller?.dispose();
    _controller = null;
    emit(CameraLoading()); // UI menampilkan loading/hitam saat inactive
  }

  Future<void> onAppResumed() async {
    // 👇 HARDENING: Cek dulu, kalau controller masih hidup & sehat, JANGAN DIMATIKAN!
    // Ini mencegah siklus 'Dispose -> Init' yang bikin crash thread pool.
    if (_controller != null && _controller!.value.isInitialized) {
      // Opsional: Panggil resumePreview kalau previewnya sempat freeze (jarang terjadi di plugin baru)
      // Tapi biasanya membiarkannya saja sudah cukup.
      return;
    }

    // Kalau controller kosong (mati), baru kita init ulang.
    await _initCamera();
  }

  void _safeEmit(CameraState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  // Settings Helper
  Future<void> openSettings() async {
    await openAppSettings();
  }

  @override
  Future<void> close() {
    // Kita dispose controller, tapi controller ini object hardware.
    // Kadang butuh waktu sepersekian detik untuk mati.
    // Error 'buildPreview called on disposed controller' terjadi karena
    // UI masih mencoba render 1 frame terakhir saat controller sedang 'sekarat'.

    final controllerToDispose = _controller;
    _controller = null;

    controllerToDispose?.dispose();
    return super.close();
  }
}
