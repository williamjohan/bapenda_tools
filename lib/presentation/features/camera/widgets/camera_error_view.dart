import 'package:flutter/material.dart';

class CameraErrorView extends StatelessWidget {
  final bool isPermanentlyDenied;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onRetry;

  const CameraErrorView({
    super.key,
    this.isPermanentlyDenied = false,
    this.onOpenSettings,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // UX: Icon Merah/Putih agar terlihat urgent/jelas di background hitam
            Icon(
              isPermanentlyDenied ? Icons.settings_suggest : Icons.camera_alt,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),

            // UX: Text Putih agar terbaca di Scaffold Hitam
            Text(
              isPermanentlyDenied
                  ? 'Izin kamera & lokasi ditolak permanen.\nMohon izinkan via Pengaturan agar dapat mengambil bukti foto.'
                  : 'Aplikasi membutuhkan izin Kamera & Lokasi untuk memvalidasi reklame.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isPermanentlyDenied ? onOpenSettings : onRetry,
                child: Text(
                  isPermanentlyDenied ? 'Buka Pengaturan' : 'Izinkan Akses',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ UX FIX: Tombol Kembali (Agar user tidak terjebak)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Kembali",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
