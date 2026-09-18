import 'dart:convert';
import 'dart:typed_data';

class Base64ImageCache {
  static final Map<String, Uint8List> _cache = {};

  static Uint8List decode(String base64) {
    return _cache.putIfAbsent(base64, () {
      final cleaned = base64.contains(',') ? base64.split(',').last : base64;

      return base64Decode(cleaned);
    });
  }

  static void clear() {
    _cache.clear();
  }
}
