import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<({String token, bool isResetPassword})> login({
    required String nip,
    required String password,
  }) async {

    final response = await dio.post(
      '/auth/login',
      data: {'nip': nip, 'password': password},
    );

    final body = response.data as Map<String, dynamic>;

    // backend bisa aja balikin HTTP 200 tapi isSuccess: false, jadi dicek eksplisit
    if (body['isSuccess'] != true) {
      throw Exception(body['title'] ?? 'Login gagal');
    }

    final data = body['data'] as Map<String, dynamic>;
    return (
      token: data['token'] as String? ?? '',
      isResetPassword: data['isResetPassword'] as bool? ?? false,
    );
  }
}
