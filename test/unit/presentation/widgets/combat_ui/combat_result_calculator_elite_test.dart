import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_result_calculator.dart';

void main() {
  group('CombatResultCalculator elite victoryThreshold', () {
    test('score=0 with threshold=1 → defeat (엘리트 무승부 불허)', () {
      final result = CombatResultCalculator.calculate(
        ['effective', 'neutral', 'ineffective', 'neutral', 'neutral'],
        victoryThreshold: 1,
      );
      expect(result.score, 0);
      expect(result.outcome, CombatOutcome.defeat);
    });

    test('score=1 with threshold=1 → victory (엘리트 최소 승리)', () {
      final result = CombatResultCalculator.calculate(
        ['effective', 'effective', 'ineffective', 'neutral', 'neutral'],
        victoryThreshold: 1,
      );
      expect(result.score, 1);
      expect(result.outcome, CombatOutcome.victory);
    });

    test('score=2 with threshold=1 → victory (엘리트 확실한 승리)', () {
      final result = CombatResultCalculator.calculate(
        ['effective', 'effective', 'effective', 'ineffective', 'neutral'],
        victoryThreshold: 1,
      );
      expect(result.score, 2);
      expect(result.outcome, CombatOutcome.victory);
    });

    test('default threshold=0 preserves existing behavior', () {
      final result = CombatResultCalculator.calculate(
        ['effective', 'neutral', 'ineffective'],
      );
      expect(result.score, 0);
      expect(result.outcome, CombatOutcome.victory);
    });
  });
}
