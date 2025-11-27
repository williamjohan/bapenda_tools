// lib/presentation/features/result/bloc/check_result_cubit.dart
import 'package:cekreklamemobile/domain/usecases/check_billboard_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'check_result_state.dart';

class CheckResultCubit extends Cubit<CheckResultState> {
  final CheckBillboardUseCase checkBillboard;

  CheckResultCubit(this.checkBillboard) : super(CheckResultInitial());

  Future<void> fetchResults({
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    emit(CheckResultLoading());
    try {
      final results = await checkBillboard.call(
        imagePath: imagePath,
        latitude: latitude,
        longitude: longitude,
      );

      emit(CheckResultLoaded(results));
    } catch (e) {
      String errorMessage = "Gagal mengambil data. Silakan coba lagi.";

      if (e is DioException) {
        // 🟢 KOREKSI: Pecah DioException berdasarkan Tipe
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = "Kesalahan Koneksi: Waktu koneksi habis (Timeout).";
            break;

          case DioExceptionType.badResponse:
            // 💡 Server merespons (misalnya 404, 500)
            final statusCode = e.response?.statusCode ?? 0;
            final statusMsg =
                e.response?.statusMessage ?? "Unknown Server Error";

            if (statusCode >= 500) {
              errorMessage =
                  "Server Error ($statusCode): Server sedang bermasalah.";
            } else if (statusCode >= 400) {
              errorMessage =
                  "Request Gagal ($statusCode): Format data salah atau tidak ditemukan.";
            } else {
              errorMessage = "Respon Buruk: $statusMsg";
            }
            break;

          case DioExceptionType.connectionError:
            errorMessage =
                "Kesalahan Jaringan: Tidak ada koneksi internet atau server tidak terjangkau.";
            break;

          case DioExceptionType.unknown:
          default:
            errorMessage =
                "Kesalahan Tidak Diketahui: Coba periksa alamat API. Detail: ${e.message}";
        }
      } else {
        // Penanganan error non-Dio (misalnya, Exception dari Domain/Repository Layer)
        errorMessage = e.toString().contains("Failed to check reklame")
            ? "Error I/O File: Gagal membaca/mengunggah foto." // Jika error dari remote_datasource
            : "Kesalahan Aplikasi Umum: ${e.toString()}";
      }

      emit(CheckResultError(errorMessage));
    }
  }
}
