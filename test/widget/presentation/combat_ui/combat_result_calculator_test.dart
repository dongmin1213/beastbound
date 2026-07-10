import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_result_calculator.dart';

void main() {
  group('CombatResultCalculator', () {
    test('전체 effective → victory (score=양수)', () {
      final result = CombatResultCalculator.calculate(
        ['effective', 'effective', 'effective'],
      );
      expect(result.outcome, CombatOutcome.victory);
      expect(result.score, 3);
      expect(result.turnResults, ['effective', 'effective', 'effective']);
    });

    test('전체 ineffective → defeat (score=음수)', () {
      final result = CombatResultCalculator.calculate(
        ['ineffective', 'ineffective', 'ineffective'],
      );
      expect(result.outcome, CombatOutcome.defeat);
      expect(result.score, -3);
      expect(result.turnResults, ['ineffective', 'ineffective', 'ineffective']);
    });

    test('전체 neutral → victory (score=0)', () {
      final result = CombatResultCalculator.calculate(
        ['neutral', 'neutral', 'neutral'],
      );
      expect(result.outcome, CombatOutcome.victory);
      expect(result.score, 0);
    });

    test('2 effective + 1 ineffective → victory (score=+1)', () {
      final result = CombatResultCalculator.calculate(
        ['effective', 'effective', 'ineffective'],
      );
      expect(result.outcome, CombatOutcome.victory);
      expect(result.score, 1);
    });

    test('1 effective + 2 ineffective → defeat (score=-1)', () {
      final result = CombatResultCalculator.calculate(
        ['effective', 'ineffective', 'ineffective'],
      );
      expect(result.outcome, CombatOutcome.defeat);
      expect(result.score, -1);
    });

    test('1 effective + 1 neutral + 1 ineffective → victory (score=0)', () {
      final result = CombatResultCalculator.calculate(
        ['effective', 'neutral', 'ineffective'],
      );
      expect(result.outcome, CombatOutcome.victory);
      expect(result.score, 0);
    });

    test('빈 리스트 → victory (score=0)', () {
      final result = CombatResultCalculator.calculate([]);
      expect(result.outcome, CombatOutcome.victory);
      expect(result.score, 0);
      expect(result.turnResults, isEmpty);
    });
  });
}
