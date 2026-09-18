import 'package:flutter/material.dart';

class AppThemeColors {
  const AppThemeColors._();

  // ==========================================================
  // Brand Colors (Vendor)
  // ==========================================================

  /// Primary CTA & Active Accent
  static const Color primary = Color(0xFFFF9634);

  /// Soft Action Surface
  static const Color primarySoft = Color(0xFFFFF3E7);

  /// Historic Gold Accent
  static const Color gold = Color(0xFFA46A04);

  /// Navbar Gradient Start
  static const Color goldLight = Color(0xFFCE9300);

  /// Gradient End
  static const Color brown = Color(0xFF99530E);

  /// Legacy Promotion Accent
  static const Color yellow = Color(0xFFFFBD17);

  static const Color transparent = Colors.transparent;

  // ==========================================================
  // Text
  // ==========================================================

  /// Strong detail text
  static const Color detailText = Color(0xFF04091C);

  /// Primary text
  static const Color primaryText = Color(0xFF0A0A0A);

  /// Titles & headings
  static const Color titleText = Color(0xFF121424);

  /// Secondary text
  static const Color secondaryText = Color(0xFF636262);

  /// Tertiary text
  static const Color tertiaryText = Color(0xFF99A1B7);

  // ==========================================================
  // Border
  // ==========================================================

  static const Color defaultBorder = Color(0xFFDBDFE9);

  static const Color subtleBorder = Color(0xFFEFEFEF);

  static const Color veryLightBorder = Color(0xFFF5F5F5);

  // ==========================================================
  // Background
  // ==========================================================

  static const Color defaultBackground = Color(0xFFF9F9F9);

  static const Color contentBackground = Color(0xFFFBFCFD);

  static const Color defaultSurface = Colors.white;

  static const Color filterBackground = Color(0xFFEBEDF3);
  static const Color brownDarkerBackground = Color(0xFF573814);

  // ==========================================================
  // Status
  // ==========================================================

  static const Color success = Color(0xFF04B440);
  static const Color successSoft = Color(0xFFEAFFF1);

  static const Color warning = Color(0xFFF6B100);
  static const Color warningSoft = Color(0xFFFFF8DD);

  static const Color danger = Color(0xFFD81A48);
  static const Color dangerSoft = Color(0xFFFFEEF3);

  static const Color information = Color(0xFF016C74);
  static const Color informationSoft = Color(0xFFE3F8F8);

  // ==========================================================
  // Existing Compatibility Layer
  // ==========================================================

  // ----- Primary -----

  @Deprecated('Use primarySoft')
  static const Color primarySurface = primarySoft;

  @Deprecated('Use brown')
  static const Color primaryDark = brown;

  @Deprecated('Use yellow')
  static const Color primaryLight = yellow;

  // ----- Secondary -----

  /// Legacy palette, tetap dipertahankan agar tidak merusak kode lama
  static const Color secondary = Color(0xFF2C3E50);
  static const Color secondaryLight = Color(0xFF3E556B);
  static const Color secondaryDark = Color(0xFF1B2836);
  static const Color secondarySurface = Color(0xFFF2F5F8);

  // ----- Background -----

  @Deprecated('Use defaultBackground')
  static const Color background = defaultBackground;

  @Deprecated('Use defaultSurface')
  static const Color surface = defaultSurface;

  @Deprecated('Use defaultSurface')
  static const Color cardBackground = defaultSurface;

  // ----- Text -----

  @Deprecated('Use primaryText')
  static const Color textPrimary = primaryText;

  @Deprecated('Use secondaryText')
  static const Color textSecondary = secondaryText;

  @Deprecated('Use tertiaryText')
  static const Color textHint = tertiaryText;

  static const Color textOnPrimary = Colors.white;

  @Deprecated('Use primaryText')
  static const Color textOnSurface = primaryText;

  // ----- Status -----

  @Deprecated('Use danger')
  static const Color error = danger;

  @Deprecated('Use information')
  static const Color info = information;

  static const Color completed = Color(0xFF607D8B);

  // ----- Neutral -----

