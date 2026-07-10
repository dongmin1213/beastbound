import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';

void main() {
  group('GameLogger', () {
    test('debug does not throw', () {
      expect(
        () => GameLogger.debug(LogSystem.core, 'test message'),
        returnsNormally,
      );
    });

    test('info does not throw', () {
      expect(
        () => GameLogger.info(LogSystem.core, 'test info'),
        returnsNormally,
      );
    });

    test('warning does not throw', () {
      expect(
        () => GameLogger.warning(LogSystem.core, 'test warning'),
        returnsNormally,
      );
    });

    test('error does not throw', () {
      expect(
        () => GameLogger.error(LogSystem.core, 'test error'),
        returnsNormally,
      );
    });

    test('error with cause does not throw', () {
      expect(
        () => GameLogger.error(LogSystem.core, 'test error', Exception('cause')),
        returnsNormally,
      );
    });

    test('all LogSystem values are valid', () {
      for (final system in LogSystem.values) {
        expect(
          () => GameLogger.warning(system, 'testing ${system.name}'),
          returnsNormally,
        );
      }
    });

    test('debug and info are guarded by kDebugMode', () {
      // In test environment, kDebugMode is true, so these should execute
      // This test documents the kDebugMode guard exists
      expect(kDebugMode, isTrue);
      expect(
        () => GameLogger.debug(LogSystem.core, 'debug in test'),
        returnsNormally,
      );
    });
  });
}
