import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileCacheHelper {
  // Folder khusus di dalam cache agar rapi
  static const String _folderName = 'upload_cache';

  /// [PENGGANTI copyFileToCache]
  /// Menyalin file (hasil crop/kamera) ke direktori cache aplikasi yang aman.
  /// Ini penting agar file asli tidak terkunci (lock) saat proses upload.
  static Future<File> saveToCache(File sourceFile) async {
    try {
      // 1. getTemporaryDirectory() ini otomatis memilih lokasi cache terbaik (Internal/External)
      // sesuai kondisi HP user. Ini JODOHNYA <cache-path> di XML Anda.
      final cacheDir = await getTemporaryDirectory();

      // 2. Buat folder khusus (misal: /cache/upload_cache/)
      final targetDir = Directory('${cacheDir.path}/$_folderName');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 3. Generate nama file unik biar tidak bentrok
      final newPath =
          '${targetDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 4. Lakukan Copy
      return await sourceFile.copy(newPath);
    } catch (e) {
      debugPrint("❌ FileCacheHelper Error: Gagal copy file -> $e");
      // Jika gagal copy (misal storage penuh banget), kembalikan file asli sebagai fallback
      return sourceFile;
    }
  }

  /// [PENGGANTI cleanUploadCache]
  /// Membersihkan sampah foto yang menumpuk di folder cache khusus kita.
  static Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final targetDir = Directory('${cacheDir.path}/$_folderName');

      if (await targetDir.exists()) {
        await targetDir.delete(recursive: true);
        debugPrint("🧹 Cache foto di '$_folderName' berhasil dibersihkan.");
      }
    } catch (e) {
      debugPrint("⚠️ Gagal membersihkan cache: $e");
    }
  }
}
