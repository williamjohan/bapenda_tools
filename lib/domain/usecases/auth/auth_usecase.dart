import 'package:cekreklamemobile/domain/entities/users/user_entity.dart';
import 'package:cekreklamemobile/domain/repositories/auth/auth_repository.dart';

class AuthUseCase {
  final AuthRepository repository;
  AuthUseCase(this.repository);

  Future<bool> login({required String nip, required String password}) {
    return repository.login(nip: nip, password: password);
  }

  Future<void> logout() {
    return repository.logout();
  }

  Future<bool> getCurrentSession() => repository.getCurrentSession();
}
