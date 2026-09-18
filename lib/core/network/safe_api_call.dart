import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../errors/exception.dart';
import '../errors/failure.dart';
import '../utils/app_logger.dart';
import 'dio_error_handler.dart';

Future<Either<Failure, T>> executeSafeApiCall<T>(
  Future<T> Function() action,
) async {
  try {
    // Jalankan aksi dari Repository (yang memanggil DataSource)
    final result = await action();
    return Right(result);
  } on DioException catch (e) {
    // Ubah menjadi AppException menggunakan DioErrorHandler kita
    final appException = DioErrorHandler.handle(e);
    return _mapExceptionToFailure(appException);
  } on AppException catch (e) {
    return _mapExceptionToFailure(e);
  } catch (e, stackTrace) {
    AppLogger.error(
      '❌ Terjadi kesalahan fatal tak terduga (Non-HTTP/Non-App)',
      e,
      stackTrace,
    );
    return const Left(UnknownFailure());
  }
}

/// Helper privat agar pemetaan Failure konsisten & bersih
Either<Failure, T> _mapExceptionToFailure<T>(AppException e) {
  if (e is ServerException) {
    AppLogger.warning(
      '⚠️ API Business Failure (${e.statusCode}): ${e.message}',
    );
    return Left(ServerFailure(e.message));
  } else if (e is UnauthorizedException) {
    AppLogger.warning('⚠️ API Failure: Kredensial/Token tidak valid (401)');
    return Left(UnauthorizedFailure());
  } else if (e is TimeoutException) {
    return Left(TimeoutFailure());
  } else if (e is NoInternetException) {
    return Left(NoInternetFailure());
  }
  return const Left(UnknownFailure());
}
