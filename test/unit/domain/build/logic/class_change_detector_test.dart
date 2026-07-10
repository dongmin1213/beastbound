import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/build/logic/class_change_detector.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

void main() {
  const config = BuildConfig(
    classChangeThreshold: 5,
    wandererMinTotal: 10,
    wandererMaxDeviation: 2,
  );

  Map<DispositionAxis, int> makeDisposition({
    int struggle = 0,
    int mercy = 0,
    int wisdom = 0,
    int shadow = 0,
    int will = 0,
    int harmony = 0,
  }) =>
      {
        DispositionAxis.struggle: struggle,
        DispositionAxis.mercy: mercy,
        DispositionAxis.wisdom: wisdom,
        DispositionAxis.shadow: shadow,
        DispositionAxis.will: will,
        DispositionAxis.harmony: harmony,
      };

  group('ClassChangeDetector', () {
    test('single axis >= threshold returns corresponding job', () {
      final result = ClassChangeDetector.evaluate(
        makeDisposition(struggle: 6),
        config,
      );
      expect(result, isA<Warrior>());
    });

    test('all axes below threshold returns null', () {
      final result = ClassChangeDetector.evaluate(
        makeDisposition(struggle: 3, mercy: 3, wisdom: 2),
        config,
      );
      expect(result, isNull);
    });

    test('exactly threshold returns corresponding job', () {
      final result = ClassChangeDetector.evaluate(
        makeDisposition(mercy: 5),
        config,
      );
      expect(result, isA<Saint>());
    });

    test('multi-axis simultaneous threshold returns JobPath.values order priority', () {
      // struggle(5) + mercy(5) → Warrior (JobPath.values에서 먼저)
      final result = ClassChangeDetector.evaluate(
        makeDisposition(struggle: 5, mercy: 5),
        config,
      );
      expect(result, isA<Warrior>());
    });

    test('wanderer condition met returns Wanderer', () {
      // 5축 non-zero: struggle:3, mercy:3, wisdom:2, shadow:2, will:2
      // total=12>=10, nonZero=5>=3, deviation=3-2=1<=2
      // 단일 축 threshold(5) 미만이므로 방랑자 조건 체크
      final result = ClassChangeDetector.evaluate(
        makeDisposition(struggle: 3, mercy: 3, wisdom: 2, shadow: 2, will: 2),
        config,
      );
      expect(result, isA<Wanderer>());
    });

    test('wanderer total below minimum returns null', () {
      // total=6<10
      final result = ClassChangeDetector.evaluate(
        makeDisposition(struggle: 2, mercy: 2, wisdom: 2),
        config,
      );
      expect(result, isNull);
    });

    test('wanderer deviation exceeds maximum returns null', () {
      // struggle:4, mercy:1 → deviation=4-1=3>2
      final result = ClassChangeDetector.evaluate(
        makeDisposition(struggle: 4, mercy: 1, wisdom: 2, shadow: 2, will: 2),
        config,
      );
      expect(result, isNull);
    });

    test('wanderer non-zero axes less than 3 returns null', () {
      // only 2 non-zero axes, both below threshold
      final result = ClassChangeDetector.evaluate(
        makeDisposition(struggle: 4, mercy: 4),
        config,
      );
      expect(result, isNull);
    });
  });
}
