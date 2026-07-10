import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/action_interaction.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

void main() {
  group('ActionInteraction.getResult — 9개 조합 결과 등급', () {
    test('공격 vs 공격 → neutral', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.attack, EnemyActionType.attack),
        ActionResult.neutral,
      );
    });

    test('공격 vs 방어 → ineffective', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.attack, EnemyActionType.defend),
        ActionResult.ineffective,
      );
    });

    test('공격 vs 관찰 → effective', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.attack, EnemyActionType.observe),
        ActionResult.effective,
      );
    });

    test('방어 vs 공격 → effective', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.defend, EnemyActionType.attack),
        ActionResult.effective,
      );
    });

    test('방어 vs 방어 → neutral', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.defend, EnemyActionType.defend),
        ActionResult.neutral,
      );
    });

    test('방어 vs 관찰 → ineffective', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.defend, EnemyActionType.observe),
        ActionResult.ineffective,
      );
    });

    test('관찰 vs 공격 → ineffective', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.observe, EnemyActionType.attack),
        ActionResult.ineffective,
      );
    });

    test('관찰 vs 방어 → neutral', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.observe, EnemyActionType.defend),
        ActionResult.neutral,
      );
    });

    test('관찰 vs 관찰 → effective', () {
      expect(
        ActionInteraction.getResult(
            PlayerActionType.observe, EnemyActionType.observe),
        ActionResult.effective,
      );
    });
  });

  group('ActionInteraction.getResultText — 9개 조합 텍스트', () {
    test('공격 vs 공격 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.attack, EnemyActionType.attack),
        '양쪽의 공격이 맞부딪힌다!',
      );
    });

    test('공격 vs 방어 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.attack, EnemyActionType.defend),
        '적의 방어에 공격이 막힌다.',
      );
    });

    test('공격 vs 관찰 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.attack, EnemyActionType.observe),
        '무방비 상태의 적에게 강한 일격을 날렸다!',
      );
    });

    test('방어 vs 공격 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.defend, EnemyActionType.attack),
        '적의 공격을 견고히 막아냈다!',
      );
    });

    test('방어 vs 방어 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.defend, EnemyActionType.defend),
        '양쪽 모두 방어 자세로 대치한다.',
      );
    });

    test('방어 vs 관찰 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.defend, EnemyActionType.observe),
        '적이 관찰하는데 방어만 하고 있다...',
      );
    });

    test('관찰 vs 공격 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.observe, EnemyActionType.attack),
        '적의 공격에 맞으며 관찰한다... 아프다.',
      );
    });

    test('관찰 vs 방어 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.observe, EnemyActionType.defend),
        '방어 중인 적을 안전하게 관찰한다.',
      );
    });

    test('관찰 vs 관찰 결과 텍스트', () {
      expect(
        ActionInteraction.getResultText(
            PlayerActionType.observe, EnemyActionType.observe),
        '서로 관찰하며 깊은 통찰을 얻었다!',
      );
    });
  });

  group('ActionInteraction.getResultText — 모든 텍스트가 비어있지 않음', () {
    for (final player in PlayerActionType.values) {
      for (final enemy in EnemyActionType.values) {
        test('${player.name} vs ${enemy.name} → 비어있지 않은 텍스트', () {
          final text = ActionInteraction.getResultText(player, enemy);
          expect(text, isNotEmpty);
        });
      }
    }
  });

  group('ActionInteraction.getResultPrefix', () {
    test('effective → ✦ 접두사', () {
      expect(
          ActionInteraction.getResultPrefix(ActionResult.effective), '✦ ');
    });

    test('neutral → - 접두사', () {
      expect(ActionInteraction.getResultPrefix(ActionResult.neutral), '- ');
    });

    test('ineffective → ✧ 접두사', () {
      expect(ActionInteraction.getResultPrefix(ActionResult.ineffective),
          '✧ ');
    });
  });

  group('PlayerActionType', () {
    test('attack prefix', () {
      expect(PlayerActionType.attack.prefix, '⚔ ');
    });

    test('defend prefix', () {
      expect(PlayerActionType.defend.prefix, '🛡 ');
    });

    test('observe prefix', () {
      expect(PlayerActionType.observe.prefix, '👁 ');
    });

    test('5개 행동 유형 존재', () {
      expect(PlayerActionType.values, hasLength(5));
    });
  });

  group('ActionResult 매트릭스 대칭 검증', () {
    test('effective 결과 21개 존재 (기존 7 + environment×7 + special×7)', () {
      var count = 0;
      for (final player in PlayerActionType.values) {
        for (final enemy in EnemyActionType.values) {
          if (ActionInteraction.getResult(player, enemy) ==
              ActionResult.effective) {
            count++;
          }
        }
      }
      expect(count, 21);
    });

    test('neutral 결과 10개 존재', () {
      var count = 0;
      for (final player in PlayerActionType.values) {
        for (final enemy in EnemyActionType.values) {
          if (ActionInteraction.getResult(player, enemy) ==
              ActionResult.neutral) {
            count++;
          }
        }
      }
      expect(count, 10);
    });

    test('ineffective 결과 4개 존재', () {
      var count = 0;
      for (final player in PlayerActionType.values) {
        for (final enemy in EnemyActionType.values) {
          if (ActionInteraction.getResult(player, enemy) ==
              ActionResult.ineffective) {
            count++;
          }
        }
      }
      expect(count, 4);
    });
  });
}
