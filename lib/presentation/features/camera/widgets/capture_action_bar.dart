import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CaptureActionBar extends StatelessWidget {
  final FlashMode flashMode;
  final VoidCallback onToggleFlash;
  final VoidCallback? onCapture;
  final bool isLoading; // 👈 UNTUK SPINNER (Hanya saat capture)
  final bool isDisabled; // 👈 UNTUK BLOKIR KLIK (Capture + Processing)

  const CaptureActionBar({
    super.key,
    required this.flashMode,
    required this.onToggleFlash,
    required this.onCapture,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Tombol Flash (Pojok Kanan Atas - Sesuai Layout Lama)
        // Atau bisa ditaruh di AppBar custom jika mau persis lama.
        // Tapi untuk Action Bar biasanya di bawah.
        // Mari kita sesuaikan dengan layout God Widget lama:
        // God Widget: Flash ada di AppBar atas, Shutter di bawah.

        // KARENA STRUKTUR LAMA: Flash di AppBar, Shutter di Bawah.
        // Maka widget ini sebaiknya FOKUS di area BAWAH (Shutter),
        // Sedangkan Flash harusnya di widget terpisah atau AppBar.

        // TAPI, agar simple dan terkelompok, kita taruh tombol shutter di tengah bawah
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: isDisabled ? null : onCapture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDisabled ? Colors.white30 : Colors.white,
                    width: 6,
                  ),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: isLoading
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
                    : Icon(
                        Icons.camera_alt,
                        size: 40,
                        // Kalau disabled tapi gak loading (Processing), icon jadi abu
                        color: isDisabled && !isLoading
                            ? Colors.white30
                            : Colors.white,
                      ),
              ),
            ),
          ),
        ),

        // 2. Tombol Flash (Kita taruh di pojok kanan atas layar Sesuai God Widget)
        // Note: Karena ini ActionBar, idealnya dia menempati full screen stack
        // agar bisa menaruh item di posisi absolute manapun.
        Positioned(
          top: 0, // Sesuai posisi AppBar
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                iconSize: 28,
                icon: Icon(_getFlashIcon(flashMode), color: Colors.white),
                onPressed: isDisabled ? null : onToggleFlash,
              ),
            ),
          ),
        ),

        // 3. Tombol Back (Pojok Kiri Atas)
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: isDisabled
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
}
