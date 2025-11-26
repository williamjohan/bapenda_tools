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
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ikon di bagian atas (jika ada)
            if (topIcon != null) ...[topIcon!, const SizedBox(height: 15)],

            // Close Button di kanan atas
            if (showCloseButton)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

            // Judul (jika ada)
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10), // Jarak setelah judul
              const Divider(
                height: 10,
                thickness: 1,
              ), // Divider setelah judul jika ada
              const SizedBox(height: 10),
            ] else if (topIcon == null && showCloseButton == false) ...[
              // Jika tidak ada title dan tidak ada icon, dan tidak ada tombol close, mungkin tidak perlu divider
              // Anda bisa atur logic divider di sini sesuai kebutuhan
              const SizedBox(height: 10),
            ],

            // Isi Konten Utama
            SingleChildScrollView(child: content),

            // Primary Action Button (jika ada)
            if (primaryButton != null) ...[
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: primaryButton!),
            ],
          ],
        ),
      ),
    );
  }
}

void showAppModal({
  required BuildContext context,
  String? title,
  required Widget content,
  Widget? primaryButton,
  bool isDismissible = false,
  Widget? topIcon,
  bool showCloseButton = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (context) {
      return CustomModal(
        title: title,
        content: content,
        primaryButton: primaryButton,
        topIcon: topIcon,
        showCloseButton: showCloseButton,
      );
    },
  );
}
