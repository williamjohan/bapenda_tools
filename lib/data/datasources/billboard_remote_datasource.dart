import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart'; // Wajib untuk MediaType
import '../models/billboard_model.dart';

class BillboardRemoteDataSource {
  final Dio dio;
  // static const String baseUrl = 'http://112.140.162.23:8181/api';
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'URL_NOT_FOUND';

  BillboardRemoteDataSource(this.dio);

  Future<List<BillboardModel>> checkReklame({required String imagePath}) async {
    final endpoint = '$baseUrl/ReklameChecker/CheckReklame';

    // 1. Siapkan File (MultipartFile)
    final fileName = imagePath.split('/').last;
    final file = await MultipartFile.fromFile(
      imagePath,
      filename: fileName,
      // 🛑 Penting: Pastikan ini sesuai dengan kontrak API
      contentType: MediaType('image', 'png'),
    );

    // 2. Siapkan FormData (Kunci harus 'File' sesuai cURL)
    final formData = FormData.fromMap({'File': file});

    try {
      final response = await dio.post(
        endpoint,
        data: formData,
        options: Options(headers: {'accept': '*/*'}),
      );

      if (response.statusCode == 200) {
        // 🛑 API mengembalikan List<Object>, jadi parsing sebagai List<dynamic>
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => BillboardModel.fromJson(json)).toList();
      } else {
        throw Exception(
          "API returned status code ${response.statusCode}: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      throw Exception("Failed to check reklame via API: ${e.message}");
    }
  }

  Future<List<BillboardModel>> checkReklameWithCoordinate({
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    // 1. Buat URL dengan Query Parameters
    final endpoint =
        '$baseUrl/ReklameChecker/CheckReklameKoordinat'
        '?latitude=$latitude&longitude=$longitude';

    // 2. Siapkan File (MultipartFile)
    final fileName = imagePath.split('/').last;
    final file = await MultipartFile.fromFile(
      imagePath,
      filename: fileName,
      contentType: MediaType('image', 'png'),
    );

    // 3. Siapkan FormData (Kunci 'File')
    final formData = FormData.fromMap({'File': file});

    try {
      final response = await dio.post(
        endpoint, // URL sekarang sudah lengkap dengan lat/lon
        data: formData,
        options: Options(headers: {'accept': '*/*'}),
      );

      // ... (Logika parsing response 200) ...
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => BillboardModel.fromJson(json)).toList();
      } else {
        throw Exception(
          "API returned status code ${response.statusCode}: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      throw Exception("Failed to check reklame via API: ${e.message}");
    }
  }

  Future<bool> postReport({
    required String imagePath,
    required double latitude,
    required double longitude,
    required int type,
  }) async {
    final endpoint =
        '$baseUrl/ReklameChecker/LaporReklameIlegal'
        '?latitude=$latitude&longitude=$longitude&jenis=$type';

    try {
      // 2. Siapkan Body (Hanya File)
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
          contentType: MediaType('image', 'png'),
        ),
      });

      // 3. Kirim dengan Header Accept
      final response = await dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {'accept': '*/*'},
          contentType: 'multipart/form-data',
        ),
      );

      return response.statusCode == 200;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("System Error: $e");
    }
  }
}
