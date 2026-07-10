import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('ShopItem', () {
    test('constructor sets default sold=false', () {
      final item = ShopItem(
        id: 'blessing_001',
        name: '힘의 축복',
        description: '공격 효과 강화',
        itemType: ItemType.blessing,
        rarity: Rarity.common,
        price: 30,
      );

      expect(item.id, 'blessing_001');
      expect(item.name, '힘의 축복');
      expect(item.description, '공격 효과 강화');
      expect(item.itemType, ItemType.blessing);
      expect(item.rarity, Rarity.common);
      expect(item.price, 30);
      expect(item.sold, false);
    });

    test('copyWith sold creates new instance with sold=true', () {
      final item = ShopItem(
        id: 'supply_001',
        name: '치유의 물약',
        description: 'HP 회복',
        itemType: ItemType.supply,
        rarity: Rarity.rare,
        price: 45,
      );

      final soldItem = item.copyWith(sold: true);

      expect(soldItem.sold, true);
      expect(soldItem.id, 'supply_001');
      expect(soldItem.price, 45);
      // Original unchanged
      expect(item.sold, false);
    });

    test('Equatable: same fields are equal, different fields are not', () {
      final item1 = ShopItem(
        id: 'blessing_001',
        name: '힘의 축복',
        description: '공격 효과 강화',
        itemType: ItemType.blessing,
        rarity: Rarity.common,
        price: 30,
      );

      final item2 = ShopItem(
        id: 'blessing_001',
        name: '힘의 축복',
        description: '공격 효과 강화',
        itemType: ItemType.blessing,
        rarity: Rarity.common,
        price: 30,
      );

      final differentItem = ShopItem(
        id: 'blessing_002',
        name: '방어의 축복',
        description: '방어 효과 강화',
        itemType: ItemType.blessing,
        rarity: Rarity.rare,
        price: 45,
      );

      expect(item1, item2);
      expect(item1.hashCode, item2.hashCode);
      expect(item1, isNot(differentItem));
    });
  });
}
