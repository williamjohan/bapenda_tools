import 'package:bapendacore/core/constants/app_colors_new.dart';
import 'package:bapendacore/core/utils/file_cache_utils.dart';
import 'package:bapendacore/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bapendacore/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/theme/theme_mode_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID');
  // Wajib di-await: SharedPreferences di-preResolve sebelum cubit lain terdaftar.
  await configureDependencies();
  await FileCacheHelper.clearCache();

  final authCubit = getIt<AuthCubit>()..checkSession();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ThemeModeCubit>.value(value: getIt<ThemeModeCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      title: 'Bapenda Internal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppThemeColors.primary),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
    );
  }
}
