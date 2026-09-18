import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/di/injection.dart';
import '../domain/entities/billboard_entity.dart';
import '../presentation/features/detail/pages/detail_page.dart';
import '../presentation/features/home/cubit/home_cubit.dart';
import '../presentation/features/home/pages/home_page.dart';
import '../presentation/features/splashscreen/cubit/splash_cubit.dart';
import '../presentation/features/splashscreen/pages/splash_page.dart';
import '../presentation/features/onboarding/pages/onboarding_page.dart';
import '../presentation/features/auth/pages/login_page.dart';
import '../presentation/features/auth/pages/signup_page.dart';
import 'app_routes.dart';

class AppRouter {
  // Cegah instansiasi
  AppRouter._();

 static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    
    observers: kDebugMode ? [ChuckerFlutter.navigatorObserver] : [],
    
    initialLocation: AppRoutes.splashscreen,
    debugLogDiagnostics: kDebugMode,

    routes: [
      GoRoute(
        path: AppRoutes.splashscreen,
        name: AppRoutes.splashscreen,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => SplashCubit()..start(),
            child: const SplashScreen(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),

      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<HomeCubit>(
              // GANTI locator DENGAN locator (atau getIt) DARI injection.dart
             create: (_) => getIt<HomeCubit>()..onPageOpened(),
              child: const HomePage(),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      // GoRoute(
      //   path: AppRoutes.camera,
      //   name: AppRoutes.camera,
      //   pageBuilder: (context, state) {
      //     return CustomTransitionPage(
      //       key: state.pageKey,
      //       child: BlocProvider(
      //         create: (_) => CameraCubit()..start(),
      //         child: const CameraPage(),
      //       ),
      //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //         const begin = 0.9;
      //         const end = 1.0;
      //         const curve = Curves.easeOutExpo;

      //         final tween = Tween(
      //           begin: begin,
      //           end: end,
      //         ).chain(CurveTween(curve: curve));

      //         return FadeTransition(
      //           opacity: animation,
      //           child: ScaleTransition(
      //             scale: animation.drive(tween),
      //             child: child,
      //           ),
      //         );
      //       },
      //       transitionDuration: const Duration(milliseconds: 500),
      //     );
      //   },
      // ),

      // GoRoute(
      //   path: AppRoutes.results,
      //   name: AppRoutes.results,
      //   builder: (context, state) {
      //     final args = state.extra as Map<String, dynamic>?;
      //     return CheckResultScreen(
      //       imagePath: args?['imagePath'] ?? '',
      //       latitude: args?['latitude'] ?? 0.0,
      //       longitude: args?['longitude'] ?? 0.0,
      //     );
      //   },
      // ),

      GoRoute(
        path: AppRoutes.detail,
        name: AppRoutes.detail,
        builder: (context, state) {
          // Asumsi Anda akan menggunakan guard atau try-catch jika extra null
          final billboard = state.extra as BillboardEntity;
          return BillboardDetailScreen(billboard: billboard);
        },
      ),
    ],
  );
}