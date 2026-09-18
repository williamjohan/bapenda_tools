// lib/presentation/features/result/bloc/check_result_cubit.dart
import 'dart:io';
import 'package:bapendacore/core/errors/failure_messages_temp.dart';
import 'package:bapendacore/core/utils/image_utils.dart';
import 'package:bapendacore/domain/entities/billboard_entity.dart';
import 'package:bapendacore/domain/usecases/check_billboard_usecase.dart';
import 'package:bapendacore/domain/usecases/post_report_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'check_result_state.dart';

@injectable
class CheckResultCubit extends Cubit<CheckResultState> {
  final CheckBillboardUseCase checkBillboard;
  final PostReportUsecase postReport;
  List<BillboardEntity> _currentResults = [];

  CheckResultCubit(this.checkBillboard, this.postReport)
    : super(CheckResultInitial());

  Future<void> fetchResults({
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    if (isClosed) return;
    emit(CheckResultLoading());

    await Future.delayed(const Duration(milliseconds: 500));
    if (isClosed) return;

    try {
      File originalFile = File(imagePath);
      File compressedFile = await ImageUtils.compressImage(originalFile);
      if (isClosed) return;

      final String finalPath = compressedFile.path;

      final results = await checkBillboard.call(
        imagePath: finalPath,
        latitude: latitude,
        longitude: longitude,
        onProgress: (progress) {
          if (isClosed) return;
          emit(CheckResultLoading(progress: progress));
        },
      );
      _currentResults = results;
      if (isClosed) return;
      emit(CheckResultLoaded(results));
    } catch (e) {
      if (isClosed) return;
      emit(CheckResultError(_mapErrorToMessage(e)));
    }
  }

  Future<void> submitReport({
    required String imagePath,
    required double latitude,
    required double longitude,
    required int type,
    String? reklameId,
  }) async {
    emit(CheckResultReporting());

    await Future.delayed(const Duration(milliseconds: 500));
    try {
      File originalFile = File(imagePath);
      File compressedFile = await ImageUtils.compressImage(originalFile);
      final String finalPath = compressedFile.path;

      final isSuccess = await postReport.call(
        imagePath: finalPath,
        latitude: latitude,
        longitude: longitude,
        type: type,
      );

      if (isSuccess) {
        if (type == 2 && reklameId != null) {
          _markItemAsReported(reklameId);
        }
        emit(
          CheckResultReportSuccess(
            "Laporan berhasil terkirim. Terimakasih!",
            reportType: type,
          ),
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

  void backToResult() {
    emit(CheckResultLoaded(_currentResults));
  }

  Future<void> testingfetchResult({
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    // 1. MULAI LOADING (Simulasi Progress Jalan)
    emit(const CheckResultLoading(progress: 0.1)); // 10%
    await Future.delayed(const Duration(milliseconds: 500));

    emit(const CheckResultLoading(progress: 0.4)); // 40%
    await Future.delayed(const Duration(milliseconds: 500));

    emit(const CheckResultLoading(progress: 0.8)); // 80%
    await Future.delayed(const Duration(milliseconds: 500));
    // 2. SIAPKAN DATA DUMMY
    final List<BillboardEntity> dummyData = [
      // 1. DATA IDEAL (Aktif & Cocok)
      BillboardEntity(
        id: "MOCK-001",
        name: "503.05/2024/IKLAN-01",
        type: "Billboard / Papan",
        distance: 120.5,
        address: "Jl. Basuki Rahmat No. 10, Surabaya",
        score: 0.92, // 92% Kemiripan
        status: "Aktif",
        detailLocation: "Depan Toko Elektronik XYZ, menghadap jalan raya",
        isActive: true,
        isExpired: false,
        longitude: 112.737826,
        latitude: -7.257472,
        startDate: DateTime(2023, 1, 15),
        endDate: DateTime(2025, 1, 15),
        imageUrl:
            "https://images.unsplash.com/photo-1562077966-3d7c3b038827?w=400",
      ),

      // 2. DATA WARNING (Pajak Habis / Expired)
      BillboardEntity(
        id: "MOCK-002",
        name: "503.05/2023/LED-99",
        type: "Videotron / LED",
        distance: 45.2, // Lebih dekat
        address: "Jl. Tunjungan (Depan Hotel Majapahit)",
        score: 0.85,
        status:
            "Pajak Habis", // Status beda untuk testing UI warna merah/kuning
        detailLocation: "Samping pos polisi, arah utara",
        isActive: true, // Masih tayang tapi bermasalah administrasi
        isExpired: true, // Flag expired nyala
        longitude: 112.739100,
        latitude: -7.259200,
        startDate: DateTime(2022, 5, 20),
        endDate: DateTime(2023, 12, 31), // Sudah lewat
        imageUrl:
            "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400",
      ),

      // 3. DATA LOW SCORE / ILEGAL (Jarak Jauh / Tidak Sesuai)
      BillboardEntity(
        id: "MOCK-003",
        name: "UNKNOWN-8821",
        type: "Baliho / Kain",
        distance: 350.0, // Agak jauh
        address: "Jl. Embong Malang No. 88",
        score: 0.45, // Skor rendah (Mungkin salah deteksi)
        status: "Tidak Terdaftar",
        detailLocation: "Menempel di tiang listrik simpang empat",
        isActive: false,
        isExpired: false,
        longitude: 112.735500,
        latitude: -7.261000,
        startDate: DateTime(2020, 1, 1), // Data lama
        endDate: DateTime(2020, 2, 1),
        imageUrl:
            "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400",
      ),
    ];
    _currentResults = dummyData;
    // 3. EMIT LOADED (Langsung sukses menampilkan data dummy)
    emit(CheckResultLoaded(dummyData));
  }

  void _markItemAsReported(String id) {
    final updatedList = _currentResults.map((item) {
      if (item.id == id) {
        // Pastikan model Anda punya copyWith dan field isReported
        return item.copyWith(isReported: true);
      }
      return item;
    }).toList();

    _currentResults = updatedList; // Update variable memory
  }
}
