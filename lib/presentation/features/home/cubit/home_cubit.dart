import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/app_logger_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/update_service.dart';
import 'home_state.dart';
import 'home_action.dart';

class HomeCubit extends Cubit<HomeState> {
  final UpdateService updateService;
  final PermissionService permissionService;
  final LocationService locationService;
  final LoggerService logger;
  bool _isNavigating = false;

  HomeCubit({
    required this.updateService,
    required this.permissionService,
    required this.locationService,
    required this.logger,
  }) : super(HomeState.initial());

  Future<void> onPageOpened() async {
    emit(state.copyWith(isCheckingUpdate: true));
    try {
      final updateInfo = await updateService.getAvailableUpdate();
      // Logic: Jika updateInfo ada, trigger action dialog
      emit(
        state.copyWith(
          isCheckingUpdate: false,
          updateInfo: updateInfo,
          action: updateInfo != null ? HomeShowUpdateDialog(updateInfo) : null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isCheckingUpdate: false));
    }
  }

  // Logic Tombol Capture (Cek Permission & GPS sekilas sebelum buka kamera)
  Future<void> onCapturePressed() async {
    if (_isNavigating) return;
    _isNavigating = true;

    final granted = await permissionService.requestCameraAndLocation();
    if (!granted) {
      final cameraStatus = await Permission.camera.status;
      final locationStatus = await Permission.location.status;

      // Jika salah satu ditolak permanen (Hard Deny)
      if (cameraStatus.isPermanentlyDenied ||
          locationStatus.isPermanentlyDenied) {
        emit(
          state.copyWith(action: const HomeShowPermissionPermanentlyDenied()),
        );
      }
      // Jika ditolak biasa (Soft Deny)
      else {
        emit(state.copyWith(action: const HomeShowPermissionDenied()));
      }

      _isNavigating = false;
      return;
    }

    final gpsEnabled = await locationService.isLocationServiceEnabled();
    if (!gpsEnabled) {
      emit(state.copyWith(action: const HomeShowGpsDisabled()));
      _isNavigating = false;
      return;
    }

    emit(state.copyWith(action: const HomeNavigateToCamera()));
    await Future.delayed(const Duration(milliseconds: 500));
    _isNavigating = false;
  }

  void onManualCheckUpdate() {
    final info = state.updateInfo;
    if (info != null) {
      emit(state.copyWith(action: HomeShowUpdateDialog(info)));
    }
  }

  void clearAction() {
    emit(state.copyWith(clearAction: true));
  }
}
