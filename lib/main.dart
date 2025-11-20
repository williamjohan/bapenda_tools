import 'package:cekreklamemobile/di.dart';
import 'package:cekreklamemobile/routes/app_router.dart';
import 'package:flutter/material.dart';

void main() {
  // 1. Pastikan Flutter Binding siap untuk memanggil kode native/async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 🟢 Panggil fungsi setupLocator()
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
