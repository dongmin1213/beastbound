import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/event/event_widget.dart';

import '../../../../helpers/game_screen_test_helper.dart';
import '../../../../helpers/rich_text_finder.dart';

void main() {
  late GameEventBus gameEventBus;

  const testChoice1 = EventChoice(
    label: '도움을 준다',
    outcomeText: '감사의 표시로 여행자가 금화를 건넨다.',
    goldChange: 10,
    hpChange: 0,
  );
  const testChoice2 = EventChoice(
    label: '무시하고 지나간다',
    outcomeText: '여행자의 시선을 피해 걸음을 옮긴다.',
    goldChange: 0,
    hpChange: 0,
  );
  const testChoice3 = EventChoice(
    label: '짐을 약탈한다',
    outcomeText: '여행자가 저항했지만... 결국 금화를 빼앗았다.',
    goldChange: 15,
    hpChange: -5,
  );
  final testData = EventRoomData(
    title: '길을 잃은 여행자',
    narrativeText: '어두운 통로 한편에 지친 여행자가 앉아 있다.',
    choices: [testChoice1, testChoice2, testChoice3],
  );

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('GameScreen 이벤트 방 연동', () {
    testWidgets('이벤트 방 진입 → 인트로 텍스트 + EventWidget 표시', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      gameState.enterEventForTest(testData, withGold: 50);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // EventWidget 렌더링 확인
      expect(find.byType(EventWidget), findsOneWidget);
      // RetroWindowFrame 타이틀 + 이벤트 제목 별도 Text 위젯
      expect(find.text('[이벤트]'), findsOneWidget);
      expect(find.text('길을 잃은 여행자'), findsOneWidget);
      expect(find.text('어두운 통로 한편에 지친 여행자가 앉아 있다.'), findsOneWidget);

      // 선택지 label + 효과 요약 표시
      expect(find.text('도움을 준다 (골드 +10)'), findsOneWidget);
      expect(find.text('무시하고 지나간다'), findsOneWidget);
      expect(find.text('짐을 약탈한다 (HP -5 / 골드 +15)'), findsOneWidget);

      // outcomeText 미노출
      expect(find.text('감사의 표시로 여행자가 금화를 건넨다.'), findsNothing);
    });

    testWidgets('선택지 탭 → 결과 텍스트 + 효과 적용', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      gameState.enterEventForTest(testData, withGold: 30);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // 첫 번째 선택지 탭 (도움 → +10 gold)
      await tester.tap(find.text('도움을 준다 (골드 +10)'));
      await tester.pump(); // EventRoomBloc SelectEventChoice → EventRoomCompleted
      await tester.pump(); // BlocListener → _onEventCompleted
      await tester.pump(); // setState + _appendFeedbackText
      await tester.pump(); // scroll

      // 골드 업데이트 확인
      expect(gameState.playerRunStateForTest.gold, 40); // 30 + 10

      // outcomeText 표시
      expect(findRichText('감사의 표시로 여행자가 금화를 건넨다.'), findsOneWidget);

      // EventWidget 사라짐
      expect(find.byType(EventWidget), findsNothing);
    });

    testWidgets('골드 획득 피드백 + GoldGainedEvent', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      GoldGainedEvent? receivedEvent;
      final sub = gameEventBus.on<GoldGainedEvent>().listen((event) {
        receivedEvent = event;
      });
      addTearDown(() => sub.cancel());

      gameState.enterEventForTest(testData, withGold: 30);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 첫 번째 선택지 탭 (도움 → +10 gold)
      await tester.tap(find.text('도움을 준다 (골드 +10)'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 골드 피드백 텍스트
      expect(findRichText('10 골드 획득!'), findsOneWidget);

      // GoldGainedEvent 발행
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.amount, 10);
      expect(receivedEvent!.totalGold, 40);
    });

    testWidgets('HP 회복 피드백', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      const healChoice = EventChoice(
        label: '기도한다',
        outcomeText: '온기가 몸을 감싼다.',
        goldChange: -5,
        hpChange: 10,
      );
      final healData = EventRoomData(
        title: '깨진 제단',
        narrativeText: '고대 제단의 잔해.',
        choices: [healChoice],
      );

      gameState.enterEventForTest(healData, withGold: 20, withHp: 80);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('기도한다 (HP +10 / 골드 -5)'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // HP 회복 확인
      expect(gameState.playerRunStateForTest.currentHp, 90); // 80 + 10
      expect(gameState.playerRunStateForTest.gold, 15); // 20 - 5

      // 피드백 텍스트
      expect(findRichText('HP 10 회복!'), findsOneWidget);
      expect(findRichText('5 골드 소비.'), findsOneWidget);
    });

    testWidgets('HP ≤ 0 → 퍼마데스 플로우', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // HP를 3으로 설정 + 약탈 선택지 (hpChange: -5 → HP 0 이하)
      gameState.enterEventForTest(testData, withHp: 3);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 세 번째 선택지 탭 (약탈 → -5 HP)
      await tester.tap(find.text('짐을 약탈한다 (HP -5 / 골드 +15)'));
      await tester.pump(); // EventRoomBloc → EventRoomCompleted
      await tester.pump(); // BlocListener → _onEventCompleted → setTextBlockData
      await tester.pump(); // TypewriterWidget init
      await tester.pump(); // onComplete
      await tester.pump(); // rebuild
      await tester.pump(); // final settle

      // HP 0 확인
      expect(gameState.playerRunStateForTest.currentHp, 0);

      // permadeath 텍스트 — RichText 또는 Text 어디든 표시
      final permadeathFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is RichText) {
            final span = widget.text;
            if (span is TextSpan) {
              return span.text?.contains('치명적인 결과') ?? false;
            }
          }
          if (widget is Text) {
            return widget.data?.contains('치명적인 결과') ?? false;
          }
          return false;
        },
        description: 'Widget containing "치명적인 결과"',
      );
      expect(permadeathFinder, findsAtLeastNWidgets(1),
          reason: 'permadeath 텍스트가 표시되어야 함');
    });

    testWidgets('HP 정확히 0 경계 → 퍼마데스 (currentHp:5, hpChange:-5)', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      const exactChoice = EventChoice(
        label: '위험한 선택',
        outcomeText: '치명적.',
        goldChange: 0,
        hpChange: -5,
      );
      final exactData = EventRoomData(
        title: '경계 테스트',
        narrativeText: '정확히 0.',
        choices: [exactChoice],
      );

      gameState.enterEventForTest(exactData, withHp: 5);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('위험한 선택 (HP -5)'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // HP 정확히 0 확인
      expect(gameState.playerRunStateForTest.currentHp, 0);

      // permadeath 트리거 확인 (텍스트 또는 선택지)
      final permadeathOrRestartFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is RichText) {
            final span = widget.text;
            if (span is TextSpan) {
              return span.text?.contains('치명적인 결과') ?? false;
            }
          }
          if (widget is Text) {
            final data = widget.data ?? '';
            return data.contains('치명적인 결과') ||
                data.contains('처음부터 다시 시작');
          }
          return false;
        },
        description: 'Widget containing permadeath text or restart choice',
      );
      expect(permadeathOrRestartFinder, findsAtLeastNWidgets(1),
          reason: 'HP 정확히 0에서 퍼마데스 트리거');
    });

    testWidgets('골드 감소 → 0 clamp 방지 (gold:2, goldChange:-5 → gold:0)', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      const expensiveChoice = EventChoice(
        label: '비싼 거래',
        outcomeText: '거래 완료.',
        goldChange: -5,
        hpChange: 0,
      );
      final expensiveData = EventRoomData(
        title: '골드 테스트',
        narrativeText: '골드 부족.',
        choices: [expensiveChoice],
      );

      gameState.enterEventForTest(expensiveData, withGold: 2);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('비싼 거래 (골드 -5)'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 골드 0 이하로 내려가지 않음
      expect(gameState.playerRunStateForTest.gold, 0);
    });

    testWidgets('복합 효과: 골드 획득 + HP 손실 동시 적용 (약탈 선택지)', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // 약탈 선택지: +15 gold, -5 HP
      gameState.enterEventForTest(testData, withGold: 30, withHp: 80);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 세 번째 선택지 탭 (약탈)
      await tester.tap(find.text('짐을 약탈한다 (HP -5 / 골드 +15)'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 골드 증가 + HP 감소 동시 확인
      expect(gameState.playerRunStateForTest.gold, 45); // 30 + 15
      expect(gameState.playerRunStateForTest.currentHp, 75); // 80 - 5

      // 피드백 텍스트 확인
      expect(findRichText('15 골드 획득!'), findsOneWidget);
      expect(findRichText('HP 5 손실!'), findsOneWidget);
    });

    testWidgets('비이벤트 방(shop) 진입 시 _resetEventState 검증', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // 이벤트 방 진입
      gameState.enterEventForTest(testData, withGold: 50);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      // EventWidget 표시 확인
      expect(find.byType(EventWidget), findsOneWidget);

      // 상점 진입 (비이벤트 방) → 이벤트 상태 리셋
      gameState.enterShopForTest([]);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      // EventWidget 사라짐 확인
      expect(find.byType(EventWidget), findsNothing);
    });
  });
}
