import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';

void main() {
  group('EnemyCombatData', () {
    const rat = EnemyCombatData(
      id: 'rat',
      name: '쥐',
      hp: 25,
      atk: 8,
      def: 2,
      floor: 1,
      pattern: [
        EnemyActionType.attack,
        EnemyActionType.attack,
        EnemyActionType.attack,
      ],
    );

    const goblin = EnemyCombatData(
      id: 'goblin',
      name: '고블린',
      hp: 30,
      atk: 10,
      def: 3,
      floor: 1,
      pattern: [
        EnemyActionType.attack,
        EnemyActionType.charge,
        EnemyActionType.heavy,
      ],
    );

    const slime = EnemyCombatData(
      id: 'slime',
      name: '슬라임',
      hp: 35,
      atk: 6,
      def: 4,
      floor: 1,
      pattern: [
        EnemyActionType.defend,
        EnemyActionType.attack,
        EnemyActionType.attack,
      ],
    );

    test('기본 필드', () {
      expect(rat.id, 'rat');
      expect(rat.name, '쥐');
      expect(rat.hp, 25);
      expect(rat.atk, 8);
      expect(rat.def, 2);
      expect(rat.floor, 1);
      expect(rat.isElite, false);
    });

    test('actionAt — 패턴 순환', () {
      expect(rat.actionAt(0), EnemyActionType.attack);
      expect(rat.actionAt(1), EnemyActionType.attack);
      expect(rat.actionAt(2), EnemyActionType.attack);
      expect(rat.actionAt(3), EnemyActionType.attack); // 순환
    });

    test('actionAt — 복합 패턴', () {
      expect(goblin.actionAt(0), EnemyActionType.attack);
      expect(goblin.actionAt(1), EnemyActionType.charge);
      expect(goblin.actionAt(2), EnemyActionType.heavy);
      expect(goblin.actionAt(3), EnemyActionType.attack); // 순환
    });

    test('damageAt — attack 배율 1.0', () {
      expect(rat.damageAt(0), 8);
    });

    test('damageAt — heavy 배율 1.8', () {
      expect(goblin.damageAt(2), 18); // 10 * 1.8 = 18
    });

    test('damageAt — charge 배율 0', () {
      expect(goblin.damageAt(1), 0);
    });

    test('damageAt — defend 배율 0', () {
      expect(slime.damageAt(0), 0);
    });

    test('blockAt — defend 시 def 반환', () {
      expect(slime.blockAt(0), 4);
    });

    test('blockAt — attack 시 0', () {
      expect(rat.blockAt(0), 0);
    });

    test('Equatable 동등성', () {
      const rat2 = EnemyCombatData(
        id: 'rat',
        name: '쥐',
        hp: 25,
        atk: 8,
        def: 2,
        floor: 1,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.attack,
        ],
      );
      expect(rat, equals(rat2));
    });
  });

  group('EnemyActionType 확장', () {
    test('heavy attackMultiplier = 1.8', () {
      expect(EnemyActionType.heavy.attackMultiplier, 1.8);
    });

    test('charge attackMultiplier = 0', () {
      expect(EnemyActionType.charge.attackMultiplier, 0.0);
    });

    test('heal attackMultiplier = 0', () {
      expect(EnemyActionType.heal.attackMultiplier, 0.0);
    });

    test('buff attackMultiplier = 0', () {
      expect(EnemyActionType.buff.attackMultiplier, 0.0);
    });

    test('isAttack — attack과 heavy만 true', () {
      expect(EnemyActionType.attack.isAttack, true);
      expect(EnemyActionType.heavy.isAttack, true);
      expect(EnemyActionType.defend.isAttack, false);
      expect(EnemyActionType.charge.isAttack, false);
      expect(EnemyActionType.heal.isAttack, false);
      expect(EnemyActionType.buff.isAttack, false);
    });

    test('displayName', () {
      expect(EnemyActionType.heavy.displayName, '강공격');
      expect(EnemyActionType.charge.displayName, '충전');
      expect(EnemyActionType.heal.displayName, '회복');
      expect(EnemyActionType.buff.displayName, '강화');
    });
  });
}
