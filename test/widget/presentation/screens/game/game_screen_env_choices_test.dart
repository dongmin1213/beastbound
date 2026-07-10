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
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import '../../../../helpers/rich_text_finder.dart';
import '../../../../helpers/game_screen_test_helper.dart';

/// 환경 단서 포함 2턴 전투
CombatEncounter _encounterWith2Turns() {
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
      CombatTurnData(
        turnNumber: 3,
        enemyAction: EnemyAction(
          type: EnemyActionType.observe,
          previewText: '적이 관찰하려 한다',
        ),
        playerChoices: [],
      ),
    ],
    victoryText: '승리!',
    defeatText: '패배...',
  );
}

Widget _buildApp(GlobalKey<GameScreenState> key, GameEventBus eventBus) {
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
        key: key,
        initialBlockData: const [TextBlockData(text: '초기')],
        speed: TextSpeed.instant,
        eventConfig: const EventConfig(),
      ),
    ),
  );
}

/// 선택지까지 진행
Future<void> _advanceToChoices(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    await tapGameScreen(tester);
    for (int j = 0; j < 10; j++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
}

/// 관찰 선택 + delay 처리 (선택지 존재를 assert로 검증)
Future<void> _selectObserve(WidgetTester tester) async {
  final observeChoice = find.textContaining('관찰한다');
  expect(observeChoice, findsOneWidget);
  await tester.tap(observeChoice);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('GameScreen 환경 선택지 표시 및 사용', () {
    testWidgets('관찰 후 다음 턴 선택지에 환경 선택지 추가 표시', (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Turns());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 1턴 선택지까지 진행
      await _advanceToChoices(tester);

      // 1턴: 관찰 선택 (환경 해금)
      await _selectObserve(tester);

      // 결과 블록 + 발견 블록들 + 2턴 구분자 + 예고 + 선택지까지 진행
      for (int i = 0; i < 10; i++) {
        await tapGameScreen(tester);
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // 2턴 선택지에 환경 선택지가 포함되어야 함
      expect(find.textContaining('균열을 이용할 수 있다'), findsOneWidget);
    });

    testWidgets('환경 선택지 미해금 시 기본 3개만 표시', (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Turns());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 1턴 선택지까지 진행
      await _advanceToChoices(tester);

      // 해금 전: 환경 선택지 없어야 함
      expect(find.textContaining('균열을 이용할 수 있다'), findsNothing);
      // 기본 3개만 존재
      expect(find.textContaining('공격한다'), findsOneWidget);
      expect(find.textContaining('방어한다'), findsOneWidget);
      expect(find.textContaining('관찰한다'), findsOneWidget);
    });

    testWidgets('환경 선택지 탭 시 결과 텍스트 표시', (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Turns());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 1턴: 관찰 → 환경 해금
      await _advanceToChoices(tester);
      await _selectObserve(tester);

      // 2턴 선택지까지 진행
      for (int i = 0; i < 10; i++) {
        await tapGameScreen(tester);
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // 환경 선택지 탭
      final envChoice = find.textContaining('균열을 이용할 수 있다');
      expect(envChoice, findsOneWidget);
      await tester.tap(envChoice);
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

      // 결과 블록 진행
      for (int i = 0; i < 3; i++) {
        await tapGameScreen(tester);
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // 환경 활용 결과 텍스트 확인
      expect(findRichText('균열을 이용할 수 있다를 활용했다!'), findsOneWidget);
    });

    testWidgets('환경 선택지 탭 시 MomentumBloc에 ActionPerformed(environment) emit',
        (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      late MomentumBloc momentumBloc;

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MomentumBloc>(
              create: (_) {
                momentumBloc = MomentumBloc(
                  gameEventBus: eventBus,
                  config: const MomentumConfig(),
                );
                return momentumBloc;
              },
            ),
            BlocProvider<ProgressionBloc>(
              create: (_) => ProgressionBloc(gameEventBus: eventBus),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: GameScreen(
              key: key,
              initialBlockData: const [TextBlockData(text: '초기')],
              speed: TextSpeed.instant,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Turns());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 1턴: 관찰 → 환경 해금
      await _advanceToChoices(tester);
      await _selectObserve(tester);

      // MomentumBloc 상태: 관찰 행동 기록됨
      expect(momentumBloc.state, isA<MomentumUpdated>());

      // 2턴 선택지까지 진행
      for (int i = 0; i < 10; i++) {
        await tapGameScreen(tester);
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // 환경 선택지 탭
      final envChoice = find.textContaining('균열을 이용할 수 있다');
      expect(envChoice, findsOneWidget);
      await tester.tap(envChoice);
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

      // MomentumBloc 상태: environment 행동 기록됨
      final state = momentumBloc.state;
      expect(state, isA<MomentumUpdated>());
      final updatedState = state as MomentumUpdated;
      expect(updatedState.lastActionType, ActionType.environment);
    });

    testWidgets('환경 서술→관찰→발견→다음 턴 환경 선택지 순서 검증 (통합 테스트)',
        (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Turns());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 1. 환경 서술 블록 확인
      expect(findRichText('낡은 석실에 균열이 보인다'), findsOneWidget);

      // 진행: 환경 서술 → 적 등장 → 1턴 구분자 → 예고 → 선택지
      await _advanceToChoices(tester);

      // 2. 관찰 선택
      await _selectObserve(tester);

      // 3. combatResult 블록 진행
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 4. 발견 도입 블록
      expect(findRichText('주변을 주의 깊게 살핀다'), findsOneWidget);
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 5. 단서 블록
      expect(findRichText('균열을 이용할 수 있다'), findsOneWidget);
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 6. 2턴으로 진행 → 환경 선택지 표시 확인
      for (int i = 0; i < 6; i++) {
        await tapGameScreen(tester);
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // 다음 턴 선택지에 환경 선택지 포함 확인
      expect(find.textContaining('균열을 이용할 수 있다'), findsOneWidget);
    });
  });
}
