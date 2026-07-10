import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/shop_purchase_event.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_event.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_state.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  late GameEventBus gameEventBus;
  late ShopBloc shopBloc;

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

  const item3 = ShopItem(
    id: 'blessing_002',
    name: '방어의 축복',
    description: '방어 효과 강화',
    itemType: ItemType.blessing,
    rarity: Rarity.legendary,
    price: 75,
  );

  setUp(() {
    gameEventBus = GameEventBus();
    shopBloc = ShopBloc(gameEventBus: gameEventBus);
  });

  tearDown(() {
    shopBloc.close();
    gameEventBus.dispose();
  });

  group('ShopBloc', () {
    test('initial state is ShopInitial', () {
      expect(shopBloc.state, isA<ShopInitial>());
    });

    blocTest<ShopBloc, ShopState>(
      'OpenShop emits ShopReady with items and gold',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      act: (bloc) =>
          bloc.add(OpenShop(items: [item1, item2], playerGold: 50)),
      expect: () => [
        ShopReady(
          items: const [item1, item2],
          gold: 50,
          purchasedItems: const [],
        ),
      ],
    );

    blocTest<ShopBloc, ShopState>(
      'OpenShop with empty list emits ShopReady with empty items',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      act: (bloc) =>
          bloc.add(const OpenShop(items: [], playerGold: 100)),
      expect: () => [
        const ShopReady(items: [], gold: 100, purchasedItems: []),
      ],
    );

    blocTest<ShopBloc, ShopState>(
      'PurchaseItem succeeds when gold >= price and item not sold',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      seed: () => ShopReady(
        items: const [item1, item2],
        gold: 50,
        purchasedItems: const [],
      ),
      act: (bloc) => bloc.add(const PurchaseItem(0)),
      expect: () => [
        ShopReady(
          items: [item1.copyWith(sold: true), item2],
          gold: 20, // 50 - 30
          purchasedItems: [item1.copyWith(sold: true)],
        ),
      ],
    );

    blocTest<ShopBloc, ShopState>(
      'PurchaseItem fails when gold < price — state unchanged',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      seed: () => ShopReady(
        items: const [item2],
        gold: 40, // price is 45
        purchasedItems: const [],
      ),
      act: (bloc) => bloc.add(const PurchaseItem(0)),
      expect: () => [],
    );

    blocTest<ShopBloc, ShopState>(
      'PurchaseItem fails when item already sold — state unchanged',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      seed: () => ShopReady(
        items: [item1.copyWith(sold: true)],
        gold: 100,
        purchasedItems: const [item1],
      ),
      act: (bloc) => bloc.add(const PurchaseItem(0)),
      expect: () => [],
    );

    blocTest<ShopBloc, ShopState>(
      'PurchaseItem fails when index out of range (positive) — state unchanged',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      seed: () => ShopReady(
        items: const [item1],
        gold: 100,
        purchasedItems: const [],
      ),
      act: (bloc) => bloc.add(const PurchaseItem(99)),
      expect: () => [],
    );

    blocTest<ShopBloc, ShopState>(
      'PurchaseItem fails when index negative — state unchanged',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      seed: () => ShopReady(
        items: const [item1],
        gold: 100,
        purchasedItems: const [],
      ),
      act: (bloc) => bloc.add(const PurchaseItem(-1)),
      expect: () => [],
    );

    blocTest<ShopBloc, ShopState>(
      'LeaveShop emits ShopClosed with remaining gold and purchased items',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      seed: () => ShopReady(
        items: [item1.copyWith(sold: true), item2],
        gold: 20,
        purchasedItems: [item1.copyWith(sold: true)],
      ),
      act: (bloc) => bloc.add(const LeaveShop()),
      expect: () => [
        ShopClosed(remainingGold: 20, purchasedItems: [item1.copyWith(sold: true)]),
      ],
    );

    blocTest<ShopBloc, ShopState>(
      'multiple purchases reduce gold correctly',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      seed: () => ShopReady(
        items: const [item1, item2, item3],
        gold: 200,
        purchasedItems: const [],
      ),
      act: (bloc) {
        bloc.add(const PurchaseItem(0)); // 30 gold
        bloc.add(const PurchaseItem(1)); // 45 gold
      },
      expect: () => [
        ShopReady(
          items: [item1.copyWith(sold: true), item2, item3],
          gold: 170,
          purchasedItems: [item1.copyWith(sold: true)],
        ),
        ShopReady(
          items: [
            item1.copyWith(sold: true),
            item2.copyWith(sold: true),
            item3,
          ],
          gold: 125,
          purchasedItems: [item1.copyWith(sold: true), item2.copyWith(sold: true)],
        ),
      ],
    );

    blocTest<ShopBloc, ShopState>(
      'PurchaseItem emits ShopPurchaseEvent on GameEventBus',
      build: () => ShopBloc(gameEventBus: gameEventBus),
      seed: () => ShopReady(
        items: const [item1],
        gold: 50,
        purchasedItems: const [],
      ),
      act: (bloc) async {
        final future = gameEventBus.on<ShopPurchaseEvent>().first;
        bloc.add(const PurchaseItem(0));
        final event = await future;
        expect(event.itemId, 'blessing_001');
        expect(event.itemName, '힘의 축복');
        expect(event.price, 30);
        expect(event.remainingGold, 20);
      },
      expect: () => [
        ShopReady(
          items: [item1.copyWith(sold: true)],
          gold: 20,
          purchasedItems: [item1.copyWith(sold: true)],
        ),
      ],
    );
  });
}
