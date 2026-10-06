import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/design_system/tokens/app_palette.dart';
import '../../../../core/services/geo_location_service.dart';
import '../../../../domain/entities/absensi/riwayat_absensi_entity.dart';
import '../../../shared/widgets/bapenda_sliver_header.dart';
import '../../../shared/widgets/processing_loading_widget.dart';
import '../../../shared/widgets/section_label.dart';
import '../constants/absensi_formatters.dart';
import '../cubit/absen/absen_cubit.dart';
import '../cubit/absen/absen_state.dart';
import '../cubit/absensi/absensi_cubit.dart';
import '../cubit/absensi/absensi_state.dart';
import '../widgets/absen_fab.dart';
import '../widgets/hasil_absen_sheet.dart';
import '../widgets/riwayat_item_card.dart';
import '../widgets/ringkasan_card.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AbsensiCubit>().loadMore();
    }
  }

  // ---------------------------------------------------------------------------
  // Reaksi alur absen
  // ---------------------------------------------------------------------------

  Future<void> _onAbsenState(BuildContext context, AbsenState state) async {
    final absenCubit = context.read<AbsenCubit>();

    switch (state) {
      case AbsenSuccess(:final result):
        absenCubit.reset();
        context.read<AbsensiCubit>().onAbsenRecorded(result.ringkasan);
        await showHasilAbsenSheet(context, result);
      case AbsenFailure(:final message):
        absenCubit.reset();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: context.palette.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
      case AbsenLocationRequired(:final reason):
        absenCubit.reset();
        await _showLocationDialog(context, reason, absenCubit);
      case AbsenIdle() || AbsenInProgress():
        break;
    }
  }

  Future<void> _showLocationDialog(
    BuildContext context,
    GeoLocationError reason,
    AbsenCubit absenCubit,
  ) {
    final (title, message, actionLabel, VoidCallback action) = switch (reason) {
      GeoLocationError.serviceDisabled => (
        'Aktifkan GPS',
        'GPS di HP Anda mati. Nyalakan GPS untuk melakukan absen.',
        'Buka Pengaturan',
        absenCubit.openLocationSettings,
      ),
      GeoLocationError.permissionDeniedForever => (
        'Izin Lokasi Ditolak',
        'Izin lokasi diperlukan untuk absen. Aktifkan izin lokasi aplikasi di pengaturan.',
        'Buka Pengaturan',
        absenCubit.openAppSettings,
      ),
      GeoLocationError.permissionDenied || GeoLocationError.timeout => (
        'Izin Lokasi Diperlukan',
        'Absen membutuhkan lokasi Anda untuk memastikan berada di area kantor.',
        'Coba Lagi',
        absenCubit.submit,
      ),
    };

    final palette = context.palette;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text(title, style: TextStyle(color: palette.textPrimary)),
        content: Text(message, style: TextStyle(color: palette.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Batal',
              style: TextStyle(color: palette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              action();
            },
            child: Text(actionLabel, style: TextStyle(color: palette.accent)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocListener<AbsenCubit, AbsenState>(
      listener: _onAbsenState,
      child: BlocBuilder<AbsenCubit, AbsenState>(
        builder: (context, absenState) {
          final isBusy = absenState is AbsenInProgress;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: palette.background,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: AbsenFab(
                  isBusy: isBusy,
                  onPressed: context.read<AbsenCubit>().submit,
                ),
                body: BlocBuilder<AbsensiCubit, AbsensiState>(
                  builder: (context, state) => RefreshIndicator(
                    onRefresh: context.read<AbsensiCubit>().load,
                    color: palette.accent,
                    backgroundColor: palette.surface,
                    edgeOffset: 110,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        BapendaSliverHeader(
                          title: 'Absensi',
                          showBackButton: true,
                          subtitle: Text(
                            AbsensiFormatters.tanggal(DateTime.now()),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          sliver: SliverToBoxAdapter(
                            child: RingkasanCard(
                              ringkasan: state.ringkasan,
                              isLoading:
                                  state.ringkasanStatus ==
                                  AbsensiLoadStatus.loading,
                              errorMessage: state.ringkasanError,
                              onRetry: context
                                  .read<AbsensiCubit>()
                                  .loadRingkasan,
                            ),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                          sliver: SliverToBoxAdapter(
                            child: SectionLabel(
                              text: 'Riwayat Absensi',
                              icon: Icons.history_rounded,
                            ),
                          ),
                        ),
                        ..._buildRiwayat(context, state),
                        // Ruang untuk FAB.
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    ),
                  ),
                ),
              ),
              if (isBusy)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: ProcessingLoadingWidget(
                        message: _stepMessage(absenState.step),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildRiwayat(BuildContext context, AbsensiState state) {
    switch (state.riwayatStatus) {
      case AbsensiLoadStatus.initial:
      case AbsensiLoadStatus.loading:
        return [_riwayatList(_placeholderItems, loading: true)];
      case AbsensiLoadStatus.failure:
        return [
          SliverToBoxAdapter(
            child: _RiwayatMessage(
              icon: Icons.wifi_off_rounded,
              message: state.riwayatError ?? 'Gagal memuat riwayat.',
              actionLabel: 'Coba lagi',
              onAction: context.read<AbsensiCubit>().load,
            ),
          ),
        ];
      case AbsensiLoadStatus.loaded:
        if (state.riwayat.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: _RiwayatMessage(
                icon: Icons.history_rounded,
                message: 'Belum ada riwayat absensi.',
              ),
            ),
          ];
        }
        return [
          _riwayatList(state.riwayat),
          if (state.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.palette.accent,
                  ),
                ),
              ),
            ),
        ];
    }
  }

  Widget _riwayatList(
    List<RiwayatAbsensiEntity> items, {
    bool loading = false,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: Skeletonizer.sliver(
        enabled: loading,
        child: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => RiwayatItemCard(item: items[i]),
        ),
      ),
    );
  }

  String _stepMessage(AbsenStep step) {
    switch (step) {
      case AbsenStep.locating:
        return 'Mengambil lokasi';
      case AbsenStep.verifying:
        return 'Verifikasi biometrik';
      case AbsenStep.submitting:
        return 'Mengirim absen';
    }
  }

  static final List<RiwayatAbsensiEntity> _placeholderItems = List.generate(
    6,
    (_) => RiwayatAbsensiEntity(
      tglPresensi: DateTime(2026, 1, 1, 7, 30),
      jenisDevice: 1,
      namaDevice: 'Ponsel placeholder',
      sumber: SumberAbsensi.online,
      isValid: true,
    ),
  );
}

class _RiwayatMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _RiwayatMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Icon(icon, color: palette.textTertiary, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, fontSize: 14),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.accent,
                side: BorderSide(color: palette.borderStrong),
              ),
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
