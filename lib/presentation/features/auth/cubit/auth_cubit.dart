import 'package:cekreklamemobile/domain/usecases/auth/auth_usecase.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/app_logger_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthUseCase authUseCase;
  final LoggerService logger;

  AuthCubit({required this.authUseCase, required this.logger})
    : super(const AuthInitial());

  Future<void> checkSession() async {
    debugPrint('[AUTH] checkSession START');
    emit(const AuthLoading());
    try {
      final user = await authUseCase.getCurrentSession();
      debugPrint('[AUTH] checkSession DONE, user=$user');
      emit(
        user != null ? AuthAuthenticated(user) : const AuthUnauthenticated(),
      );
    } catch (e) {
      debugPrint('[AUTH] checkSession ERROR: $e');
      logger.e('checkSession error: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    emit(const AuthLoading());
    try {
      final user = await authUseCase.login(
        username: username,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      logger.e('login error: $e');
      emit(AuthFailure(_mapError(e)));
    }
  }

  Future<void> logout() async {
    try {
      await authUseCase.logout();
    } catch (e) {
      logger.e('logout error: $e');
    } finally {
      emit(const AuthUnauthenticated());
    }
  }

  String _mapError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'Username atau password salah';
    }
    return 'Login gagal, silakan coba lagi';
  }
}
