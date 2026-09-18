import 'dart:io';

/* 
=============================================================================
  [APP FILE VALIDATOR UTILS]
=============================================================================
  Fungsi Utama : Memeriksa ukuran file (Byte, KB, MB) agar tidak melebihi batas API.
  Peruntukan   : Global (Semua form yang memiliki fitur upload file).
  Aturan Ketat : -

  Author       : Tim Bapenda (Diperbarui: 2026)
  WARNING      : Jangan membuat fungsi validasi ukuran file di tempat lain!
=============================================================================
*/

class AppFileValidatorUtils {
  /// Memeriksa apakah ukuran file melebihi batas dari API.
  /// Mendukung satuan 'MB', 'KB', dan 'B' / 'Bytes'.
  static bool isFileValid(File file, double? maxSize, String? unit) {
    if (maxSize == null || maxSize <= 0) return true; // Tidak ada limit

    final fileBytes = file.lengthSync();
    double maxBytes = 0;
    final safeUnit = unit?.toUpperCase() ?? 'MB'; // Default ke MB jika null

    if (safeUnit == 'MB') {
      maxBytes = maxSize * 1024 * 1024;
    } else if (safeUnit == 'KB') {
      maxBytes = maxSize * 1024;
    } else {
      maxBytes = maxSize; // Asumsi murni Bytes
    }

    return fileBytes <= maxBytes;
  }
}
