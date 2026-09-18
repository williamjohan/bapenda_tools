class AppFileExtensionUtils {
  /// Mengekstrak ekstensi file untuk UI.
  /// Karena API stream tidak memiliki ekstensi, kita paksa fallback ke 'PDF'.
  static String getDisplayExtension(
    String fileName, {
    String fallback = 'PDF',
  }) {
    if (fileName.isEmpty) return fallback;

    final nameLower = fileName.toLowerCase();

    if (nameLower.endsWith('.doc') || nameLower.endsWith('.docx')) return 'DOC';
    if (nameLower.endsWith('.xls') || nameLower.endsWith('.xlsx')) return 'XLS';
    if (nameLower.endsWith('.jpg') || nameLower.endsWith('.jpeg')) return 'JPG';
    if (nameLower.endsWith('.png')) return 'PNG';
    if (nameLower.endsWith('.pdf')) return 'PDF';

    // Jika tidak ada ekstensi yang terdeteksi, gunakan PDF.
    return fallback;
  }
}
