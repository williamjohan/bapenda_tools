import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateUtils {
  /// Membandingkan apakah ada versi baru.
  /// Return true jika [remoteVersion] lebih tinggi dari versi aplikasi saat ini.
  ///
  /// Contoh Input:
  /// local: "1.0.0", remote: "1.0.1" -> True (Update)
  /// local: "1.0.5", remote: "1.0.2" -> False (Downgrade/Sama)
  static Future<bool> isUpdateAvailable(String remoteVersion) async {
    // 1. Cek Platform (Hanya jalan di Android)
    if (!Platform.isAndroid) return false;

    // 2. Dapatkan versi aplikasi saat ini
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version; // Misal "1.0.0"

    // 3. Logic Pembanding Sederhana (Split by dot)
    // Asumsi format Semantic Versioning (Major.Minor.Patch) -> "1.0.2"
    try {
      List<int> currentV = currentVersion.split('.').map(int.parse).toList();
      List<int> remoteV = remoteVersion.split('.').map(int.parse).toList();

      // Bandingkan per angka (Major, lalu Minor, lalu Patch)
      for (int i = 0; i < 3; i++) {
        // Jika remote lebih besar, berarti ada update
        if (remoteV[i] > currentV[i]) return true;
        // Jika remote lebih kecil, berarti aplikasi kita lebih baru (dev version)
        if (remoteV[i] < currentV[i]) return false;
      }
      // Jika sampai sini berarti versinya SAMA PERSIS
      return false;
    } catch (e) {
      // Jika format versi kacau (bukan angka), anggap tidak ada update biar aman
      return false;
    }
  }
}
