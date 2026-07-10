import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_list_widget.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/elite_demo_encounter.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import '../../../../helpers/rich_text_finder.dart';
import '../../../../helpers/game_screen_test_helper.dart';

void main() {
  late GameEventBus gameEventBus;

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  /// 기본 GameScreen (DungeonBloc 없음).
  Future<GameScreenState> pumpGameScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MomentumBloc>(
            create: (_) => MomentumBloc(
              gameEventBus: gameEventBus,
              config: const MomentumConfig(),
            ),
          ),
          BlocProvider<ProgressionBloc>(
            create: (_) => ProgressionBloc(gameEventBus: gameEventBus),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: GameScreen(
            initialBlockData: const [TextBlockData(text: '테스트')],
            gameEventBus: gameEventBus,
            speed: TextSpeed.instant,
            eventConfig: const EventConfig(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return tester.state<GameScreenState>(find.byType(GameScreen));
  }

  /// DungeonBloc 포함 GameScreen (미니맵/경로 선택 테스트용).
  Future<GameScreenState> pumpGameScreenWithDungeon(
      WidgetTester tester) async {
    final generator = DungeonGenerator(
      config: const DungeonBalanceConfig(),
      gameEventBus: gameEventBus,
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MomentumBloc>(
            create: (_) => MomentumBloc(
              gameEventBus: gameEventBus,
              config: const MomentumConfig(),
            ),
          ),
          BlocProvider<ProgressionBloc>(
            create: (_) => ProgressionBloc(gameEventBus: gameEventBus),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: GameScreen(
            initialBlockData: const [TextBlockData(text: '테스트')],
            gameEventBus: gameEventBus,
            speed: TextSpeed.instant,
            dungeonGenerator: generator,
            eventConfig: const EventConfig(),
          ),
        ),
      ),
    );
    await tester.pump(); // initState + GenerateFloor
    await tester.pump(); // DungeonBloc → DungeonFloorReady
    await tester.pump(); // rebuild with minimap
    return tester.state<GameScreenState>(find.byType(GameScreen));
  }

  /// enterEliteConfirmForTest 후 확인 선택지까지 진행.
  Future<void> advanceToEliteChoices(WidgetTester tester) async {
    await tester.pump(); // ToggleMinimap 처리 + rebuild with new blocks
    await tester.pump(); // rebuild (minimap hidden)
    await tester.pump(); // block 0 instant complete
    // 확인 텍스트(block 0) 완료 후 탭하여 선택지(block 1)로 진행
    // TypewriterWidget 탭 → 부모 GestureDetector로 전파 → _handleTap
    await tester.tap(find.byType(TypewriterWidget));
    await tester.pump(); // _advanceToNextBlock → block 1
    await tester.pump(); // block 1 instant complete, _showingChoices=true
    await tester.pump(); // rebuild with choices
  }

  /// DungeonBloc에서 시작 노드의 첫 번째 다음 노드 ID 반환.
  String getFirstNextNodeId(WidgetTester tester) {
    final scaffoldContext = tester.element(find.byType(Scaffold).first);
    final dungeonBloc = BlocProvider.of<DungeonBloc>(scaffoldContext);
    final state = dungeonBloc.state;
    if (state is DungeonFloorReady) {
      final startNode = state.floorMap.nodeById(state.currentNodeId);
      return startNode!.nextNodeIds.first;
    }
    throw StateError('DungeonBloc not in DungeonFloorReady state');
  }

  group('GameScreen 엘리트 확인 UI', () {
    testWidgets('(1) enterEliteConfirmForTest → 확인 텍스트 "강한 적의 기척" 표시',
        (tester) async {
      final gameState = await pumpGameScreen(tester);

      gameState.enterEliteConfirmForTest();
      await tester.pump(); // rebuild
      await tester.pump(); // block 0 instant complete

      // 확인 텍스트가 TypewriterWidget에 표시됨
      expect(find.byType(TypewriterWidget), findsOneWidget);
    });

    testWidgets('(2) 확인 텍스트 + 2선택지 렌더링 검증', (tester) async {
      final gameState = await pumpGameScreen(tester);

      gameState.enterEliteConfirmForTest();
      await advanceToEliteChoices(tester);

      // 확인 텍스트가 completedBlocks에 표시
      expect(findRichText('강한 적의 기척'), findsOneWidget);

      // 2개 선택지 표시
      expect(find.byType(ChoiceListWidget), findsOneWidget);
      expect(find.textContaining('⚔ 도전한다'), findsOneWidget);
      expect(find.textContaining('↩ 다른 길을 찾는다'), findsOneWidget);
    });

    testWidgets('(3) "도전한다" 탭 → DungeonBloc에 SelectNode 발행',
        (tester) async {
      final gameState = await pumpGameScreenWithDungeon(tester);
      final validNodeId = getFirstNextNodeId(tester);

      gameState.enterEliteConfirmForTest(nodeId: validNodeId);
      await advanceToEliteChoices(tester);

      // "도전한다" 탭
      await tester.tap(find.textContaining('⚔ 도전한다'));
      await tester.pump(); // _onChoiceSelected → SelectNode
      await tester.pump(); // DungeonBloc → DungeonRoomEntered
      await tester.pump(); // _onDungeonStateChanged → setTextBlockData

      // DungeonBloc 상태가 DungeonRoomEntered로 변경됨
      final scaffoldContext = tester.element(find.byType(Scaffold).first);
      final dungeonBloc = BlocProvider.of<DungeonBloc>(scaffoldContext);
      expect(dungeonBloc.state, isA<DungeonRoomEntered>());
    });

    testWidgets('(4) "다른 길을 찾는다" 탭 → 내러티브 텍스트 표시', (tester) async {
      final gameState = await pumpGameScreenWithDungeon(tester);

      gameState.enterEliteConfirmForTest();
      await advanceToEliteChoices(tester);

      // "다른 길을 찾는다" 탭
      await tester.tap(find.textContaining('↩ 다른 길을 찾는다'));
      await tester.pump(); // _onChoiceSelected → setTextBlockData
      await tester.pump(); // rebuild with new text
      await tester.pump(); // TypewriterWidget instant complete

      // 내러티브 텍스트 표시 (TypewriterWidget 또는 completedBlock)
      final typewriter = find.byType(TypewriterWidget);
      expect(typewriter, findsOneWidget);
    });

    testWidgets('(5) 비엘리트 방 → 확인 UI 없이 즉시 전투 진입', (tester) async {
      // initialEncounter로 직접 전투 진입 (비엘리트 패턴)
      final encounter = EliteDemoEncounter.create();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MomentumBloc>(
              create: (_) => MomentumBloc(
                gameEventBus: gameEventBus,
                config: const MomentumConfig(),
              ),
            ),
            BlocProvider<ProgressionBloc>(
              create: (_) => ProgressionBloc(gameEventBus: gameEventBus),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: GameScreen(
              initialBlockData: blocks,
              initialEncounter: encounter,
              gameEventBus: gameEventBus,
              speed: TextSpeed.instant,
              eventConfig: const EventConfig(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // 전투 블록이 직접 렌더링 (확인 UI 없음)
      expect(find.byType(TypewriterWidget), findsOneWidget);
      // 확인 텍스트는 없음
      expect(find.textContaining('⚔ 도전한다'), findsNothing);
      expect(find.textContaining('↩ 다른 길을 찾는다'), findsNothing);
    });

    testWidgets('(6) 상태 변경 → _pendingEliteNodeId 리셋', (tester) async {
      final gameState = await pumpGameScreenWithDungeon(tester);
      final validNodeId = getFirstNextNodeId(tester);

      // 엘리트 확인 진입
      gameState.enterEliteConfirmForTest(nodeId: validNodeId);
      await advanceToEliteChoices(tester);

      // "도전한다" → 방 진입 (상태 변경 트리거)
      await tester.tap(find.textContaining('⚔ 도전한다'));
      await tester.pump(); // SelectNode
      await tester.pump(); // DungeonRoomEntered
      await tester.pump(); // _onDungeonStateChanged → _resetEliteConfirmation

      // 이후 enterEliteConfirmForTest 다시 호출 가능 (리셋 확인)
      // DungeonBloc이 DungeonRoomEntered 상태이므로 CompleteRoom으로 복귀
      final scaffoldContext = tester.element(find.byType(Scaffold).first);
      final dungeonBloc = BlocProvider.of<DungeonBloc>(scaffoldContext);
      dungeonBloc.add(const CompleteRoom());
      await tester.pump(); // DungeonFloorReady
      await tester.pump(); // rebuild

      // 다시 엘리트 확인 진입 가능 (리셋됨)
      gameState.enterEliteConfirmForTest();
      await advanceToEliteChoices(tester);

      expect(find.textContaining('⚔ 도전한다'), findsOneWidget);
    });

    testWidgets('(7) 엘리트 전투 완료 → 2배 골드 보상', (tester) async {
      // 0턴 전투 → 즉시 승리 (score=0 but turns=0, victoryThreshold=0)
      const quickWinEncounter = CombatEncounter(
        roomType: RoomType.elite,
        enemyName: '약한 엘리트',
        introText: '약한 엘리트가 나타났다.',
        turns: [],
        victoryText: '승리!',
        defeatText: '패배!',
      );
      final blocks = CombatFlowManager.toDynamicTextBlocks(quickWinEncounter);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MomentumBloc>(
              create: (_) => MomentumBloc(
                gameEventBus: gameEventBus,
                config: const MomentumConfig(),
              ),
            ),
            BlocProvider<ProgressionBloc>(
              create: (_) => ProgressionBloc(gameEventBus: gameEventBus),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: GameScreen(
              initialBlockData: blocks,
              initialEncounter: quickWinEncounter,
              gameEventBus: gameEventBus,
              combatConfig: const CombatBalanceConfig(
                eliteVictoryThreshold: 0,
              ),
              economyConfig: const EconomyConfig(),
              speed: TextSpeed.instant,
              eventConfig: const EventConfig(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // 모든 블록 진행
      for (var i = 0; i < 15; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
        await tester.pump();
      }

      // 엘리트 전투 보상은 3.0배 (eliteGoldMultiplier=3.0)
      // 기본 baseGold=8 * 3.0 = 24
      expect(gameState.playerRunStateForTest.gold, 24);
    });

    testWidgets('(8) 엘리트 패배 → HP 50 손실', (tester) async {
      // 0턴 전투 → 즉시 패배 (victoryThreshold=1, score=0)
      const defeatEncounter = CombatEncounter(
        roomType: RoomType.elite,
        enemyName: '강한 엘리트',
        introText: '강한 엘리트가 나타났다.',
        turns: [],
        victoryText: '승리!',
        defeatText: '패배했다...',
      );
      final blocks = CombatFlowManager.toDynamicTextBlocks(defeatEncounter);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MomentumBloc>(
              create: (_) => MomentumBloc(
                gameEventBus: gameEventBus,
                config: const MomentumConfig(),
              ),
            ),
            BlocProvider<ProgressionBloc>(
              create: (_) => ProgressionBloc(gameEventBus: gameEventBus),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: GameScreen(
              initialBlockData: blocks,
              initialEncounter: defeatEncounter,
              gameEventBus: gameEventBus,
              combatConfig: const CombatBalanceConfig(
                eliteVictoryThreshold: 1,
                eliteDefeatHpLoss: 50,
              ),
              speed: TextSpeed.instant,
              eventConfig: const EventConfig(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      final initialHp = gameState.playerRunStateForTest.currentHp;

      // 모든 블록 진행
      for (var i = 0; i < 15; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
        await tester.pump();
      }

      // 엘리트 패배 시 HP 50 손실
      expect(
        gameState.playerRunStateForTest.currentHp,
        initialHp - 50,
      );
    });

    testWidgets('(9) 연속 회피 후 도전 → 정상 동작', (tester) async {
      final gameState = await pumpGameScreenWithDungeon(tester);
      final validNodeId = getFirstNextNodeId(tester);

      // 1차: 회피
      gameState.enterEliteConfirmForTest(nodeId: validNodeId);
      await advanceToEliteChoices(tester);

      await tester.tap(find.textContaining('↩ 다른 길을 찾는다'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 2차: 도전
      gameState.enterEliteConfirmForTest(nodeId: validNodeId);
      await advanceToEliteChoices(tester);

      await tester.tap(find.textContaining('⚔ 도전한다'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // SelectNode 발행되어 DungeonRoomEntered로 전환
      final scaffoldContext = tester.element(find.byType(Scaffold).first);
      final dungeonBloc = BlocProvider.of<DungeonBloc>(scaffoldContext);
      expect(dungeonBloc.state, isA<DungeonRoomEntered>());
    });

    testWidgets('(10) elite_challenge + _pendingEliteNodeId null → 무시(가드)',
        (tester) async {
      final gameState = await pumpGameScreen(tester);

      // 선택지를 직접 설정 (enterEliteConfirmForTest 미사용 → _pendingEliteNodeId null)
      gameState.setTextBlockData([
        const TextBlockData(text: '테스트 확인'),
        TextBlockData(
          text: '',
          choices: [
            ChoiceData(
              id: 'elite_challenge',
              text: '⚔ 도전한다',
              resultTextBlocks: const ['결과 텍스트'],
            ),
          ],
        ),
      ], endCombat: false);
      await advanceToEliteChoices(tester);

      // "도전한다" 탭 — _pendingEliteNodeId가 null이므로 엘리트 핸들러 스킵
      // 일반 choice 처리 플로우로 진행 (크래시 없음)
      await tester.tap(find.textContaining('⚔ 도전한다'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 일반 선택 결과 텍스트가 표시됨 (엘리트 핸들러가 아닌 기본 처리)
      await tester.pump(const Duration(milliseconds: 500)); // Future.delayed
      await tester.pump();
      await tester.pump();

      expect(findRichText('도전한다'), findsOneWidget);
    });

    // (11) 미니맵 read-only 전환으로 _onMinimapNodeTap 삭제됨 — re-entry guard 불필요
  });
}
