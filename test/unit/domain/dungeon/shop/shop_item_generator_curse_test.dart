import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item_generator.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';

/// 카드/카드제거 아이템은 priceMultiplier 영향을 받지 않으므로 비교에서 제외.
List<ShopItem> _baseItems(List<ShopItem> items) =>
    items.where((i) => i.itemType != ItemType.card && i.itemType != ItemType.cardRemoval).toList();

void main() {
  const economyConfig = EconomyConfig();

  group('ShopItemGenerator - Curse Price Multiplier', () {
    test('priceMultiplier 1.0 → 기본 가격과 동일', () {
      final items1 = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final items2 = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        priceMultiplier: 1.0,
        seed: 42,
      );

      final base1 = _baseItems(items1);
      final base2 = _baseItems(items2);
      expect(base1.length, base2.length);
      for (int i = 0; i < base1.length; i++) {
        expect(base1[i].price, base2[i].price);
      }
    });

    test('priceMultiplier 기본값 → 1.0과 동일', () {
      final itemsDefault = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final itemsExplicit = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        priceMultiplier: 1.0,
        seed: 42,
      );

      final baseDefault = _baseItems(itemsDefault);
      final baseExplicit = _baseItems(itemsExplicit);
      expect(baseDefault.length, baseExplicit.length);
      for (int i = 0; i < baseDefault.length; i++) {
        expect(baseDefault[i].price, baseExplicit[i].price);
      }
    });

    test('priceMultiplier 1.5 → 가격 ~1.5배', () {
      final itemsBase = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final itemsCursed = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        priceMultiplier: 1.5,
        seed: 42,
      );

      final base = _baseItems(itemsBase);
      final cursed = _baseItems(itemsCursed);
      expect(base.length, cursed.length);
      for (int i = 0; i < base.length; i++) {
        // priceMultiplier는 basePrice에 먼저 적용 후 rarity 배율 적용 →
        // double rounding으로 ±1 오차 가능
        expect(
          cursed[i].price,
          closeTo(base[i].price * 1.5, 1.5),
          reason: 'Item $i should be ~1.5x more expensive (±1 rounding)',
        );
      }
    });

    test('priceMultiplier 2.0 → 가격 2배', () {
      final itemsBase = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final itemsCursed = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        priceMultiplier: 2.0,
        seed: 42,
      );

      final base = _baseItems(itemsBase);
      final cursed = _baseItems(itemsCursed);
      expect(base.length, cursed.length);
      for (int i = 0; i < base.length; i++) {
        // basePrice에서 priceMultiplier 적용 후 한 번만 round()하므로
        // 희귀도 배율 적용 시 ±1 오차 발생 가능 (double rounding)
        expect(
          cursed[i].price,
          closeTo(base[i].price * 2.0, 1.5),
          reason: 'Item $i should be ~2x more expensive (±1 rounding)',
        );
      }
    });

    test('priceMultiplier 0.5 → 가격 절반 (할인 시나리오)', () {
      final itemsBase = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final itemsDiscount = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        priceMultiplier: 0.5,
        seed: 42,
      );

      final base = _baseItems(itemsBase);
      final discount = _baseItems(itemsDiscount);
      expect(base.length, discount.length);
      for (int i = 0; i < base.length; i++) {
        // priceMultiplier는 basePrice에 먼저 적용 후 rarity 배율 적용 →
        // double rounding으로 ±1 오차 가능
        expect(
          discount[i].price,
          closeTo(base[i].price * 0.5, 1.5),
          reason: 'Item $i should be ~0.5x cheaper (±1 rounding)',
        );
      }
    });

    test('priceMultiplier + floor 조합 → 양쪽 배율 모두 적용', () {
      final floor1Base = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final floor5Cursed = ShopItemGenerator.generateItems(
        floor: 5,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        priceMultiplier: 1.5,
        seed: 42,
      );

      final base1 = _baseItems(floor1Base);
      final cursed5 = _baseItems(floor5Cursed);
      expect(base1.length, cursed5.length);
      for (int i = 0; i < base1.length; i++) {
        expect(
          cursed5[i].price,
          greaterThan(base1[i].price * 2),
          reason: 'Floor 5 cursed should be >2x floor 1',
        );
      }
    });

    test('priceMultiplier는 희귀도 보정 후 적용됨', () {
      const onlyCommon = RarityConfig(
        weightCommon: 100,
        weightRare: 0,
        weightLegendary: 0,
        weightCursed: 0,
      );

      final itemsBase = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        rarityConfig: onlyCommon,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );
      final itemsCursed = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        rarityConfig: onlyCommon,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        priceMultiplier: 1.5,
        seed: 42,
      );

      final base = _baseItems(itemsBase);
      final cursed = _baseItems(itemsCursed);
      expect(base.length, cursed.length);
      for (int i = 0; i < base.length; i++) {
        final expectedPrice = (base[i].price * 1.5).round();
        expect(cursed[i].price, expectedPrice);
      }
    });

    test('상점에 카드 아이템과 카드 제거 서비스가 포함됨', () {
      final items = ShopItemGenerator.generateItems(
        floor: 1,
        economyConfig: economyConfig,
        jobRewardsLookup: CardPool.jobRewards,
        colorlessCards: ColorlessCards.all,
        seed: 42,
      );

      // 카드 제거 서비스는 항상 포함
      final removalItems = items.where((i) => i.itemType == ItemType.cardRemoval);
      expect(removalItems.length, 1);
      expect(removalItems.first.price, ShopItemGenerator.cardRemovalPrice);

      // 카드 아이템이 1개 이상 포함 (무색 카드풀에서)
      final cardItems = items.where((i) => i.itemType == ItemType.card);
      expect(cardItems.length, greaterThanOrEqualTo(1));
    });
  });
}
