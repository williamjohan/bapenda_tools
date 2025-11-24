// lib/core/services/map_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Untuk kDebugMode

String? _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

class MapService {
  // Method untuk menghasilkan URL Peta Statis
  MapService() {
    // Ini akan mengambil key yang sudah dimuat di main()
    _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  }

  String generateStaticMapUrl({required double lat, required double long}) {
    // Cek apakah key berhasil dimuat
    if (_googleApiKey == null || _googleApiKey!.isEmpty) {
      if (kDebugMode) {
        print("WARNING: Google Maps API Key TIDAK DITEMUKAN di .env!");
      }
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

    // print("🔍 TEST THIS URL: $url");
    return url;
  }
}
