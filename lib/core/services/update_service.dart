import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/update_utils.dart';

// Model Data Update
class UpdateInfo {
  final String version;
  final String changelog;
  final String downloadUrl;

  UpdateInfo({
    required this.version,
    required this.changelog,
    required this.downloadUrl,
  });
}

class UpdateService {
  final Dio _dio;

  UpdateService(this._dio);

  // 1. FUNGSI CEK UPDATE (Mengembalikan Data atau Null)
  Future<UpdateInfo?> getAvailableUpdate() async {
    try {
      // final jsonUrl = dotenv.env['UPDATE_JSON_URL'] ?? '';
      final jsonTestingUrl = dotenv.env['UPDATE_JSON_TESTING_URL'] ?? '';

      print("🔍 Checking update status: $jsonTestingUrl");
      final response = await _dio.get(jsonTestingUrl);

      Map<String, dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data);
      } else {
        data = Map<String, dynamic>.from(response.data);
      }

      int serverBuildNumber = int.tryParse(data['buildNumber'].toString()) ?? 0;

      // Logic Versioning (Server > Local)
      bool hasUpdate = await UpdateUtils.isUpdateAvailable(serverBuildNumber);

      if (hasUpdate) {
        print("🚀 New version found: ${data['versionName']}");
        return UpdateInfo(
          version: data['versionName'] ?? 'Unknown',
          changelog: data['changelog'] ?? '-',
          downloadUrl: data['url'] ?? '',
        );
      } else {
        print("✅ App is up to date.");
      }
    } catch (e) {
      print("❌ Failed to get update info: $e");
    }
    return null; // Tidak ada update atau Error
  }
}
