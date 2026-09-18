import 'dart:io';
import 'package:cekreklamemobile/core/services/app_logger_service.dart';
import 'package:cekreklamemobile/core/services/location_service.dart';
import 'package:cekreklamemobile/core/services/map_service.dart';
import 'package:cekreklamemobile/core/services/network_service.dart';
import 'package:cekreklamemobile/core/services/permission_service.dart';
import 'package:cekreklamemobile/core/services/update_service.dart';
import 'package:cekreklamemobile/core/services/update_version_service.dart';
import 'package:cekreklamemobile/core/network/auth_interceptor.dart';
import 'package:cekreklamemobile/data/datasources/auth/auth_local_datasource.dart';
import 'package:cekreklamemobile/data/datasources/auth/auth_remote_datasource.dart';
import 'package:cekreklamemobile/data/repositories/auth/auth_repository_impl.dart';
import 'package:cekreklamemobile/domain/repositories/auth/auth_repository.dart'; 
import 'package:cekreklamemobile/domain/usecases/auth/auth_usecase.dart';
import 'package:cekreklamemobile/presentation/features/auth/cubit/auth_cubit.dart'; 
import 'package:cekreklamemobile/domain/usecases/post_report_usecase.dart';
import 'package:cekreklamemobile/presentation/features/home/cubit/home_cubit.dart';
import 'package:cekreklamemobile/presentation/features/home/cubit/nearby_cubit.dart';
import 'package:cekreklamemobile/presentation/features/result/cubit/check_result_cubit.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/billboard_remote_datasource.dart';
import 'data/repositories/billboard_repository_impl.dart';
import 'domain/repositories/billboard_repository.dart';
import 'domain/usecases/check_billboard_usecase.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // =========================
  // AUTH
  // =========================
  locator.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSource());

  /// =========================
  //  External Libraries
  // =========================
  locator.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 45),
      ),
    );

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
            final baseUrl = dotenv.env['BASE_URL'] ?? '';
            if (baseUrl.contains(host)) return true;
            if (host.contains("drivebapenda.surabaya.go.id")) return true;
            return false;
          };
      return client;
    };

    dio.interceptors.add(AuthInterceptor(locator<AuthLocalDataSource>()));

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: (obj) => locator<LoggerService>().d(obj),
        retries: 3,
        retryDelays: const [
          Duration(seconds: 2),
          Duration(seconds: 5),
          Duration(seconds: 10),
        ],
        retryableExtraStatuses: {status408RequestTimeout},
      ),
    );

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

    if (kDebugMode) {
      dio.interceptors.add(ChuckerDioInterceptor());
    }

    return dio;
  });

  // =========================
  // 1. Data Source Layer
  // =========================
  locator.registerLazySingleton<BillboardRemoteDataSource>(
    () => BillboardRemoteDataSource(locator<Dio>()),
  );
  locator.registerLazySingleton<AuthRemoteDataSource>( 
    () => AuthRemoteDataSource(locator<Dio>()),
  );

  // =========================
  // 2. Repository Layer
  // =========================
  locator.registerLazySingleton<BillboardRepository>(
    () => BillboardRepositoryImpl(locator<BillboardRemoteDataSource>()),
  );
  locator.registerLazySingleton<AuthRepository>( 
    () => AuthRepositoryImpl(
      locator<AuthRemoteDataSource>(),
      locator<AuthLocalDataSource>(),
    ),
  );

  // =========================
  // 3. Use Case Layer
  // =========================
  locator.registerLazySingleton<CheckBillboardUseCase>(
    () => CheckBillboardUseCase(locator()),
  );
  locator.registerLazySingleton<PostReportUsecase>(
    () => PostReportUsecase(locator<BillboardRepository>()),
  );
  locator.registerLazySingleton<AuthUseCase>( 
    () => AuthUseCase(locator<AuthRepository>()),
  );

  // =========================
  // 4. Core Services
  // =========================
  locator.registerLazySingleton<LoggerService>(() => AppLoggerService());
  locator.registerLazySingleton<LocationService>(
    () => LocationService(locator<LoggerService>()),
  );
  locator.registerLazySingleton<MapService>(
    () => MapService(locator<LoggerService>()),
  );
  locator.registerLazySingleton<UpdateVersionService>(
    () => UpdateVersionService(locator<LoggerService>()),
  );
  locator.registerLazySingleton<PermissionService>(
    () => PermissionService(locator<LoggerService>()),
  );
  locator.registerLazySingleton<NetworkService>(
    () => NetworkService(locator<LoggerService>()),
  );
  locator.registerLazySingleton<UpdateService>(
    () => UpdateService(
      locator<Dio>(),
      locator<UpdateVersionService>(),
      locator<LoggerService>(),
    ),
  );

  // =========================
  // 5. PRESENTATION LAYER
  // =========================
  locator.registerFactory<CheckResultCubit>(
    () => CheckResultCubit(
      locator<CheckBillboardUseCase>(),
      locator<PostReportUsecase>(),
    ),
  );
  locator.registerFactory<HomeCubit>(
    () => HomeCubit(
      updateService: locator<UpdateService>(),
      permissionService: locator<PermissionService>(),
      locationService: locator<LocationService>(),
      logger: locator<LoggerService>(),
    ),
  );
  locator.registerFactory<NearbyCubit>(
    () => NearbyCubit(
      mapService: locator<MapService>(),
      networkService: locator<NetworkService>(),
    ),
  );

  locator.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authUseCase: locator<AuthUseCase>(),
      logger: locator<LoggerService>(),
    ),
  );
}