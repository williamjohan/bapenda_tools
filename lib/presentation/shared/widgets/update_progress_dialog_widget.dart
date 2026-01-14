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
    // 🛑 iOS Guard
    if (Platform.isIOS) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Update Tidak Tersedia"),
          content: const Text("Pembaruan iOS hanya via AppStore/TestFlight."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

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
      // 🚀 OTA UPDATE MAGIC
      // Library ini otomatis menangani Download -> Notification -> Install Intent
      OtaUpdate()
          .execute(
        widget.downloadUrl,
        destinationFilename:
            'cek_reklame_v${widget.version.replaceAll(" ", "_")}.apk',
      )
          .listen((OtaEvent event) {
        if (mounted) {
          setState(() {
            // Update Progress
            if (event.value != null && event.value!.isNotEmpty) {
              // Kadang return value string, kita parsing ke int
              try {
                _percent = int.parse(event.value!) / 100;
                _statusMessage = "Mengunduh: ${event.value}%";
              } catch (e) {
                _percent = 0;
              }
            }

            // Handle Status
            if (event.status == OtaStatus.DOWNLOADING) {
              // Sedang download...
            } else if (event.status == OtaStatus.INSTALLING) {
              _statusMessage = "Menginstall...";
              _percent = 1.0;
              // Biasanya setelah ini UI akan tertutup oleh installer Android
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) Navigator.pop(context);
              });
            } else if (event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
              _statusMessage = "Gagal: Izin tidak diberikan.";
              _isDownloading = false;
            } else if (event.status == OtaStatus.INTERNAL_ERROR) {
              _statusMessage = "Gagal: Internal Error.";
              _isDownloading = false;
            }
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "Terjadi Kesalahan: $e";
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Pengganti WillPopScope
      canPop: false,
      child: AlertDialog(
        title: Text("Update Versi ${widget.version}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.system_update_alt, size: 50, color: Colors.blue),
            const SizedBox(height: 16),
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
