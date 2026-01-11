import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/presentation/features/detail/pages/detail_page.dart';
import 'package:cekreklamemobile/presentation/features/home/pages/home_page.dart';
import 'package:cekreklamemobile/presentation/features/result/pages/check_result_page.dart';
import 'package:cekreklamemobile/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../presentation/features/onboarding/pages/onboarding_page.dart';
import '../presentation/features/auth/pages/login_page.dart';
import '../presentation/features/auth/pages/signup_page.dart';
import '../presentation/features/camera/pages/camera_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashscreen,
  routes: [
    GoRoute(
      path: AppRoutes.splashscreen,
      name: AppRoutes.splashscreen,
      builder: (context, state) => const SplashScreen(),
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
      path: AppRoutes.camera,
      name: AppRoutes.camera,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const CaptureScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.9;
            const end = 1.0;
            const curve = Curves.easeOutExpo;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(tween),
                child: child,
              ),
            );
          },
          // Durasi transisi (misal 300ms biar cepat seperti kamera asli)
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.results,
      name: AppRoutes.results,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return CheckResultScreen(
          imagePath: args?['imagePath'] ?? '',
          latitude: args?['latitude'] ?? 0.0,
          longitude: args?['longitude'] ?? 0.0,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.detail,
      name: AppRoutes.detail,
      builder: (context, state) {
        final billboard = state.extra as BillboardEntity;
        return BillboardDetailScreen(billboard: billboard);
      },
    ),

    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.home,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // Tambahkan route lainnya di sini
  ],
);
