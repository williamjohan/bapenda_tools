import 'package:envied/envied.dart';

part 'env_config.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class EnvConfig {
  // 1. BASE URL (Ambil dari .env agar dinamis jika pindah server Staging/Prod)
  @EnviedField(varName: 'BASE_URL', obfuscate: false)
  static const String baseUrl = _EnvConfig.baseUrl;

  // 2. GOOGLE MAPS API KEY (Untuk fitur peta reklame)
  @EnviedField(varName: 'GOOGLE_MAPS_API_KEY', obfuscate: true)
  static final String googleMapsApiKey = _EnvConfig.googleMapsApiKey;

  // // 3. APP SECRET KEY (Dari tektokan dengan BE)
  // // Dipakai untuk header X-App-Key DAN kunci rumus HMAC-SHA256
  // @EnviedField(varName: 'APP_SECRET_KEY', obfuscate: true)
  // static final String appSecretKey = _EnvConfig.appSecretKey;

  @EnviedField(varName: 'APP_SIGN_STAGING', obfuscate: true)
  static final String appSignStaging = _EnvConfig.appSignStaging;
}
