import 'package:cekreklamemobile/data/datasources/auth/auth_local_datasource.dart';
import 'package:cekreklamemobile/data/datasources/auth/auth_remote_datasource.dart';
import 'package:cekreklamemobile/domain/repositories/auth/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<bool> login({required String nip, required String password}) async {
    final result = await remoteDataSource.login(nip: nip, password: password);
    await localDataSource.saveSession(token: result.token);
    return result.isResetPassword; 
  }

  @override
  Future<bool> getCurrentSession() => localDataSource.hasActiveSession();

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }
}
