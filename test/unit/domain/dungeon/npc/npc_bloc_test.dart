import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/npc_interaction_event.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_event.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_state.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  late GameEventBus gameEventBus;

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

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('NpcBloc', () {
    test('초기 상태는 NpcInitial', () {
      final bloc = NpcBloc(gameEventBus: gameEventBus);
      expect(bloc.state, isA<NpcInitial>());
      bloc.close();
    });

    blocTest<NpcBloc, NpcState>(
      'MeetNpc 성공 — NpcReady emit',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      act: (bloc) =>
          bloc.add(const MeetNpc(npc: traderNpc, playerGold: 100)),
      expect: () => [
        const NpcReady(npc: traderNpc, playerGold: 100, dialogueRead: false),
      ],
    );

    blocTest<NpcBloc, NpcState>(
      'ReadDialogue 성공 — dialogueRead=true',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => const NpcReady(
        npc: sageNpc,
        playerGold: 50,
        dialogueRead: false,
      ),
      act: (bloc) => bloc.add(const ReadDialogue()),
      expect: () => [
        const NpcReady(npc: sageNpc, playerGold: 50, dialogueRead: true),
      ],
    );

    blocTest<NpcBloc, NpcState>(
      'ReadDialogue 잘못된 상태 (NpcInitial) — 무시',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const ReadDialogue()),
      expect: () => [],
    );

    blocTest<NpcBloc, NpcState>(
      'PurchaseNpcItem 성공 — gold 차감, item.sold=true',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => const NpcReady(
        npc: traderNpc,
        playerGold: 100,
        dialogueRead: false,
      ),
      act: (bloc) => bloc.add(const PurchaseNpcItem(0)),
      expect: () => [
        NpcReady(
          npc: traderNpc.copyWith(
            tradeItems: [testItem1.copyWith(sold: true), testItem2],
          ),
          playerGold: 70, // 100 - 30
          dialogueRead: false,
          totalGoldSpent: 30,
        ),
      ],
    );

    blocTest<NpcBloc, NpcState>(
      'PurchaseNpcItem 골드 부족 — 상태 유지',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => const NpcReady(
        npc: traderNpc,
        playerGold: 10, // item1.price = 30
        dialogueRead: false,
      ),
      act: (bloc) => bloc.add(const PurchaseNpcItem(0)),
      expect: () => [],
    );

    blocTest<NpcBloc, NpcState>(
      'PurchaseNpcItem 이미 판매됨 — 상태 유지',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => NpcReady(
        npc: traderNpc.copyWith(
          tradeItems: [testItem1.copyWith(sold: true), testItem2],
        ),
        playerGold: 100,
        dialogueRead: false,
      ),
      act: (bloc) => bloc.add(const PurchaseNpcItem(0)),
      expect: () => [],
    );

    blocTest<NpcBloc, NpcState>(
      'PurchaseNpcItem 잘못된 상태 (NpcInitial) — 무시',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const PurchaseNpcItem(0)),
      expect: () => [],
    );

    blocTest<NpcBloc, NpcState>(
      'PurchaseNpcItem index 범위 초과 (음수/length 이상) — 상태 유지',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => const NpcReady(
        npc: traderNpc,
        playerGold: 100,
        dialogueRead: false,
      ),
      act: (bloc) {
        bloc.add(const PurchaseNpcItem(-1));
        bloc.add(const PurchaseNpcItem(99));
      },
      expect: () => [],
    );

    blocTest<NpcBloc, NpcState>(
      'LeaveNpc 대화 보상 포함 (sage, dialogueRead=true) + totalGoldSpent',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => const NpcReady(
        npc: sageNpc,
        playerGold: 50,
        dialogueRead: true,
      ),
      act: (bloc) => bloc.add(const LeaveNpc()),
      expect: () => [
        const NpcClosed(goldReward: 8, totalGoldSpent: 0),
      ],
    );

    blocTest<NpcBloc, NpcState>(
      'LeaveNpc 대화 안읽음 (sage, dialogueRead=false) — goldReward=0',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => const NpcReady(
        npc: sageNpc,
        playerGold: 50,
        dialogueRead: false,
      ),
      act: (bloc) => bloc.add(const LeaveNpc()),
      expect: () => [
        const NpcClosed(goldReward: 0, totalGoldSpent: 0),
      ],
    );

    blocTest<NpcBloc, NpcState>(
      'LeaveNpc 보상 없음 (trader, dialogueRead=true) — goldReward=0',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => const NpcReady(
        npc: traderNpc,
        playerGold: 100,
        dialogueRead: true,
      ),
      act: (bloc) => bloc.add(const LeaveNpc()),
      expect: () => [
        const NpcClosed(goldReward: 0, totalGoldSpent: 0),
      ],
    );

    blocTest<NpcBloc, NpcState>(
      'LeaveNpc 잘못된 상태 (NpcInitial) — 무시',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const LeaveNpc()),
      expect: () => [],
    );

    blocTest<NpcBloc, NpcState>(
      'PurchaseNpcItem emits NpcInteractionEvent on GameEventBus',
      build: () => NpcBloc(gameEventBus: gameEventBus),
      seed: () => const NpcReady(
        npc: traderNpc,
        playerGold: 100,
        dialogueRead: false,
      ),
      act: (bloc) async {
        final future = gameEventBus.on<NpcInteractionEvent>().first;
        bloc.add(const PurchaseNpcItem(0));
        final event = await future;
        expect(event.npcName, '방랑 상인 이즈');
        expect(event.interactionType, 'trade');
        expect(event.goldChange, -30);
      },
      expect: () => [
        NpcReady(
          npc: traderNpc.copyWith(
            tradeItems: [testItem1.copyWith(sold: true), testItem2],
          ),
          playerGold: 70,
          dialogueRead: false,
          totalGoldSpent: 30,
        ),
      ],
    );
  });
}
