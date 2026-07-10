import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/error/game_error.dart';
import 'package:soul_dungeon/core/error/result.dart';

void main() {
  group('Result', () {
    test('Success holds data', () {
      const result = Success(42);
      expect(result.data, 42);
    });

    test('Failure holds GameError', () {
      const error = GameError(message: 'test error');
      final result = Failure<int>(error);
      expect(result.error.message, 'test error');
    });

    test('sealed class exhaustive switch works', () {
      final Result<int> result = const Success(10);
      final value = switch (result) {
        Success(:final data) => data,
        Failure() => -1,
      };
      expect(value, 10);
    });
  });

  group('GameError', () {
    test('default severity is recoverable', () {
      const error = GameError(message: 'test');
      expect(error.severity, ErrorSeverity.recoverable);
    });

    test('toString includes severity and system', () {
      const error = GameError(
        message: 'load failed',
        severity: ErrorSeverity.critical,
        system: 'save',
      );
      expect(error.toString(), contains('critical'));
      expect(error.toString(), contains('save'));
      expect(error.toString(), contains('load failed'));
    });
  });
}
