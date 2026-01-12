import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  // ==========================================
  // 1. FUNGSI LAMA ANDA (Decode Base64)
  // ==========================================

  /// Mendekode Base64 Data URL menjadi Uint8List yang siap digunakan oleh Image.memory.
  static Uint8List? decodeBase64DataUrl(String dataUrl) {
    if (dataUrl.isEmpty) {
      return null;
    }

    final parts = dataUrl.split(',');
    if (parts.length > 1) {
      final base64String = parts.last;
      try {
        return base64Decode(base64String);
      } catch (e) {
        return null;
      }
    }

    try {
      return base64Decode(dataUrl);
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // 2. FUNGSI BARU (Compress Image untuk Upload)
  // ==========================================

  /// Mengompres file gambar agar ukurannya lebih kecil sebelum diupload.
  /// Target: Mengecilkan file kamera (5-10MB) menjadi < 1MB.
  static Future<File> compressImage(File file) async {
    // Cek ukuran file asli
    final int fileSize = await file.length();

    // Jika file sudah kecil (dibawah 1 MB), kembalikan aslinya saja (gak usah capek2 kompres)
    // 1 MB = 1024 * 1024 bytes
    if (fileSize <= 1024 * 1024) {
      return file;
    }

    try {
      // Cari folder temporary di HP (Cache)
      final dir = await getTemporaryDirectory();

      // Bikin nama file unik baru biar gak numpuk
      // Contoh: /data/user/0/com.app/cache/compressed_171000222.jpg
      final targetPath =
          '${dir.absolute.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Lakukan Kompresi
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, // Path file asli
        targetPath, // Path tujuan file baru
        quality: 70, // Kualitas turun ke 70% (Mata manusia gak sadar bedanya)
        minWidth: 1280, // Resize lebar maks 1280px (Standard HD)
        minHeight: 1280, // Resize tinggi maks 1280px
      );

      // Kembalikan file hasil kompresi. Jika gagal (null), kembalikan file asli.
      return result != null ? File(result.path) : file;
    } catch (e) {
      // Jika ada error system saat kompres, kembalikan file asli (fail-safe)
      // print("Error compressing image: $e");
      return file;
    }
  }
}
