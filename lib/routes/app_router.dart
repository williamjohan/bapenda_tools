import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:cekreklamemobile/presentation/features/auth/cubit/auth_state.dart';
import 'package:cekreklamemobile/presentation/features/camera/cubit/camera_cubit.dart';
import 'package:cekreklamemobile/presentation/features/camera/pages/camera_page.dart';
import 'package:cekreklamemobile/presentation/features/detail/pages/detail_page.dart';
import 'package:cekreklamemobile/presentation/features/home/cubit/home_cubit.dart';
import 'package:cekreklamemobile/presentation/features/home/pages/home_page.dart';
import 'package:cekreklamemobile/presentation/features/result/pages/check_result_page.dart';
import 'package:cekreklamemobile/presentation/features/splashscreen/cubit/splash_cubit.dart';
import 'package:cekreklamemobile/presentation/features/splashscreen/pages/splash_page.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';
import '../presentation/features/onboarding/pages/onboarding_page.dart';
import '../presentation/features/auth/pages/login_page.dart';

final GoRouter appRouter = GoRouter(
  observers: [if (kDebugMode) ChuckerFlutter.navigatorObserver],
  initialLocation: AppRoutes.splashscreen,
  refreshListenable: GoRouterRefreshStream(locator<AuthCubit>().stream),
  redirect: (context, state) {
    final authState = locator<AuthCubit>().state;
    final location = state.matchedLocation;

    if (authState is AuthInitial || authState is AuthLoading) {
      return location == AppRoutes.splashscreen ? null : AppRoutes.splashscreen;
    }

    final isLoggedIn = authState is AuthAuthenticated;

    final isAuthExemptRoute =
        location == AppRoutes.login || location == AppRoutes.onboarding;

    if (!isLoggedIn) {
      return isAuthExemptRoute ? null : AppRoutes.login;
    }

    if (location == AppRoutes.login ||
        location == AppRoutes.splashscreen ||
        location == AppRoutes.onboarding) {
      return AppRoutes.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splashscreen,
      name: AppRoutes.splashscreen,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => SplashCubit(authCubit: locator<AuthCubit>())..start(),
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
        final billboard = state.extra as BillboardEntity;
        return BillboardDetailScreen(billboard: billboard);
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.home,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider<HomeCubit>(
            create: (_) => locator<HomeCubit>()..onPageOpened(),
            child: const HomePage(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    // Tambahkan route lainnya di sini
  ],
);
