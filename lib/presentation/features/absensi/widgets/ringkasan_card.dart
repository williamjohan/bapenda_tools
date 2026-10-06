import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../domain/entities/absensi/ringkasan_absensi_entity.dart';
import '../../../shared/widgets/section_label.dart';
import '../constants/absensi_formatters.dart';

/// Ringkasan hari ini: nama pegawai + jam MASUK & PULANG.
///
/// Nilai MASUK/PULANG diambil apa adanya dari endpoint ringkasan
/// (aturan window jadwal di server), tidak dihitung dari list riwayat.
class RingkasanCard extends StatelessWidget {
  final RingkasanAbsensiEntity? ringkasan;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const RingkasanCard({
    super.key,
    required this.ringkasan,
    required this.isLoading,
    required this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final data = ringkasan;

    return SurfaceCard(
      withPattern: true,
      child: Skeletonizer(
        enabled: isLoading && data == null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel(
              text: 'Ringkasan Hari Ini',
              icon: Icons.today_rounded,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: palette.accentSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.person_rounded, color: palette.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (data?.nama ?? 'Nama Pegawai Bapenda').toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _jadwalText(data),
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (data != null) _KeteranganChip(kode: data.keterangan),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _JamTile(
                    label: 'MASUK',
                    jam: AbsensiFormatters.jam(data?.masuk),
                    icon: Icons.login_rounded,
                    color: palette.success,
                    background: palette.successSoft,
                    badge: (data?.isTelat ?? false)
                        ? 'Telat ${data!.menitTelat} mnt'
                        : null,
                    badgeColor: palette.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _JamTile(
                    label: 'PULANG',
                    jam: AbsensiFormatters.jam(data?.pulang),
                    icon: Icons.logout_rounded,
                    color: palette.danger,
                    background: palette.dangerSoft,
                    badge: (data?.isPulangCepat ?? false)
                        ? 'Pulang cepat'
                        : null,
                    badgeColor: palette.danger,
                  ),
                ),
              ],
            ),
            if (errorMessage != null && data == null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.error_outline, color: palette.danger, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: palette.danger, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _jadwalText(RingkasanAbsensiEntity? data) {
    if (data == null) return 'Jadwal 07:30 – 16:00';
    if (data.jamMasukJadwal == null) return 'Tidak ada jadwal hari ini';
    return 'Jadwal ${data.jamMasukJadwal} – ${data.jamPulangJadwal ?? '-'}';
  }
}

class _JamTile extends StatelessWidget {
  final String label;
  final String jam;
  final IconData icon;
  final Color color;
  final Color background;
  final String? badge;
  final Color badgeColor;

  const _JamTile({
    required this.label,
    required this.jam,
    required this.icon,
    required this.color,
    required this.background,
    required this.badgeColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              jam,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 4),
            Text(
              badge!,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KeteranganChip extends StatelessWidget {
  final String? kode;
  const _KeteranganChip({required this.kode});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (label, fg, bg) = switch (kode) {
      'H' => ('Hadir', palette.success, palette.successSoft),
      'M' => ('Mangkir', palette.danger, palette.dangerSoft),
      '*' => ('Tanpa jadwal', palette.textSecondary, palette.surfaceMuted),
      'R' => ('Libur', palette.accent, palette.accentSoft),
      null => ('Belum absen', palette.warning, palette.warningSoft),
      _ => (kode!, palette.accent, palette.accentSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
