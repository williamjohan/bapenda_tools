// lib/core/utils/file_utils.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Membaca file dari assets, menyalinnya ke direktori sementara,
/// dan mengembalikan File Path dari file sementara tersebut.
Future<String> getFilePathFromAsset(String assetPath) async {
  // 1. Dapatkan data biner (bytes) dari asset
  final byteData = await rootBundle.load(assetPath);

  // 2. Tulis bytes ke direktori sementara
  final file = File(
    '${(await getTemporaryDirectory()).path}/temp_reklame_test.png',
  );

  // Ambil offset dan length dari byteData
  final buffer = byteData.buffer;
  await file.writeAsBytes(
    buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
  );

  // 3. Kembalikan path dari file sementara
  return file.path;
}
