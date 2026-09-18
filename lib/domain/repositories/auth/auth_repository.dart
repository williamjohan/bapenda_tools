

import 'package:cekreklamemobile/domain/entities/users/user_entity.dart';

abstract class AuthRepository {
  Future<bool> login({
    required String nip,
    required String password,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentSession();
}