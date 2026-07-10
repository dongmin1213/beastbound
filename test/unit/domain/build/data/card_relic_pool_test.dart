import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/build/data/card_relic_pool.dart';
import 'package:soul_dungeon/core/models/card_relic_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CardRelicPool', () {
    test('총 20종', () {
      expect(CardRelicPool.all.length, 20);
    });

    test('ID 고유', () {
      final ids = CardRelicPool.all.map((r) => r.id).toSet();
      expect(ids.length, 20);
    });

    test('모든 ID는 cr_ 접두사', () {
      for (final r in CardRelicPool.all) {
        expect(r.id.startsWith('cr_'), true,
            reason: '${r.name} id should start with cr_');
      }
    });

    test('findById — 존재하는 ID', () {
      final relic = CardRelicPool.findById('cr_blood_ring');
      expect(relic, isNotNull);
      expect(relic!.name, '핏빛 반지');
    });

    test('findById — 존재하지 않는 ID', () {
      expect(CardRelicPool.findById('unknown'), isNull);
    });

    test('핏빛 반지 — combatStart 힘 +2', () {
      expect(CardRelicPool.bloodRing.trigger, RelicTrigger.combatStart);
      expect(CardRelicPool.bloodRing.effectType, 'gainStrength');
      expect(CardRelicPool.bloodRing.effectValue, 2);
    });

    test('가시 방패 — onBlock 조건값 10', () {
      expect(CardRelicPool.thornShield.trigger, RelicTrigger.onBlock);
      expect(CardRelicPool.thornShield.conditionValue, 10);
      expect(CardRelicPool.thornShield.effectValue, 2);
    });

    test('거울 조각 — turnStart 20% 확률', () {
      expect(CardRelicPool.mirrorShard.trigger, RelicTrigger.turnStart);
      expect(CardRelicPool.mirrorShard.conditionValue, 20);
      expect(CardRelicPool.mirrorShard.rarity, Rarity.legendary);
    });

    test('CardRelicData equality', () {
      const a = CardRelicData(
        id: 'test',
        name: 'A',
        description: '',
        rarity: Rarity.common,
        trigger: RelicTrigger.passive,
        effectType: 'test',
        effectValue: 1,
      );
      const b = CardRelicData(
        id: 'test',
        name: 'B',
        description: '',
        rarity: Rarity.rare,
        trigger: RelicTrigger.combatStart,
        effectType: 'other',
        effectValue: 99,
      );
      expect(a, equals(b));
    });
  });
}
