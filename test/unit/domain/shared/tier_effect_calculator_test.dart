import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/tier_effect.dart';
import 'package:soul_dungeon/core/models/tier_effect_calculator.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_calculator.dart';

void main() {
  // 기본 config (thresholds: low=30, medium=60, high=80)
  const config = MomentumConfig();
  const calculator = TierEffectCalculator(config: config);

  group('TierEffectCalculator — 9개 조합 테스트', () {
    // === High tier ===
    test('high × effective → enhanced + "결정적 일격!"', () {
      final result = calculator.calculate(MomentumTier.high, ActionResult.effective);
      expect(result.effectLevel, TierEffectLevel.enhanced);
      expect(result.effectText, '결정적 일격!');
      expect(result.originalResult, ActionResult.effective);
    });

    test('high × neutral → enhanced + "밀어붙인다!"', () {
      final result = calculator.calculate(MomentumTier.high, ActionResult.neutral);
      expect(result.effectLevel, TierEffectLevel.enhanced);
      expect(result.effectText, '밀어붙인다!');
      expect(result.originalResult, ActionResult.neutral);
    });

    test('high × ineffective → neutral + 효과 텍스트 없음', () {
      final result = calculator.calculate(MomentumTier.high, ActionResult.ineffective);
      expect(result.effectLevel, TierEffectLevel.neutral);
      expect(result.effectText, isNull);
      expect(result.originalResult, ActionResult.ineffective);
    });

    // === Medium tier ===
    test('medium × effective → neutral + 효과 텍스트 없음', () {
      final result = calculator.calculate(MomentumTier.medium, ActionResult.effective);
      expect(result.effectLevel, TierEffectLevel.neutral);
      expect(result.effectText, isNull);
    });

    test('medium × neutral → neutral + 효과 텍스트 없음', () {
      final result = calculator.calculate(MomentumTier.medium, ActionResult.neutral);
      expect(result.effectLevel, TierEffectLevel.neutral);
      expect(result.effectText, isNull);
    });

    test('medium × ineffective → neutral + 효과 텍스트 없음', () {
      final result = calculator.calculate(MomentumTier.medium, ActionResult.ineffective);
      expect(result.effectLevel, TierEffectLevel.neutral);
      expect(result.effectText, isNull);
    });

    // === Low tier ===
    test('low × effective → neutral + 효과 텍스트 없음 (페널티 없음)', () {
      final result = calculator.calculate(MomentumTier.low, ActionResult.effective);
      expect(result.effectLevel, TierEffectLevel.neutral);
      expect(result.effectText, isNull);
    });

    test('low × neutral → diminished + "적이 반격한다!"', () {
      final result = calculator.calculate(MomentumTier.low, ActionResult.neutral);
      expect(result.effectLevel, TierEffectLevel.diminished);
      expect(result.effectText, '적이 반격한다!');
    });

    test('low × ineffective → diminished + "힘이 빠진다..."', () {
      final result = calculator.calculate(MomentumTier.low, ActionResult.ineffective);
      expect(result.effectLevel, TierEffectLevel.diminished);
      expect(result.effectText, '힘이 빠진다...');
    });
  });

  group('TierEffectCalculator — 3개 경계값 테스트 (getTier 연동)', () {
    test('기세 정확히 30 → medium 티어 (thresholdMedium=30)', () {
      final tier = MomentumCalculator.getTier(30, config);
      expect(tier, MomentumTier.medium);
      final result = calculator.calculate(tier, ActionResult.ineffective);
      expect(result.effectLevel, TierEffectLevel.neutral);
      expect(result.effectText, isNull);
    });

    test('기세 정확히 60 → medium 티어, effective → neutral', () {
      final tier = MomentumCalculator.getTier(60, config);
      expect(tier, MomentumTier.medium);
      final result = calculator.calculate(tier, ActionResult.effective);
      expect(result.effectLevel, TierEffectLevel.neutral);
      expect(result.effectText, isNull);
    });

    test('기세 정확히 80 → high 티어, effective → enhanced', () {
      final tier = MomentumCalculator.getTier(80, config);
      expect(tier, MomentumTier.high);
      final result = calculator.calculate(tier, ActionResult.effective);
      expect(result.effectLevel, TierEffectLevel.enhanced);
      expect(result.effectText, '결정적 일격!');
    });
  });

  group('TierEffectCalculator — 2개 폴백 테스트', () {
    test('tier_effects 전체 누락 → 기본값 사용', () {
      // TierEffectConfig()는 기본값으로 생성됨
      final configNoTierEffects = MomentumConfig.fromJson(const {
        'initial_value': 0,
        'min': 0,
        'max': 100,
        'thresholds': {'low': 30, 'medium': 60, 'high': 80},
        // tier_effects 누락
      });
      final calc = TierEffectCalculator(config: configNoTierEffects);

      final result = calc.calculate(MomentumTier.high, ActionResult.effective);
      expect(result.effectLevel, TierEffectLevel.enhanced);
      expect(result.effectText, '결정적 일격!'); // 기본값
    });

    test('부분 누락 (high만 있고 low 없음) → low 기본값 사용', () {
      final configPartial = MomentumConfig.fromJson(const {
        'initial_value': 0,
        'min': 0,
        'max': 100,
        'thresholds': {'low': 30, 'medium': 60, 'high': 80},
        'tier_effects': {
          'high': {
            'effective_text': '커스텀 일격!',
            'neutral_text': '커스텀 밀어붙인다!',
          },
          // low 누락
        },
      });
      final calc = TierEffectCalculator(config: configPartial);

      // high는 커스텀 값 사용
      final highResult = calc.calculate(MomentumTier.high, ActionResult.effective);
      expect(highResult.effectText, '커스텀 일격!');

      // low는 기본값 폴백
      final lowResult = calc.calculate(MomentumTier.low, ActionResult.ineffective);
      expect(lowResult.effectText, '힘이 빠진다...'); // 기본값
    });
  });

  group('TierModifiedResult — Equatable', () {
    test('동일 값 → 동등', () {
      const a = TierModifiedResult(
        originalResult: ActionResult.effective,
        effectLevel: TierEffectLevel.enhanced,
        effectText: '결정적 일격!',
      );
      const b = TierModifiedResult(
        originalResult: ActionResult.effective,
        effectLevel: TierEffectLevel.enhanced,
        effectText: '결정적 일격!',
      );
      expect(a, equals(b));
    });

    test('다른 값 → 비동등', () {
      const a = TierModifiedResult(
        originalResult: ActionResult.effective,
        effectLevel: TierEffectLevel.enhanced,
        effectText: '결정적 일격!',
      );
      const b = TierModifiedResult(
        originalResult: ActionResult.neutral,
        effectLevel: TierEffectLevel.neutral,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
