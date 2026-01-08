import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Membuat salinan (deep copy) dari file sumber ke direktori cache.
/// Mengatasi masalah file lock/stream saat mengupload file kamera.
Future<File> copyFileToCache(File sourceFile) async {
  // Dapatkan direktori cache aplikasi
  final cacheDir = await getTemporaryDirectory();

  // Buat nama file unik
  final newPath =
      '${cacheDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  // Lakukan penyalinan file secara sinkron/langsung
  final newFile = await sourceFile.copy(newPath);

  return newFile;
}

Future<void> cleanUploadCache() async {
  try {
    final directory = await getApplicationSupportDirectory();
    final uploadDir = Directory('${directory.path}/uploads');

    if (await uploadDir.exists()) {
      // Ambil daftar semua file di dalam folder uploads
      final List<FileSystemEntity> files = uploadDir.listSync();

      // Hapus satu per satu
      for (var file in files) {
        if (file is File) {
          await file.delete();
        }
      }
      debugPrint("🧹 Cache foto berhasil dibersihkan");
    }
  } catch (e) {
    debugPrint("❌ Gagal membersihkan cache: $e");
  }
}
