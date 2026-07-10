import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/npc/npc_widget.dart';

void main() {
  const testItem1 = ShopItem(
    id: 'npc_blessing_001',
    name: '은둔자의 부적',
    description: '전투 시 방어력 약간 증가',
    itemType: ItemType.blessing,
    rarity: Rarity.common,
    price: 30,
  );

  const testItem2 = ShopItem(
    id: 'npc_supply_001',
    name: '방랑자의 물약',
    description: 'HP 소량 회복',
    itemType: ItemType.supply,
    rarity: Rarity.rare,
    price: 45,
  );

  const traderNpc = NpcData(
    id: 'npc_trader_42',
    npcType: NpcType.trader,
    name: '방랑 상인 이즈',
    greetingText: '방랑 상인이 반갑게 손을 흔든다.',
    dialogueText: '이 던전에서 좋은 물건을 많이 모았지.',
    tradeItems: [testItem1, testItem2],
    goldReward: 0,
  );

  const sageNpc = NpcData(
    id: 'npc_sage_42',
    npcType: NpcType.sage,
    name: '현자 마로',
    greetingText: '긴 수염의 현자가 고개를 끄덕인다.',
    dialogueText: '이 층의 적들은 만만치 않다네.',
    tradeItems: [],
    goldReward: 8,
  );

  Widget buildNpcWidget({
    NpcData npc = traderNpc,
    int playerGold = 100,
    bool dialogueRead = false,
    ValueChanged<int>? onPurchase,
    VoidCallback? onReadDialogue,
    VoidCallback? onLeave,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: NpcWidget(
            npc: npc,
            playerGold: playerGold,
            dialogueRead: dialogueRead,
            onPurchase: onPurchase ?? (_) {},
            onReadDialogue: onReadDialogue ?? () {},
            onLeave: onLeave ?? () {},
          ),
        ),
      ),
    );
  }

  group('NpcWidget', () {
    testWidgets('메인 뷰 렌더링 — NPC 이름, 인사말, 버튼', (tester) async {
      await tester.pumpWidget(buildNpcWidget());

      expect(find.text('NPC 방'), findsOneWidget);
      expect(find.text('방랑 상인 이즈'), findsOneWidget);
      expect(find.text('방랑 상인이 반갑게 손을 흔든다.'), findsOneWidget);
      expect(find.text('대화하기'), findsOneWidget);
      expect(find.text('거래하기'), findsOneWidget);
      expect(find.text('떠나기'), findsOneWidget);
    });

    testWidgets('대화 버튼 탭 → 대화 텍스트 표시', (tester) async {
      bool dialogueRead = false;
      await tester.pumpWidget(buildNpcWidget(
        onReadDialogue: () => dialogueRead = true,
      ));

      await tester.tap(find.text('대화하기'));
      await tester.pump();

      expect(dialogueRead, true);
      expect(find.text('이 던전에서 좋은 물건을 많이 모았지.'), findsOneWidget);
      expect(find.text('돌아가기'), findsOneWidget);
    });

    testWidgets('거래 버튼 탭 → 아이템 목록 표시', (tester) async {
      await tester.pumpWidget(buildNpcWidget());

      await tester.tap(find.text('거래하기'));
      await tester.pump();

      expect(find.text('은둔자의 부적'), findsOneWidget);
      expect(find.text('방랑자의 물약'), findsOneWidget);
      expect(find.text('돌아가기'), findsOneWidget);
    });

    testWidgets('구매 버튼 탭 → onPurchase 콜백', (tester) async {
      int? purchasedIndex;
      await tester.pumpWidget(buildNpcWidget(
        onPurchase: (index) => purchasedIndex = index,
      ));

      // 거래 뷰로 전환
      await tester.tap(find.text('거래하기'));
      await tester.pump();

      // 첫 번째 아이템 구매 버튼 탭
      await tester.tap(find.text('구매').first);
      await tester.pump();

      expect(purchasedIndex, 0);
    });

    testWidgets('떠나기 버튼 탭 → onLeave 콜백', (tester) async {
      bool left = false;
      await tester.pumpWidget(buildNpcWidget(
        onLeave: () => left = true,
      ));

      await tester.tap(find.text('떠나기'));
      await tester.pump();

      expect(left, true);
    });

    testWidgets('sage NPC — 거래 버튼 비표시', (tester) async {
      await tester.pumpWidget(buildNpcWidget(npc: sageNpc));

      expect(find.text('NPC 방'), findsOneWidget);
      expect(find.text('현자 마로'), findsOneWidget);
      expect(find.text('대화하기'), findsOneWidget);
      expect(find.text('거래하기'), findsNothing);
      expect(find.text('떠나기'), findsOneWidget);
    });

    testWidgets('sage NPC — 대화 보상 힌트 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildNpcWidget(npc: sageNpc));

      expect(find.text('대화하면 보상을 받을 수 있을 것 같다.'), findsOneWidget);
    });
  });
}
