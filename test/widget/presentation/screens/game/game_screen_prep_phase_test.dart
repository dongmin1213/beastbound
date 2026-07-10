import 'package:flutter/material.dart' hide SelectAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import '../../../../helpers/game_screen_test_helper.dart';


void main() {
  late GameEventBus eventBus;
  late DungeonGenerator dungeonGenerator;

  setUp(() {
    eventBus = GameEventBus();
    dungeonGenerator = DungeonGenerator(
      config: const DungeonBalanceConfig(),
      gameEventBus: eventBus,
    );
  });

  tearDown(() {
    eventBus.dispose();
  });

  /// 6개 준비 선택지 이름 목록 — 랜덤 3개 중 어느 것이든 유효.
  final allPrepChoiceNames = [
    '노련한 탐험가의 주머니',
    '생명력의 부적',
    '선대 모험가의 축복',
    '고대의 유물',
    '치유사의 기도',
    '방랑자의 배낭',
  ];

  /// 준비 페이즈 모드: dungeonGenerator 주입 + initialBlockData 없음.
  Widget buildPrepPhaseScreen({
    PrepConfig prepConfig = const PrepConfig(),
  }) {
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
          dungeonGenerator: dungeonGenerator,
          speed: TextSpeed.instant,
          prepConfig: prepConfig,
        ),
      ),
    );
  }

  /// 준비 페이즈 초기화 + 첫 블록 완료까지 대기.
  /// instant 모드: build → postFrameCallback(onComplete) → setState.
  Future<void> pumpPrepPhase(WidgetTester tester, {
    PrepConfig prepConfig = const PrepConfig(),
  }) async {
    await tester.pumpWidget(buildPrepPhaseScreen(prepConfig: prepConfig));
    await tester.pump(); // build frame
    await tester.pump(); // postFrameCallback → onComplete
    await tester.pump(); // setState → rebuild
  }

  /// 인트로 블록 → 선택 프롬프트 블록으로 advance + 선택지 렌더 대기.
  Future<void> advanceToChoices(WidgetTester tester) async {
    // 인트로 블록 완료 상태 → 탭 → advance to block 1
    await tapGameScreen(tester);
    await tester.pump(); // process tap → _advanceToNextBlock
    await tester.pump(); // postFrameCallback → block 1 TypewriterWidget build
    await tester.pump(); // postFrameCallback → onComplete (instant)
    await tester.pump(); // setState → _showingChoices = true, rebuild
  }

  /// 선택 후 결과 처리 대기.
  Future<void> waitForChoiceResult(WidgetTester tester) async {
    await tester.pump(); // process tap
    await tester.pump(const Duration(milliseconds: 500)); // async processing
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// 현재 표시된 선택지 중 하나 찾아 탭.
  /// 6개 이름 중 화면에 있는 것을 순회하여 첫 번째 매칭을 탭.
  Future<String?> tapFirstVisibleChoice(
    WidgetTester tester,
    List<String> candidateNames,
  ) async {
    for (final name in candidateNames) {
      final finder = find.textContaining(name);
      if (finder.evaluate().isNotEmpty) {
        expect(finder, findsOneWidget);
        await tester.tap(finder);
        return name;
      }
    }
    return null;
  }

  group('GameScreen prep phase', () {
    testWidgets('준비 페이즈 → 인트로 텍스트 표시', (tester) async {
      await pumpPrepPhase(tester);

      // PrepPhaseData.introText 표시
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('던전의 입구에 서있다'));
    });

    testWidgets('인트로 탭 → 선택지 3개 표시', (tester) async {
      await pumpPrepPhase(tester);
      await advanceToChoices(tester);

      // 6개 중 랜덤 3개가 표시됨 — 각각이 유효한 선택지인지 확인
      int visibleCount = 0;
      for (final name in allPrepChoiceNames) {
        if (find.textContaining(name).evaluate().isNotEmpty) {
          visibleCount++;
        }
      }
      expect(visibleCount, 3);
    });

    testWidgets('HP 선택 → 시작 HP 증가', (tester) async {
      await pumpPrepPhase(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final initialHp = state.playerRunStateForTest.currentHp;
      final initialMaxHp = state.playerRunStateForTest.maxHp;

      await advanceToChoices(tester);

      // HP 타입 선택지 찾기 (생명력의 부적 or 치유사의 기도)
      final hpChoiceNames = ['생명력의 부적', '치유사의 기도'];
      final tapped = await tapFirstVisibleChoice(tester, hpChoiceNames);

      if (tapped != null) {
        await waitForChoiceResult(tester);
        // HP 증가 확인 (어느 선택지든 HP가 증가해야 함)
        expect(state.playerRunStateForTest.currentHp, greaterThan(initialHp));
        expect(state.playerRunStateForTest.maxHp, greaterThan(initialMaxHp));
      }
      // HP 선택지가 랜덤으로 안 나올 수 있으므로, 나오지 않으면 스킵
    });

    testWidgets('PrepConfig 기본값 → 선택지 텍스트에 반영', (tester) async {
      await pumpPrepPhase(tester);
      await advanceToChoices(tester);

      // 6개 중 3개가 표시되므로, 표시된 선택지의 텍스트가 올바른지 확인
      // 골드 선택지가 있으면 +20 포함
      if (find.textContaining('노련한 탐험가의 주머니').evaluate().isNotEmpty) {
        expect(find.textContaining('시작 골드 +20'), findsOneWidget);
      }
      // HP 선택지가 있으면 +15 포함
      if (find.textContaining('생명력의 부적').evaluate().isNotEmpty) {
        expect(find.textContaining('시작 HP +15'), findsOneWidget);
      }
      // 축복 선택지가 있으면 축복 텍스트 포함
      if (find.textContaining('선대 모험가의 축복').evaluate().isNotEmpty) {
        expect(find.textContaining('시작 축복 1개 획득'), findsOneWidget);
      }
    });

    testWidgets('골드 선택 → 결과 텍스트 탭 → 던전 인트로 표시', (tester) async {
      await pumpPrepPhase(tester);
      await advanceToChoices(tester);

      // 아무 선택지나 탭
      final tapped = await tapFirstVisibleChoice(tester, allPrepChoiceNames);
      expect(tapped, isNotNull);
      await waitForChoiceResult(tester);

      // 결과 텍스트 표시 확인
      expect(find.byType(TypewriterWidget), findsOneWidget);

      // 결과 텍스트 탭 → 던전 인트로 전환
      await tapGameScreen(tester);
      await tester.pump(); // advance to next block
      await tester.pump(); // postFrameCallback → _showDungeonFloorIntro
      await tester.pump(); // rebuild with new text blocks
      await tester.pump(); // postFrameCallback → onComplete (instant)
      await tester.pump(); // setState

      // 던전 인트로 텍스트 표시 확인
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final introWidget = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(introWidget.text, contains('던전 1층에 발을 들인다'));
    });

    testWidgets('골드 선택 → 시작 골드 증가', (tester) async {
      await pumpPrepPhase(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final initialGold = state.playerRunStateForTest.gold;

      await advanceToChoices(tester);

      // 골드 타입 선택지 찾기
      if (find.textContaining('노련한 탐험가의 주머니').evaluate().isNotEmpty) {
        await tester.tap(find.textContaining('노련한 탐험가의 주머니'));
        await waitForChoiceResult(tester);
        expect(state.playerRunStateForTest.gold, initialGold + 20);
      }
    });

    testWidgets('축복 선택 → 축복 ID 추가', (tester) async {
      await pumpPrepPhase(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      expect(state.playerRunStateForTest.ownedBlessingIds, isEmpty);

      await advanceToChoices(tester);

      if (find.textContaining('선대 모험가의 축복').evaluate().isNotEmpty) {
        await tester.tap(find.textContaining('선대 모험가의 축복'));
        await waitForChoiceResult(tester);
        expect(
          state.playerRunStateForTest.ownedBlessingIds,
          contains('blessing_001'),
        );
      }
    });

    testWidgets('골드 선택 → 결과 텍스트 표시', (tester) async {
      await pumpPrepPhase(tester);
      await advanceToChoices(tester);

      if (find.textContaining('노련한 탐험가의 주머니').evaluate().isNotEmpty) {
        await tester.tap(find.textContaining('노련한 탐험가의 주머니'));
        await waitForChoiceResult(tester);

        expect(find.byType(TypewriterWidget), findsOneWidget);
        final typewriter = tester.widget<TypewriterWidget>(
          find.byType(TypewriterWidget),
        );
        expect(typewriter.text, contains('골드를 챙겼다'));
      }
    });

    testWidgets('HP 선택 → 결과 텍스트에 HP 표시', (tester) async {
      await pumpPrepPhase(tester);
      await advanceToChoices(tester);

      if (find.textContaining('생명력의 부적').evaluate().isNotEmpty) {
        await tester.tap(find.textContaining('생명력의 부적'));
        await waitForChoiceResult(tester);

        expect(find.byType(TypewriterWidget), findsOneWidget);
        final typewriter = tester.widget<TypewriterWidget>(
          find.byType(TypewriterWidget),
        );
        expect(typewriter.text, contains('생명력이 강화되었다'));
      }
    });
  });
}
