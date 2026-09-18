import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/enums/app_permission_enum.dart';
import '../../../../core/services/permission/i_permission_service.dart';
import '../../../../core/services/update_service.dart';
import '../../../../core/utils/app_logger.dart';
import 'home_state.dart';
import 'home_action.dart';

@injectable // WAJIB @injectable, BUKAN @lazySingleton
class HomeCubit extends Cubit<HomeState> {
  final UpdateService updateService;
  final IPermissionService permissionService;
  
  bool _isNavigating = false;

  HomeCubit({
    required this.updateService,
    required this.permissionService,
  }) : super(const HomeState());

  Future<void> onPageOpened() async {
    if (isClosed) return;
    emit(state.copyWith(isCheckingUpdate: true));
    
    try {
      // --- AREA MOCK PROFIL (Nanti diganti dengan fetch dari Hive/Prefs) ---
      await Future.delayed(const Duration(milliseconds: 500)); 
      if (isClosed) return; // Proteksi setelah await
      
      const mockUserName = 'William Saliba';
      const mockUserRole = 'Divisi IT';
      // --------------------------------------------------------------------

      final updateInfo = await updateService.getAvailableUpdate();
      if (isClosed) return;
      
      emit(
        state.copyWith(
          isCheckingUpdate: false,
          updateInfo: updateInfo,
          action: updateInfo != null ? HomeShowUpdateDialog(updateInfo) : null,
          userName: mockUserName,
          userRole: mockUserRole,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load home data', e, stackTrace);
      
      if (isClosed) return;
      emit(state.copyWith(
        isCheckingUpdate: false,
        userName: 'Guest',
        userRole: 'Bapenda Core',
      ));
    }
  }

  // TODO: Logic navigasi Reklame dipindah ke cubit tersendiri saat refactoring fitur
  Future<void> onCapturePressed() async {
    if (_isNavigating || isClosed) return;
    _isNavigating = true;

    try {
      AppLogger.debug('Mengecek kesiapan izin dan sensor untuk Cek Reklame');

      // 1. Cek Sensor GPS (Hardware Level)
      final gpsStatus = await permissionService.requestPermission(AppPermissionType.locationService);
      if (isClosed) return;
      
      if (gpsStatus == AppPermissionStatus.permanentlyDenied) {
        emit(state.copyWith(action: const HomeShowGpsDisabled()));
        return; // Keluar awal jika gagal
      }

      // 2. Cek Izin Lokasi (Software Level)
      final locationStatus = await permissionService.requestPermission(AppPermissionType.location);
      if (isClosed) return;
      
      if (locationStatus == AppPermissionStatus.permanentlyDenied) {
        emit(state.copyWith(action: const HomeShowPermissionPermanentlyDenied()));
        return;
      } else if (locationStatus != AppPermissionStatus.granted) {
        emit(state.copyWith(action: const HomeShowPermissionDenied()));
        return;
      }

      // 3. Cek Izin Kamera
      final cameraStatus = await permissionService.requestPermission(AppPermissionType.camera);
      if (isClosed) return;
      
      if (cameraStatus == AppPermissionStatus.permanentlyDenied) {
        emit(state.copyWith(action: const HomeShowPermissionPermanentlyDenied()));
        return;
      } else if (cameraStatus != AppPermissionStatus.granted) {
        emit(state.copyWith(action: const HomeShowPermissionDenied()));
        return;
      }

      // 4. Jika Semua Lolos -> Navigasi
      emit(state.copyWith(action: const HomeNavigateToCamera()));
      
      // Delay kecil untuk memberi waktu UI transisi sebelum flag dibuka
      await Future.delayed(const Duration(milliseconds: 500));
      
    } finally {
      // Finally memastikan flag selalu di-reset baik saat sukses maupun error
      _isNavigating = false;
    }
  }

  void onManualCheckUpdate() {
    if (isClosed) return;
    
    final info = state.updateInfo;
    if (info != null) {
      emit(state.copyWith(action: HomeShowUpdateDialog(info)));
    }
  }

  void clearAction() {
    if (isClosed) return;
    emit(state.copyWith(action: null));
  }
}