import 'dart:convert';
import 'package:cekreklamemobile/core/services/app_logger_service.dart';
import 'package:cekreklamemobile/core/services/update_version_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final UpdateVersionService versionService;
  final LoggerService _logger;

  UpdateService(this._dio, this.versionService, this._logger);

  Future<UpdateInfo?> getAvailableUpdate() async {
    try {
      // final jsonTestingUrl = dotenv.env['UPDATE_JSON_TESTING_URL'] ?? '';
      final jsonUrl = dotenv.env['UPDATE_JSON_URL'] ?? '';

      _logger.i("Checking update status");
      _logger.d("Update JSON URL: $jsonUrl");

      final response = await _dio.get(jsonUrl);

      _logger.d("Raw response: ${response.data}");

      Map<String, dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data);
      } else {
        data = Map<String, dynamic>.from(response.data);
      }

      final serverBuildNumber =
          int.tryParse(data['buildNumber'].toString()) ?? 0;

      _logger.d("Server build number: $serverBuildNumber");

      final hasUpdate = await versionService.isUpdateAvailable(
        serverBuildNumber,
      );

      if (hasUpdate) {
        _logger.w("New version found: ${data['versionName']}");

        return UpdateInfo(
          version: data['versionName'] ?? 'Unknown',
          changelog: data['changelog'] ?? '-',
          downloadUrl: data['url'] ?? '',
        );
      } else {
        _logger.i("App is up to date");
      }
    } catch (e, s) {
      _logger.e("Failed to get update info", e, s);
    }

    return null;
  }
}
