// lib/di.dart
import 'dart:io';

import 'package:cekreklamemobile/core/services/map_service.dart';
import 'package:cekreklamemobile/domain/usecases/post_report_usecase.dart';
import 'package:cekreklamemobile/presentation/features/result/bloc/check_result_cubit.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
// 💡 Pastikan import ini benar (sesuai lokasi file Anda)
import 'data/datasources/billboard_remote_datasource.dart';
import 'data/repositories/billboard_repository_impl.dart';
import 'domain/repositories/billboard_repository.dart';
import 'domain/usecases/check_billboard_usecase.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // --- External Dependencies ---
  locator.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: const Duration(
          seconds: 15,
        ), // Naikkan sedikit untuk upload
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 20),
      ),
    );

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client
          .badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Hanya izinkan bypass jika host-nya adalah IP server Bapenda
        final baseUrl = dotenv.env['BASE_URL'] ?? '';
        if (baseUrl.contains(host)) {
          return true;
        }
        return false; // Tetap blokir jika mencoba ke domain lain yang sertifikatnya rusak
      };
      return client;
    };

    // Tambahkan Interceptor ke objek Dio, bukan ke BaseOptions
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  });

  // --- Data Layer ---
  // 1. Remote Data Source (butuh Dio)
  locator.registerLazySingleton<BillboardRemoteDataSource>(
    () => BillboardRemoteDataSource(locator<Dio>()),
  );

  // 2. Repository Implementasi (butuh Remote Data Source)
  locator.registerLazySingleton<BillboardRepository>(
    () => BillboardRepositoryImpl(locator<BillboardRemoteDataSource>()),
  );

  // --- Use Case Layer ---
  // 3. Use Case (butuh Repository)
  locator.registerLazySingleton<CheckBillboardUseCase>(
    () => CheckBillboardUseCase(locator()),
  );

  locator.registerLazySingleton<PostReportUsecase>(
    () => PostReportUsecase(locator<BillboardRepository>()),
  );

  // --- 4 Presentation Layer ---
  locator.registerFactory<CheckResultCubit>(
    () => CheckResultCubit(
      locator<CheckBillboardUseCase>(),
      locator<PostReportUsecase>(),
    ),
  );

  // --- 5 Core Services ---
  //
  locator.registerLazySingleton<MapService>(() => MapService());

  // ... (Tambahkan Cubit/Bloc di sini nanti)
}
