import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateUtils {
  /// Cek Update berdasarkan Build Number (Integer)
  /// Contoh: Local build 1, Remote build 2 -> True (Update Available)
  static Future<bool> isUpdateAvailable(int remoteBuildNumber) async {
    // 1. Cek Platform (OTA Update package biasanya untuk Android)
    if (!Platform.isAndroid) return false;

    // 2. Dapatkan info aplikasi saat ini
    final packageInfo = await PackageInfo.fromPlatform();

    // Parse build number lokal ke integer
    // (di pubspec.yaml: 1.0.0+1 -> buildNumber adalah 1)
    int currentBuildNumber = int.parse(packageInfo.buildNumber);

    print(
      "Cek Versi: Local($currentBuildNumber) vs Remote($remoteBuildNumber)",
    );

    // 3. Bandingkan Integer
    if (remoteBuildNumber > currentBuildNumber) {
      return true; // Ada update
    }

    return false; // Sudah paling baru
  }
}
