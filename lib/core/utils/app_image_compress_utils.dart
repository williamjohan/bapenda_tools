import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'app_logger.dart';

/* 
=============================================================================
  [APP IMAGE COMPRESS UTILS]
=============================================================================
  Fungsi Utama : Mengompresi gambar (JPG/PNG) & MENGONVERSI HEIC ke JPG secara Native.
  Peruntukan   : Dipanggil SECARA EKSKLUSIF oleh `AppFilePickerUtils`.
  Aturan Ketat : Jangan memanggil utilitas ini secara langsung di UI/Cubit. 
                 Gunakan `AppFilePickerUtils.pickImage()`.

  Author       : Tim Bapenda (Diperbarui: 2026)
  WARNING      : Membutuhkan package `flutter_image_compress`.
=============================================================================
*/

class AppImageCompressUtils {
  /// Mengompresi gambar (dan otomatis konversi HEIC ke JPG jika format awal HEIC).
  /// Berjalan di background thread (Native) sehingga UI tidak freeze.
  static Future<File?> compressAndConvert(File file) async {
    try {
      final originalSize = file.lengthSync() / 1024;
      AppLogger.info(
        "📸 Ukuran Asli Gambar: ${originalSize.toStringAsFixed(2)} KB",
      );

      // Siapkan path target (selalu kita paksa jadi .jpg agar aman untuk API)
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath =
          '${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      // Proses Kompresi & Konversi
      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: 75, // Kualitas optimal untuk Bapenda
            minWidth: 1024, // Resize jika lebar di atas 1024
            format: CompressFormat.jpeg, // Paksa output ke JPEG
          );

      if (compressedXFile == null) {
        AppLogger.error("❌ Gagal mengompres gambar (Native return null)");
        return file; // Fallback ke file asli jika gagal
      }

      final compressedFile = File(compressedXFile.path);
      final newSize = compressedFile.lengthSync() / 1024;
      AppLogger.info(
        "✅ Ukuran Setelah Dikompres: ${newSize.toStringAsFixed(2)} KB",
      );

      return compressedFile;
    } catch (e) {
      AppLogger.error("❌ Terjadi kesalahan saat kompresi/konversi HEIC", e);
      return file; // Fallback ke file asli
    }
  }
}
