import 'dart:developer';
import 'dart:io';
import '../../../../core/utils/file_utils.dart';
import 'package:cekreklamemobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/permission_service.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

const String staticTestAssetPath = 'assets/images/guardian_reklame.jpg';

class _CaptureScreenState extends State<CaptureScreen> {
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
      _isLoadingLocation = false;
      _isCapturing = false;
    });
  }

  Future<void> _navigateToResultsAndReset() async {
    if (_capturedPhoto == null || _currentPosition == null || !mounted) return;

    // 1. Dapatkan File Path nyata dari asset
    final String assetFilePath = await getFilePathFromAsset(
      staticTestAssetPath,
    );

    if (!mounted) {
      return;
    }
    // 1. Lakukan Navigasi dan TUNGGU hasilnya (menggunakan await)
    await context.pushNamed(
      AppRoutes.results,
      extra: {
        // 'imagePath': _capturedPhoto!.path,
        'imagePath': assetFilePath,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      },
    );

    // 2. Baris ini dijalankan SETELAH pengguna POP kembali ke CaptureScreen
    // Panggil fungsi reset state lokal
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
        // Mungkin arahkan user ke pengaturan atau kembali
        // Navigator.pop(context);
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

    // --- 1. Set Flag ---
    setState(() {
      _isCapturing = true;
    });

    // 1. Cek apakah layanan lokasi aktif
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
      // setState(() => _isLoadingLocation = false); // Hentikan loading
      return; // Hentikan fungsi
    }

    // 1. Ambil foto
    try {
      final file = await controller!.takePicture();
      setState(() {
        _capturedPhoto = file;
        _isLoadingLocation = true; // Mulai loading lokasi
      });

      // 2. Ambil lokasi GPS
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false; // Selesai loading lokasi
      });
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
    }

    setState(() {
      _isCapturing = false; // Pastikan flag direset di akhir, baik sukses/gagal
    });
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
    _initCameraAndPermissions();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Tampilan setelah foto diambil
    if (_capturedPhoto != null) {
      return Scaffold(
        backgroundColor:
            Colors.grey[100], // Background lebih terang untuk hasil
        body: Stack(
          children: [
            // Gambar yang diambil di bagian atas
            Positioned.fill(
              child: Image.file(File(_capturedPhoto!.path), fit: BoxFit.cover),
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
                              child: GoogleMap(
                                // Posisi awal kamera di lokasi saat ini
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  zoom: 15, // Zoom level yang cukup dekat
                                ),

                                // Fitur kontrol dinonaktifkan karena ini hanya preview
                                myLocationEnabled: false,
                                zoomControlsEnabled: false,
                                scrollGesturesEnabled: false,
                                rotateGesturesEnabled: false,

                                // Marker untuk menandai titik foto
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('currentLocation'),
                                    position: LatLng(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                    ),
                                  ),
                                },
                              ),
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
      );
    }

    // Tampilan Kamera Live
    return Scaffold(
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
                onPressed: _resetCapture, // Kembali dari screen
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
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    /* Handle settings */
                  },
                ),
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
