import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../routes/app_routes.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';

/// Handler utama untuk tombol Capture Billboard
Future<void> handleCaptureTap(BuildContext context) async {
  // 1. Cek Permission (Kamera & Lokasi)
  final isGranted = await PermissionService.requestCameraAndLocation();

  if (isGranted) {
    // 2. Jika Izin OK, Cek Layanan GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (context.mounted) _showGpsDisabledModal(context);
      return;
    }

    // 3. Navigasi ke Kamera
    if (context.mounted) context.pushNamed(AppRoutes.camera);
  } else {
    // 4. Jika Izin Ditolak
    if (context.mounted) _handlePermissionDenied(context);
  }
}

// --- Helper Functions (Private) ---

void _showGpsDisabledModal(BuildContext context) {
  showAppModal(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/no_location.png', height: 150),
        const SizedBox(height: 16),
        const Text(
          "GPS Tidak Aktif",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Mohon aktifkan GPS Anda agar lokasi reklame dapat tercatat dengan akurat.",
          textAlign: TextAlign.center,
        ),
      ],
    ),
    primaryButton: ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Geolocator.openLocationSettings();
      },
      child: const Text("Aktifkan GPS"),
    ),
  );
}

void _handlePermissionDenied(BuildContext context) async {
  final statusLocation = await Permission.locationWhenInUse.status;
  final statusCamera = await Permission.camera.status;

  if (!context.mounted) return;

  if (statusLocation.isPermanentlyDenied || statusCamera.isPermanentlyDenied) {
    showAppModal(
      context: context,
      title: "Izin Diperlukan",
      showCloseButton: false,
      isDismissible: true,
      content: const Text(
        "Izin Kamera dan Lokasi ditolak permanen. Mohon aktifkan secara manual di pengaturan aplikasi.",
        textAlign: TextAlign.center,
      ),
      primaryButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF175CFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          openAppSettings();
        },
        child: const Text("Buka Pengaturan Izin"),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Izin ditolak. Mohon berikan izin untuk melanjutkan."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
