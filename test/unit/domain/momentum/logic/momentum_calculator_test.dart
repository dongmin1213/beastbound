import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/momentum/logic/momentum_calculator.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  const config = MomentumConfig();

  group('MomentumCalculator.calculateDelta', () {
    test('행동 전환 보너스: attack → defend → delta +12, reason actionSwitch', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.attack,
        currentAction: ActionType.defend,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 12);
      expect(delta.reason, MomentumChangeReason.actionSwitch);
    });

    test('행동 전환 보너스: defend → observe → delta +12', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.defend,
        currentAction: ActionType.observe,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 12);
      expect(delta.reason, MomentumChangeReason.actionSwitch);
    });

    test('2연속 같은 행동: attack → attack (consecutiveCount=1) → delta -15', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.attack,
        currentAction: ActionType.attack,
        consecutiveCount: 1,
        config: config,
      );

      expect(delta.value, -15);
      expect(delta.reason, MomentumChangeReason.sameAction);
    });

    test('3+연속 같은 행동: attack 3연속 (consecutiveCount=2) → delta -25', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.attack,
        currentAction: ActionType.attack,
        consecutiveCount: 2,
        config: config,
      );

      expect(delta.value, -25);
      expect(delta.reason, MomentumChangeReason.sameActionStreak);
    });

    test('첫 턴 (previousAction null) → delta 0, reason none', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: null,
        currentAction: ActionType.attack,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 0);
      expect(delta.reason, MomentumChangeReason.none);
    });

    test('커스텀 MomentumConfig 적용 확인', () {
      const customConfig = MomentumConfig(
        actionSwitchBonus: 25,
        sameActionPenalty: -5,
        sameActionStreakPenalty: -30,
      );

      final switchDelta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.attack,
        currentAction: ActionType.defend,
        consecutiveCount: 0,
        config: customConfig,
      );
      expect(switchDelta.value, 25);

      final sameDelta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.attack,
        currentAction: ActionType.attack,
        consecutiveCount: 1,
        config: customConfig,
      );
      expect(sameDelta.value, -5);

      final streakDelta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.attack,
        currentAction: ActionType.attack,
        consecutiveCount: 2,
        config: customConfig,
      );
      expect(streakDelta.value, -30);
    });
  });

  group('MomentumCalculator.calculateDelta — 환경 보너스', () {
    test('attack→environment 전환 시 +20 (environmentAction reason)', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.attack,
        currentAction: ActionType.environment,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 20);
      expect(delta.reason, MomentumChangeReason.environmentAction);
    });

    test('defend→environment 전환 시 +20', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.defend,
        currentAction: ActionType.environment,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 20);
      expect(delta.reason, MomentumChangeReason.environmentAction);
    });

    test('observe→environment 전환 시 +20', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.observe,
        currentAction: ActionType.environment,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 20);
      expect(delta.reason, MomentumChangeReason.environmentAction);
    });

    test('environment→attack 전환 시 +12 (일반 actionSwitch reason)', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.environment,
        currentAction: ActionType.attack,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 12);
      expect(delta.reason, MomentumChangeReason.actionSwitch);
    });

    test('environment→environment 2연속 시 -15 (sameAction reason)', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.environment,
        currentAction: ActionType.environment,
        consecutiveCount: 1,
        config: config,
      );

      expect(delta.value, -15);
      expect(delta.reason, MomentumChangeReason.sameAction);
    });

    test('environment→environment 3+연속 시 -25 (sameActionStreak reason)', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.environment,
        currentAction: ActionType.environment,
        consecutiveCount: 2,
        config: config,
      );

      expect(delta.value, -25);
      expect(delta.reason, MomentumChangeReason.sameActionStreak);
    });

    test('첫 턴 환경 행동 (previousAction null) → delta 0', () {
      final delta = MomentumCalculator.calculateDelta(
        previousAction: null,
        currentAction: ActionType.environment,
        consecutiveCount: 0,
        config: config,
      );

      expect(delta.value, 0);
      expect(delta.reason, MomentumChangeReason.none);
    });

    test('커스텀 config environmentMomentumBonus=0 시 delta 0 반환', () {
      const zeroConfig = MomentumConfig(environmentMomentumBonus: 0);
      final delta = MomentumCalculator.calculateDelta(
        previousAction: ActionType.attack,
        currentAction: ActionType.environment,
        consecutiveCount: 0,
        config: zeroConfig,
      );

      expect(delta.value, 0);
      expect(delta.reason, MomentumChangeReason.environmentAction);
    });
  });

  group('MomentumCalculator.applyDelta', () {
    test('applyDelta: 0 미만 클램핑 (momentum 5, delta -10 → 0)', () {
      const delta = MomentumDelta(
        value: -10,
        reason: MomentumChangeReason.sameAction,
      );
      expect(MomentumCalculator.applyDelta(5, delta, config), 0);
    });

    test('applyDelta: 100 초과 클램핑 (momentum 95, delta +15 → 100)', () {
      const delta = MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );
      expect(MomentumCalculator.applyDelta(95, delta, config), 100);
    });
  });

  group('MomentumCalculator.getTier', () {
    test('0 → low', () {
      expect(MomentumCalculator.getTier(0, config), MomentumTier.low);
    });

    test('30 → medium (thresholdMedium=30 기준)', () {
      expect(MomentumCalculator.getTier(30, config), MomentumTier.medium);
    });

    test('60 → medium', () {
      expect(MomentumCalculator.getTier(60, config), MomentumTier.medium);
    });

    test('80 → high', () {
      expect(MomentumCalculator.getTier(80, config), MomentumTier.high);
    });

    test('100 → high', () {
      expect(MomentumCalculator.getTier(100, config), MomentumTier.high);
    });

    test('임계값 경계 (29 → low, 30 → medium, 79 → medium)', () {
      expect(MomentumCalculator.getTier(29, config), MomentumTier.low);
      expect(MomentumCalculator.getTier(30, config), MomentumTier.medium);
      expect(MomentumCalculator.getTier(79, config), MomentumTier.medium);
    });
  });

  group('MomentumCalculator.calculateCardDelta', () {
    test('첫 턴 (previousCardType null) → delta 0, reason none', () {
      final delta = MomentumCalculator.calculateCardDelta(
        previousCardType: null,
        currentCardType: CardType.attack,
        config: config,
      );

      expect(delta.value, 0);
      expect(delta.reason, MomentumChangeReason.none);
    });

    test('같은 카드 유형 → delta 0, reason none (페널티 없음)', () {
      final delta = MomentumCalculator.calculateCardDelta(
        previousCardType: CardType.attack,
        currentCardType: CardType.attack,
        config: config,
      );

      expect(delta.value, 0);
      expect(delta.reason, MomentumChangeReason.none);
    });

    test('다른 카드 유형 → delta +12, reason cardTypeSwitch', () {
      final delta = MomentumCalculator.calculateCardDelta(
        previousCardType: CardType.attack,
        currentCardType: CardType.skill,
        config: config,
      );

      expect(delta.value, 12);
      expect(delta.reason, MomentumChangeReason.cardTypeSwitch);
    });

    test('같은 카드 유형 연속 플레이 → 페널티 없음 (항상 delta 0)', () {
      // 2연속
      final delta2 = MomentumCalculator.calculateCardDelta(
        previousCardType: CardType.skill,
        currentCardType: CardType.skill,
        config: config,
      );
      expect(delta2.value, 0);
      expect(delta2.reason, MomentumChangeReason.none);

      // 3연속 (calculateCardDelta는 stateless이므로 동일 결과)
      final delta3 = MomentumCalculator.calculateCardDelta(
        previousCardType: CardType.skill,
        currentCardType: CardType.skill,
        config: config,
      );
      expect(delta3.value, 0);
      expect(delta3.reason, MomentumChangeReason.none);
    });
  });
}
