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

      // Penanganan error yang lebih spesifik
      if (e is DioException) {
        errorMessage = "Kesalahan koneksi: ${e.message}";
      } else {
        errorMessage = e.toString().contains("Failed to check reklame")
            ? "API Error: Gagal mengunggah foto."
            : e.toString();
      }

      emit(CheckResultError(errorMessage));
    }
  }
}
