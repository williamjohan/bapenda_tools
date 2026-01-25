import 'package:cekreklamemobile/core/services/app_logger_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final LoggerService logger;

  LocationService(this.logger);

  Future<bool> isLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    logger.d("Location service enabled: $enabled");
    return enabled;
  }

  Future<void> openLocationSettings() async {
    logger.i("Opening location settings");
    await Geolocator.openLocationSettings();
  }
}
