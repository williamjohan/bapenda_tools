// lib/core/utils/image_utils.dart
import 'dart:convert';
import 'dart:typed_data';

/// Mendekode Base64 Data URL menjadi Uint8List yang siap digunakan oleh Image.memory.
/// Mengembalikan null jika string tidak valid, kosong, atau gagal di-decode.
Uint8List? decodeBase64DataUrl(String dataUrl) {
  if (dataUrl.isEmpty) {
    return null;
  }

  // Pisahkan prefix (e.g., 'data:image/png;base64,') dari string Base64 murni
  final parts = dataUrl.split(',');
  if (parts.length > 1) {
    // String Base64 murni ada di bagian terakhir
    final base64String = parts.last;
    try {
      return base64Decode(base64String);
    } catch (e) {
      // Gagal decode Base64
      // print('ERROR decoding Base64: $e');
      return null;
    }
  }

  // Jika format tidak sesuai Data URL, coba decode langsung (jarang, tapi aman)
  try {
    return base64Decode(dataUrl);
  } catch (e) {
    return null;
  }
}
