import 'dart:io';

import 'package:cekreklamemobile/core/services/app_logger_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateVersionService {
  final LoggerService logger;

  UpdateVersionService(this.logger);

  Future<bool> isUpdateAvailable(int remoteBuildNumber) async {
    if (!Platform.isAndroid) return false;

    final packageInfo = await PackageInfo.fromPlatform();
    final localBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

    logger.d("Version check: local($localBuild) vs remote($remoteBuildNumber)");

    return remoteBuildNumber > localBuild;
  }
}
