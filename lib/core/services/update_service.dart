import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../utils/update_utils.dart';
import '../../presentation/shared/widgets/update_progress_dialog_widget.dart';

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

  // URL JSON (Pastikan Direct Download / Raw)
  final String _jsonUrl =
      "https://drivebapenda.surabaya.go.id/s/JHs8ksmt2HqxoRJ/download";

  UpdateService(this._dio);

  // 1. FUNGSI CEK UPDATE (Mengembalikan Data atau Null)
  Future<UpdateInfo?> getAvailableUpdate() async {
    try {
      print("🔍 Checking update status: $_jsonUrl");
      final response = await _dio.get(_jsonUrl);

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

  // 2. FUNGSI TAMPILKAN DIALOG (Satu-satunya method dialog)
  void showUpdateDialog(BuildContext context, UpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Update Tersedia v${info.version}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Versi baru tersedia. Mohon update aplikasi."),
              const SizedBox(height: 10),
              const Text(
                "Apa yang baru:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(info.changelog),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Nanti",
              style: TextStyle(color: Color(0xFF175CFF)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog konfirmasi

              // Panggil Widget Download yang sudah kita fix sebelumnya
              UpdateProgressDialogWidget.show(
                context,
                downloadUrl: info.downloadUrl,
                version: info.version,
              );
            },
            child: const Text("Update Sekarang"),
          ),
        ],
      ),
    );
  }
}
