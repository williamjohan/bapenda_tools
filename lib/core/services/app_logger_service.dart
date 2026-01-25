import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

abstract class LoggerService {
  void d(dynamic message);
  void i(dynamic message);
  void w(dynamic message);
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]);
}

class AppLoggerService implements LoggerService {
  final Logger _logger = Logger(
    level: kReleaseMode ? Level.warning : Level.debug,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  @override
  void d(message) => _logger.d(message);

  @override
  void i(message) => _logger.i(message);

  @override
  void w(message) => _logger.w(message);

  @override
  void e(message, [error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
