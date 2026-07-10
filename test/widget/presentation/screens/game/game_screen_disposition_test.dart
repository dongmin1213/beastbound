import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import '../../../../helpers/rich_text_finder.dart';

void main() {
  late GameEventBus gameEventBus;

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  /// GameScreen 빌드 + 초기화 (2 pump = instant 타이핑 완료).
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
            dispositionConfig: const DispositionConfig(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return tester.state<GameScreenState>(find.byType(GameScreen));
  }

  /// DungeonBloc 포함 GameScreen (엘리트 테스트용).
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
            dispositionConfig: const DispositionConfig(),
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
    await tester.tap(find.byType(TypewriterWidget));
    await tester.pump(); // _advanceToNextBlock → block 1
    await tester.pump(); // block 1 instant complete, _showingChoices=true
    await tester.pump(); // rebuild with choices
  }

  group('GameScreen 성향 적용 (Story 4-1)', () {
    testWidgets('이벤트 선택 후 RunBloc에 ChangeDisposition 발행', (tester) async {
      final gameState = await pumpGameScreen(tester);

      const choice = EventChoice(
        label: '도움을 준다',
        outcomeText: '감사합니다.',
        goldChange: 10,
        hpChange: 0,
        dispositionRewards: {DispositionAxis.mercy: 3},
      );
      final data = EventRoomData(
        title: '테스트 이벤트',
        narrativeText: '테스트.',
        choices: [choice],
      );

      gameState.enterEventForTest(data, withGold: 50);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.textContaining('도움을 준다'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // RunBloc의 disposition 변경 확인 — mercy:3 정확히 적용
      expect(gameState.playerRunStateForTest.disposition[DispositionAxis.mercy],
          3);
    });

    testWidgets('이벤트 선택 후 피드백 텍스트 표시', (tester) async {
      final gameState = await pumpGameScreen(tester);

      const choice = EventChoice(
        label: '도움을 준다',
        outcomeText: '감사합니다.',
        goldChange: 0,
        hpChange: 0,
        dispositionRewards: {DispositionAxis.mercy: 3},
      );
      final data = EventRoomData(
        title: '테스트 이벤트',
        narrativeText: '테스트.',
        choices: [choice],
      );

      gameState.enterEventForTest(data, withGold: 50);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.textContaining('도움을 준다'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 피드백 텍스트 확인 — "자비의 기운이 느껴진다."
      expect(findRichText('자비의 기운이 느껴진다.'), findsOneWidget);
    });

    testWidgets('엘리트 도전 → RunBloc에 struggle 성향 적용', (tester) async {
      final gameState = await pumpGameScreenWithDungeon(tester);

      // 엘리트 확인 진입
      gameState.enterEliteConfirmForTest(nodeId: 'elite_node');
      await advanceToEliteChoices(tester);

      // "⚔ 도전한다" 선택
      await tester.tap(find.textContaining('도전한다'));
      await tester.pump();
      await tester.pump();

      // struggle 성향 증가 확인 — eliteChallengeReward 기본값 2
      final disposition = gameState.playerRunStateForTest.disposition;
      expect(disposition[DispositionAxis.struggle], 2);
    });

    testWidgets('엘리트 회피 → RunBloc에 shadow 성향 적용', (tester) async {
      final gameState = await pumpGameScreenWithDungeon(tester);

      // 엘리트 확인 진입
      gameState.enterEliteConfirmForTest(nodeId: 'elite_node');
      await advanceToEliteChoices(tester);

      // "↩ 다른 길을 찾는다" 선택
      await tester.tap(find.textContaining('다른 길을 찾는다'));
      await tester.pump();
      await tester.pump();

      // shadow 성향 증가 확인 — eliteAvoidReward 기본값 1
      final disposition = gameState.playerRunStateForTest.disposition;
      expect(disposition[DispositionAxis.shadow], 1);
    });

    testWidgets('dispositionRewards 빈 Map → ChangeDisposition 미발행', (tester) async {
      final gameState = await pumpGameScreen(tester);

      const choice = EventChoice(
        label: '무시한다',
        outcomeText: '지나간다.',
        goldChange: 0,
        hpChange: 0,
        // dispositionRewards 기본값 = const {} (빈 Map)
      );
      final data = EventRoomData(
        title: '테스트 이벤트',
        narrativeText: '테스트.',
        choices: [choice],
      );

      gameState.enterEventForTest(data, withGold: 50);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.textContaining('무시한다'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // disposition 변화 없음 — 모든 축이 초기값(0)
      final disposition = gameState.playerRunStateForTest.disposition;
      for (final axis in DispositionAxis.values) {
        expect(disposition[axis], 0, reason: '${axis.name} should remain 0');
      }

      // 성향 피드백 텍스트 미표시
      expect(findRichText('기운이 느껴진다'), findsNothing);
    });
  });
}
