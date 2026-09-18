import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthCubit authCubit;

  SplashCubit({required this.authCubit}) : super(SplashInitial());

  void start() {
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    final minDelay = Future.delayed(const Duration(seconds: 3));

    // ini yang tadinya ilang — checkSession harus dipanggil dari sini
    await authCubit.checkSession();
    await minDelay;

    if (isFirstLaunch) {
      emit(SplashNavigateOnboarding());
      return;
    }

    final isLoggedIn = authCubit.state is AuthAuthenticated;
    emit(isLoggedIn ? SplashNavigateHome() : SplashNavigateLogin());
  }
}
