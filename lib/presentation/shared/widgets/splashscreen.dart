// lib/presentation/features/splash/pages/splash_screen.dart
import 'package:cekreklamemobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunchAndNavigate();
  }

  Future<void> _checkFirstLaunchAndNavigate() async {
    // Pastikan Shared Preferences sudah siap
    final prefs = await SharedPreferences.getInstance();

    // Default-nya adalah true jika belum pernah diset
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // Jeda waktu untuk efek branding (2 detik)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (isFirstLaunch) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.camera);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna utama dari tema (asumsi Anda akan set tema nanti)
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white, // Gunakan warna utama aplikasi
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 🖼️ Logo Aplikasi (Ganti dengan Asset Anda)
            Image.asset('assets/images/logosby.png', height: 150),
            const SizedBox(height: 16),

            const Text(
              'Cek Reklame Surabaya',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Validasi Cepat, Kota Tertib',
              style: TextStyle(color: Colors.black45, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
