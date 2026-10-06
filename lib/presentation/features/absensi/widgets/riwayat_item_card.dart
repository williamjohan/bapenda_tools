import 'package:flutter/material.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/absensi/riwayat_absensi_entity.dart';
import '../constants/absensi_formatters.dart';

class RiwayatItemCard extends StatelessWidget {
  final RiwayatAbsensiEntity item;

  const RiwayatItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, iconColor, iconBg) = _iconFor(item, palette);
    final subtitle = [
      item.namaDevice ?? _defaultDeviceName(item),
      if (item.namaLokasi != null) item.namaLokasi!,
    ].join(' · ');

    return Opacity(
      opacity: item.isValid ? 1 : 0.6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AbsensiFormatters.tanggal(item.tglPresensi),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AbsensiFormatters.jam(item.tglPresensi),
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (!item.isValid) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: palette.dangerSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Ditolak',
                            style: TextStyle(
                              color: palette.danger,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.keterangan != null && item.keterangan!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.keterangan!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, Color) _iconFor(
    RiwayatAbsensiEntity item,
    AppPalette palette,
  ) {
    switch (item.sumber) {
      case SumberAbsensi.manual:
        return (
          Icons.edit_outlined,
          palette.textSecondary,
          palette.surfaceMuted,
        );
      case SumberAbsensi.sync:
        return (Icons.fingerprint, palette.success, palette.successSoft);
      case SumberAbsensi.online:
        return item.jenisDevice == 2
            ? (Icons.fingerprint, palette.success, palette.successSoft)
            : (Icons.smartphone_rounded, palette.accent, palette.accentSoft);
    }
  }

  String _defaultDeviceName(RiwayatAbsensiEntity item) {
    switch (item.sumber) {
      case SumberAbsensi.manual:
        return 'Input manual';
      case SumberAbsensi.sync:
        return 'Mesin fingerprint';
      case SumberAbsensi.online:
        return 'Ponsel';
    }
  }
}
