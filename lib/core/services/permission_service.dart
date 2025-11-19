import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraAndLocation() async {
    // Meminta izin kamera
    final cameraStatus = await Permission.camera.request();
    // Meminta izin lokasi
    final locationStatus = await Permission.locationWhenInUse.request();

    // Mengembalikan true jika kedua izin diberikan
    return cameraStatus.isGranted && locationStatus.isGranted;
  }
}
