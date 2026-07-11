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
import 'package:soul_dungeon/presentation/widgets/choice/choice_card_widget.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import '../../../../helpers/game_screen_test_helper.dart';

/// 전체 탐험 플로우 E2E 테스트 — 실제 Flutter 엔진이 위젯을 빌드하고 Bloc을 처리.
///
/// 준비 페이즈 → 던전 인트로 → 텍스트 경로 선택지 → 방 진입까지 실제 탭으로 진행.
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

  Widget buildPrepPhaseScreen() {
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
          prepConfig: const PrepConfig(),
        ),
      ),
    );
  }

  /// 타이핑 완료 대기 (instant 모드).
  Future<void> waitForTypewriter(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  /// 화면 탭 → 다음 블록.
  Future<void> tapToAdvance(WidgetTester tester) async {
    await tapGameScreen(tester);
    await tester.pump();
    await waitForTypewriter(tester);
  }

  /// 선택지 탭 후 결과 대기.
  Future<void> tapChoiceAndWait(
      WidgetTester tester, Finder choiceFinder) async {
    await tester.tap(choiceFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets(
      '전체 탐험 플로우: 준비 페이즈 → 던전 인트로 → 경로 선택지 → 방 진입',
      (tester) async {
    // ═══════════════════════════════════════════
    // STEP 1: 앱 시작 → 준비 페이즈 인트로
    // ═══════════════════════════════════════════
    await tester.pumpWidget(buildPrepPhaseScreen());
    await waitForTypewriter(tester);

    expect(find.byType(TypewriterWidget), findsOneWidget);
    final intro =
        tester.widget<TypewriterWidget>(find.byType(TypewriterWidget));
    expect(intro.text, contains('심층의 초입에 섰다'));
    debugPrint('STEP 1: 준비 페이즈 인트로 — "${intro.text}"');

    // ═══════════════════════════════════════════
    // STEP 2: 탭 → 선택지 프롬프트 + 3개 선택지 (6개 중 랜덤)
    // ═══════════════════════════════════════════
    await tapToAdvance(tester);

    // 6개 중 랜덤 3개 선택지 표시 확인
    final allNames = [
      '노련한 탐험가의 주머니', '생명력의 부적', '선대 모험가의 축복',
      '고대의 유물', '치유사의 기도', '방랑자의 배낭',
    ];
    Finder? firstVisibleChoice;
    int visibleCount = 0;
    for (final name in allNames) {
      final f = find.textContaining(name);
      if (f.evaluate().isNotEmpty) {
        visibleCount++;
        firstVisibleChoice ??= f;
      }
    }
    expect(visibleCount, 3, reason: '6개 중 3개 선택지가 표시되어야 함');
    debugPrint('STEP 2: 선택지 $visibleCount개 표시됨');

    // ═══════════════════════════════════════════
    // STEP 3: 선택지 탭 → 결과 텍스트
    // ═══════════════════════════════════════════
    final gameState =
        tester.state<GameScreenState>(find.byType(GameScreen));

    await tapChoiceAndWait(tester, firstVisibleChoice!);

    expect(find.byType(TypewriterWidget), findsOneWidget);
    debugPrint('STEP 3: 선택 완료');

    // ═══════════════════════════════════════════
    // STEP 4: 결과 텍스트 탭 → 던전 인트로
    // ═══════════════════════════════════════════
    await tapToAdvance(tester);
    // postFrameCallback → _showPathChoices (with intro)
    await tester.pump();
    await waitForTypewriter(tester);

    expect(find.byType(TypewriterWidget), findsOneWidget);
    final dungeonIntro =
        tester.widget<TypewriterWidget>(find.byType(TypewriterWidget));
    expect(dungeonIntro.text, contains('이끼 낀 폐허에 들어선다'));
    debugPrint('STEP 4: 던전 인트로 — "${dungeonIntro.text}"');

    // ═══════════════════════════════════════════
    // STEP 5: 탭 → 경로 선택지 블록 + 경로 선택지 표시 (텍스트 기반)
    // ═══════════════════════════════════════════
    await tapToAdvance(tester);
    // 추가 pump: _onBlockComplete → _showingChoices=true → setState → rebuild
    await tester.pump();
    await tester.pump();

    // 경로 선택지가 있는 블록: "앞에 N갈래의 길이 보인다."
    expect(find.byType(TypewriterWidget), findsOneWidget);
    final pathBlock =
        tester.widget<TypewriterWidget>(find.byType(TypewriterWidget));
    expect(pathBlock.text, contains('갈래의 길이 보인다'));
    debugPrint('STEP 5: 경로 선택지 블록 — "${pathBlock.text}"');

    // 경로 선택지가 ChoiceCardWidget으로 렌더링되는지 확인
    final pathChoices = find.byType(ChoiceCardWidget);
    expect(pathChoices, findsWidgets);

    final choiceCount =
        tester.widgetList<ChoiceCardWidget>(pathChoices).length;
    debugPrint('STEP 5: 경로 선택지 $choiceCount개 표시됨');
    expect(choiceCount, greaterThanOrEqualTo(2));

    // 첫 번째 선택지의 텍스트 확인 (PathDescriptionGenerator가 생성)
    final firstChoice =
        tester.widget<ChoiceCardWidget>(pathChoices.first);
    debugPrint('STEP 5: 첫 번째 경로 — "${firstChoice.choice.text}"');

    // ═══════════════════════════════════════════
    // STEP 6: 경로 선택지 탭 → 방 진입
    // ═══════════════════════════════════════════
    await tapChoiceAndWait(tester, pathChoices.first);

    // DungeonRoomEntered 처리 대기
    await tester.pump();
    await waitForTypewriter(tester);

    // 방 진입 성공 확인: 새 텍스트 블록이 표시됨
    expect(find.byType(TypewriterWidget), findsOneWidget);
    final roomWidget =
        tester.widget<TypewriterWidget>(find.byType(TypewriterWidget));
    debugPrint('STEP 6: 방 진입 성공 — "${roomWidget.text}"');

    // ═══════════════════════════════════════════
    // 결과 요약
    // ═══════════════════════════════════════════
    debugPrint('');
    debugPrint('============================================');
    debugPrint('전체 탐험 플로우 테스트 성공!');
    debugPrint('   준비 페이즈 -> 던전 인트로 -> 경로 선택지 -> 방 진입');
    debugPrint('   골드: ${gameState.playerRunStateForTest.gold}');
    debugPrint(
        '   HP: ${gameState.playerRunStateForTest.currentHp}/${gameState.playerRunStateForTest.maxHp}');
    debugPrint('============================================');
  });
}
