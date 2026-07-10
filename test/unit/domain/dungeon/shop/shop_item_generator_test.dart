import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item_generator.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';

/// 기본 상점 아이템만 필터 (카드/카드제거 제외).
List<ShopItem> _baseItems(List<ShopItem> items) =>
    items.where((i) => i.itemType != ItemType.card && i.itemType != ItemType.cardRemoval).toList();

void main() {
  const economyConfig = EconomyConfig();

  group('ShopItemGenerator', () {
    test('generates 3 to 5 base items (+ card items)', () {
      // Run multiple seeds to verify range
      for (int seed = 0; seed < 50; seed++) {
        final items = ShopItemGenerator.generateItems(
          floor: 1,
          economyConfig: economyConfig,
          jobRewardsLookup: CardPool.jobRewards,
          colorlessCards: ColorlessCards.all,
          seed: seed,
        );
        final base = _baseItems(items);
        expect(base.length, inInclusiveRange(3, 5),
            reason: 'seed=$seed should produce 3~5 base items');
        // All items should not be sold
        for (final item in items) {
          expect(item.sold, false);
        }
      }
    });

    test('always includes card removal service', () {
      final items = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final removals = items.where((i) => i.itemType == ItemType.cardRemoval);
      expect(removals.length, 1);
      expect(removals.first.price, ShopItemGenerator.cardRemovalPrice);
    });

    test('includes 1~2 card items', () {
      final items = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final cards = items.where((i) => i.itemType == ItemType.card);
      expect(cards.length, inInclusiveRange(1, 2));
    });

    test('prices scale with floor using shopPriceFloorMultiplier', () {
      final floor1Items = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final floor5Items = ShopItemGenerator.generateItems(
        floor: 5,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );

      final base1 = _baseItems(floor1Items);
      final base5 = _baseItems(floor5Items);

      // Same seed → same rarity distribution → can compare prices
      final floor1CommonPrice = base1
          .where((i) => i.rarity == Rarity.common)
          .map((i) => i.price);
      final floor5CommonPrice = base5
          .where((i) => i.rarity == Rarity.common)
          .map((i) => i.price);

      if (floor1CommonPrice.isNotEmpty && floor5CommonPrice.isNotEmpty) {
        expect(floor5CommonPrice.first, greaterThan(floor1CommonPrice.first));
      }

      // Floor 5 base items should all be more expensive than floor 1
      for (int i = 0; i < base1.length && i < base5.length; i++) {
        if (base1[i].rarity == base5[i].rarity) {
          expect(base5[i].price, greaterThan(base1[i].price),
              reason: 'Floor 5 item $i should be more expensive than floor 1');
        }
      }
    });

    test('same seed produces identical items', () {
      final items1 = ShopItemGenerator.generateItems(
        floor: 2,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final items2 = ShopItemGenerator.generateItems(
        floor: 2,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );

      expect(items1.length, items2.length);
      for (int i = 0; i < items1.length; i++) {
        expect(items1[i], items2[i]);
      }
    });

    test('기본 RarityConfig — 4등급 분포 (common 55%, rare 30%, legendary 10%, cursed 5%)', () {
      int commonCount = 0;
      int rareCount = 0;
      int legendaryCount = 0;
      int cursedCount = 0;
      int total = 0;

      for (int seed = 0; seed < 200; seed++) {
        final items = ShopItemGenerator.generateItems(
          floor: 1,
          economyConfig: economyConfig,
          jobRewardsLookup: CardPool.jobRewards,
          colorlessCards: ColorlessCards.all,
          seed: seed,
        );
        // 기본 아이템만 집계 (카드/카드제거 제외)
        for (final item in _baseItems(items)) {
          total++;
          switch (item.rarity) {
            case Rarity.common:
              commonCount++;
            case Rarity.rare:
              rareCount++;
            case Rarity.legendary:
              legendaryCount++;
            case Rarity.cursed:
              cursedCount++;
          }
        }
      }

      final commonRatio = commonCount / total;
      final rareRatio = rareCount / total;
      final legendaryRatio = legendaryCount / total;

      expect(commonRatio, closeTo(0.55, 0.15),
          reason: 'Common should be ~55% (was ${(commonRatio * 100).toStringAsFixed(1)}%)');
      expect(rareRatio, closeTo(0.30, 0.15),
          reason: 'Rare should be ~30% (was ${(rareRatio * 100).toStringAsFixed(1)}%)');
      expect(legendaryRatio, closeTo(0.10, 0.1),
          reason: 'Legendary should be ~10% (was ${(legendaryRatio * 100).toStringAsFixed(1)}%)');
      expect(cursedCount, greaterThan(0), reason: 'Cursed items should be generated');
    });

    test('cursed 가중치 0 → cursed 아이템 없음', () {
      const noCursedConfig = RarityConfig(weightCursed: 0);

      for (int seed = 0; seed < 100; seed++) {
        final items = ShopItemGenerator.generateItems(
          floor: 1,
          economyConfig: economyConfig,
          rarityConfig: noCursedConfig,
          jobRewardsLookup: CardPool.jobRewards,
          colorlessCards: ColorlessCards.all,
          seed: seed,
        );
        for (final item in _baseItems(items)) {
          expect(item.rarity, isNot(Rarity.cursed),
              reason: 'seed=$seed should not produce cursed items');
        }
      }
    });

    test('cursed 아이템은 전용 풀에서 선택됨', () {
      const onlyCursed = RarityConfig(
        weightCommon: 0,
        weightRare: 0,
        weightLegendary: 0,
        weightCursed: 100,
      );

      final items = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        rarityConfig: onlyCursed,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );

      for (final item in _baseItems(items)) {
        expect(item.rarity, Rarity.cursed);
        expect(item.id, startsWith('cb_'));
      }
    });

    test('cursed 아이템 가격 — priceMultiplierCursed 적용', () {
      const cursedConfig = RarityConfig(
        weightCommon: 0,
        weightRare: 0,
        weightLegendary: 0,
        weightCursed: 100,
        priceMultiplierCursed: 0.8,
      );

      final items = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        rarityConfig: cursedConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );

      // basePrice = 20, cursed multiplier = 0.8 → price = 16
      for (final item in _baseItems(items)) {
        expect(item.price, 16);
      }
    });
  });
}
