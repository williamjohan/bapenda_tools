enum FailureType {
  connectionTimeout,
  serverError,
  badRequest,
  noInternet,
  unknownError,
  fileProcessError,
  sslError,
}

class FailureMessages {
  static const String connectionTimeout = "Kesalahan Koneksi: Waktu habis.";
  static const String serverError = "Server sedang mengalami gangguan (500).";
  static const String badRequest =
      "Data tidak ditemukan atau format salah (400).";
  static const String noInternet = "Tidak ada koneksi internet.";
  static const String unknownError = "Terjadi kesalahan yang tidak diketahui.";
  static const String fileProcessError = "Gagal memproses file gambar.";
  static const String sslError =
      "Gagal verifikasi keamanan. Hal ini bisa terjadi karena sinyal yang tidak stabil.";
}
