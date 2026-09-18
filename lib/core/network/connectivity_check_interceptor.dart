import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ConnectivityCheckInterceptor extends Interceptor {
  final Connectivity connectivity;
  ConnectivityCheckInterceptor(this.connectivity);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final result = await connectivity.checkConnectivity();
    // Memastikan koneksi tidak benar-benar mati
    if (result.contains(ConnectivityResult.none)) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        ),
      );
    }
    return handler.next(options);
  }
}
