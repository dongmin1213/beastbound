import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/models/combat_turn_result.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/tier_effect.dart';

void main() {
  group('CombatTurnResult', () {
    test('기본 생성 및 필드 확인', () {
      const result = CombatTurnResult(
        turnNumber: 1,
        playerAction: ActionType.attack,
        enemyAction: EnemyActionType.observe,
        actionResult: ActionResult.effective,
      );

      expect(result.turnNumber, 1);
      expect(result.playerAction, ActionType.attack);
      expect(result.enemyAction, EnemyActionType.observe);
      expect(result.actionResult, ActionResult.effective);
      expect(result.tierEffect, isNull);
    });

    test('티어 효과 포함 생성', () {
      const tierEffect = TierModifiedResult(
        originalResult: ActionResult.effective,
        effectLevel: TierEffectLevel.enhanced,
        effectText: '기세가 공격을 강화한다!',
      );

      const result = CombatTurnResult(
        turnNumber: 2,
        playerAction: ActionType.defend,
        enemyAction: EnemyActionType.attack,
        actionResult: ActionResult.effective,
        tierEffect: tierEffect,
      );

      expect(result.tierEffect, isNotNull);
      expect(result.tierEffect!.effectLevel, TierEffectLevel.enhanced);
      expect(result.tierEffect!.effectText, '기세가 공격을 강화한다!');
    });

    test('Equatable 동등성', () {
      const a = CombatTurnResult(
        turnNumber: 1,
        playerAction: ActionType.attack,
        enemyAction: EnemyActionType.attack,
        actionResult: ActionResult.neutral,
      );
      const b = CombatTurnResult(
        turnNumber: 1,
        playerAction: ActionType.attack,
        enemyAction: EnemyActionType.attack,
        actionResult: ActionResult.neutral,
      );

      expect(a, equals(b));
    });
  });
}
