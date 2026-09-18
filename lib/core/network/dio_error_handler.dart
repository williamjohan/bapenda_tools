import 'dart:io';
import 'package:dio/dio.dart';
import '../errors/exception.dart';
import '../utils/app_logger.dart';

class DioErrorHandler {
  static AppException handle(DioException e) {
    // 1. Identifikasi Timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      AppLogger.warning('⏳ Timeout saat mengakses: ${e.requestOptions.path}');
      return const TimeoutException();
    }

    // 2. Identifikasi Internet Mati
    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      AppLogger.warning(
        '🔌 Koneksi terputus saat mengakses: ${e.requestOptions.path}',
      );
      return const NoInternetException();
    }

    // 3. Kasus Khusus : Time Drift dari HmacSecurityInterceptor.
    if (e.type == DioExceptionType.badResponse && e.error is String) {
      final customError = e.error.toString();
      if (customError.contains('Waktu di perangkat Anda')) {
        return ServerException(e.response?.statusCode ?? 400, customError);
      }
    }

    // 4. Ekstrak Status Code & Pesan dari Backend
    final statusCode = e.response?.statusCode ?? 500;
    final responseData = e.response?.data;
    String? message;

    if (responseData is Map<String, dynamic>) {
      final dynamic errors = responseData['errors'];
      final String? title = responseData['title']?.toString();
      final String? legacyMessage = responseData['message']?.toString();

      if (errors != null) {
        if (errors is String && errors.isNotEmpty) {
          message = errors;
        } else if (errors is List && errors.isNotEmpty) {
          message = errors.join(', ');
        } else if (errors is Map && errors.isNotEmpty) {
          message = errors.values
              .map((v) => v is List ? v.join(', ') : v.toString())
              .join(' | ');
        }
      }

      message ??= title ?? legacyMessage;
    } else if (responseData is String) {
      // Pertahanan Anti-HTML (404, 502 Bad Gateway)
      message =
          'Server menolak request (Kode: $statusCode). Format respons tidak dikenali.';
    }

    message ??= e.message ?? 'Terjadi kesalahan tidak terduga dari server.';

    // 5. Kasus Khusus: Sesi Habis (401)
    if (statusCode == 401) {
      AppLogger.warning(
        '🔒 Sesi kadaluarsa (401) di endpoint: ${e.requestOptions.path}',
      );
      return const UnauthorizedException();
    }

    // 6. Logging Eksklusif
    AppLogger.error(
      '⛔ API Error [$statusCode] di endpoint: ${e.requestOptions.path}\nAlasan: $message',
      e,
      e.stackTrace,
    );

    return ServerException(statusCode, message);
  }
}
