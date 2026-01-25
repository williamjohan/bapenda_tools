// lib/core/services/map_service.dart
import 'package:cekreklamemobile/core/services/app_logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Untuk kDebugMode

class MapService {
  final LoggerService logger;
  final String? _googleApiKey;
  MapService(this.logger) : _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  String generateStaticMapUrl({required double lat, required double long}) {
    // Cek apakah key berhasil dimuat
    if (_googleApiKey == null || _googleApiKey.isEmpty) {
      if (kDebugMode) {
        print("WARNING: Google Maps API Key TIDAK DITEMUKAN di .env!");
      }
      logger.w('MapService: GOOGLE_MAPS_API_KEY missing');
      return 'https://via.placeholder.com/400x200?text=MAP+API+KEY+MISSING';
    }

    const String size = '600x200';
    const int zoom = 15;
    final String marker = 'color:red|$lat,$long';

    final url =
        'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$lat,$long'
        '&zoom=$zoom'
        '&size=$size'
        '&scale=2'
        '&maptype=roadmap'
        '&markers=$marker'
        '&key=$_googleApiKey';

    logger.d('MapService: static map url generated');
    return url;
  }
}
