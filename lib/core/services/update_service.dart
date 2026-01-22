import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../utils/update_utils.dart';
import '../../presentation/shared/widgets/update_progress_dialog_widget.dart'; // Import Widget Lama Anda

class UpdateService {
  final Dio _dio;

  // URL JSON Anda
  final String _jsonUrl =
      "https://drivebapenda.surabaya.go.id/s/JHs8ksmt2HqxoRJ/download";

  UpdateService(this._dio);

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      print("🔍 Memeriksa update ke: $_jsonUrl");
      final response = await _dio.get(_jsonUrl);

      Map<String, dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data);
      } else {
        data = Map<String, dynamic>.from(response.data);
      }

      int serverBuildNumber = int.tryParse(data['buildNumber'].toString()) ?? 0;
      String serverVersionName = data['versionName'] ?? '';
      String apkUrl = data['url'] ?? '';
      String changelog = data['changelog'] ?? '';

      bool hasUpdate = await UpdateUtils.isUpdateAvailable(serverBuildNumber);

      if (hasUpdate && context.mounted) {
        // Jika ada update, tampilkan Dialog Konfirmasi Dulu
        _showUpdateDialog(context, serverVersionName, changelog, apkUrl);
      } else {
        print("✅ Aplikasi sudah versi terbaru.");
      }
    } catch (e) {
      print("❌ Gagal cek update: $e");
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    String version,
    String log,
    String downloadUrl,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Update Tersedia v$version"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Versi baru tersedia. Mohon update aplikasi."),
              const SizedBox(height: 10),
              const Text(
                "Change Log:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(log),
            ],
          ),
        ),
        actions: [
          // Tombol Nanti (Optional)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Nanti"),
          ),
          // Tombol Update
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog konfirmasi

              // 👇 PANGGIL WIDGET LAMA ANDA DISINI 👇
              // Widget ini yang akan handle download, permission, dan install.
              UpdateProgressDialogWidget.show(
                context,
                downloadUrl: downloadUrl,
                version: version,
              );
            },
            child: const Text("Update Sekarang"),
          ),
        ],
      ),
    );
  }
}
