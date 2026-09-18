import 'package:flutter/material.dart';

class HomeFeatureMenuItem {
  const HomeFeatureMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  /// Set to false for a "coming soon" placeholder card (greyed out,
  /// not tappable).
  final bool enabled;
}
