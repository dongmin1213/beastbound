import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/clock/clock.dart';

void main() {
  group('SystemClock', () {
    late SystemClock clock;

    setUp(() {
      clock = const SystemClock();
    });

    test('now returns current time', () {
      final before = DateTime.now();
      final now = clock.now();
      final after = DateTime.now();

      expect(now.isAfter(before) || now.isAtSameMomentAs(before), isTrue);
      expect(now.isBefore(after) || now.isAtSameMomentAs(after), isTrue);
    });

    test('elapsed returns non-negative duration', () {
      final from = clock.now();
      final elapsed = clock.elapsed(from);

      expect(elapsed.inMicroseconds, greaterThanOrEqualTo(0));
    });

    test('elapsed increases over time', () {
      final from = DateTime.now().subtract(const Duration(seconds: 1));
      final elapsed = clock.elapsed(from);

      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(900));
    });
  });

  group('GameClock interface', () {
    test('SystemClock implements GameClock', () {
      const GameClock clock = SystemClock();
      expect(clock, isA<GameClock>());
    });
  });
}
