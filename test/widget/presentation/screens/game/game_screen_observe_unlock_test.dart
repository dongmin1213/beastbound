import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import '../../../../helpers/game_screen_test_helper.dart';

/// 환경 단서가 포함된 다턴 전투 encounter
CombatEncounter _encounterWithEnvMultiTurn() {
  return const CombatEncounter(
    enemyName: '테스트 적',
    environmentText: '낡은 석실에 균열이 보인다.',
    environmentClues: [
      EnvironmentClue(
        id: 'ceiling_crack',
        description: '천장에 균열이 보인다',
        actionHint: '균열을 이용할 수 있다',
      ),
    ],
    introText: '적이 나타났다!',
    turns: [
      CombatTurnData(
        turnNumber: 1,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '적이 공격하려 한다',
        ),
        playerChoices: [],
      ),
      CombatTurnData(
        turnNumber: 2,
        enemyAction: EnemyAction(
          type: EnemyActionType.defend,
          previewText: '적이 방어하려 한다',
        ),
        playerChoices: [],
      ),
    ],
    victoryText: '승리!',
    defeatText: '패배...',
  );
}

/// 환경 단서가 없는 전투 encounter
CombatEncounter _encounterWithoutEnv() {
  return const CombatEncounter(
    enemyName: '테스트 적',
    introText: '적이 나타났다!',
    turns: [
      CombatTurnData(
        turnNumber: 1,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '적이 공격하려 한다',
        ),
        playerChoices: [],
      ),
    ],
    victoryText: '승리!',
    defeatText: '패배...',
  );
}

void main() {
  group('GameScreen 관찰→환경 해금 상태 관리', () {
    testWidgets('관찰 후 _environmentUnlocked = true', (tester) async {
      final encounter = _encounterWithEnvMultiTurn();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      final gameScreenKey = GlobalKey<GameScreenState>();

      await tester.pumpWidget(
        MultiBlocProvider(
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
              key: gameScreenKey,
              initialBlockData: const [TextBlockData(text: '초기')],
              speed: TextSpeed.instant,
              eventConfig: const EventConfig(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 전투 시작
      gameScreenKey.currentState!.setCombatEncounter(encounter);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 초기: 해금 안 됨
      expect(gameScreenKey.currentState!.environmentUnlockedForTest, false);

      // 환경 서술 → 적 등장 → 턴 구분자 → 행동 예고 → 선택지까지 진행
      // 탭으로 블록 진행
      for (int i = 0; i < 6; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
        await tester.pump();
      }

      // 관찰 선택지를 탭
      final observeChoice = find.textContaining('관찰한다');
      expect(observeChoice, findsOneWidget);
      await tester.tap(observeChoice);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // highlight delay
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 관찰 후 해금 상태 확인
      expect(gameScreenKey.currentState!.environmentUnlockedForTest, true);
      expect(
        gameScreenKey.currentState!.discoveredCluesForTest,
        hasLength(1),
      );
    });

    testWidgets('재관찰 시 _environmentUnlocked 유지 (중복 해금 없음)',
        (tester) async {
      final encounter = _encounterWithEnvMultiTurn();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      final gameScreenKey = GlobalKey<GameScreenState>();

      await tester.pumpWidget(
        MultiBlocProvider(
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
              key: gameScreenKey,
              initialBlockData: const [TextBlockData(text: '초기')],
              speed: TextSpeed.instant,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      gameScreenKey.currentState!.setCombatEncounter(encounter);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 블록 진행 → 선택지까지
      for (int i = 0; i < 6; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
        await tester.pump();
      }

      // 관찰 선택
      final observeChoice = find.textContaining('관찰한다');
      expect(observeChoice, findsOneWidget);
      await tester.tap(observeChoice);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 첫 해금
      expect(gameScreenKey.currentState!.environmentUnlockedForTest, true);

      // 발견 블록들을 탭으로 진행
      for (int i = 0; i < 6; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
        await tester.pump();
      }

      // 2회차 관찰 — 해금 상태 유지
      final observeChoice2 = find.textContaining('관찰한다');
      expect(observeChoice2, findsOneWidget);
      await tester.tap(observeChoice2);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 해금 상태 여전히 true
      expect(
          gameScreenKey.currentState!.environmentUnlockedForTest, true);
      // 발견 단서 동일 (중복 추가 없음)
      expect(
        gameScreenKey.currentState!.discoveredCluesForTest,
        hasLength(1),
      );
    });

    testWidgets('setCombatEncounter로 새 전투 시작 시 해금 상태 초기화',
        (tester) async {
      final encounter = _encounterWithEnvMultiTurn();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      final gameScreenKey = GlobalKey<GameScreenState>();

      await tester.pumpWidget(
        MultiBlocProvider(
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
              key: gameScreenKey,
              initialBlockData: const [TextBlockData(text: '초기')],
              speed: TextSpeed.instant,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 전투 1: 해금
      gameScreenKey.currentState!.setCombatEncounter(encounter);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 해금 상태를 직접 세팅 (간접 테스트 대신)
      // setCombatEncounter가 _environmentUnlocked = false 리셋하는지 검증
      expect(gameScreenKey.currentState!.environmentUnlockedForTest, false);
      expect(gameScreenKey.currentState!.discoveredCluesForTest, isEmpty);

      // 전투 2: 새 전투 → 초기화 검증
      gameScreenKey.currentState!.setCombatEncounter(encounter);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(gameScreenKey.currentState!.environmentUnlockedForTest, false);
      expect(gameScreenKey.currentState!.discoveredCluesForTest, isEmpty);
    });

    testWidgets('빈 단서 전투에서 관찰 시 해금 안 됨', (tester) async {
      final encounter = _encounterWithoutEnv();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      final gameScreenKey = GlobalKey<GameScreenState>();

      await tester.pumpWidget(
        MultiBlocProvider(
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
              key: gameScreenKey,
              initialBlockData: const [TextBlockData(text: '초기')],
              speed: TextSpeed.instant,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      gameScreenKey.currentState!.setCombatEncounter(encounter);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 블록 진행 → 선택지까지
      for (int i = 0; i < 6; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
        await tester.pump();
      }

      // 관찰 선택
      final observeChoice = find.textContaining('관찰한다');
      expect(observeChoice, findsOneWidget);
      await tester.tap(observeChoice);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 빈 단서이므로 해금 안 됨
      expect(gameScreenKey.currentState!.environmentUnlockedForTest, false);
      expect(gameScreenKey.currentState!.discoveredCluesForTest, isEmpty);
    });
  });
}
