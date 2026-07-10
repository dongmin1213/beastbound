import 'package:flutter/material.dart' hide SelectAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/models/devil_deal_data.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import '../../../../helpers/game_screen_test_helper.dart';


void main() {
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  Widget buildScreen() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MomentumBloc>(
          create: (_) => MomentumBloc(
            gameEventBus: eventBus,
            config: const MomentumConfig(),
          ),
        ),
        BlocProvider<ProgressionBloc>(
          create: (_) => ProgressionBloc(gameEventBus: eventBus),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: GameScreen(
          gameEventBus: eventBus,
          initialBlockData: const [TextBlockData(text: '테스트')],
          speed: TextSpeed.instant,
          economyConfig: const EconomyConfig(),
          eventConfig: const EventConfig(),
        ),
      ),
    );
  }

  // deal_001: 피의 계약(축복) + 약화(저주), cost=0
  const testDeal = DevilDealData(
    id: 'deal_001',
    blessingId: 'devil_blessing_001',
    curseId: 'curse_001',
    flavorText: '힘을 원하는가? 대가는 육체의 쇠약.',
  );

  // deal_004: 광기의 힘(축복) + 적의(저주), cost=10
  const costDeal = DevilDealData(
    id: 'deal_004',
    blessingId: 'devil_blessing_004',
    curseId: 'curse_004',
    cost: 10,
    flavorText: '절대적 힘... 하지만 적도 강해진다.',
  );

  /// 악마 거래 진입 후 첫 블록 완료 대기.
  Future<void> enterDeal(WidgetTester tester, GameScreenState state, DevilDealData deal) async {
    state.enterDevilDealForTest(deal);
    await tester.pump(); // setState
    await tester.pump(); // postFrameCallback → scrollToBottom
    await tester.pump(); // postFrameCallback → onComplete (instant)
    await tester.pump(); // setState → rebuild
  }

  /// 블록 하나 advance (탭 → 다음 블록 완료 대기).
  Future<void> advanceBlock(WidgetTester tester) async {
    await tapGameScreen(tester);
    await tester.pump(); // process tap
    await tester.pump(); // postFrameCallback
    await tester.pump(); // onComplete (instant)
    await tester.pump(); // rebuild
  }

  /// 3개 블록 모두 advance → 선택지 표시.
  /// Block 0: "수상한 인물..." → Block 1: flavor → Block 2: 축복/저주+선택지.
  Future<void> advanceToDevilChoices(WidgetTester tester) async {
    await advanceBlock(tester); // block 0 → block 1
    await advanceBlock(tester); // block 1 → block 2 (with choices)
  }

  group('GameScreen devil deal', () {
    testWidgets('악마 거래 진입 → 수상한 인물 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      await enterDeal(tester, state, testDeal);

      // 수상한 인물 텍스트 (TypewriterWidget 직접 확인)
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('수상한 인물이 다가온다'));
    });

    testWidgets('악마 거래 → 선택지 2개 표시', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      await enterDeal(tester, state, testDeal);
      await advanceToDevilChoices(tester);

      // 선택지 2개
      expect(find.textContaining('거래를 수락한다'), findsOneWidget);
      expect(find.textContaining('거절하고 상점으로 간다'), findsOneWidget);
    });

    testWidgets('거래 수락 → 축복+저주 적용', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      expect(state.playerRunStateForTest.ownedBlessingIds, isEmpty);
      expect(state.playerRunStateForTest.activeCurseIds, isEmpty);

      await enterDeal(tester, state, testDeal);
      await advanceToDevilChoices(tester);

      // 수락 선택
      await tester.tap(find.textContaining('거래를 수락한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 축복+저주 적용 확인
      expect(
        state.playerRunStateForTest.ownedBlessingIds,
        contains('devil_blessing_001'),
      );
      expect(
        state.playerRunStateForTest.activeCurseIds,
        contains('curse_001'),
      );
    });

    testWidgets('거래 거절 → 축복/저주 미적용', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      await enterDeal(tester, state, testDeal);
      await advanceToDevilChoices(tester);

      // 거절 선택
      await tester.tap(find.textContaining('거절하고 상점으로 간다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 축복/저주 없음
      expect(state.playerRunStateForTest.ownedBlessingIds, isEmpty);
      expect(state.playerRunStateForTest.activeCurseIds, isEmpty);
    });

    testWidgets('유료 거래 수락 → 골드 차감', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      // 골드 설정
      state.enterShopForTest([], withGold: 50);
      await tester.pump();
      await tester.pump();

      // 악마 거래 진입 (cost=10)
      await enterDeal(tester, state, costDeal);
      await advanceToDevilChoices(tester);

      // 수락
      await tester.tap(find.textContaining('거래를 수락한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 골드 차감 확인 (50 - 10 = 40)
      expect(state.playerRunStateForTest.gold, 40);

      // 축복+저주 적용 확인
      expect(
        state.playerRunStateForTest.ownedBlessingIds,
        contains('devil_blessing_004'),
      );
      expect(
        state.playerRunStateForTest.activeCurseIds,
        contains('curse_004'),
      );
    });

    testWidgets('거래 flavor 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      await enterDeal(tester, state, testDeal);

      // block 0 → block 1 (flavor)
      await advanceBlock(tester);

      // flavor 텍스트 표시
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('힘을 원하는가'));
    });
  });
}
