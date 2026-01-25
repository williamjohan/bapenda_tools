import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'app_logger_service.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final LoggerService logger;

  NetworkService(this.logger);

  /// Cek koneksi sekali jalan (untuk init)
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet)) {
        return true;
      }
      return false;
    } catch (e) {
      logger.e("Network check error", e, StackTrace.current);
      return false;
    }
  }

  /// Stream untuk memantau perubahan koneksi secara real-time
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((
      List<ConnectivityResult> results,
    ) {
      return results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
    });
  }
}
