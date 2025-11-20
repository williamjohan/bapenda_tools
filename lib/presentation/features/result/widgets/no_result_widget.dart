import 'package:flutter/material.dart';

// ✅ KOREKSI: Ubah menjadi StatelessWidget yang mandiri
class NoResultsWidget extends StatelessWidget {
  const NoResultsWidget({super.key});

  // Jika Anda ingin mengizinkan pesan error kustom, Anda bisa tambahkan final String message;
  // dan menggunakannya di sini.

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ganti ikon sesuai mockup yang lebih cocok (Icons.cancel_schedule_send terlalu teknis)
          Icon(
            Icons.block, // Menggunakan ikon yang lebih umum/simpel
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            "No Billboards Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "There are no registered billboards within this area. Try moving to a different location.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
