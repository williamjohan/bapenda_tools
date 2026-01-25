import 'package:cekreklamemobile/core/services/app_logger_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  final LoggerService logger;

  PermissionService(this.logger);

  Future<bool> requestCameraAndLocation() async {
    logger.i("Requesting camera & location permission");

    final cameraStatus = await Permission.camera.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    final granted = cameraStatus.isGranted && locationStatus.isGranted;

    if (!granted) {
      logger.w("Permission denied");
    }

    return granted;
  }
}
