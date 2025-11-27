import 'package:flutter/material.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/permission_service.dart';

void handleCaptureTap(BuildContext context) async {
  // 1. Minta Izin Kamera dan Lokasi
  final isGranted = await PermissionService.requestCameraAndLocation();

  // 2. Jika diizinkan, langsung navigasi dan keluar dari fungsi
  if (isGranted) {
    if (context.mounted) {
      context.pushNamed(AppRoutes.camera);
    }
    return;
  }

  // 3. Jika TIDAK diizinkan: Periksa status secara individual untuk mendeteksi penolakan permanen.
  final statusLocation = await Permission.locationWhenInUse.status;
  final statusCamera = await Permission.camera.status;

  if (context.mounted) {
    if (statusLocation.isPermanentlyDenied ||
        statusCamera.isPermanentlyDenied) {
      // 🟢 KONDISI A: Ditolak Permanen (Arahkan ke Settings Aplikasi)
      showAppModal(
        context: context,
        title: "Izin Diperlukan",
        content: const Text(
          "Izin Kamera dan Lokasi ditolak permanen. Mohon aktifkan secara manual di pengaturan aplikasi.",
          textAlign: TextAlign.center,
        ),
        primaryButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF175CFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            openAppSettings(); // Membuka pengaturan izin aplikasi
          },
          child: const Text("Buka Pengaturan Izin"),
        ),
        showCloseButton: false,
        isDismissible: true,
      );
    } else {
      // 🟢 KONDISI B: Ditolak Sementara (User menekan "Deny")
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Izin ditolak sementara. Mohon berikan izin untuk melanjutkan.",
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
