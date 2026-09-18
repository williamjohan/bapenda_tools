import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'app_logger.dart';

class Base64FileUtils {
  Base64FileUtils._();

  /// Mengubah String Base64 menjadi file fisik.
  /// Jika [autoDetectExtension] true, fungsi akan membaca header Base64 untuk menebak ekstensi (.pdf, .png, .docx).
  /// Pastikan [fileName] TIDAK memiliki ekstensi jika [autoDetectExtension] bernilai true.
  static Future<String?> saveToFile({
    required String? base64String,
    required String fileName,
    required String folderName,
    bool autoDetectExtension = true, // Default hidup agar pintar
  }) async {
    if (base64String == null || base64String.trim().isEmpty) return null;

    try {
      // 1. Ekstrak prefix dan decode
      final cleanBase64 = _cleanBase64Prefix(base64String);
      final bytes = base64Decode(cleanBase64);

      // 2. Siapkan Brankas Direktori
      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${appDir.path}/$folderName');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 3. Tentukan Nama File Akhir
      String finalFileName = fileName;
      if (autoDetectExtension) {
        final extension = _detectExtension(base64String);
        finalFileName = '$fileName$extension';
      }

      // 4. Tulis ke Disk
      final file = File('${targetDir.path}/$finalFileName');
      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      AppLogger.error('❌ Gagal menyimpan Base64 ke file: $fileName', e);
      return null;
    }
  }

  static String _detectExtension(String base64) {
    final lowerBase64 = base64.toLowerCase();
    if (lowerBase64.startsWith('data:application/pdf')) return '.pdf';
    if (lowerBase64.startsWith('data:application/msword')) return '.doc';
    if (lowerBase64.startsWith(
      'data:application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    )) {
      return '.docx';
    }
    if (lowerBase64.startsWith('data:application/vnd.ms-excel')) return '.xls';
    if (lowerBase64.startsWith(
      'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    )) {
      return '.xlsx';
    }
    if (lowerBase64.startsWith('data:image/png')) return '.png';
    if (lowerBase64.startsWith('data:image/jpeg') ||
        lowerBase64.startsWith('data:image/jpg')) {
      return '.jpg';
    }
    return ''; // Jika gagal deteksi, biarkan tanpa ekstensi tambahan
  }

  static String _cleanBase64Prefix(String base64) {
    if (base64.contains(',')) {
      return base64.split(',').last;
    }
    return base64;
  }
}
