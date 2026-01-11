// lib/presentation/features/result/bloc/check_result_cubit.dart
import 'package:cekreklamemobile/core/errors/failures.dart';
import 'package:cekreklamemobile/domain/usecases/check_billboard_usecase.dart';
import 'package:cekreklamemobile/domain/usecases/post_report_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'check_result_state.dart';

class CheckResultCubit extends Cubit<CheckResultState> {
  final CheckBillboardUseCase checkBillboard;
  final PostReportUsecase postReport;

  CheckResultCubit(this.checkBillboard, this.postReport)
    : super(CheckResultInitial());

  Future<void> fetchResults({
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    emit(CheckResultLoading());

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final results = await checkBillboard.call(
        imagePath: imagePath,
        latitude: latitude,
        longitude: longitude,
        onProgress: (progress) {
          emit(CheckResultLoading(progress: progress));
        },
      );

      emit(CheckResultLoaded(results));
    } catch (e) {
      emit(CheckResultError(_mapErrorToMessage(e)));
    }
  }

  Future<void> submitReport({
    required String imagePath,
    required double latitude,
    required double longitude,
    required int type,
  }) async {
    emit(CheckResultReporting());

    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final isSuccess = await postReport.call(
        imagePath: imagePath,
        latitude: latitude,
        longitude: longitude,
        type: type,
      );

      if (isSuccess) {
        emit(
          CheckResultReportSuccess("Laporan berhasil terkirim. Terimakasih!"),
        );
      } else {
        emit(
          CheckResultReportError("Gagal mengirim laporan. Coba lagi nanti."),
        );
      }
    } catch (e) {
      emit(CheckResultReportError(_mapErrorToMessage(e)));
    }
  }

  String _mapErrorToMessage(dynamic e) {
    if (e is DioException) {
      // Log detail untuk mempermudah debugging saat di lapangan
      debugPrint("🚨 Dio Error: [${e.type}] ${e.message}");
      if (e.response != null) {
        debugPrint("🚨 Data: ${e.response?.data}");
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return FailureMessages.connectionTimeout;

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode >= 500) return FailureMessages.serverError;
          return FailureMessages.badRequest;

        case DioExceptionType.connectionError:
          if (e.message?.contains("HandshakeException") ?? false) {
            return FailureMessages.sslError;
          }
          return FailureMessages.noInternet;

        default:
          if (e.message?.contains("SocketException") ?? false) {
            return FailureMessages.noInternet;
          }
          return FailureMessages.unknownError;
      }
    }

    // KHUSUS ERROR FILE: spesifik agar tidak bentrok dengan error network
    final errorStr = e.toString();
    if (errorStr.contains("FileSystemException") ||
        (errorStr.contains("File") && errorStr.contains("copy"))) {
      return FailureMessages.fileProcessError;
    }

    return FailureMessages.unknownError;
  }
}
