import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';
import 'package:soul_dungeon/domain/combat/logic/enemy_ai.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';

/// 테스트용 가짜 Random — nextDouble/nextBool 결과를 시퀀스로 주입.
class _FakeRandom implements Random {
  final List<double> _doubles;
  final List<bool> _bools;
  int _doubleIndex = 0;
  int _boolIndex = 0;

  _FakeRandom({List<double> doubles = const [], List<bool> bools = const []})
      : _doubles = doubles,
        _bools = bools;

  @override
  double nextDouble() => _doubles[_doubleIndex++ % _doubles.length];

  @override
  bool nextBool() =>
      _bools.isEmpty ? true : _bools[_boolIndex++ % _bools.length];

  @override
  int nextInt(int max) => 0;
}

void main() {
  group('EnemyAI.getAction', () {
    test('쥐 — 항상 attack', () {
      expect(EnemyAI.getAction(FloorEnemies.rat, 0), EnemyActionType.attack);
      expect(EnemyAI.getAction(FloorEnemies.rat, 1), EnemyActionType.attack);
      expect(EnemyAI.getAction(FloorEnemies.rat, 2), EnemyActionType.attack);
    });

    test('고블린 — attack, charge, heavy 패턴', () {
      expect(EnemyAI.getAction(FloorEnemies.goblin, 0), EnemyActionType.attack);
      expect(EnemyAI.getAction(FloorEnemies.goblin, 1), EnemyActionType.charge);
      expect(EnemyAI.getAction(FloorEnemies.goblin, 2), EnemyActionType.heavy);
    });

    test('패턴 순환', () {
      // 고블린: [attack, charge, heavy, attack] (길이 4)
      expect(EnemyAI.getAction(FloorEnemies.goblin, 3), EnemyActionType.attack);
      expect(EnemyAI.getAction(FloorEnemies.goblin, 4), EnemyActionType.attack); // 4%4=0
      expect(EnemyAI.getAction(FloorEnemies.goblin, 5), EnemyActionType.charge); // 5%4=1
    });
  });

  group('EnemyAI.getNextIntent', () {
    test('다음 턴 의도 반환', () {
      expect(
        EnemyAI.getNextIntent(FloorEnemies.goblin, 0),
        EnemyActionType.charge,
      );
    });
  });

  group('EnemyAI.intentText', () {
    test('attack — 데미지 수치 포함', () {
      final text = EnemyAI.intentText(FloorEnemies.rat, 0);
      expect(text, contains('공격'));
      expect(text, contains('10'));
    });

    test('heavy — 강공격 텍스트', () {
      final text = EnemyAI.intentText(FloorEnemies.goblin, 2);
      expect(text, contains('강공격'));
      expect(text, contains('21'));
    });

    test('charge — 충전 텍스트', () {
      final text = EnemyAI.intentText(FloorEnemies.goblin, 1);
      expect(text, contains('힘을 모으'));
    });

    test('defend — 방어 텍스트', () {
      final text = EnemyAI.intentText(FloorEnemies.slime, 0);
      expect(text, contains('방어'));
    });

    test('buff — 강화 텍스트', () {
      final text = EnemyAI.intentText(FloorEnemies.goblinChief, 0);
      expect(text, contains('강화'));
    });

    test('heal — 회복 텍스트', () {
      final text = EnemyAI.intentText(FloorEnemies.goblinChief, 4);
      expect(text, contains('회복'));
    });
  });

  group('EnemyAI.hiddenIntentText', () {
    test('숨김 텍스트 — 적 이름 포함', () {
      final text = EnemyAI.hiddenIntentText(FloorEnemies.goblinChief);
      expect(text, contains('고블린 족장'));
      expect(text, contains('준비'));
    });
  });

  group('EnemyAI.shouldShowIntent', () {
    test('일반 적 — 항상 공개', () {
      expect(
        EnemyAI.shouldShowIntent(
          isElite: false, isBoss: false, currentTurn: 0, intentRevealed: false,
        ),
        true,
      );
    });

    test('일반 적 — 첫 턴도 공개', () {
      expect(
        EnemyAI.shouldShowIntent(
          isElite: false, isBoss: false, currentTurn: 0, intentRevealed: false,
        ),
        true,
      );
    });

    test('엘리트 — 첫 2턴 비공개', () {
      expect(
        EnemyAI.shouldShowIntent(
          isElite: true, isBoss: false, currentTurn: 0, intentRevealed: false,
        ),
        false,
      );
      expect(
        EnemyAI.shouldShowIntent(
          isElite: true, isBoss: false, currentTurn: 1, intentRevealed: false,
        ),
        false,
      );
    });

    test('엘리트 — 턴 2부터 공개', () {
      expect(
        EnemyAI.shouldShowIntent(
          isElite: true, isBoss: false, currentTurn: 2, intentRevealed: false,
        ),
        true,
      );
      expect(
        EnemyAI.shouldShowIntent(
          isElite: true, isBoss: false, currentTurn: 5, intentRevealed: false,
        ),
        true,
      );
    });

    test('엘리트 — 관찰로 즉시 해제', () {
      expect(
        EnemyAI.shouldShowIntent(
          isElite: true, isBoss: false, currentTurn: 0, intentRevealed: true,
        ),
        true,
      );
    });

    test('보스 — 항상 공개 (StS 스타일)', () {
      expect(
        EnemyAI.shouldShowIntent(
          isElite: false, isBoss: true, currentTurn: 0, intentRevealed: false,
        ),
        true,
      );
      expect(
        EnemyAI.shouldShowIntent(
          isElite: false, isBoss: true, currentTurn: 10, intentRevealed: false,
        ),
        true,
      );
      expect(
        EnemyAI.shouldShowIntent(
          isElite: false, isBoss: true, currentTurn: 0, intentRevealed: true,
        ),
        true,
      );
    });
  });

  group('EnemyAI.resolveAction', () {
    test('attack — 기본 데미지', () {
      final result = EnemyAI.resolveAction(FloorEnemies.rat, 0);
      expect(result.type, EnemyActionType.attack);
      expect(result.damage, 10);
      expect(result.block, 0);
    });

    test('attack — 힘 보너스 적용', () {
      final result = EnemyAI.resolveAction(
        FloorEnemies.rat,
        0,
        enemyStrength: 3,
      );
      expect(result.damage, 13); // 10 + 3
    });

    test('heavy — 1.8배 데미지', () {
      final result = EnemyAI.resolveAction(FloorEnemies.goblin, 2);
      expect(result.type, EnemyActionType.heavy);
      expect(result.damage, 21); // 12 * 1.8
    });

    test('defend — 블록 반환', () {
      final result = EnemyAI.resolveAction(FloorEnemies.slime, 0);
      expect(result.type, EnemyActionType.defend);
      expect(result.block, 4);
      expect(result.damage, 0);
    });

    test('charge — 데미지/블록 0', () {
      final result = EnemyAI.resolveAction(FloorEnemies.goblin, 1);
      expect(result.type, EnemyActionType.charge);
      expect(result.damage, 0);
      expect(result.block, 0);
    });

    test('heal — HP 20% 회복', () {
      final result = EnemyAI.resolveAction(FloorEnemies.goblinChief, 4);
      expect(result.type, EnemyActionType.heal);
      expect(result.healAmount, 13); // 65 * 0.2 = 13
    });

    test('buff — 힘 +4 (엘리트)', () {
      final result = EnemyAI.resolveAction(FloorEnemies.goblinChief, 0);
      expect(result.type, EnemyActionType.buff);
      expect(result.buffStrength, 4); // elite: 4, normal: 3
    });
  });

  // ── Phase 3-C: resolveActionAdvanced ────────────────────

  group('EnemyAI.resolveActionAdvanced', () {
    // 테스트용 적 데이터
    // 일반 적: 공격 패턴 (attack, attack, defend, attack)
    const normalEnemy = EnemyCombatData(
      id: 'test_normal',
      name: '테스트 일반',
      hp: 50,
      atk: 10,
      def: 5,
      floor: 1,
      pattern: [
        EnemyActionType.attack,
        EnemyActionType.attack,
        EnemyActionType.defend,
        EnemyActionType.attack,
      ],
    );

    // 엘리트 적: buff, attack, attack, defend, heal
    const eliteEnemy = EnemyCombatData(
      id: 'test_elite',
      name: '테스트 엘리트',
      hp: 80,
      atk: 14,
      def: 6,
      floor: 1,
      isElite: true,
      pattern: [
        EnemyActionType.buff,
        EnemyActionType.attack,
        EnemyActionType.attack,
        EnemyActionType.defend,
        EnemyActionType.heal,
      ],
    );

    group('오버라이드 없음 (기본)', () {
      test('HP 충분 + 블록 적당 → 원래 패턴 유지', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 1.0,
          playerBlock: 5,
          random: _FakeRandom(doubles: [0.99]),
        );
        expect(result.type, EnemyActionType.attack);
        expect(result.overrideApplied, isNull);
        expect(result.damage, 10);
      });

      test('메타데이터 기본값 확인', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 1.0,
          random: _FakeRandom(doubles: [0.99]),
        );
        expect(result.isEnrage, false);
        expect(result.longCombatStrengthBonus, 0);
        expect(result.overrideApplied, isNull);
      });
    });

    group('charge/heavy 보호', () {
      test('charge — 절대 오버라이드 안 됨', () {
        // 고블린: 턴 1 = charge
        final result = EnemyAI.resolveActionAdvanced(
          FloorEnemies.goblin,
          1,
          enemyHpRatio: 0.1, // 극저 HP
          playerBlock: 0,
          random: _FakeRandom(doubles: [0.0]),
        );
        expect(result.type, EnemyActionType.charge);
        expect(result.overrideApplied, isNull);
      });

      test('heavy — 절대 오버라이드 안 됨', () {
        // 고블린: 턴 2 = heavy
        final result = EnemyAI.resolveActionAdvanced(
          FloorEnemies.goblin,
          2,
          enemyHpRatio: 0.1,
          playerBlock: 20,
          random: _FakeRandom(doubles: [0.0]),
        );
        expect(result.type, EnemyActionType.heavy);
        expect(result.overrideApplied, isNull);
      });
    });

    group('오버라이드 1: 엘리트 HP ≤ 25% → 격노(buff) 40%', () {
      test('확률 통과 → buff 오버라이드 + isEnrage', () {
        final result = EnemyAI.resolveActionAdvanced(
          eliteEnemy,
          1, // 원래 attack
          enemyHpRatio: 0.2,
          isBoss: false,
          random: _FakeRandom(doubles: [0.3]), // < 0.4 통과
        );
        expect(result.type, EnemyActionType.buff);
        expect(result.overrideApplied, EnemyActionType.buff);
        expect(result.isEnrage, true);
      });

      test('확률 실패 → 원래 행동 유지', () {
        final result = EnemyAI.resolveActionAdvanced(
          eliteEnemy,
          1,
          enemyHpRatio: 0.2,
          isBoss: false,
          random: _FakeRandom(doubles: [0.5]), // >= 0.4 실패
        );
        expect(result.type, EnemyActionType.attack);
        expect(result.overrideApplied, isNull);
        expect(result.isEnrage, false);
      });

      test('보스는 엘리트 격노 불가', () {
        final result = EnemyAI.resolveActionAdvanced(
          eliteEnemy,
          1,
          enemyHpRatio: 0.2,
          isBoss: true,
          random: _FakeRandom(doubles: [0.0]),
        );
        // 보스이므로 오버라이드 1 건너뜀
        // 오버라이드 2도 isBoss라 건너뜀
        // 오버라이드 3/4 조건 미달
        expect(result.type, EnemyActionType.attack);
        expect(result.isEnrage, false);
      });

      test('연속 방지: 직전 buff → 이번 턴 buff 불가', () {
        final result = EnemyAI.resolveActionAdvanced(
          eliteEnemy,
          1, // attack
          enemyHpRatio: 0.2,
          isBoss: false,
          lastOverrideAction: EnemyActionType.buff,
          random: _FakeRandom(
            doubles: [0.0], // 오버라이드 2 확률 통과
            bools: [true],  // defend 선택
          ),
        );
        // lastOverrideAction == buff → 오버라이드 1 스킵
        // 오버라이드 2: HP ≤ 50% + attack → defend
        expect(result.overrideApplied, EnemyActionType.defend);
      });
    });

    group('오버라이드 2: HP ≤ 50% + attack → defend/heal 30%', () {
      test('확률 통과 + nextBool true → defend', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0, // attack
          enemyHpRatio: 0.4,
          isBoss: false,
          random: _FakeRandom(
            doubles: [0.2], // < 0.3 통과
            bools: [true], // true → defend
          ),
        );
        expect(result.type, EnemyActionType.defend);
        expect(result.overrideApplied, EnemyActionType.defend);
      });

      test('확률 통과 + nextBool false → heal', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 0.4,
          isBoss: false,
          random: _FakeRandom(
            doubles: [0.2],
            bools: [false], // false → heal
          ),
        );
        expect(result.type, EnemyActionType.heal);
        expect(result.overrideApplied, EnemyActionType.heal);
      });

      test('확률 실패 → 원래 attack 유지', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 0.4,
          isBoss: false,
          random: _FakeRandom(doubles: [0.5]), // >= 0.3 실패
        );
        expect(result.type, EnemyActionType.attack);
        expect(result.overrideApplied, isNull);
      });

      test('비공격 행동 → 오버라이드 안 됨', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          2, // defend
          enemyHpRatio: 0.3,
          isBoss: false,
          random: _FakeRandom(doubles: [0.0]),
        );
        // defend는 isAttack = false → 오버라이드 2 조건 불충족
        // 오버라이드 4: playerBlock=0 + defend → attack (40%)
        expect(result.type, EnemyActionType.attack);
        expect(result.overrideApplied, EnemyActionType.attack);
      });

      test('보스는 오버라이드 2 불가', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 0.3,
          isBoss: true,
          random: _FakeRandom(doubles: [0.0]),
        );
        expect(result.type, EnemyActionType.attack);
        expect(result.overrideApplied, isNull);
      });
    });

    group('오버라이드 3: 플레이어 블록 ≥ 15 + attack → buff 30%', () {
      test('확률 통과 → buff 오버라이드', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0, // attack
          enemyHpRatio: 1.0,
          playerBlock: 20,
          random: _FakeRandom(doubles: [0.2]), // < 0.3 통과
        );
        expect(result.type, EnemyActionType.buff);
        expect(result.overrideApplied, EnemyActionType.buff);
      });

      test('블록 14 → 조건 미달', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 1.0,
          playerBlock: 14,
          random: _FakeRandom(doubles: [0.0]),
        );
        expect(result.type, EnemyActionType.attack);
        expect(result.overrideApplied, isNull);
      });

      test('heavy는 attack과 다름 → 오버라이드 안 됨 (attack만)', () {
        // heavy 행동에서는 이미 charge/heavy 보호에 걸려 빠져나가므로 불가
        final result = EnemyAI.resolveActionAdvanced(
          FloorEnemies.goblin,
          2, // heavy
          enemyHpRatio: 1.0,
          playerBlock: 20,
          random: _FakeRandom(doubles: [0.0]),
        );
        expect(result.type, EnemyActionType.heavy);
      });

      test('연속 방지: 직전 buff → 이번 턴 buff 불가', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 1.0,
          playerBlock: 20,
          lastOverrideAction: EnemyActionType.buff,
          random: _FakeRandom(doubles: [0.0]),
        );
        expect(result.overrideApplied, isNull);
        expect(result.type, EnemyActionType.attack);
      });
    });

    group('오버라이드 4: 플레이어 블록 = 0 + defend → attack 40%', () {
      test('확률 통과 → attack 오버라이드', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          2, // defend
          enemyHpRatio: 1.0,
          playerBlock: 0,
          random: _FakeRandom(doubles: [0.3]), // < 0.4 통과
        );
        expect(result.type, EnemyActionType.attack);
        expect(result.overrideApplied, EnemyActionType.attack);
      });

      test('확률 실패 → defend 유지', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          2,
          enemyHpRatio: 1.0,
          playerBlock: 0,
          random: _FakeRandom(doubles: [0.5]), // >= 0.4 실패
        );
        expect(result.type, EnemyActionType.defend);
        expect(result.overrideApplied, isNull);
      });

      test('블록 1 이상 → 조건 미달', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          2,
          enemyHpRatio: 1.0,
          playerBlock: 1,
          random: _FakeRandom(doubles: [0.0]),
        );
        expect(result.type, EnemyActionType.defend);
        expect(result.overrideApplied, isNull);
      });

      test('연속 방지: 직전 attack → 이번 턴 attack 불가', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          2,
          enemyHpRatio: 1.0,
          playerBlock: 0,
          lastOverrideAction: EnemyActionType.attack,
          random: _FakeRandom(doubles: [0.0]),
        );
        expect(result.overrideApplied, isNull);
        expect(result.type, EnemyActionType.defend);
      });
    });

    group('오버라이드 우선순위 (최대 1회/턴)', () {
      test('엘리트 HP 25% + 블록 0 + defend → 오버라이드 1 우선', () {
        // 엘리트, HP 20%, 행동=attack(턴1), 블록 0
        final result = EnemyAI.resolveActionAdvanced(
          eliteEnemy,
          1, // attack
          enemyHpRatio: 0.2,
          playerBlock: 0,
          isBoss: false,
          random: _FakeRandom(doubles: [0.1]),
        );
        // 오버라이드 1(엘리트 격노)이 먼저 매칭
        expect(result.type, EnemyActionType.buff);
        expect(result.isEnrage, true);
      });
    });

    group('장기전 보너스 (10턴 초과)', () {
      test('엘리트 11턴 → 힘 +1', () {
        final result = EnemyAI.resolveActionAdvanced(
          eliteEnemy,
          1, // attack
          enemyHpRatio: 1.0,
          currentTurnNumber: 11,
          random: _FakeRandom(doubles: [0.99]),
        );
        expect(result.damage, 15); // 14 + 1 (bonus)
        expect(result.longCombatStrengthBonus, 1);
      });

      test('엘리트 10턴 → 보너스 없음', () {
        final result = EnemyAI.resolveActionAdvanced(
          eliteEnemy,
          1,
          enemyHpRatio: 1.0,
          currentTurnNumber: 10,
          random: _FakeRandom(doubles: [0.99]),
        );
        expect(result.damage, 14);
        expect(result.longCombatStrengthBonus, 0);
      });

      test('일반 적 11턴 → 보너스 없음', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 1.0,
          currentTurnNumber: 15,
          random: _FakeRandom(doubles: [0.99]),
        );
        expect(result.damage, 10);
        expect(result.longCombatStrengthBonus, 0);
      });

      test('보스 12턴 → 힘 +1', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 1.0,
          currentTurnNumber: 12,
          isBoss: true,
          random: _FakeRandom(doubles: [0.99]),
        );
        expect(result.damage, 11); // 10 + 1
        expect(result.longCombatStrengthBonus, 1);
      });
    });

    group('격노 (enragedTurns)', () {
      test('enragedTurns > 0 → ATK×1.5', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0, // attack, atk=10
          enemyHpRatio: 1.0,
          enragedTurns: 2,
          random: _FakeRandom(doubles: [0.99]),
        );
        expect(result.damage, 15); // 10 * 1.5
      });

      test('enragedTurns = 0 → 배율 없음', () {
        final result = EnemyAI.resolveActionAdvanced(
          normalEnemy,
          0,
          enemyHpRatio: 1.0,
          enragedTurns: 0,
          random: _FakeRandom(doubles: [0.99]),
        );
        expect(result.damage, 10);
      });

      test('격노 + 힘 + 장기전 보너스 중첩', () {
        final result = EnemyAI.resolveActionAdvanced(
          eliteEnemy,
          1, // attack, atk=14
          enemyStrength: 3,
          enemyHpRatio: 1.0,
          enragedTurns: 1,
          currentTurnNumber: 11,
          random: _FakeRandom(doubles: [0.99]),
        );
        // (14 + 3 + 1[장기전]) * 1.5 = 27
        expect(result.damage, 27);
      });
    });
  });

  // ── Phase 3-C: resolveGimmickAdvanced ───────────────────

  group('EnemyAI.resolveGimmickAdvanced', () {
    group('regen — 독/화상 시 재생 2배', () {
      test('플레이어 독 → 재생 2배', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.regen,
          200, // maxHp
          playerPoisonStacks: 3,
        );
        final base = EnemyAI.resolveGimmick(BossGimmick.regen, 200);
        expect(result.healAmount, base.healAmount * 2);
        expect(result.doubleRegen, true);
      });

      test('플레이어 화상 → 재생 2배', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.regen,
          200,
          playerBurnStacks: 2,
        );
        expect(result.doubleRegen, true);
      });

      test('상태이상 없음 → 기본 재생', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.regen,
          200,
        );
        final base = EnemyAI.resolveGimmick(BossGimmick.regen, 200);
        expect(result.healAmount, base.healAmount);
        expect(result.doubleRegen, false);
      });
    });

    group('web — 0AP 카드 사용 시 추가 드로우 패널티', () {
      test('카드 사용 + 공격 0회 → 추가 드로우 -1', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.web,
          100,
          cardsPlayedThisTurn: 2,
          attacksPlayedThisTurn: 0,
        );
        expect(result.playerDrawPenalty, 2); // 기본 1 + 추가 1
        expect(result.extraDrawPenalty, 1);
      });

      test('카드 미사용 → 기본 패널티만', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.web,
          100,
          cardsPlayedThisTurn: 0,
        );
        expect(result.playerDrawPenalty, 1);
        expect(result.extraDrawPenalty, 0);
      });

      test('공격 카드 사용 → 기본 패널티만', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.web,
          100,
          cardsPlayedThisTurn: 3,
          attacksPlayedThisTurn: 1,
        );
        expect(result.playerDrawPenalty, 1);
        expect(result.extraDrawPenalty, 0);
      });
    });

    group('rage — 3턴 연속 피격 시 광폭화', () {
      test('3턴 연속 피격 → berserk', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.rage,
          100,
          consecutiveHitTurns: 3,
        );
        expect(result.berserk, true);
      });

      test('5턴 연속 피격 → berserk', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.rage,
          100,
          consecutiveHitTurns: 5,
        );
        expect(result.berserk, true);
      });

      test('2턴 연속 피격 → 기본 rage만', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.rage,
          100,
          consecutiveHitTurns: 2,
        );
        expect(result.berserk, false);
        expect(result.strengthOnHit, 2);
      });
    });

    group('drain — 플레이어 HP < 50% 시 흡혈 강화', () {
      test('HP 40% → 흡혈 50%', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.drain,
          100,
          playerHp: 40,
          playerMaxHp: 100,
        );
        expect(result.drainPercent, 50);
        expect(result.enhancedDrainPercent, 50);
      });

      test('HP 50% → 기본 흡혈 30%', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.drain,
          100,
          playerHp: 50,
          playerMaxHp: 100,
        );
        expect(result.drainPercent, 30);
        expect(result.enhancedDrainPercent, 0);
      });

      test('maxHp 0 → 기본 흡혈 (0 나눗셈 방지)', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.drain,
          100,
          playerHp: 10,
          playerMaxHp: 0,
        );
        expect(result.drainPercent, 30);
      });
    });

    group('bleed — 블록 0 시 화상 강화 / 화상 5+ 시 폭발', () {
      test('블록 0 → 화상 4 (기본 2)', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.bleed,
          100,
          playerBlock: 0,
        );
        expect(result.bleedBurnStacks, 4);
      });

      test('블록 있음 + 화상 5+ → burnBurst', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.bleed,
          100,
          playerBlock: 5,
          playerBurnStacks: 5,
        );
        expect(result.burnBurst, true);
      });

      test('블록 있음 + 화상 4 → 기본 bleed만', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.bleed,
          100,
          playerBlock: 5,
          playerBurnStacks: 4,
        );
        expect(result.bleedBurnStacks, 2);
        expect(result.burnBurst, false);
      });

      test('블록 0은 burnBurst보다 우선', () {
        // 블록 0 조건이 먼저 체크됨
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.bleed,
          100,
          playerBlock: 0,
          playerBurnStacks: 10,
        );
        expect(result.bleedBurnStacks, 4);
        expect(result.burnBurst, false);
      });
    });

    group('corruption — 디버프 3+ 시 추가 공격 / Power 사용 시 면역', () {
      test('디버프 3개 → 추가 공격', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.corruption,
          100,
          playerDebuffCount: 3,
        );
        expect(result.extraAttack, true);
      });

      test('Power 사용 → 디버프 면역', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.corruption,
          100,
          playerDebuffCount: 0,
          playerUsedPowerThisTurn: true,
        );
        expect(result.debuffImmunity, true);
      });

      test('디버프 3+ 우선 (Power 사용도 동시)', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.corruption,
          100,
          playerDebuffCount: 5,
          playerUsedPowerThisTurn: true,
        );
        // extraAttack이 먼저
        expect(result.extraAttack, true);
        expect(result.debuffImmunity, false);
      });

      test('조건 없음 → 기본 corruption만', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.corruption,
          100,
          playerDebuffCount: 1,
        );
        expect(result.applyRandomDebuff, true);
        expect(result.extraAttack, false);
        expect(result.debuffImmunity, false);
      });
    });

    group('shackle — 1장 사용 시 패널티 해제 / Skill 사용 시 절반 해제', () {
      test('1장만 사용 → AP 패널티 완전 해제', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.shackle,
          100,
          cardsPlayedThisTurn: 1,
        );
        expect(result.apPenaltyRemoved, true);
      });

      test('Skill 사용 (2장 이상) → 절반 해제', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.shackle,
          100,
          cardsPlayedThisTurn: 3,
          playerUsedSkillThisTurn: true,
        );
        expect(result.halfApPenaltyRemoved, true);
        expect(result.apPenaltyRemoved, false);
      });

      test('여러 장 + Skill 미사용 → 기본 shackle만', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.shackle,
          100,
          cardsPlayedThisTurn: 3,
        );
        expect(result.playerApPenalty, 1);
        expect(result.apPenaltyRemoved, false);
        expect(result.halfApPenaltyRemoved, false);
      });
    });

    group('voidGimmick — 소진 5+ 시 데미지 / 소진 0 시 직접 HP 감소', () {
      test('소진 7장 → 14 데미지 (7×2)', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.voidGimmick,
          100,
          exhaustPileSize: 7,
        );
        expect(result.exhaustDamage, 14);
      });

      test('소진 0장 → HP -5', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.voidGimmick,
          100,
          exhaustPileSize: 0,
        );
        expect(result.directHpDamage, 5);
      });

      test('소진 3장 → 기본 void만', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.voidGimmick,
          100,
          exhaustPileSize: 3,
        );
        expect(result.exhaustDamage, 0);
        expect(result.directHpDamage, 0);
        expect(result.playerDrawPenalty, 1);
      });
    });

    group('reflect — 힘 5+ 시 반사 강화 / 연쇄 3+ 시 반사 2배', () {
      test('플레이어 힘 5 → 반사 25%', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.reflect,
          100,
          playerStrength: 5,
        );
        expect(result.reflectPercent, 25);
        expect(result.enhancedReflectPercent, 25);
      });

      test('연쇄 3 → 반사 2배', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.reflect,
          100,
          playerStrength: 2,
          chainCount: 3,
        );
        expect(result.doubleReflectDamage, true);
      });

      test('힘 5+ 우선 (연쇄 3+ 동시)', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.reflect,
          100,
          playerStrength: 6,
          chainCount: 5,
        );
        expect(result.reflectPercent, 25);
        expect(result.doubleReflectDamage, false);
      });

      test('조건 없음 → 기본 반사 15%', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.reflect,
          100,
          playerStrength: 3,
          chainCount: 1,
        );
        expect(result.reflectPercent, 15);
        expect(result.enhancedReflectPercent, 0);
        expect(result.doubleReflectDamage, false);
      });
    });

    group('formShift — 반응형 효과 없음', () {
      test('기본 결과 반환', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.formShift,
          100,
        );
        expect(result.hasReactiveEffect, false);
      });
    });

    group('none — 효과 없음', () {
      test('빈 결과 반환', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.none,
          100,
        );
        expect(result.healAmount, 0);
        expect(result.hasReactiveEffect, false);
      });
    });

    group('hasReactiveEffect', () {
      test('반응형 효과 있을 때 true', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.regen,
          200,
          playerPoisonStacks: 3,
        );
        expect(result.hasReactiveEffect, true);
      });

      test('반응형 효과 없을 때 false', () {
        final result = EnemyAI.resolveGimmickAdvanced(
          BossGimmick.regen,
          200,
        );
        expect(result.hasReactiveEffect, false);
      });
    });
  });
}