  @Deprecated('Use defaultBorder')
  static const Color border = defaultBorder;

  @Deprecated('Use subtleBorder')
  static const Color divider = subtleBorder;

  static const Color disabled = Color(0xFFC7C7C7);

  static const Color shimmer = Color(0xFFEEEEEE);

  @Deprecated('Use defaultSurface')
  static const Color inputFill = defaultSurface;

  // ==========================================================
  // Gradients
  // ==========================================================

  /// Login / Dashboard Header
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [yellow, brown],
  );

  /// Header AppBar
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [goldLight, brown],
  );

  /// Secondary Gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, brown],
  );

  /// Danger Button
  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF8285A), Color(0xFFC0103F)],
  );

  /// Approval Workflow
  static const LinearGradient approvalGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [information, Color(0xFF013337)],
  );

  /// Other
  static const Color white2 = Color(0xFFFFFFFF);
  static const Color white1 = Color(0xFFFAF8FE);
  static const Color iconPrimaryInverseWhite = Color(0xFFF9F9F9);
  static const Color textPrimaryInverseWhite = Color(0xFFF9F9F9);
  static const Color blackPrimary = Color(0xFF1F2937);
  static const Color yellow5 = Color(0xFFFF8A00);
  static const Color yellow6 = Color(0xFFFF6B00);
  static const Color textFormulir = Color(0xFFFF9634);
  static const Color brown2 = Color(0xFFFFDBCC);
  static const Color backgroundMutedBlueGray = Color(0xFFE2E8F0);
  static const Color borderPrimary = Color(0xFFDBDFE9);
  static const Color borderPrimaryHover = Color(0xFFF1F1F4);
  static const Color borderLighter = Color(0xFFEFEFEF);
  static const Color borderVeryLight = Color(0xFFF5F5F5);
  static const Color textPrimaryDisable = Color(0xFF99A1B7);
  static const Color textPrimarySubtitle = Color(0xFFDBDFE9);
  static const Color textDanger = Color(0xFFD81A48);
  static const Color textPrimaryBlueGray = Color(0xFF0F172A);
  static const Color textOutlineVariant = Color(0xFFCAC4D0);
  static const Color textMuted = Color(0xFFB5B5C3);
  static const Color grey1 = Color(0xFF5F5E5E);
  static const Color grey2 = Color(0xFFDDDDDD);
  static const Color grey3 = Color(0xFFF7F7F7);
  static const Color grey4 = Color(0xFFE5E7EB);
  static const Color grey5 = Color(0xFFF4F3F8);
  static const Color grey6 = Color(0xFFDCDCDC);
  static const Color grey7 = Color(0xFFF3F4F6);
  static const Color grey8 = Color(0xFFF9FAFB);
  static const Color grey9 = Color(0xFFE3E2E7);
  static const Color black1 = Color(0xFF1A1B1F);
  static const Color yellow1 = Color(0xFFCE9300);
  static const Color yellow2 = Color(0xFFE2BFB0);
  static const Color yellow3 = Color(0xFFFFA617);
  static const Color yellow4 = Color(0xFF995D0E);
  static const Color yellowBold = Color(0xFFDFA000);
  static const Color yellowDark = Color(0xFFA46A04);
  static const Color brown1 = Color(0xFF99530E);
  static const Color brown3 = Color(0xFFA04100);
  static const Color brown4 = Color(0xFF7A3000);
  static const Color brown5 = Color(0xFFDEC1AF);
  static const Color brown6 = Color(0xFF5A4136);
  static const Color backgroundSubtile = Color(0xFFF1F1F4);
  static const Color backgroundPrimary = Color(0xFFF9F9F9);
  static LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      blackPrimary.withValues(alpha: 0.40),
      blackPrimary.withValues(alpha: 0.38),
    ],
  );
  static const LinearGradient reklameGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [yellow3, yellow4],
  );
  static LinearGradient mapComponentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      blackPrimary.withValues(alpha: 0.40),
      blackPrimary.withValues(alpha: 0.38),
    ],
  );
  static const LinearGradient sisiGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [yellow5, yellow6],
  );
}
