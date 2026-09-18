import 'dart:convert';
import 'package:cekreklamemobile/data/models/users/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession({required String token}) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<UserModel?> getUser() async {
    final raw = await _storage.read(key: _keyUser);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }
}
