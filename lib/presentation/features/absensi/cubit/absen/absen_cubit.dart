import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/biometric_service.dart';
import '../../../../../core/services/geo_location_service.dart';
import '../../../../../domain/entities/absensi/absen_entity.dart';
import '../../../../../domain/usecases/absensi/absensi_usecase.dart';
import 'absen_state.dart';

/// Alur tombol absen: GPS → biometrik → POST /absen.
/// Tidak ada absen offline; waktu selalu dari server.
@injectable
class AbsenCubit extends Cubit<AbsenState> {
  final AbsensiUseCase _useCase;
  final GeoLocationService _locationService;
  final BiometricService _biometricService;

  AbsenCubit(this._useCase, this._locationService, this._biometricService)
    : super(const AbsenIdle());

  Future<void> submit() async {
    // Cegah dobel tap selama proses berjalan.
    if (state is AbsenInProgress) return;

    emit(const AbsenInProgress(AbsenStep.locating));
    final GeoPosition position;
    try {
      position = await _locationService.getCurrentPosition();
    } on GeoLocationException catch (e) {
      if (e.error == GeoLocationError.timeout) {
        emit(
          const AbsenFailure(
            'Gagal mendapatkan lokasi. Coba lagi di area terbuka.',
          ),
        );
      } else {
        emit(AbsenLocationRequired(e.error));
      }
      return;
    }

    // Fake GPS: tidak perlu verifikasi biometrik, tapi tetap dikirim
    // (isMockLocation=true) agar server menolak & mencatatnya untuk audit.
    if (!position.isMocked) {
      emit(const AbsenInProgress(AbsenStep.verifying));
      final bio = await _biometricService.authenticate('Konfirmasi absen');
      if (isClosed) return;
      switch (bio) {
        case BiometricResult.success:
          break;
        case BiometricResult.failed:
          emit(
            const AbsenFailure('Verifikasi dibatalkan. Absen tidak dikirim.'),
          );
          return;
        case BiometricResult.notAvailable:
          emit(
            const AbsenFailure(
              'Aktifkan kunci layar (sidik jari / PIN) di HP Anda untuk absen.',
            ),
          );
          return;
      }
    }

    emit(const AbsenInProgress(AbsenStep.submitting));
    final result = await _useCase.absen(
      AbsenParams(
        latitude: position.latitude,
        longitude: position.longitude,
        akurasiMeter: position.akurasiMeter,
        isMockLocation: position.isMocked,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(AbsenFailure(failure.message)),
      (absen) => emit(AbsenSuccess(absen)),
    );
  }

  Future<void> openLocationSettings() =>
      _locationService.openLocationSettings();

  Future<void> openAppSettings() => _locationService.openAppSettings();

  void reset() => emit(const AbsenIdle());
}
