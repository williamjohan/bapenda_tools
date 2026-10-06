import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/app_logger.dart';

enum BiometricResult {
  success,

  /// User membatalkan / gagal verifikasi.
  failed,

  /// Perangkat tidak punya kunci layar / biometrik sama sekali.
  notAvailable,
}

abstract class BiometricService {
  Future<BiometricResult> authenticate(String reason);
}

@LazySingleton(as: BiometricService)
class BiometricServiceImpl implements BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<BiometricResult> authenticate(String reason) async {
    try {
      if (!await _localAuth.isDeviceSupported()) {
        return BiometricResult.notAvailable;
      }

      // biometricOnly=false: PIN/pola tetap diterima sebagai fallback.
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricResult.success : BiometricResult.failed;
    } on LocalAuthException catch (e) {
      AppLogger.warning('🔐 Biometrik gagal: ${e.code.name}');
      if (e.code == LocalAuthExceptionCode.noCredentialsSet ||
          e.code == LocalAuthExceptionCode.noBiometricHardware) {
        return BiometricResult.notAvailable;
      }
      return BiometricResult.failed;
    }
  }
}
