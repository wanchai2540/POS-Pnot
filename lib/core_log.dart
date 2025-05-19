import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CoreLog {
  // Singleton instance
  static final CoreLog _instance = CoreLog._internal();
  factory CoreLog() => _instance;

  late final Logger _logger;

  CoreLog._internal() {
    if (kReleaseMode) {
      _logger = Logger(
        level: Level.warning,
        printer: SimplePrinter(),
      );
    } else {
      _logger = Logger(
        level: Level.trace,
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 5,
          lineLength: 100,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
    }
  }

  // Verbose
  void verbose(dynamic message) => _logger.v(message);

  // Debug
  void debug(dynamic message) => _logger.d(message);

  // Info
  void info(dynamic message) => _logger.i(message);

  // Warning
  void warning(dynamic message) => _logger.w(message);

  // Error
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
