import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/environment_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/environment_card_resolver.dart';

void main() {
  group('EnvironmentCardResolver', () {
    test('층별 base 환경 카드 결정', () {
      expect(EnvironmentCardResolver.baseForFloor(1)?.id,
          EnvironmentCards.ceilingCollapse.id);
      expect(EnvironmentCardResolver.baseForFloor(2)?.id,
          EnvironmentCards.swampMiasma.id);
      expect(EnvironmentCardResolver.baseForFloor(3)?.id,
          EnvironmentCards.manaCrystal.id);
      expect(EnvironmentCardResolver.baseForFloor(4)?.id,
          EnvironmentCards.altarFlame.id);
      expect(EnvironmentCardResolver.baseForFloor(5)?.id,
          EnvironmentCards.abyssalRift.id);
    });

    test('유효하지 않은 층은 null', () {
      expect(EnvironmentCardResolver.baseForFloor(0), isNull);
      expect(EnvironmentCardResolver.baseForFloor(6), isNull);
    });

    test('층별 observed 환경 카드 결정', () {
      expect(EnvironmentCardResolver.observedForFloor(1)?.id,
          EnvironmentCards.ceilingCollapsePlus.id);
      expect(EnvironmentCardResolver.observedForFloor(5)?.id,
          EnvironmentCards.abyssalRiftPlus.id);
    });

    test('보스별 base 환경 카드 결정', () {
      expect(EnvironmentCardResolver.baseForBoss('boss_slime_king')?.id,
          EnvironmentCards.acidPool.id);
      expect(EnvironmentCardResolver.baseForBoss('boss_spider_lord')?.id,
          EnvironmentCards.webReversal.id);
      expect(EnvironmentCardResolver.baseForBoss('boss_orc_general')?.id,
          EnvironmentCards.trapTrigger.id);
      expect(EnvironmentCardResolver.baseForBoss('boss_vampire_lord')?.id,
          EnvironmentCards.holyWater.id);
      expect(EnvironmentCardResolver.baseForBoss('boss_dungeon_master')?.id,
          EnvironmentCards.primordialLight.id);
    });

    test('알 수 없는 보스는 null', () {
      expect(EnvironmentCardResolver.baseForBoss('unknown'), isNull);
    });

    test('resolveBase — 보스 우선', () {
      final card = EnvironmentCardResolver.resolveBase(
        floor: 1,
        bossId: 'boss_slime_king',
      );
      expect(card?.id, EnvironmentCards.acidPool.id);
    });

    test('resolveBase — 보스 없으면 층별', () {
      final card = EnvironmentCardResolver.resolveBase(
        floor: 3,
      );
      expect(card?.id, EnvironmentCards.manaCrystal.id);
    });

    test('resolveObserved — 보스 우선', () {
      final card = EnvironmentCardResolver.resolveObserved(
        floor: 4,
        bossId: 'boss_vampire_lord',
      );
      expect(card?.id, EnvironmentCards.holyWaterPlus.id);
    });

    test('resolveObserved — 보스 없으면 층별 upgraded', () {
      final card = EnvironmentCardResolver.resolveObserved(
        floor: 2,
      );
      expect(card?.id, EnvironmentCards.swampMiasmaPlus.id);
    });
  });
}
