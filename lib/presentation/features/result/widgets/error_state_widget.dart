import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  // 💡 KOREKSI 1: Tambahkan properti final 'message'
  final String message;

  const ErrorStateWidget({
    super.key,
    required this.message, // 💡 Wajib diinisialisasi
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              // 💡 KOREKSI 2: Jadikan static jika tidak menerima variabel
              "Terjadi Kesalahan:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ), // Diganti agar tidak terlalu bergantung pada theme
            ),
            const SizedBox(height: 8),
            Text(
              message, // ✅ Sekarang variabel message bisa digunakan
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
