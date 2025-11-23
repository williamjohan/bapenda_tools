import 'package:flutter/material.dart';
import 'dart:io';

// ✅ KOREKSI: Ubah menjadi StatelessWidget yang mandiri
class NoResultsWidget extends StatelessWidget {
  final String capturedImagePath;

  const NoResultsWidget({super.key, required this.capturedImagePath});

  // Jika Anda ingin mengizinkan pesan error kustom, Anda bisa tambahkan final String message;
  // dan menggunakannya di sini.

  @override
  Widget build(BuildContext context) {
    final imageToDisplay = File(capturedImagePath).existsSync()
        ? File(capturedImagePath)
        : null;

    return SingleChildScrollView(
      // 💡 Ganti Center dengan SingleChildScrollView agar konten tidak terpotong
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri untuk judul
        children: [
          //* -------------------------------
          //* 1. JUDUL HASIL TANGKAPAN FOTO
          //* -------------------------------
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 16, right: 16),
            child: Text(
              "Hasil Tangkapan Foto",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          //* -------------------------------
          //* 2. TAMPILAN FOTO (Container)
          //* -------------------------------
          Container(
            height: 180, // Ukuran sedang
            width: double.infinity,
            margin: const EdgeInsets.only(
              top: 8,
              bottom: 24,
              left: 16,
              right: 16,
            ), // Tambah margin bawah
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageToDisplay != null
                  ? Image.file(imageToDisplay, fit: BoxFit.cover)
                  : const Center(
                      child: Text(
                        "Gambar capture tidak ditemukan",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ),

          //* -------------------------------
          //* 3. PESAN NO RESULTS
          //* -------------------------------
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 20),
                const Text(
                  "Tidak Ada Reklame Ditemukan",
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
                    "Tidak ada papan reklame terdaftar di area ini. Coba pindah ke lokasi lain.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 40), // Tambah padding di bawah
              ],
            ),
          ),
        ],
      ),
    );
  }
}
