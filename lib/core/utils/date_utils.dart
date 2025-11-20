import 'package:flutter/foundation.dart'; // Untuk kDebugMode

DateTime safeParseDateTime(String dateString) {
  try {
    if (dateString.isNotEmpty) {
      return DateTime.parse(dateString).toLocal();
    }
  } catch (e) {
    if (kDebugMode) {
      print('UTIL ERROR: Failed to parse date string "$dateString". Error: $e');
    }
  }
  return DateTime.now();
}
