import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cekreklamemobile/presentation/shared/widgets/custom_modal_widget.dart';
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
  // UI State
  double _percent = 0.0;
  String _statusMessage = "Menyiapkan unduhan...";

  // Logic State
  StreamSubscription<OtaEvent>? _otaSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _stuckTimer;
  double _lastPercent = -1.0;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _startDownloadProcess();
  }

  @override
  void dispose() {
    _disposeAllListeners();
    super.dispose();
  }

  void _disposeAllListeners() {
    _otaSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _stuckTimer?.cancel();
  }

  // Wrapper function untuk memulai proses bersih
  void _startDownloadProcess() {
    _startMonitoring();
    _executeDownload();
  }

  void _startMonitoring() {
    // Reset subscription lama jika ada
    _connectivitySubscription?.cancel();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      // 🛡️ GLITCH GUARD: Hanya error jika BENAR-BENAR none
      // Kadang saat switch data -> wifi, statusnya bisa none sebentar.
      // Kita validasi ulang.
      if (results.contains(ConnectivityResult.none)) {
        _handleError("Koneksi internet terputus.");
      }
    });

    // Reset timer stuck
    _stuckTimer?.cancel();
    _stuckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      // Logic timeout: Kalau persen gak naik-naik dalam 15 detik
      if (_percent == _lastPercent && _percent < 0.99 && _percent > 0.0) {
        _handleError("Koneksi lambat (Timeout).");
      } else {
        _lastPercent = _percent;
      }
    });
  }

  Future<void> _executeDownload() async {
    try {
      // Pastikan stream sebelumnya mati
      _otaSubscription?.cancel();

      _otaSubscription = OtaUpdate()
          .execute(
            widget.downloadUrl,
            destinationFilename:
                'cek_reklame_v${widget.version.replaceAll(" ", "_")}.apk',
          )
          .listen(
            (OtaEvent event) {
              if (!mounted) return;

              setState(() {
                String rawValue = event.value ?? '0';
                String cleanValue = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleanValue.isEmpty) cleanValue = '0';

                if (event.status == OtaStatus.DOWNLOADING) {
                  double progress = double.tryParse(cleanValue) ?? 0;
                  _percent = progress / 100;
                  _statusMessage = "Mengunduh: $cleanValue%";
                } else if (event.status == OtaStatus.INSTALLING) {
                  _statusMessage = "Memverifikasi & Menginstal...";
                  _percent = 1.0;
                  _disposeAllListeners(); // Stop monitoring saat install

                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });
                } else if (event.status ==
                    OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
                  _handleError("Izin instalasi ditolak.");
                } else if (event.status == OtaStatus.INTERNAL_ERROR) {
                  // Sering terjadi jika internet putus tiba-tiba
                  _handleError("Gagal mengunduh file.");
                }
              });
            },
            onError: (e) {
              // Error stream native
              _handleError("Terjadi kesalahan koneksi.");
            },
          );
    } catch (e) {
      _handleError("Gagal memulai unduhan.");
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    if (_isRetrying) return;

    // 1. Stop semua aktivitas, tapi JANGAN tutup dialog utama (Stacking Strategy)
    _disposeAllListeners();

    // 2. Munculkan Modal Error
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      // Reset flag retry
      _isRetrying = false;

      // Panggil Modal Error
      showConnectionErrorModal(
        context,
        onRetry: () {
          // 👇 FIX BUG 2 (GLITCH):
          // Set flag true agar logic 'dismiss' di bawah tidak tereksekusi
          _isRetrying = true;
          _performRetryLogic();
        },
      ).then((_) {
        // 👇 FIX BUG 1 (CANCEL STUCK):
        // Fungsi .then() ini jalan ketika Modal Error tertutup (baik via Close, Back, atau Retry).
        // Kita cek: Kalau tutupnya BUKAN karena tombol Retry, berarti User Cancel.
        if (!_isRetrying) {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      });
    });
  }

  // 👇 Logic Retry yang Lebih Aman (Anti Glitch)
  void _performRetryLogic() async {
    setState(() {
      _statusMessage = "Menghubungkan kembali...";
      _percent = 0.0;
      _lastPercent = -1.0;
    });

    // 🛡️ DELAY PENTING! (Fix Glitch)
    // Beri waktu 2 detik agar Network Stack HP stabil setelah data dinyalakan.
    // Tanpa ini, OtaUpdate sering gagal instan karena socket belum siap.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Cek koneksi manual sebelum start stream
    // Ini memastikan kita gak mulai download kalau ternyata internet masih mati
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Kalau pas retry ternyata masih mati, lempar error lagi
      _isRetrying = false; // Reset flag biar error modal bisa muncul lagi
      _handleError("Koneksi masih terputus.");
      return;
    }
    _isRetrying = false;
    _startDownloadProcess();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_download_rounded,
                size: 48,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Update v${widget.version}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _percent,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
