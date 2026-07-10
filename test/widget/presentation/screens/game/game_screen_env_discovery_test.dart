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

import '../../../../helpers/rich_text_finder.dart';
import '../../../../helpers/game_screen_test_helper.dart';

/// 환경 단서 2개 포함 전투
CombatEncounter _encounterWith2Clues() {
  return const CombatEncounter(
    enemyName: '테스트 적',
    environmentText: '낡은 석실에 균열이 보인다.',
    environmentClues: [
      EnvironmentClue(
        id: 'ceiling_crack',
        description: '천장에 균열이 보인다',
        actionHint: '균열을 이용할 수 있다',
      ),
      EnvironmentClue(
        id: 'wet_floor',
        description: '바닥에 물이 고여 있다',
        actionHint: '발을 미끄러뜨릴 수 있다',
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

/// 환경 단서 없는 전투
CombatEncounter _encounterNoClues() {
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

/// 선택지까지 진행하는 헬퍼 (탭 반복)
Future<void> _advanceToChoices(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    await tapGameScreen(tester);
    for (int j = 0; j < 10; j++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
}

/// 특정 텍스트가 나올 때까지 탭 반복 (최대 maxTaps회)
Future<void> _advanceUntilText(
  WidgetTester tester,
  String targetText, {
  int maxTaps = 20,
}) async {
  for (int i = 0; i < maxTaps; i++) {
    final finder = find.textContaining(targetText);
    if (finder.evaluate().isNotEmpty) {
      expect(finder, findsOneWidget);
      return;
    }
    await tapGameScreen(tester);
    for (int j = 0; j < 10; j++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
  // 최대 탭 후에도 텍스트가 나타나야 함
  expect(find.textContaining(targetText), findsOneWidget);
}

/// 관찰 선택 + delay 처리 헬퍼 (선택지 존재를 assert로 검증)
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
  group('GameScreen 환경 발견 텍스트', () {
    testWidgets('관찰 후 발견 텍스트 표시 (actionHint 내용 포함)', (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Clues());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await _advanceToChoices(tester);
      await _selectObserve(tester);

      // 결과 블록들 진행
      for (int i = 0; i < 4; i++) {
        await tapGameScreen(tester);
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // 발견 텍스트의 actionHint가 completedBlocks에 있는지 확인
      expect(findRichText('균열을 이용할 수 있다'), findsOneWidget);
    });

    testWidgets('발견 텍스트가 단서별 개별 블록으로 순차 생성 (2단서 → 도입1+단서2=3블록)',
        (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Clues());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await _advanceToChoices(tester);
      await _selectObserve(tester);

      // 결과 블록 + 발견 블록들이 삽입됨
      // combatResult 1개 + environmentDiscovery 3개(도입+단서2개) = 4블록
      // 하나씩 진행하면서 블록 텍스트 확인
      // combatResult 블록 진행
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

      // 도입 블록: "주변을 주의 깊게 살핀다..."
      expect(findRichText('주변을 주의 깊게 살핀다'), findsOneWidget);
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

      // 단서1 블록
      expect(findRichText('균열을 이용할 수 있다'), findsOneWidget);
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

      // 단서2 블록
      expect(findRichText('발을 미끄러뜨릴 수 있다'), findsOneWidget);
    });

    testWidgets('발견 텍스트 시안 스타일 렌더링', (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Clues());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await _advanceToChoices(tester);
      await _selectObserve(tester);

      // combatResult 진행
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

      // 도입 블록 진행 → completedBlock으로 이동
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }

      // completedBlock에서 환경 발견 텍스트가 시안 색상인지 확인
      final cyanTextFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is RichText) {
            final textSpan = widget.text;
            if (textSpan is TextSpan) {
              return textSpan.text?.contains('주변을 주의 깊게 살핀다') == true &&
                  textSpan.style?.color == AppTheme.environmentClueColor;
            }
          }
          return false;
        },
        description: 'RichText with discovery text in cyan',
      );
      expect(cyanTextFinder, findsOneWidget);
    });

    testWidgets('재관찰 시 "주변을 다시 살피지만 새로운 단서는 없다" 텍스트 표시',
        (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterWith2Clues());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 1회 관찰
      await _advanceToChoices(tester);
      await _selectObserve(tester);

      // 결과 블록 + 발견 블록들 진행 → 2턴 선택지까지
      await _advanceUntilText(tester, '👁 관찰한다');

      // 2회 관찰
      await _selectObserve(tester);

      // 결과 블록 진행
      for (int i = 0; i < 3; i++) {
        await tapGameScreen(tester);
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // 재관찰 텍스트 확인
      expect(findRichText('새로운 단서는 없다'), findsOneWidget);
    });

    testWidgets('빈 단서 전투 관찰 시 발견 블록 미생성', (tester) async {
      final key = GlobalKey<GameScreenState>();
      final eventBus = GameEventBus();
      addTearDown(() => eventBus.dispose());
      await tester.pumpWidget(_buildApp(key, eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      key.currentState!.setCombatEncounter(_encounterNoClues());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await _advanceToChoices(tester);
      await _selectObserve(tester);

      // 결과 블록 진행
      for (int i = 0; i < 3; i++) {
        await tapGameScreen(tester);
        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // 발견 텍스트 없어야 함
      expect(findRichText('주변을 주의 깊게 살핀다'), findsNothing);
      expect(findRichText('균열'), findsNothing);
    });
  });
}
