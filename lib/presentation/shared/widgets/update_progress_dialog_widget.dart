import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

class UpdateProgressDialogWidget extends StatefulWidget {
  final String downloadUrl;
  final String version;

  const UpdateProgressDialogWidget({
    super.key,
    required this.downloadUrl,
    required this.version,
  });

  static void show(
    BuildContext context, {
    required String downloadUrl,
    required String version,
  }) {
    // Guard iOS
    if (Platform.isIOS) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateProgressDialogWidget(
        downloadUrl: downloadUrl,
        version: version,
      ),
    );
  }

  @override
  State<UpdateProgressDialogWidget> createState() =>
      _UpdateProgressDialogWidgetState();
}

class _UpdateProgressDialogWidgetState
    extends State<UpdateProgressDialogWidget> {
  double _percent = 0.0;
  String _statusMessage = "Menghubungkan...";
  bool _isDownloading = true;

  @override
  void initState() {
    super.initState();
    _executeDownload();
  }

  Future<void> _executeDownload() async {
    try {
      OtaUpdate()
          .execute(
            widget.downloadUrl,
            // ✅ PASTIKAN AKHIRANNYA .apk (Penting untuk Android Installer)
            destinationFilename:
                'cek_reklame_v${widget.version.replaceAll(" ", "_")}.apk',
          )
          .listen(
            (OtaEvent event) {
              if (!mounted) return;

              setState(() {
                // 🛡️ ANTI CRASH: Parsing angka dengan Regex (Ambil angka saja)
                String rawValue = event.value ?? '0';
                String cleanValue = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleanValue.isEmpty) cleanValue = '0';

                // Update Status based on Event Code
                if (event.status == OtaStatus.DOWNLOADING) {
                  // Hitung persen (OtaUpdate biasanya return 0-100)
                  double progress = double.tryParse(cleanValue) ?? 0;
                  _percent = progress / 100;
                  _statusMessage = "Mengunduh: $cleanValue%";
                } else if (event.status == OtaStatus.INSTALLING) {
                  _statusMessage = "Membuka Installer...";
                  _percent = 1.0;
                  // Tutup dialog otomatis setelah delay sebentar
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });
                } else if (event.status ==
                    OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
                  _statusMessage = "Gagal: Izin instalasi belum diberikan.";
                  _isDownloading = false;
                } else if (event.status == OtaStatus.INTERNAL_ERROR) {
                  _statusMessage = "Gagal: Internal Error / File Corrupt.";
                  _isDownloading = false;
                }
              });
            },
            onError: (e) {
              if (mounted) {
                setState(() {
                  _statusMessage = "Error: $e";
                  _isDownloading = false;
                });
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "Exception: $e";
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope menggantikan WillPopScope di Flutter terbaru
    return PopScope(
      canPop: false, // User tidak bisa back tombol HP saat download
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.system_update_alt, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Update v${widget.version}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_statusMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _percent,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
        actions: [
          // Tombol tutup hanya muncul jika GAGAL / SELESAI
          if (!_isDownloading)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
        ],
      ),
    );
  }
}
