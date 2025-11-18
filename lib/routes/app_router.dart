import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../presentation/features/onboarding/pages/onboarding.dart';
import '../presentation/features/auth/pages/login_page.dart';
import '../presentation/features/auth/pages/signup_page.dart';
// import other pages when available

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),

    // Add other routes here
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupPage(),
    ),
  ],
);
