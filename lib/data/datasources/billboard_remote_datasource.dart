import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart'; // Wajib untuk MediaType
import '../models/billboard_model.dart';

class BillboardRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'http://112.140.162.23:8181/api';

  BillboardRemoteDataSource(this.dio);

  Future<List<BillboardModel>> checkReklame({required String imagePath}) async {
    const endpoint = '$baseUrl/ReklameChecker/CheckReklame';

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
}
