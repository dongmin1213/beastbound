import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/monster_passives.dart';

void main() {
  group('MonsterPassives 타입/친화', () {
    test('타입 유도', () {
      expect(MonsterPassives.typeOf('enemy_goblin'), MonsterType.attack);
      expect(MonsterPassives.typeOf('enemy_slime'), MonsterType.guard);
      expect(MonsterPassives.typeOf('enemy_poison_toad'), MonsterType.venom);
      expect(MonsterPassives.typeOf('enemy_unknown'), MonsterType.none);
    });

    test('친화 카운트', () {
      final aff = MonsterPassives.affinity(
          ['enemy_poison_toad', 'enemy_spider', 'enemy_goblin']);
      expect(aff[MonsterType.venom], 2);
      expect(aff[MonsterType.attack], 1);
    });

    test('단일 몬스터 — 친화 보너스 없음', () {
      final p = MonsterPassives.aggregate(['enemy_poison_toad']);
      expect(p.poisonPerTurn, 2); // 기본만
    });

    test('같은 타입 2마리 → 합산 + 친화 +1', () {
      // 독두꺼비(2) + 거미(2) = 4, 친화 2마리 보너스 +1 = 5
      final p = MonsterPassives.aggregate(['enemy_poison_toad', 'enemy_spider']);
      expect(p.poisonPerTurn, 5);
    });

    test('같은 타입 3마리 → 친화 +2', () {
      // 독 3마리: 2+2+2=6, 친화 3마리 보너스 +2 = 8
      final p = MonsterPassives.aggregate(
          ['enemy_poison_toad', 'enemy_spider', 'enemy_spider_queen']);
      expect(p.poisonPerTurn, 8);
    });

    test('서로 다른 타입 — 각자 기본만 (친화 없음)', () {
      final p =
          MonsterPassives.aggregate(['enemy_slime', 'enemy_poison_toad']);
      expect(p.blockPerTurn, 3); // 슬라임 기본
      expect(p.poisonPerTurn, 2); // 독두꺼비 기본
    });
  });
}
