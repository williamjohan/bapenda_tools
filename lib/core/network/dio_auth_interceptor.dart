import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';
import '../storage/app_secure_storage.dart';
import '../utils/app_logger.dart';
import 'api_endpoints.dart';
import 'env_config/env_config.dart';

@lazySingleton
class DioAuthInterceptor extends Interceptor {
  final AppSecureStorage _securePreference;

  DioAuthInterceptor(this._securePreference);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _securePreference.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    AppLogger.info('🌐 API REQ: [${options.method}] ${options.uri}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      '✅ API RES: [${response.statusCode}] ${response.requestOptions.uri}',
    );
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.error(
      '❌ API ERR: [${err.response?.statusCode}] ${err.requestOptions.uri}',
    );

    // JIKA TOKEN MATI (401 UNAUTHORIZED)
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Memulai proses Refresh Token / Force Logout...');

      final refreshToken = await _securePreference.getRefreshToken();

      // Kasus 1: Tidak punya Refresh Token (Kasus Surabaya Tax saat ini)
      if (refreshToken == null || refreshToken.isEmpty) {
        await _forceLogout();
        return super.onError(err, handler);
      }

      // Kasus 2: Punya Refresh Token, coba perbarui!
      try {
        final refreshDio = Dio(BaseOptions(baseUrl: EnvConfig.baseUrl));
        final response = await refreshDio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final newAccessToken = response.data['data'] as String;
          await _securePreference.saveAccessToken(newAccessToken);

          // Ulangi request yang tadi gagal dengan token baru
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          AppLogger.info('🔄 Token Refreshed! Mengulang Request...');
          final retryResponse = await refreshDio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        AppLogger.error('Gagal Refresh Token. Menendang user ke Login.', e);
        await _forceLogout();
        return super.onError(err, handler);
      }
    }

    return super.onError(err, handler);
  }

  // --- KUMPULAN LOGIC KELUAR ---
  Future<void> _forceLogout() async {
    // 1. Bersihkan Brankas Baja (Token hilang)
    await _securePreference.clearAllSecureData();

    // 2. Tendang User ke Layar Login menggunakan GoRouter!
    // Catatan: Gunakan .go() agar seluruh stack layar sebelumnya terhapus.
    AppRouter.router.go(AppRoutes.login);
  }
}
