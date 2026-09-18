import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  // ==========================================================
  // Base Typography
  // ==========================================================

  static TextStyle get _base => GoogleFonts.dmSans();

  // ==========================================================
  // Vendor Design System (Source of Truth)
  //
  // DM Sans is the official typography defined by the
  // Vendor Design System.
  //
  // All NEW screens/components MUST use these tokens.
  // ==========================================================

  /// ST / Display / Amount
  static TextStyle get displayAmount => _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 32 / 28,
  );

  /// ST / Heading / Page
  static TextStyle get headingPage => _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
  );

  /// ST / Heading / Section
  static TextStyle get headingSection => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
  );

  /// ST / Title / Card
  static TextStyle get titleCard => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
  );

  /// ST / Body / Primary
  static TextStyle get bodyPrimary => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  /// ST / Body / Primary Medium
  static TextStyle get bodyPrimaryMedium => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
  );

  /// ST / Body / Primary Medium
  static TextStyle get bodySemiBold => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  /// ST / Body / Primary Medium
  static TextStyle get bodyBold => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
  );

  /// ST / Body / Supporting
  static TextStyle get bodySupporting => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );

  /// ST / Body / Supporting Medium
  static TextStyle get bodySupportingMedium => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );

  /// ST / Body / Supporting Bold
  static TextStyle get bodySupportingBold => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
  );

  /// ST / Caption
  static TextStyle get caption => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
  );

  /// ST / Micro
  static TextStyle get micro => _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 14 / 10,
  );

  // ==========================================================
  // Existing Compatibility Layer
  //
  // These aliases preserve backward compatibility with
  // screens developed before the Vendor Design System.
  //
  // DO NOT add new typography tokens here.
  // Always add new typography to the Vendor Design System
  // section above.
  // ==========================================================

  static TextStyle get displayLarge => displayAmount;

  static TextStyle get displayMedium => displayAmount;

  static TextStyle get displaySmall => headingPage;

  static TextStyle get headlineLarge => headingPage;

  static TextStyle get headlineMedium => headingSection;

  static TextStyle get headlineSmall => headingSection;

  static TextStyle get titleLarge => titleCard;

  static TextStyle get titleMedium => bodyPrimaryMedium;

  static TextStyle get titleSmall => bodySupportingMedium;

  static TextStyle get bodyLarge => titleCard;

  static TextStyle get bodyMedium => bodyPrimary;

  static TextStyle get bodySmall => bodySupporting;

  static TextStyle get labelLarge => bodyPrimaryMedium;

  static TextStyle get labelMedium => bodySupportingMedium;

  static TextStyle get labelSmall => caption;
}
