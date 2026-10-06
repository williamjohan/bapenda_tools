import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/services/biometric_service.dart';
import 'package:bapendacore/core/services/geo_location_service.dart';
import 'package:bapendacore/domain/entities/absensi/absen_entity.dart';
import 'package:bapendacore/domain/entities/absensi/riwayat_absensi_entity.dart';
import 'package:bapendacore/domain/entities/absensi/ringkasan_absensi_entity.dart';
import 'package:bapendacore/domain/repositories/absensi/absensi_repository.dart';
import 'package:bapendacore/domain/usecases/absensi/absensi_usecase.dart';
import 'package:bapendacore/presentation/features/absensi/cubit/absen/absen_cubit.dart';
import 'package:bapendacore/presentation/features/absensi/cubit/absensi/absensi_cubit.dart';
import 'package:bapendacore/core/constants/design_system/tokens/app_palette.dart';
import 'package:bapendacore/core/storage/app_preference.dart';
import 'package:bapendacore/core/theme/theme_mode_cubit.dart';
import 'package:bapendacore/presentation/shared/widgets/adaptive_theme_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapendacore/presentation/features/absensi/pages/absensi_page.dart';
import 'package:bapendacore/presentation/features/absensi/widgets/riwayat_item_card.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _Repo implements AbsensiRepository {
  @override
  Future<Either<Failure, RingkasanAbsensiEntity>> getRingkasan({
    DateTime? tanggal,
  }) async => Right(
    RingkasanAbsensiEntity(
      nip: '3506192511010005',
      nama: 'Mochammad Miftachun Najib',
      tanggal: DateTime(2026, 10, 2),
      masuk: DateTime(2026, 10, 2, 6, 10, 22),
      jamMasukJadwal: '07:30',
      jamPulangJadwal: '16:30',
    ),
  );

  @override
  Future<Either<Failure, RiwayatAbsensiPageResult>> getRiwayat({
    required int page,
    int pageSize = 20,
    int? tahun,
    int? bulan,
  }) async => Right(
    RiwayatAbsensiPageResult(
      page: page,
      pageSize: pageSize,
      total: 2,
      items: [
        RiwayatAbsensiEntity(
          tglPresensi: DateTime(2026, 10, 2, 7, 33, 1),
          jenisDevice: 1,
          namaDevice: 'Ponsel 24069PC21G',
          sumber: SumberAbsensi.online,
          isValid: true,
        ),
        RiwayatAbsensiEntity(
          tglPresensi: DateTime(2026, 10, 2, 6, 10, 22),
          jenisDevice: 1,
          sumber: SumberAbsensi.online,
          isValid: false,
        ),
      ],
    ),
  );

  @override
  Future<Either<Failure, AbsenResultEntity>> absen(AbsenParams params) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String>> downloadLaporanPdf({
    required int tahun,
    required int bulan,
    void Function(double? progress)? onProgress,
  }) => throw UnimplementedError();
}

class _Location implements GeoLocationService {
  @override
  Future<GeoPosition> getCurrentPosition() => throw UnimplementedError();
  @override
  Future<void> openAppSettings() async {}
  @override
  Future<void> openLocationSettings() async {}
}

class _Biometric implements BiometricService {
  @override
  Future<BiometricResult> authenticate(String reason) async =>
      BiometricResult.failed;
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('menampilkan ringkasan dari API & riwayat (${mode.name})', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      final useCase = AbsensiUseCase(_Repo());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => ThemeModeCubit(prefs)),
              BlocProvider(create: (_) => AbsensiCubit(useCase)..load()),
              BlocProvider(
                create: (_) => AbsenCubit(useCase, _Location(), _Biometric()),
              ),
            ],
            child: const AdaptiveThemeScope(child: AbsensiPage()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(
        scaffold.backgroundColor,
        mode == ThemeMode.dark
            ? AppPalette.dark.background
            : AppPalette.light.background,
      );

      expect(find.text('MOCHAMMAD MIFTACHUN NAJIB'), findsOneWidget);
      expect(find.text('06:10:22'), findsWidgets);
      // PULANG kosong dari API → placeholder, tidak diambil dari scan terakhir.
      expect(find.text('--:--:--'), findsOneWidget);
      expect(find.byType(RiwayatItemCard), findsNWidgets(2));
      expect(find.text('Jumat, 2 Oktober 2026'), findsNWidgets(2));
      expect(find.text('Ditolak'), findsOneWidget);
      // Unduh laporan sudah dipindah ke menu sendiri.
      expect(find.text('Unduh'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
