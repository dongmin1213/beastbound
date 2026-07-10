import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('RoomType', () {
    test('has exactly 8 values', () {
      expect(RoomType.values.length, 8);
    });

    test('contains all expected values', () {
      expect(RoomType.values, containsAll([
        RoomType.combat,
        RoomType.elite,
        RoomType.event,
        RoomType.mystery,
        RoomType.shop,
        RoomType.npc,
        RoomType.rest,
        RoomType.boss,
      ]));
    });

    test('switch exhaustiveness covers all cases', () {
      for (final type in RoomType.values) {
        final result = switch (type) {
          RoomType.combat => 'combat',
          RoomType.elite => 'elite',
          RoomType.event => 'event',
          RoomType.mystery => 'mystery',
          RoomType.shop => 'shop',
          RoomType.npc => 'npc',
          RoomType.rest => 'rest',
          RoomType.boss => 'boss',
        };
        expect(result, isNotEmpty);
      }
    });
  });

  group('ItemType', () {
    test('has exactly 7 values', () {
      expect(ItemType.values.length, 7);
    });

    test('contains all expected values', () {
      expect(ItemType.values, containsAll([
        ItemType.blessing,
        ItemType.curse,
        ItemType.supply,
        ItemType.relic,
        ItemType.memoryEcho,
        ItemType.card,
        ItemType.cardRemoval,
      ]));
    });
  });

  group('Rarity', () {
    test('has exactly 4 values', () {
      expect(Rarity.values.length, 4);
    });

    test('contains all expected values', () {
      expect(Rarity.values, containsAll([
        Rarity.common,
        Rarity.rare,
        Rarity.legendary,
        Rarity.cursed,
      ]));
    });
  });

  group('FloorTheme', () {
    test('has exactly 5 values', () {
      expect(FloorTheme.values.length, 5);
    });

    test('contains all expected values', () {
      expect(FloorTheme.values, containsAll([
        FloorTheme.ruins,
        FloorTheme.cavern,
        FloorTheme.prison,
        FloorTheme.sanctuary,
        FloorTheme.abyss,
      ]));
    });
  });

  group('BossDisposition', () {
    test('has exactly 5 values', () {
      expect(BossDisposition.values.length, 5);
    });

    test('contains all expected values', () {
      expect(BossDisposition.values, containsAll([
        BossDisposition.slayer,
        BossDisposition.liberator,
        BossDisposition.coexister,
        BossDisposition.mixed,
        BossDisposition.none,
      ]));
    });
  });

  group('NarrativeLayer', () {
    test('has exactly 3 values', () {
      expect(NarrativeLayer.values.length, 3);
    });

    test('contains all expected values', () {
      expect(NarrativeLayer.values, containsAll([
        NarrativeLayer.l1,
        NarrativeLayer.l2,
        NarrativeLayer.l3,
      ]));
    });
  });

  group('RunType', () {
    test('has exactly 2 values', () {
      expect(RunType.values.length, 2);
    });

    test('contains all expected values', () {
      expect(RunType.values, containsAll([
        RunType.first,
        RunType.repeat,
      ]));
    });
  });

  group('MemoryCategory', () {
    test('has exactly 5 values', () {
      expect(MemoryCategory.values.length, 5);
    });

    test('contains all expected values', () {
      expect(MemoryCategory.values, containsAll([
        MemoryCategory.origin,
        MemoryCategory.loss,
        MemoryCategory.bond,
        MemoryCategory.cycle,
        MemoryCategory.none,
      ]));
    });
  });

  group('CardType', () {
    test('has exactly 3 values', () {
      expect(CardType.values.length, 3);
    });

    test('contains attack, skill, power', () {
      expect(CardType.values, containsAll([
        CardType.attack,
        CardType.skill,
        CardType.power,
      ]));
    });

    test('displayName 한국어', () {
      expect(CardType.attack.displayName, '공격');
      expect(CardType.skill.displayName, '스킬');
      expect(CardType.power.displayName, '파워');
    });
  });

  group('CardKeyword', () {
    test('has exactly 4 values', () {
      expect(CardKeyword.values.length, 4);
    });

    test('displayName 한국어', () {
      expect(CardKeyword.exhaust.displayName, '소진');
      expect(CardKeyword.innate.displayName, '선천');
      expect(CardKeyword.ethereal.displayName, '영체');
      expect(CardKeyword.retain.displayName, '유지');
    });
  });

  group('StatusEffectType', () {
    test('has exactly 8 values', () {
      expect(StatusEffectType.values.length, 8);
    });

    test('isDebuff — 독/화상/약화/취약', () {
      expect(StatusEffectType.poison.isDebuff, true);
      expect(StatusEffectType.burn.isDebuff, true);
      expect(StatusEffectType.weak.isDebuff, true);
      expect(StatusEffectType.vulnerable.isDebuff, true);
    });

    test('isBuff — 힘/민첩/가시/재생', () {
      expect(StatusEffectType.strength.isBuff, true);
      expect(StatusEffectType.dexterity.isBuff, true);
      expect(StatusEffectType.thorn.isBuff, true);
      expect(StatusEffectType.regenerate.isBuff, true);
    });

    test('displayName 한국어', () {
      expect(StatusEffectType.poison.displayName, '독');
      expect(StatusEffectType.strength.displayName, '힘');
    });
  });

  group('CombatOutcome', () {
    test('has exactly 3 values', () {
      expect(CombatOutcome.values.length, 3);
    });

    test('contains victory, defeat, fled', () {
      expect(CombatOutcome.values, containsAll([
        CombatOutcome.victory,
        CombatOutcome.defeat,
        CombatOutcome.fled,
      ]));
    });
  });

  group('ResourceType', () {
    test('has exactly 5 values', () {
      expect(ResourceType.values.length, 5);
    });

    test('contains all expected values', () {
      expect(ResourceType.values, containsAll([
        ResourceType.gold,
        ResourceType.hp,
        ResourceType.momentum,
        ResourceType.soul,
        ResourceType.memoryFragment,
      ]));
    });

    test('persistent getter returns true only for soul and memoryFragment', () {
      expect(ResourceType.gold.persistent, isFalse);
      expect(ResourceType.hp.persistent, isFalse);
      expect(ResourceType.momentum.persistent, isFalse);
      expect(ResourceType.soul.persistent, isTrue);
      expect(ResourceType.memoryFragment.persistent, isTrue);
    });

    test('persistent resources count is exactly 2', () {
      final persistentCount =
          ResourceType.values.where((r) => r.persistent).length;
      expect(persistentCount, 2);
    });
  });
}
