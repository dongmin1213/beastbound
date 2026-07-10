import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/combat_reward_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

import '../../../../helpers/game_screen_test_helper.dart';
import '../../../../helpers/rich_text_finder.dart';

void main() {
  late GameEventBus gameEventBus;

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  const shopItem1 = ShopItem(
    id: 'blessing_001',
    name: '힘의 축복',
    description: '공격 효과 강화',
    itemType: ItemType.blessing,
    rarity: Rarity.common,
    price: 30,
  );

  group('GameScreen 상점 연동', () {
    testWidgets('CombatRewardEvent 구독 dispose 시 메모리 누수 없음', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      // GameScreen dispose 시 StreamSubscription 정리 확인
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('replaced'))),
      );
      await tester.pump();

      // dispose 후 이벤트 발행해도 에러 없음 (구독 해제됨)
      gameEventBus.emit(CombatRewardEvent(goldAmount: 10));

      expect(find.text('replaced'), findsOneWidget);
    });

    testWidgets('CombatRewardEvent 수신 시 Gold 획득 피드백 + GoldGainedEvent 발행', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      // GoldGainedEvent 구독
      GoldGainedEvent? receivedEvent;
      final sub = gameEventBus.on<GoldGainedEvent>().listen((event) {
        receivedEvent = event;
      });
      addTearDown(() => sub.cancel());

      // CombatRewardEvent 발행
      gameEventBus.emit(CombatRewardEvent(goldAmount: 10));
      await tester.pump(); // setState rebuild
      await tester.pump(); // scroll callback

      // RichText로 렌더링되므로 findRichText 사용
      expect(findRichText('10 골드 획득!'), findsOneWidget);

      // GoldGainedEvent 수신 확인 (동기적으로 emit → listen 전달)
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.amount, 10);
      expect(receivedEvent!.totalGold, 10);
    });

    testWidgets('다중 CombatRewardEvent로 gold 누적 확인', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      // 3회 전투 승리 시뮬레이션
      gameEventBus.emit(CombatRewardEvent(goldAmount: 10));
      await tester.pump();
      await tester.pump();

      gameEventBus.emit(CombatRewardEvent(goldAmount: 10));
      await tester.pump();
      await tester.pump();

      gameEventBus.emit(CombatRewardEvent(goldAmount: 20));
      await tester.pump();
      await tester.pump();

      // playerRunState.gold = 40 확인
      final gameScreenState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      expect(gameScreenState.playerRunStateForTest.gold, 40);

      // 피드백 텍스트 확인 (RichText)
      expect(findRichText('10 골드 획득!'), findsNWidgets(2));
      expect(findRichText('20 골드 획득!'), findsOneWidget);
    });

    testWidgets('AC12 상점 진입 서술 텍스트 + ShopWidget 렌더링', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterShopForTest([shopItem1], withGold: 50);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // ShopWidget 렌더링 확인
      expect(find.text('여행자의 상점'), findsOneWidget);
      expect(find.text('보유 금화: 50'), findsOneWidget);
      expect(find.text('힘의 축복'), findsOneWidget);
    });

    testWidgets('AC13 구매 피드백 텍스트 표시', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterShopForTest([shopItem1], withGold: 50);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // 구매 버튼 탭
      await tester.tap(find.text('구매'));
      await tester.pump(); // post-frame callback → _appendFeedbackText
      await tester.pump(); // rebuild

      // 구매 피드백 텍스트 확인 (CompletedBlock → RichText)
      expect(findRichText("'힘의 축복'을 구매했다."), findsOneWidget);
    });
  });
}
