import 'package:cekreklamemobile/data/datasources/auth/auth_local_datasource.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  AuthInterceptor(this.localDataSource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await localDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
