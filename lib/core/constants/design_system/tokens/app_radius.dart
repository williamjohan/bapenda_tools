import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  // ==========================================================
  // Vendor Design System (Source of Truth)
  //
  // All NEW screens/components MUST use these tokens.
  // ==========================================================

  /// Small controls
  static const double xs = 4;

  /// Compact controls
  static const double sm = 6;

  /// Inner surfaces
  static const double md = 8;

  /// Default cards & inputs
  static const double lg = 12;

  /// Large surfaces & bottom sheets
  static const double xl = 16;

  /// Pills & circular treatments
  static const double pill = 999;

  // BorderRadius

  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));

  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));

  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));

  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));

  static const BorderRadius radiusPill = BorderRadius.all(
    Radius.circular(pill),
  );

  // ==========================================================
  // Existing Compatibility Layer
  //
  // These aliases preserve backward compatibility with
  // screens developed before the Vendor Design System.
  //
  // DO NOT add new radius tokens here.
  // Always add new radius tokens to the Vendor Design System
  // section above.
  // ==========================================================

  /// Existing xs (4)
  static BorderRadius get xsRadius => radiusXs;

  /// Existing sm (8)
  ///
  /// Historically `smRadius` was 8px.
  /// Use `radiusSm` (6px) for new screens.
  static BorderRadius get smRadius => radiusMd;

  /// Existing md (12)
  ///
  /// Historically `mdRadius` was 12px.
  /// Use `radiusLg` (12px) for new screens.
  static BorderRadius get mdRadius => radiusLg;

  /// Existing lg (16)
  static BorderRadius get lgRadius => radiusXl;

  /// Existing xl (20)
  ///
  /// Not part of Vendor Design System.
  static BorderRadius get xlRadius =>
      const BorderRadius.all(Radius.circular(20));

  /// Existing xxl (24)
  ///
  /// Not part of Vendor Design System.
  static BorderRadius get xxlRadius =>
      const BorderRadius.all(Radius.circular(24));

  /// Existing full
  static BorderRadius get fullRadius => radiusPill;

  /// Other
  static const double xxl = 24.0;
}
