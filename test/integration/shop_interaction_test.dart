import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/shop/shop_widget.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';

import 'helpers/integration_test_helper.dart';

void main() {
  IntegrationTestHelper.ensureInitialized();

  group('Shop interaction', () {
    testWidgets('상점 진입 → ShopWidget 렌더링', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      // 상점 진입 시뮬레이션 (테스트 헬퍼 사용)
      state.enterShopForTest([
        const ShopItem(id: 'potion_1', name: '체력 물약', price: 10, description: 'HP 회복', itemType: ItemType.supply, rarity: Rarity.common),
        const ShopItem(id: 'stone_1', name: '강화석', price: 20, description: '공격력 증가', itemType: ItemType.supply, rarity: Rarity.common),
      ], withGold: 50);
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // ShopWidget 렌더링 확인
      expect(find.byType(ShopWidget), findsOneWidget);

      eventBus.dispose();
    });

    testWidgets('상점 진입 → 아이템 목록 표시', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      state.enterShopForTest([
        const ShopItem(id: 'potion_1', name: '체력 물약', price: 10, description: 'HP 회복', itemType: ItemType.supply, rarity: Rarity.common),
      ], withGold: 50);
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // 아이템 이름 표시
      expect(find.textContaining('체력 물약'), findsOneWidget);

      eventBus.dispose();
    });

    testWidgets('상점 진입 → 골드 잔액 표시', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      state.enterShopForTest([], withGold: 75);
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // 골드 잔액
      expect(state.playerRunStateForTest.gold, 75);

      eventBus.dispose();
    });
  });
}
