import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cekreklamemobile/core/services/map_service.dart';
import 'package:cekreklamemobile/core/utils/file_copy_utils.dart';
import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/services/permission_service.dart';

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
  XFile? _capturedPhoto;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  FlashMode _currentFlashMode = FlashMode.off;
  Offset? _focusPoint;
  bool _isCapturing = false;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  String? _mapImageUrl;

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

  void _resetCapture() {
    setState(() {
      _capturedPhoto = null;
      _currentPosition = null;
      _mapImageUrl = null;
      _isLoadingLocation = false;
      _isCapturing = false;
    });
  }

  void _handlePopInvoked(bool didPop, dynamic result) {
    // Argument 'result' akan berisi detail tambahan tentang pop/exit,
    // namun kita hanya perlu argumen 'didPop'.

    if (didPop) return; // Jika pop sudah terjadi, keluar.

    // Jika Pop dicegah atau belum terjadi:
    if (_capturedPhoto != null) {
      // STATE 2: Foto ada. Kita cegah pop dan reset.
      _resetCapture();
      // Di PopScope, kita tidak perlu memanggil pop lagi.
    } else {
      // STATE 1: Live camera (Root). Kita ingin keluar aplikasi.
      // Panggil pop secara manual untuk melanjutkan aksi pop/exit.
      SystemNavigator.pop();
    }
  }

  Future<void> _navigateToResultsAndReset() async {
    if (_capturedPhoto == null || _currentPosition == null || !mounted) return;

    //! pakai File Path dari asset untuk testing
    // final String assetFilePath = await getFilePathFromAsset(
    //   staticTestAssetPath,
    // );

    // 1. Dapatkan file asli
    final File originalFile = File(_capturedPhoto!.path);

    // 2. Salin file ke cache
    final File safeFileToUpload;
    try {
      safeFileToUpload = await copyFileToCache(originalFile);
    } catch (e) {
      if (mounted) {
        // Gagal menyalin file (kemungkinan file asli sudah corrupt/lock)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyiapkan foto untuk diunggah: $e")),
        );
      }
      _resetCapture();
      return;
    }

    // 3. Cek mounted lagi
    if (!mounted) {
      return;
    }

    // 4. Lakukan Navigasi dan TUNGGU hasilnya
    await context.pushNamed(
      AppRoutes.results,
      extra: {
        // 'imagePath': assetFilePath,
        'imagePath': safeFileToUpload.path,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      },
    );

    // 5. Reset state lokal saat kembali (ini juga bisa membersihkan file salinan)
    _resetCapture();
  }

  Future<void> _initCameraAndPermissions() async {
    // 1. Request izin kamera dan lokasi
    final allowed = await PermissionService.requestCameraAndLocation();
    if (!allowed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin kamera & lokasi diperlukan")),
        );
      }
      return;
    }

    // 2. Setup kamera
    final cameras = await availableCameras();

    if (!mounted) {
      return;
    }

    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada kamera tersedia.")),
      );
      Navigator.pop(context);
      return;
    }

    controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller!.initialize();
      controller!.setFlashMode(_currentFlashMode);

      // 🔍 CETAK NILAI DIAGNOSTIK
      // debugPrint(
      //   'Camera Aspect Ratio DILAPORKAN: ${controller!.value.aspectRatio}',
      // );

      _minZoomLevel = await controller!.getMinZoomLevel();
      _maxZoomLevel = await controller!.getMaxZoomLevel();

      if (context.mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error inisialisasi kamera: ${e.description}"),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _capturePhotoAndLocation() async {
    if (!controller!.value.isInitialized || _isCapturing) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kamera belum siap.")));
      return;
    }

    // A. Set Flag Awal
    setState(() {
      _isCapturing = true;
    });

    // B. Cek apakah layanan lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Tampilkan peringatan, dan JANGAN lanjutkan ke langkah 2.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Layanan GPS tidak aktif. Mohon nyalakan GPS Anda."),
            duration: Duration(seconds: 4),
          ),
        );
      }
      Geolocator.openLocationSettings();
      setState(() {
        _isCapturing = false; // Reset agar tombol tidak terkunci
      });
      return;
    }

    //*  ----------------------------------------------------------------
    //* LOGIC AMBIL FOTO, CROP, DAN GPS
    //* -----------------------------------------------------------------
    XFile? finalCroppedFile;
    Position? position;

    try {
      // 1. Ambil foto
      final XFile capturedFile = await controller!.takePicture();

      // 2. Panggil Cropper Screen
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: capturedFile.path,
        compressQuality: 70, // Kompresi 70% untuk mengurangi ukuran payload
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

      // 3. Jika pengguna membatalkan cropping, hentikan proses
      if (croppedFile == null) {
        return;
      }

      // 4. Update data lokal dengan file cropped
      finalCroppedFile = XFile(croppedFile.path);

      // 5. Mulai loading GPS (Status ini hanya relevan jika kita punya indicator loading global)
      setState(() {
        _capturedPhoto = finalCroppedFile;
        _isLoadingLocation = true;
      });

      // 6. Ambil lokasi GPS
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10)); // Timeout setelah 10 detik

      // 🟢 KOREKSI INTI: Panggil MapService dari locator
      final mapService = locator<MapService>();
      final mapUrl = mapService.generateStaticMapUrl(
        lat: position.latitude,
        long: position.longitude,
      );

      // 7. Update state dengan file BARU yang sudah di-crop
      setState(() {
        _mapImageUrl = mapUrl;
        _currentPosition = position;
        _isLoadingLocation = false; // Mulai loading lokasi
      });
    } on TimeoutException {
      // 💡 TANGANI ERROR KHUSUS TIMEOUT
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mendapatkan lokasi GPS: Waktu habisf"),
          ),
        );
      }
      setState(() => _isLoadingLocation = false);
      // Karena lokasi gagal, kita harus membiarkan _capturedPhoto di-reset
      _resetCapture();
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil foto: ${e.description}")),
        );
      }
      setState(() => _isLoadingLocation = false); // Hentikan loading jika gagal
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendapatkan lokasi: ${e.message}")),
        );
      }
      setState(() => _isLoadingLocation = false); // Hentikan loading jika gagal
    } finally {
      setState(() {
        _isCapturing = false;
      });
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

    // Tampilan setelah foto diambil
    if (_capturedPhoto != null) {
      return PopScope(
        // 💡 Mencegat Tombol Fisik BACK (Android) saat Preview
        canPop: false,
        onPopInvokedWithResult: _handlePopInvoked,
        child: Scaffold(
          backgroundColor:
              Colors.grey[100], // Background lebih terang untuk hasil
          body: Stack(
            children: [
              // Gambar yang diambil di bagian atas
              Positioned.fill(
                child: Image.file(
                  File(_capturedPhoto!.path),
                  fit: BoxFit.cover,
                ),
              ),
              // Header untuk tombol kembali dan settings
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _resetCapture, // Kembali ke mode kamera
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        /* Handle settings */
                      },
                    ),
                  ],
                ),
              ),
              // Konten bawah dengan info lokasi
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            _currentPosition != null
                                ? "Lokasi GPS Terdeteksi"
                                : "Mencari Lokasi GPS...",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tampilan Peta
                      _isLoadingLocation
                          ? const Center(child: CircularProgressIndicator())
                          : _currentPosition != null
                          ? Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _mapImageUrl != null
                                    ? Image.network(
                                        // 🟢 KOREKSI: Gunakan Image.network
                                        _mapImageUrl!,
                                        fit: BoxFit.cover,
                                        // Tambahkan placeholder/loading saat gambar diunduh
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Center(
                                                child: Text(
                                                  "Gagal memuat peta.",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              );
                                            },
                                      )
                                    : const Center(
                                        child: Text("Memuat Peta..."),
                                      ), // Fallback jika URL null
                              ),
                            )
                          : Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[200],
                              ),
                              child: const Center(
                                child: Text(
                                  "Gagal mendapatkan lokasi.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      // Koordinat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLocationInfo(
                            Icons.location_pin,
                            "Lat: ${_currentPosition?.latitude.toStringAsFixed(4) ?? '-'}",
                          ),
                          _buildLocationInfo(
                            Icons.location_searching,
                            "Long: ${_currentPosition?.longitude.toStringAsFixed(4) ?? '-'}",
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Tombol "Cek Reklame Terdekat"
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              _currentPosition != null &&
                                  _capturedPhoto != null &&
                                  !_isLoadingLocation
                              ? _navigateToResultsAndReset
                              : null, // Disable jika lokasi/foto belum siap
                          child: Text(
                            _isLoadingLocation
                                ? "Mencari Lokasi..."
                                : "Cek Reklame Terdekat",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilan Kamera Live
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // CAMERA PREVIEW
            Positioned.fill(
              child: GestureDetector(
                onTapDown: _handleTapToFocus,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Ambil dimensi dari ruang yang tersedia
                    final screenWidth = constraints.maxWidth;
                    // final screenHeight = constraints.maxHeight;

                    // Rasio Preview yang HARUS BENAR: 0.75 (1 / 1.333)
                    final cameraRatio = 1 / controller!.value.aspectRatio;

                    // Hitung Tinggi Preview yang DIBUTUHKAN untuk rasio 0.75
                    // agar memenuhi Lebar Layar (Screen Width / 0.75)
                    final requiredPreviewHeight = screenWidth / cameraRatio;

                    // Gunakan FittedBox untuk memaksa preview FILL layar
                    return SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit
                            .cover, // Wajib COVER untuk menghilangkan distorsi
                        child: SizedBox(
                          // Ukuran yang dipaksakan (width = lebar layar, height = yang dibutuhkan
                          // untuk mempertahankan rasio 0.75)
                          width: screenWidth,
                          height: requiredPreviewHeight,
                          child: CameraPreview(controller!),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            if (_focusPoint != null)
              Positioned(
                top: _focusPoint!.dy - 20, // Koreksi posisi tengah
                left: _focusPoint!.dx - 20, // Koreksi posisi tengah
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),

            // Header untuk tombol kembali dan settings
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => SystemNavigator.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _getFlashIcon(
                        _currentFlashMode,
                      ), // Menggunakan fungsi helper
                      color: Colors.white,
                    ),
                    onPressed: _toggleFlashMode, // Memanggil fungsi toggle
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.settings, color: Colors.white),
                  //   onPressed: () {
                  //     /* Handle settings */
                  //   },
                  // ),
                ],
              ),
            ),

            // Shutter Button di tengah bawah
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  iconSize: 80,
                  color: Colors.white,
                  onPressed: _capturePhotoAndLocation, // Ambil foto dan lokasi
                  icon: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ), // Sedikit transparan
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 40,
                    ), // Ikon kamera di dalam
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
