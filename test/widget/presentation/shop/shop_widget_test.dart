import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/shop/shop_widget.dart';

void main() {
  const item1 = ShopItem(
    id: 'blessing_001',
    name: '힘의 축복',
    description: '공격 효과 강화',
    itemType: ItemType.blessing,
    rarity: Rarity.common,
    price: 30,
  );

  const item2 = ShopItem(
    id: 'supply_001',
    name: '치유의 물약',
    description: 'HP 회복',
    itemType: ItemType.supply,
    rarity: Rarity.rare,
    price: 45,
  );

  const soldItem = ShopItem(
    id: 'blessing_002',
    name: '방어의 축복',
    description: '방어 효과 강화',
    itemType: ItemType.blessing,
    rarity: Rarity.legendary,
    price: 75,
    sold: true,
  );

  Widget buildShopWidget({
    List<ShopItem> items = const [],
    int gold = 50,
    ValueChanged<int>? onBuy,
    VoidCallback? onLeave,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ShopWidget(
            items: items,
            gold: gold,
            onBuy: onBuy ?? (_) {},
            onLeave: onLeave ?? () {},
          ),
        ),
      ),
    );
  }

  group('ShopWidget', () {
    testWidgets('아이템 카드 렌더링 — 이름, 설명, 가격, 희귀도', (tester) async {
      await tester.pumpWidget(buildShopWidget(
        items: [item1, item2],
        gold: 50,
      ));

      expect(find.text('여행자의 상점'), findsOneWidget);
      expect(find.text('힘의 축복'), findsOneWidget);
      expect(find.text('공격 효과 강화'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('[일반]'), findsOneWidget);
      expect(find.text('치유의 물약'), findsOneWidget);
      expect(find.text('HP 회복'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('[희귀]'), findsOneWidget);
    });

    testWidgets('골드 잔액 표시', (tester) async {
      await tester.pumpWidget(buildShopWidget(
        items: [item1],
        gold: 123,
      ));

      expect(find.text('보유 금화: 123'), findsOneWidget);
    });

    testWidgets('구매 버튼 탭 시 onBuy 콜백 호출', (tester) async {
      int? boughtIndex;
      await tester.pumpWidget(buildShopWidget(
        items: [item1],
        gold: 50,
        onBuy: (index) => boughtIndex = index,
      ));

      // Find and tap the buy button
      final buyButton = find.text('구매');
      expect(buyButton, findsOneWidget);
      await tester.tap(buyButton);

      expect(boughtIndex, 0);
    });

    testWidgets('골드 부족 시 구매 버튼 비활성화', (tester) async {
      int? boughtIndex;
      await tester.pumpWidget(buildShopWidget(
        items: [item2], // price 45
        gold: 40, // not enough
        onBuy: (index) => boughtIndex = index,
      ));

      // Button should show '부족' and be disabled
      expect(find.text('부족'), findsOneWidget);
      await tester.tap(find.text('부족'));

      expect(boughtIndex, isNull);
    });

    testWidgets('상점 나가기 버튼 탭 시 onLeave 콜백 호출', (tester) async {
      bool left = false;
      await tester.pumpWidget(buildShopWidget(
        items: [item1, soldItem],
        gold: 50,
        onLeave: () => left = true,
      ));

      expect(find.text('상점 나가기'), findsOneWidget);
      await tester.tap(find.text('상점 나가기'));

      expect(left, true);
    });
  });
}
