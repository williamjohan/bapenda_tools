import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/presentation/features/detail/pages/detail_page.dart';
import 'package:cekreklamemobile/presentation/features/result/pages/check_result.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/splashscreen.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../presentation/features/onboarding/pages/onboarding.dart';
import '../presentation/features/auth/pages/login_page.dart';
import '../presentation/features/auth/pages/signup_page.dart';
import '../presentation/features/camera/pages/camera_pages.dart';
// import other pages when available

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashscreen,
  routes: [
    GoRoute(
      path: AppRoutes.splashscreen,
      name: AppRoutes.splashscreen, // 💡 Tambahkan name
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),

    // Add other routes here
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
      builder: (context, state) => const CaptureScreen(),
    ),

    // Rute HASIL CEK (CheckResultScreen)
    GoRoute(
      path: AppRoutes.results,
      name: AppRoutes.results,
      builder: (context, state) {
        // Menerima arguments dari CaptureScreen
        final args = state.extra as Map<String, dynamic>?;

        return CheckResultScreen(
          imagePath: args?['imagePath'] ?? '',
          latitude: args?['latitude'] ?? 0.0,
          longitude: args?['longitude'] ?? 0.0,
        );
      },
    ),

    // Rute DETAIL BILLBOARD
    GoRoute(
      path: AppRoutes.detail,
      name: AppRoutes.detail,
      builder: (context, state) {
        // Menerima Entity dari CheckResultScreen (melalui .pushNamed(extra: ...))
        final billboard = state.extra as BillboardEntity;

        return BillboardDetailScreen(billboard: billboard);
      },
    ),
  ],
);
