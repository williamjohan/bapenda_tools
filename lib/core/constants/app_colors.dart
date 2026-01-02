import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama (Branding)
  static const Color primary = Color(0xFF175CFF);
  static const Color primaryLight = Color(0xFFFFB74D);
  static const Color primaryDark = Color(0xFFF57C00);

  // Warna Netral
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);

  // Warna Teks
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Warna Khusus Overlay
  static Color overlayLoading = Colors.black.withValues(alpha: 0.5);
  static Color overlaySuccess = Colors.black.withValues(alpha: 0.3);
}
