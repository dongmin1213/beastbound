import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

enum LogSystem {
  core,
  combat,
  momentum,
  narrative,
  audio,
  hsm,
  save,
  input,
  ui,
  dungeon,
  progression,
}

class GameLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  GameLogger._();

  static void debug(LogSystem system, String message) {
    if (!kDebugMode) return;
    _logger.d('[${system.name}] $message');
  }

  static void info(LogSystem system, String message) {
    if (!kDebugMode) return;
    _logger.i('[${system.name}] $message');
  }

  static void warning(LogSystem system, String message) {
    if (!kDebugMode) return;
    _logger.w('[${system.name}] $message');
  }

  static void error(LogSystem system, String message, [Object? error]) {
    if (!kDebugMode) return;
    _logger.e('[${system.name}] $message', error: error);
  }
}
