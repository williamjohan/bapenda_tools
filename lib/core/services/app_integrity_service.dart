import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../network/env_config/env_config.dart';
import '../utils/app_logger.dart';

abstract class AppIntegrityService {
  Future<String> getAppId();
}

@LazySingleton(as: AppIntegrityService)
class AppIntegrityServiceImpl implements AppIntegrityService {
  Future<String>? _memoizedAppIdFuture;

  @override
  Future<String> getAppId() {
    _memoizedAppIdFuture ??= _resolveAppId();
    return _memoizedAppIdFuture!;
  }

  Future<String> _resolveAppId() async {
    try {
      if (kDebugMode) {
        AppLogger.warning(
          '🛠️ [kDebugMode] Bypass RASP: Menggunakan APP_SIGN_STAGING untuk X-App-Id',
        );
        return EnvConfig.appSignStaging;
      }

      final packageInfo = await PackageInfo.fromPlatform();

      final String runtimeSignature = packageInfo.buildSignature.isNotEmpty
          ? packageInfo.buildSignature
          : "${packageInfo.packageName}.SURABAYA.TAX";

      AppLogger.info('🛡️ [kReleaseMode] RASP Active: Verified OS Fingerprint');
      return runtimeSignature;
    } catch (e) {
      AppLogger.error(
        '🚨 Gagal membaca integritas OS, menggunakan fallback darurat',
        e,
      );
      return EnvConfig.appSignStaging;
    }
  }
}
