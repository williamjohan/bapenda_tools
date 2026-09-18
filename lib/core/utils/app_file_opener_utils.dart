import 'package:open_filex/open_filex.dart';
import 'app_logger.dart'; // Sesuaikan path

/* 
=============================================================================
  [APP FILE OPENER UTILS]
=============================================================================
  Fungsi Utama : Membuka file MENGGUNAKAN APLIKASI EKSTERNAL (Bawaan OS).
                 (Misal: Buka PDF pakai Adobe Reader, Word pakai WPS, dll).
                 ⚠️ PERINGATAN: Fungsi ini AKAN MENGELUARKAN USER DARI APLIKASI.
                 
  Peruntukan   : HANYA untuk file Template (.docx, .xls) atau file hasil 
                 unduhan yang memang perlu diedit user di luar aplikasi kita.

  ATURAN KETAT : JANGAN gunakan ini untuk "Preview/Melihat" dokumen atau 
                 foto yang sudah di-upload. Untuk Preview di dalam aplikasi 
                 (In-App), WAJIB GUNAKAN:
                 👉 StPdfScreen (Untuk dokumen PDF)
                 👉 ImagePreview.openFullScreen (Untuk Gambar/Foto)

  Author       : Tim Bapenda (Diperbarui: 2026)
=============================================================================
*/

class AppFileOpenerUtils {
  AppFileOpenerUtils._();

  /// Membuka file menggunakan aplikasi pihak ketiga bawaan sistem operasi.
  /// Return [true] jika berhasil dibuka oleh aplikasi eksternal, [false] jika gagal.
  static Future<bool> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);

      if (result.type == ResultType.done) {
        return true; // Sukses dibuka di aplikasi eksternal
      } else {
        AppLogger.warning(
          'Gagal membuka file di OS ($filePath): ${result.message}',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error(
        '❌ Terjadi kesalahan saat melempar file ke OS: $filePath',
        e,
      );
      return false;
    }
  }
}
