import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ota_update/ota_update.dart';
import 'update_progress_state.dart';

class UpdateProgressCubit extends Cubit<UpdateProgressState> {
  final String downloadUrl;
  final String version;

  UpdateProgressCubit({required this.downloadUrl, required this.version})
    : super(UpdateInitial());

  StreamSubscription<OtaEvent>? _otaSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _stuckTimer;

  double _lastProgress = -1;
  bool _isRetrying = false;

  /// Entry point
  void start() {
    if (Platform.isIOS) return;

    _startMonitoring();
    _startDownload();
  }

  // ================= MONITORING =================

  void _startMonitoring() {
    _connectivitySub?.cancel();
    _stuckTimer?.cancel();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        _emitError("Koneksi internet terputus.");
      }
    });

    _stuckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      final state = this.state;
      if (state is UpdateDownloading) {
        if (state.progress == _lastProgress &&
            state.progress < 0.99 &&
            state.progress > 0.0) {
          _emitError("Koneksi lambat (Timeout).");
        }
        _lastProgress = state.progress;
      }
    });
  }

  // ================= DOWNLOAD =================

  void _startDownload() {
    _otaSub?.cancel();

    try {
      _otaSub = OtaUpdate()
          .execute(
            downloadUrl,
            destinationFilename:
                'cek_reklame_v${version.replaceAll(" ", "_")}.apk',
          )
          .listen(
            _onOtaEvent,
            onError: (_) {
              _emitError("Terjadi kesalahan koneksi.");
            },
          );
    } catch (_) {
      _emitError("Gagal memulai unduhan.");
    }
  }

  void _onOtaEvent(OtaEvent event) {
    final raw = event.value ?? '0';
    final clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final percent = (double.tryParse(clean) ?? 0) / 100;

    switch (event.status) {
      case OtaStatus.DOWNLOADING:
        emit(
          UpdateDownloading(progress: percent, message: "Mengunduh: $clean%"),
        );
        break;

      case OtaStatus.INSTALLING:
        _disposeMonitoring();
        emit(const UpdateInstalling());

        Future.delayed(const Duration(seconds: 2), () {
          emit(const UpdateCompleted());
        });
        break;

      case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
        _emitError("Izin instalasi ditolak.");
        break;

      case OtaStatus.INTERNAL_ERROR:
        _emitError("Gagal mengunduh file.");
        break;

      default:
        break;
    }
  }

  // ================= ERROR & RETRY =================

  void _emitError(String message) {
    if (_isRetrying) return;

    _disposeMonitoring();
    emit(UpdateError(message: message));
  }

  Future<void> retry() async {
    _isRetrying = true;

    emit(
      const UpdateDownloading(
        progress: 0.0,
        message: "Menghubungkan kembali...",
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      _isRetrying = false;
      emit(const UpdateError(message: "Koneksi masih terputus."));
      return;
    }

    _isRetrying = false;
    _startMonitoring();
    _startDownload();
  }

  // ================= CLEANUP =================

  void _disposeMonitoring() {
    _otaSub?.cancel();
    _connectivitySub?.cancel();
    _stuckTimer?.cancel();
  }

  @override
  Future<void> close() {
    _disposeMonitoring();
    return super.close();
  }
}
