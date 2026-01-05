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
    emit(CheckResultReporting()); // Tampilkan loading khusus lapor

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
          return FailureMessages.noInternet;

        default:
          debugPrint("Dio Error Detail: ${e.message}");
          debugPrint("Dio Error Type: ${e.type}");
          return FailureMessages.unknownError;
      }
    }
    // Jika error terjadi di level pemrosesan file
    if (e.toString().contains("Failed") || e.toString().contains("File")) {
      return FailureMessages.fileProcessError;
    }

    return FailureMessages.unknownError;
  }
}
