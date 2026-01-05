import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cekreklamemobile/core/utils/file_copy_utils.dart';
import 'package:cekreklamemobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

const String staticTestAssetPath = 'assets/images/guardian_reklame.jpg';

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  CroppedFile? _capturedPhoto;
  FlashMode _currentFlashMode = FlashMode.off;
  Offset? _focusPoint;
  bool _isCapturing = false;
  bool _isProcessingData = false;
  bool _isShutterLocked = false;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (!controller!.value.isInitialized || details.scale == 1.0) return;

    // Hitung zoom baru (base zoom * scale factor)
    final double newZoom = (_baseZoomLevel * details.scale).clamp(
      _minZoomLevel,
      _maxZoomLevel,
    ); // Pastikan dalam batas min/max

    await controller!.setZoomLevel(newZoom);

    setState(() {
      _currentZoomLevel = newZoom;
    });
  }

  void _handleTapToFocus(TapDownDetails details) async {
    if (!controller!.value.isInitialized || _capturedPhoto != null) return;

    // Konversi koordinat layar (pixel) ke koordinat kamera (0.0 hingga 1.0)
    final size = context.size;
    if (size == null) return;

    final x = details.localPosition.dx / size.width;
    final y = details.localPosition.dy / size.height;

    final focusPoint = Offset(x, y);

    try {
      // Atur fokus dan exposure
      await controller!.setFocusPoint(focusPoint);
      await controller!.setExposurePoint(focusPoint);

      setState(() {
        _focusPoint =
            details.localPosition; // Simpan posisi layar untuk indikator
      });

      // Hilangkan indikator fokus setelah jeda
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _focusPoint = null;
      });
    } on CameraException catch (e) {
      log("Error focusing: ${e.description}");
      // print("Error focusing: ${e.description}");
    }
  }

  void _toggleFlashMode() {
    FlashMode newMode;
    // Logika switch flash: Off -> Auto -> Always (sesuai kebutuhan)
    if (_currentFlashMode == FlashMode.off) {
      newMode = FlashMode.auto;
    } else if (_currentFlashMode == FlashMode.auto) {
      newMode = FlashMode.always;
    } else {
      newMode = FlashMode.off;
    }

    // Terapkan ke CameraController
    controller!.setFlashMode(newMode);

    setState(() {
      _currentFlashMode = newMode;
    });
  }

  Future<void> _initCameraAndPermissions() async {
    final cameras = await availableCameras();

    if (!mounted) return;

    if (cameras.isEmpty) {
      _showErrorAndPop("Tidak ada kamera tersedia.");
      return;
    }

    controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.jpeg
          : ImageFormatGroup.bgra8888,
    );

    try {
      await controller!.initialize();

      controller!.setFlashMode(_currentFlashMode);

      // 🔍 CETAK NILAI DIAGNOSTIK
      // debugPrint(
      //   'Camera Aspect Ratio DILAPORKAN: ${controller!.value.aspectRatio}',
      // );

      // Set Auto Focus secara kontinu agar kamera selalu siap tanpa perlu "hunting" fokus saat tombol ditekan
      try {
        await controller!.setFocusMode(FocusMode.auto);
      } catch (e) {
        debugPrint("Fokus otomatis tidak didukung pada perangkat ini");
      }

      _minZoomLevel = await controller!.getMinZoomLevel();
      _maxZoomLevel = await controller!.getMaxZoomLevel();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } on CameraException catch (e) {
      _showErrorAndPop("Error kamera: ${e.description}");
    }
  }

  Future<void> _capturePhotoAndLocation() async {
    // 1. GENTLE THROTTLE: Jika sedang proses, langsung abaikan tanpa Toast yang mengganggu
    if (controller == null ||
        !controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    // 2. FEEDBACK INSTAN: Getaran (Haptic) & Animasi Shutter (Opsional)
    // User merasa "perintah diterima" tanpa perlu klik berkali-kali
    HapticFeedback.mediumImpact();

    setState(() {
      _isShutterLocked = true;
      _isCapturing = true;
    });

    try {
      // 3. OPTIMASI CAPTURE: Ambil foto DULU sebelum urusan GPS
      // Semakin cepat takePicture dipanggil, semakin kecil risiko blur karena gerak
      final XFile capturedFile = await controller!.takePicture();

      setState(() {
        _isShutterLocked = false;
      });

      // 4. CEK GPS: Dilakukan setelah foto aman di memori
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Tampilkan peringatan, dan JANGAN lanjutkan ke langkah 2.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Layanan GPS tidak aktif. Mohon nyalakan GPS Anda.",
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        Geolocator.openLocationSettings();
        return;
      }

      // 5. PROSES BERAT (CROP & GPS)
      // Gunakan _isProcessingData untuk menampilkan Loading Overlay agar tombol tidak bisa ditekan
      setState(() => _isProcessingData = true);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: capturedFile.path,
        compressQuality: 70,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Foto',
            toolbarColor: Colors.blue[700],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Reklame'),
        ],
        // Menentukan rasio yang dapat digunakan pengguna (opsional)
        // cropStyle: CropStyle.rectangle,
      );

      if (croppedFile == null) {
        setState(() {
          _isCapturing = false;
          _isShutterLocked = false;
          _isProcessingData = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      if (mounted) {
        // a. Deep Copy File (Ambil path dari CroppedFile yang sudah di-crop)
        final File originalCroppedFile = File(croppedFile.path);
        final File safeFileToUpload = await copyFileToCache(
          originalCroppedFile,
        );

        if (!mounted) {
          return;
        }

        // b. Navigasi dan Submit
        await context.pushNamed(
          AppRoutes.results,
          extra: {
            'imagePath': safeFileToUpload.path,
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        );

        return;
      }
    } on TimeoutException {
      _showErrorSnackBar("Gagal mendapatkan lokasi GPS: Waktu habis.");
    } on CameraException catch (e) {
      _showErrorSnackBar("Gagal mengambil foto: ${e.description}");
    } on PlatformException catch (e) {
      _showErrorSnackBar("Masalah sistem: ${e.message}");
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _isProcessingData = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showErrorAndPop(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context);
    }
  }

  // Fungsi bantu untuk mendapatkan ikon flash
  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameraAndPermissions();
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Controller harus dipastikan tidak null dan sudah diinisialisasi
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    // Jika aplikasi di background (inactive/paused), hentikan kamera
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller?.dispose(); // Hancurkan controller lama
      setState(() => _isCameraInitialized = false); // Set state ke loading
    }

    // Jika aplikasi kembali ke foreground (resumed), inisialisasi ulang
    if (state == AppLifecycleState.resumed) {
      // Panggil ulang fungsi inisialisasi
      _initCameraAndPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    // Tampilan Kamera Live
    return AnimatedOpacity(
      // Masking Transisi Glitch
      opacity: _isCameraInitialized ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: PopScope(
        canPop: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          // 💡 KOREKSI: Tambahkan ColoredBox untuk masking yang lebih baik
          body: ColoredBox(
            color: Colors.black,
            child: Stack(
              children: [
                // 2a. Camera Preview (dengan Glitch Fix dan Gesture)
                Positioned.fill(
                  child: AnimatedOpacity(
                    // Tetap pertahankan AnimatedOpacity untuk masking transisi
                    opacity: _isCameraInitialized ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: ColoredBox(
                      color: Colors.black, // Masking background
                      child: GestureDetector(
                        onTapDown: _handleTapToFocus,
                        onScaleStart: _handleScaleStart,
                        onScaleUpdate: _handleScaleUpdate,

                        // 🟢 KOREKSI KRUSIAL: Kembalikan LayoutBuilder dan FittedBox
                        child: ClipRRect(
                          // ClipRRect harus membungkus LayoutBuilder
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final screenWidth = constraints.maxWidth;
                              // Catatan: controller!.value.aspectRatio memberikan rasio terbalik di beberapa perangkat,
                              // jadi kita gunakan 1 / rasio untuk mendapatkan nilai H:W (0.75) yang benar.
                              final cameraRatio =
                                  1 / controller!.value.aspectRatio;

                              final requiredPreviewHeight =
                                  screenWidth / cameraRatio;

                              return SizedBox.expand(
                                child: FittedBox(
                                  fit: BoxFit.cover, // Wajib COVER
                                  child: SizedBox(
                                    width: screenWidth,
                                    height:
                                        requiredPreviewHeight, // Tinggi dihitung berdasarkan rasio yang benar
                                    child: CameraPreview(controller!),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2b. AppBar/Header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () =>
                          Navigator.of(context).pop(), // Kembali ke HomePage
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          _getFlashIcon(_currentFlashMode),
                          color: Colors.white,
                        ),
                        onPressed: _toggleFlashMode,
                      ),
                    ],
                  ),
                ),

                //* ===================================
                //* Shutter Button di tengah bawah
                //* ===================================
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      iconSize: 80,
                      onPressed: _isShutterLocked
                          ? null
                          : _capturePhotoAndLocation,
                      icon: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isShutterLocked
                                ? Colors.white30
                                : Colors.white,
                            width: 6,
                          ),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: _isShutterLocked
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),

                if (_isProcessingData)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(), // Loading utama
                            SizedBox(height: 16),
                            Text(
                              "Memproses dan Mengirim Data...",
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_focusPoint != null)
                  Positioned(
                    // Posisi top/left dihitung dari _focusPoint yang disimpan di State
                    // Dikurangi 20 untuk memposisikan kotak 40x40 tepat di tengah tap (40/2 = 20)
                    top: _focusPoint!.dy - 20,
                    left: _focusPoint!.dx - 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow, width: 2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
