import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/build/data/card_blessing_pool.dart';
import 'package:soul_dungeon/core/models/card_blessing_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CardBlessingPool', () {
    test('총 33종', () {
      expect(CardBlessingPool.all.length, 33);
    });

    test('ID 고유', () {
      final ids = CardBlessingPool.all.map((b) => b.id).toSet();
      expect(ids.length, 33);
    });

    test('Common 7종', () {
      final commons = CardBlessingPool.byRarity(Rarity.common);
      expect(commons.length, 7);
    });

    test('Rare 17종', () {
      final rares = CardBlessingPool.byRarity(Rarity.rare);
      expect(rares.length, 17);
    });

    test('Legendary 9종', () {
      final legendaries = CardBlessingPool.byRarity(Rarity.legendary);
      expect(legendaries.length, 9);
    });

    test('findById — 존재하는 ID', () {
      final blessing = CardBlessingPool.findById('cb_thorn');
      expect(blessing, isNotNull);
      expect(blessing!.name, '가시');
    });

    test('findById — 존재하지 않는 ID', () {
      expect(CardBlessingPool.findById('unknown'), isNull);
    });

    test('모든 ID는 cb_ 접두사', () {
      for (final b in CardBlessingPool.all) {
        expect(b.id.startsWith('cb_'), true,
            reason: '${b.name} id should start with cb_');
      }
    });

    test('가시 — onHit 트리거', () {
      expect(CardBlessingPool.thorn.trigger, BlessingTrigger.onHit);
      expect(CardBlessingPool.thorn.effectType, 'thornDamage');
      expect(CardBlessingPool.thorn.effectValue, 5);
    });

    test('신속 — onCardPlay 트리거', () {
      expect(CardBlessingPool.swift.trigger, BlessingTrigger.onCardPlay);
      expect(CardBlessingPool.swift.effectType, 'firstCardApDiscount');
    });

    test('인내 — turnStart 트리거', () {
      expect(CardBlessingPool.patience.trigger, BlessingTrigger.turnStart);
      expect(CardBlessingPool.patience.effectType, 'retainBlock');
      expect(CardBlessingPool.patience.effectValue, 50);
    });

    test('과부하 — secondaryValue HP 비용', () {
      expect(CardBlessingPool.overload.effectType, 'bonusApWithHpCost');
      expect(CardBlessingPool.overload.effectValue, 1);
      expect(CardBlessingPool.overload.secondaryValue, 5);
    });

    test('유리대포 — secondaryValue HP 감소', () {
      expect(CardBlessingPool.glassCannon.effectType, 'strengthWithHpPenalty');
      expect(CardBlessingPool.glassCannon.effectValue, 5);
      expect(CardBlessingPool.glassCannon.secondaryValue, 20);
    });

    test('시간의 모래 — secondaryValue 주기', () {
      expect(CardBlessingPool.sandsOfTime.effectType, 'periodicBonusAp');
      expect(CardBlessingPool.sandsOfTime.effectValue, 2);
      expect(CardBlessingPool.sandsOfTime.secondaryValue, 5);
    });

    test('완벽한 형태 — Legendary', () {
      expect(CardBlessingPool.perfectForm.rarity, Rarity.legendary);
      expect(CardBlessingPool.perfectForm.effectType, 'conditionalBonusAp');
    });

    test('에코 — turnEnd 트리거', () {
      expect(CardBlessingPool.echo.trigger, BlessingTrigger.turnEnd);
      expect(CardBlessingPool.echo.effectType, 'copyLastPlayed');
    });

    test('무한 순환 — onShuffle 트리거', () {
      expect(CardBlessingPool.infiniteCycle.trigger, BlessingTrigger.onShuffle);
    });

    test('독의 대가 — passive 트리거', () {
      expect(CardBlessingPool.poisonMaster.trigger, BlessingTrigger.passive);
      expect(CardBlessingPool.poisonMaster.effectType, 'poisonMultiplier');
    });

    test('사신의 낫 — onAttack 트리거', () {
      expect(CardBlessingPool.reaper.trigger, BlessingTrigger.onAttack);
      expect(CardBlessingPool.reaper.effectType, 'executeThreshold');
      expect(CardBlessingPool.reaper.effectValue, 5);
    });

    test('CardBlessingData equality', () {
      const a = CardBlessingData(
        id: 'test',
        name: 'A',
        description: '',
        rarity: Rarity.common,
        trigger: BlessingTrigger.passive,
        effectType: 'test',
        effectValue: 1,
      );
      const b = CardBlessingData(
        id: 'test',
        name: 'B',
        description: '',
        rarity: Rarity.rare,
        trigger: BlessingTrigger.onAttack,
        effectType: 'other',
        effectValue: 99,
      );
      expect(a, equals(b)); // ID만으로 동등 비교
    });
  });
}
