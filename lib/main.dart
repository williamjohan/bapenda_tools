import 'package:cekreklamemobile/core/utils/file_cache_utils.dart';
import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:cekreklamemobile/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setupLocator();
  await FileCacheHelper.clearCache();

  runApp(
    BlocProvider<AuthCubit>(
      create: (_) => locator<AuthCubit>()..checkSession(),
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
      routerConfig: appRouter,
      title: 'Cek Reklame',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
    );
  }
}
