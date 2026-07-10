import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_calculator.dart';

void main() {
  const config = MomentumConfig();

  group('MomentumCalculator.calculateDelta', () {
    test('첫 턴 (previous null) → delta 0', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: null,
        currentAction: PlayerActionType.attack,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 0);
      expect(delta.reason, MomentumChangeReason.none);
    });

    test('행동 전환 보너스 (+12)', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: PlayerActionType.attack,
        currentAction: PlayerActionType.defend,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 12);
      expect(delta.reason, MomentumChangeReason.actionSwitch);
    });

    test('2연속 같은 행동 (-15)', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: PlayerActionType.attack,
        currentAction: PlayerActionType.attack,
        consecutiveCount: 1,
        config: config,
      );

      expect(delta.value, -15);
      expect(delta.reason, MomentumChangeReason.sameAction);
    });

    test('3+연속 같은 행동 (-25)', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: PlayerActionType.attack,
        currentAction: PlayerActionType.attack,
        consecutiveCount: 2,
        config: config,
      );

      expect(delta.value, -25);
      expect(delta.reason, MomentumChangeReason.sameActionStreak);
    });

    test('5연속도 3연속과 동일 페널티 (-25)', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: PlayerActionType.defend,
        currentAction: PlayerActionType.defend,
        consecutiveCount: 4,
        config: config,
      );

      expect(delta.value, -25);
      expect(delta.reason, MomentumChangeReason.sameActionStreak);
    });

    test('observe → attack 전환 보너스', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: PlayerActionType.observe,
        currentAction: PlayerActionType.attack,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 12);
      expect(delta.reason, MomentumChangeReason.actionSwitch);
    });

    test('커스텀 config 값 적용', () {
      const customConfig = MomentumConfig(
        actionSwitchBonus: 25,
        sameActionPenalty: -5,
        sameActionStreakPenalty: -30,
      );

      final switchDelta = MomentumCalculator.calculateDelta(
        previousAction: PlayerActionType.attack,
        currentAction: PlayerActionType.defend,
        consecutiveCount: 0,
        config: customConfig,
      );
      expect(switchDelta.value, 25);

      final sameDelta = MomentumCalculator.calculateDelta(
        previousAction: PlayerActionType.attack,
        currentAction: PlayerActionType.attack,
        consecutiveCount: 1,
        config: customConfig,
      );
      expect(sameDelta.value, -5);

      final streakDelta = MomentumCalculator.calculateDelta(
        previousAction: PlayerActionType.attack,
        currentAction: PlayerActionType.attack,
        consecutiveCount: 2,
        config: customConfig,
      );
      expect(streakDelta.value, -30);
    });
  });

  group('MomentumCalculator.applyDelta', () {
    test('기본 적용', () {
      final delta = const MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );
      expect(MomentumCalculator.applyDelta(30, delta, config), 45);
    });

    test('0 미만 클램핑', () {
      final delta = const MomentumDelta(
        value: -20,
        reason: MomentumChangeReason.sameActionStreak,
      );
      expect(MomentumCalculator.applyDelta(10, delta, config), 0);
    });

    test('100 초과 클램핑', () {
      final delta = const MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );
      expect(MomentumCalculator.applyDelta(95, delta, config), 100);
    });

    test('이미 0에서 페널티', () {
      final delta = const MomentumDelta(
        value: -10,
        reason: MomentumChangeReason.sameAction,
      );
      expect(MomentumCalculator.applyDelta(0, delta, config), 0);
    });

    test('이미 100에서 보너스', () {
      final delta = const MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );
      expect(MomentumCalculator.applyDelta(100, delta, config), 100);
    });

    test('delta 0 적용', () {
      final delta = const MomentumDelta(
        value: 0,
        reason: MomentumChangeReason.none,
      );
      expect(MomentumCalculator.applyDelta(50, delta, config), 50);
    });
  });

  group('MomentumCalculator.getTier', () {
    test('0 → low', () {
      expect(MomentumCalculator.getTier(0, config), MomentumTier.low);
    });

    test('29 → low', () {
      expect(MomentumCalculator.getTier(29, config), MomentumTier.low);
    });

    test('30 → medium (thresholdMedium=30)', () {
      expect(MomentumCalculator.getTier(30, config), MomentumTier.medium);
    });

    test('59 → medium', () {
      expect(MomentumCalculator.getTier(59, config), MomentumTier.medium);
    });

    test('60 → medium', () {
      expect(MomentumCalculator.getTier(60, config), MomentumTier.medium);
    });

    test('79 → medium', () {
      expect(MomentumCalculator.getTier(79, config), MomentumTier.medium);
    });

    test('80 → high', () {
      expect(MomentumCalculator.getTier(80, config), MomentumTier.high);
    });

    test('100 → high', () {
      expect(MomentumCalculator.getTier(100, config), MomentumTier.high);
    });

    test('커스텀 임계값', () {
      const customConfig = MomentumConfig(
        thresholdLow: 20,
        thresholdMedium: 40,
        thresholdHigh: 60,
      );

      expect(MomentumCalculator.getTier(19, customConfig), MomentumTier.low);
      expect(
          MomentumCalculator.getTier(40, customConfig), MomentumTier.medium);
      expect(MomentumCalculator.getTier(60, customConfig), MomentumTier.high);
    });
  });

  group('MomentumTier', () {
    test('displayName', () {
      expect(MomentumTier.low.displayName, '저');
      expect(MomentumTier.medium.displayName, '중');
      expect(MomentumTier.high.displayName, '고');
    });
  });

  group('MomentumDelta', () {
    test('value and reason', () {
      const delta = MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );
      expect(delta.value, 15);
      expect(delta.reason, MomentumChangeReason.actionSwitch);
    });
  });
}
