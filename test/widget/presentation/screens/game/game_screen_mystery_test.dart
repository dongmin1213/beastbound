import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';

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

  group('GameScreen 미스터리 연동', () {
    testWidgets('AC9 미스터리 진입 서술 텍스트 표시', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      const outcome = TreasureOutcome(
        goldReward: 20,
        narrativeText: '빛나는 보물 상자를 발견했다!',
      );
      gameState.enterMysteryForTest(outcome, withGold: 50);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // MysteryWidget 렌더링 확인
      expect(find.text('??? 미스터리 방'), findsOneWidget);
      expect(find.text('보물 발견!'), findsOneWidget);
      expect(find.text('빛나는 보물 상자를 발견했다!'), findsOneWidget);
      expect(find.text('+20 골드'), findsOneWidget);
    });

    testWidgets('AC10 결과 피드백 텍스트 — 보물 골드 획득', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // GoldGainedEvent 구독
      GoldGainedEvent? receivedEvent;
      final sub = gameEventBus.on<GoldGainedEvent>().listen((event) {
        receivedEvent = event;
      });
      addTearDown(() => sub.cancel());

      const outcome = TreasureOutcome(
        goldReward: 20,
        narrativeText: '보물!',
      );
      gameState.enterMysteryForTest(outcome, withGold: 30);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // "진행하기" 버튼 탭
      await tester.tap(find.text('진행하기'));
      await tester.pump(); // MysteryBloc AcceptResult → MysteryCompleted
      await tester.pump(); // BlocListener → _onMysteryCompleted
      await tester.pump(); // setState + _appendFeedbackText
      await tester.pump(); // scroll

      // 골드 업데이트 확인
      expect(gameState.playerRunStateForTest.gold, 50); // 30 + 20

      // 피드백 텍스트
      expect(findRichText('20 골드 획득!'), findsOneWidget);

      // GoldGainedEvent 발행 확인
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.amount, 20);
      expect(receivedEvent!.totalGold, 50);
    });

    testWidgets('AC10 결과 피드백 텍스트 — 함정 HP 손실 + gold 업데이트', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      const outcome = TrapOutcome(
        hpLoss: 15,
        narrativeText: '함정!',
      );
      gameState.enterMysteryForTest(outcome, withGold: 10);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // "진행하기" 버튼 탭
      await tester.tap(find.text('진행하기'));
      await tester.pump(); // MysteryBloc AcceptResult → MysteryCompleted
      await tester.pump(); // BlocListener → _onMysteryCompleted
      await tester.pump(); // setState + _appendFeedbackText
      await tester.pump(); // scroll

      // HP 감소 확인
      expect(gameState.playerRunStateForTest.currentHp, 85); // 100 - 15

      // 골드는 변화 없음
      expect(gameState.playerRunStateForTest.gold, 10);

      // 피드백 텍스트
      expect(findRichText('15 HP 손실!'), findsOneWidget);
    });

    testWidgets('함정 permadeath 트리거 확인 (HP ≤ 0)', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // HP를 10으로 설정
      const outcome = TrapOutcome(
        hpLoss: 15,
        narrativeText: '함정!',
      );
      gameState.enterMysteryForTest(outcome, withHp: 10);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // "진행하기" 버튼 탭
      await tester.tap(find.text('진행하기'));
      await tester.pump(); // MysteryBloc AcceptResult → MysteryCompleted
      await tester.pump(); // BlocListener → _onMysteryCompleted → setTextBlockData
      await tester.pump(); // TypewriterWidget init (instant)
      await tester.pump(); // onComplete → setState
      await tester.pump(); // rebuild after completed
      await tester.pump(); // final settle

      // HP 0 확인
      expect(gameState.playerRunStateForTest.currentHp, 0);

      // permadeath 텍스트 — CompletedBlock RichText 또는 TypewriterWidget Text
      final permadeathFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is RichText) {
            final span = widget.text;
            if (span is TextSpan) {
              return span.text?.contains('치명적인 함정에 의해 쓰러졌다') ?? false;
            }
          }
          if (widget is Text) {
            return widget.data?.contains('치명적인 함정에 의해 쓰러졌다') ?? false;
          }
          return false;
        },
        description: 'Widget containing "치명적인 함정에 의해 쓰러졌다"',
      );
      expect(permadeathFinder, findsAtLeastNWidgets(1),
          reason: 'permadeath 텍스트가 표시되어야 함');
    });
  });
}
