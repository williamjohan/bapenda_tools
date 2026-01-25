import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  final String? title;
  final Widget content;
  final Widget? primaryButton;
  final Color backgroundColor;
  final Widget? topIcon;
  final bool showCloseButton;

  const CustomModal({
    super.key,
    this.title,
    required this.content,
    this.primaryButton,
    this.backgroundColor = Colors.white,
    this.topIcon,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Close Button (Floating)
            if (showCloseButton)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ),

            // 2. Ikon Atas (Safe Check)
            if (topIcon != null) ...[
              topIcon!, // Aman karena di dalam if
              const SizedBox(height: 15),
            ],

            // 3. Judul (Safe Check)
            if (title != null) ...[
              Text(
                title!, // Aman karena di dalam if
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 10, thickness: 1),
              const SizedBox(height: 10),
            ],

            // 4. Konten
            SingleChildScrollView(child: content),

            // 5. Primary Button (Safe Check)
            if (primaryButton != null) ...[
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: primaryButton!), // Aman
            ],
          ],
        ),
      ),
    );
  }
}

// === HELPER FUNCTIONS ===

Future<void> showAppModal({
  required BuildContext context,
  String? title, // Boleh Null
  required Widget content,
  Widget? primaryButton,
  bool isDismissible = false,
  Widget? topIcon,
  bool showCloseButton = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (context) {
      return CustomModal(
        title: title, // ✅ Jangan pakai title! disini
        content: content,
        primaryButton: primaryButton,
        topIcon: topIcon,
        showCloseButton: showCloseButton,
      );
    },
  );
}

Future<void> showConnectionErrorModal(
  BuildContext context, {
  VoidCallback? onRetry,
  String? message, // 👈 Tambahkan parameter ini
}) {
  return showAppModal(
    context: context,
    isDismissible: true,
    topIcon: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.red),
    ),
    content: Column(
      children: [
        const Text(
          "Koneksi Terputus",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          // 👇 Gunakan parameter atau default text yang umum
          message ??
              "Gagal terhubung ke server. Periksa koneksi internet Anda dan coba lagi.",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    ),
    primaryButton: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        // Cek mounted dulu (Good Practice!)
        if (context.mounted) {
          Navigator.of(context).maybePop();
        }
        if (onRetry != null) {
          onRetry();
        }
      },
      child: const Text("Coba Lagi"),
    ),
    showCloseButton: false,
  );
}

Future<void> showConfirmationModal(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirm,
  String confirmText = "Ya, Lanjutkan",
  String cancelText = "Batal",
  bool isDestructive = false, // Jika true, tombol jadi Merah (Bahaya)
}) {
  return showAppModal(
    context: context,
    showCloseButton: false,
    isDismissible: false,
    content: Column(
      children: [
        // 1. Icon Warning / Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDestructive ? Icons.warning_amber_rounded : Icons.info_outline,
            color: isDestructive ? Colors.red : Colors.blue,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),

        // 2. Judul
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // 3. Pesan
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),

    // 4. Tombol Aksi
    primaryButton: Row(
      children: [
        // Tombol Batal
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: Colors.grey.shade700,
            ),
            child: Text(
              cancelText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Tombol Konfirmasi
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup modal dulu
              onConfirm(); // Jalankan aksi (misal: panggil cubit)
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: isDestructive
                  ? Colors.redAccent
                  : Colors.blueAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
}
