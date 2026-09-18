import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../enums/app_permission_enum.dart';
import '../../utils/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'i_permission_service.dart';

@LazySingleton(as: IPermissionService)
class PermissionServiceImpl implements IPermissionService {
  bool _isRequestingPermission = false;

  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async {
    if (_isRequestingPermission) {
      AppLogger.warning(
        '⚠️ [PermissionService] Request untuk ${type.name} diabaikan: Request izin native lain sedang berjalan.',
      );
      return AppPermissionStatus.denied;
    }

    _isRequestingPermission = true;

    try {
      AppLogger.debug(
        '🛡️ [PermissionService] Memulai request izin untuk: ${type.name}',
      );

      switch (type) {
        case AppPermissionType.camera:
          return await _handleSinglePermission(Permission.camera, type.name);

        case AppPermissionType.location:
          return await _handleSinglePermission(Permission.location, type.name);

        case AppPermissionType.notification:
          return await _handleSinglePermission(
            Permission.notification,
            type.name,
          );

        case AppPermissionType.storage:
          return await _handleSinglePermission(Permission.storage, type.name);

        case AppPermissionType.photos:
          return await _handleSinglePermission(Permission.photos, type.name);

        case AppPermissionType.microphone:
          return await _handleSinglePermission(
            Permission.microphone,
            type.name,
          );

        case AppPermissionType.bluetooth:
          return await _handleBluetoothPermissions();

        case AppPermissionType.locationService:
          return await _handleLocationHardwareService();
      }
    } catch (e, stackTrace) {
      // Menghindari Silent Failure jika terjadi error di level OS Native
      AppLogger.error(
        '🚨 [PermissionService] FATAL ERROR saat request ${type.name}',
        e,
        stackTrace,
      );
      return AppPermissionStatus.denied;
    } finally {
      //  Pastikan lock selalu dilepas baik saat sukses maupun error
      _isRequestingPermission = false;
    }
  }

  @override
  Future<void> openSettings() async {
    AppLogger.debug('⚙️ [PermissionService] Mengarahkan user ke App Settings');
    await openAppSettings();
  }

  @override
  Future<void> openLocationSettings() async {
    AppLogger.debug(
      '🛰️ [PermissionService] Mengarahkan user ke GPS Hardware Settings',
    );
    await Geolocator.openLocationSettings();
  }

  @override
  Future<void> openBluetoothSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  }

  // ===========================================================================
  // PRIVATE HELPER METHODS
  // ===========================================================================

  Future<AppPermissionStatus> _handleSinglePermission(
    Permission permission,
    String permissionName,
  ) async {
    final status = await permission.request();
    AppLogger.debug(
      '🛡️ [PermissionService] Hasil awal request $permissionName: $status',
    );

    if (status.isGranted) {
      return AppPermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    }

    // 🚀 PERTAHANAN 2: "OS Lie Detector" untuk Izin Tunggal (HP Xiaomi/Oppo/dsb)
    if (await permission.isPermanentlyDenied) {
      AppLogger.debug(
        '⚠️ [PermissionService] $permissionName terdeteksi Permanently Denied dari cek manual!',
      );
      return AppPermissionStatus.permanentlyDenied;
    }

    return AppPermissionStatus.denied;
  }

  Future<AppPermissionStatus> _handleBluetoothPermissions() async {
    try {
      AppLogger.debug('📡 [PermissionService] Meminta multi-izin Bluetooth...');

      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      final scanStatus =
          statuses[Permission.bluetoothScan] ?? PermissionStatus.denied;
      final connectStatus =
          statuses[Permission.bluetoothConnect] ?? PermissionStatus.denied;
      final locationStatus =
          statuses[Permission.locationWhenInUse] ?? PermissionStatus.denied;

      AppLogger.debug(
        '📡 [PermissionService] Hasil Scan: $scanStatus | Connect: $connectStatus | Location: $locationStatus',
      );

      if (scanStatus.isGranted &&
          connectStatus.isGranted &&
          locationStatus.isGranted) {
        return AppPermissionStatus.granted;
      }

      if (scanStatus.isPermanentlyDenied ||
          connectStatus.isPermanentlyDenied ||
          locationStatus.isPermanentlyDenied) {
        return AppPermissionStatus.permanentlyDenied;
      }

      // 3: "OS Lie Detector" khusus untuk kombo Bluetooth
      if (await Permission.bluetoothScan.isPermanentlyDenied ||
          await Permission.bluetoothConnect.isPermanentlyDenied ||
          await Permission.locationWhenInUse.isPermanentlyDenied) {
        AppLogger.debug(
          '⚠️ [PermissionService] Bluetooth terdeteksi Permanently Denied dari cek manual!',
        );
        return AppPermissionStatus.permanentlyDenied;
      }

      return AppPermissionStatus.denied;
    } catch (e, stackTrace) {
      //  4: Menangkap error spesifik kegagalan hardware bluetooth
      AppLogger.error(
        '🚨 [PermissionService] Gagal mengeksekusi multi-izin Bluetooth',
        e,
        stackTrace,
      );
      return AppPermissionStatus.denied;
    }
  }

  /// Mengecek apakah sensor GPS menyala atau mati
  Future<AppPermissionStatus> _handleLocationHardwareService() async {
    try {
      final isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      AppLogger.debug(
        '🛰️ [PermissionService] Status Sensor GPS: ${isGpsEnabled ? "ON" : "OFF"}',
      );

      // Jika GPS mati, kita anggap ini "permanentlyDenied" agar UI memunculkan
      // tombol "Buka Pengaturan" (yang nanti akan ditrigger ke openLocationSettings)
      if (!isGpsEnabled) {
        return AppPermissionStatus.permanentlyDenied;
      }

      return AppPermissionStatus.granted;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🚨 [PermissionService] Gagal mengecek status sensor GPS',
        e,
        stackTrace,
      );
      // Fallback ke permanentlyDenied agar user masih bisa klik tombol "Buka Pengaturan" di UI
      return AppPermissionStatus.permanentlyDenied;
    }
  }
}
