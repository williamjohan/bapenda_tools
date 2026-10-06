import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';

/// Tombol absen bulat 72dp dengan gradient header (emas/oranye).
class AbsenFab extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onPressed;

  const AbsenFab({super.key, required this.isBusy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: 'Absen sekarang',
      child: GestureDetector(
        // Disable saat proses berjalan → cegah dobel tap.
        onTap: isBusy ? null : onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isBusy ? 0.7 : 1,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: palette.headerLinearGradient,
              border: Border.all(color: palette.surface, width: 3),
              boxShadow: [
                BoxShadow(
                  color: palette.headerGradient.last.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: isBusy
                ? const Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.fingerprint, color: Colors.white, size: 38),
          ),
        ),
      ),
    );
  }
}
