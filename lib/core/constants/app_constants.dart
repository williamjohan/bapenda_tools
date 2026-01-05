class AppConstants {
  AppConstants._();

  static const String appName = "Cek Reklame";
  static const String btnLapor = "Laporkan Reklame";
  static const String btnKembali = "Kembali ke Beranda";
  static const String successReportTitle = "Laporan Terkirim";
  static const String successReportSub = "Terima kasih atas partisipasi Anda.";
}

enum ReportType {
  ilegal(1, "Reklame Ilegal"),
  expired(2, "Reklame Expired");

  final int value;
  final String label;

  const ReportType(this.value, this.label);
}
