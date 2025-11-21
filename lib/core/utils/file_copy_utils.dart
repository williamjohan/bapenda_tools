import 'dart:io';
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
