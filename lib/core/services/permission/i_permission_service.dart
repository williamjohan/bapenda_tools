import '../../enums/app_permission_enum.dart';

abstract class IPermissionService {
  /// Meminta izin secara dinamis berdasarkan tipenya
  Future<AppPermissionStatus> requestPermission(AppPermissionType type);
  Future<void> openLocationSettings();

  /// Membuka pengaturan native HP jika user sudah menolak secara permanen
  Future<void> openSettings();

  Future<void> openBluetoothSettings();
}
