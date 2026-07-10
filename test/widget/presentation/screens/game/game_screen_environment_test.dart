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
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import '../../../../helpers/game_screen_test_helper.dart';
import '../../../../helpers/rich_text_finder.dart';

/// 환경 단서가 포함된 전투 encounter 생성
CombatEncounter _encounterWithEnvironment() {
  return const CombatEncounter(
    enemyName: '테스트 적',
    environmentText: '낡은 석실에 발을 들인다. 천장이 낮고 균열이 보인다.',
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
    ],
    victoryText: '승리!',
    defeatText: '패배...',
  );
}

/// 환경 단서가 없는 전투 encounter 생성
CombatEncounter _encounterWithoutEnvironment() {
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
  group('GameScreen 환경 서술 렌더링', () {
    testWidgets('환경 서술 블록 렌더 시 시안 색상 텍스트 표시', (tester) async {
      final encounter = _encounterWithEnvironment();
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(encounter), encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 환경 서술이 첫 블록으로 표시됨 (TypewriterWidget → RichText)
      expect(findRichText('낡은 석실에 발을 들인다'), findsOneWidget);
    });

    testWidgets('환경 서술 블록 렌더 시 왼쪽 세로선 표시', (tester) async {
      final encounter = _encounterWithEnvironment();
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(encounter), encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Container with left border 찾기
      final containerFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            final border = decoration.border;
            if (border is Border) {
              return border.left.color == AppTheme.environmentBorderColor &&
                  border.left.width == 4;
            }
          }
          return false;
        },
        description: 'Container with environment left border',
      );
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('환경 서술 완료 후 히스토리에서 시각 스타일 유지', (tester) async {
      final encounter = _encounterWithEnvironment();
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(encounter), encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 환경 서술 블록 탭으로 진행
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 완료 블록에서 환경 서술이 시안 색상 RichText로 표시
      final richTextFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is RichText) {
            final textSpan = widget.text;
            if (textSpan is TextSpan) {
              return textSpan.text?.contains('낡은 석실에 발을 들인다') == true &&
                  textSpan.style?.color == AppTheme.environmentClueColor;
            }
          }
          return false;
        },
        description: 'RichText with environment clue color',
      );
      expect(richTextFinder, findsOneWidget);

      // 왼쪽 세로선도 유지
      final borderFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            final border = decoration.border;
            if (border is Border) {
              return border.left.color == AppTheme.environmentBorderColor &&
                  border.left.width == 4;
            }
          }
          return false;
        },
        description: 'Container with environment left border in history',
      );
      expect(borderFinder, findsOneWidget);
    });

    testWidgets('environmentText null인 encounter에서 환경 블록 미표시', (tester) async {
      final encounter = _encounterWithoutEnvironment();
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(encounter), encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 첫 블록이 introText(normal)여야 함 (TypewriterWidget → RichText)
      expect(findRichText('적이 나타났다!'), findsOneWidget);

      // 환경 관련 Container(세로선) 없어야 함
      final borderFinder = find.byWidgetPredicate(
        (widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            final border = decoration.border;
            if (border is Border) {
              return border.left.color == AppTheme.environmentBorderColor;
            }
          }
          return false;
        },
        description: 'Container with environment left border',
      );
      expect(borderFinder, findsNothing);
    });

    testWidgets('setCombatEncounter 후 _roomEnvironmentClues에 단서 저장 검증',
        (tester) async {
      final encounter = _encounterWithEnvironment();
      final eventBus = GameEventBus();
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
              initialBlockData: const [TextBlockData(text: '초기 텍스트')],
              speed: TextSpeed.instant,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // setCombatEncounter 호출
      gameScreenKey.currentState!.setCombatEncounter(encounter);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // _roomEnvironmentClues에 단서가 직접 저장되었는지 검증
      final clues = gameScreenKey.currentState!.roomEnvironmentCluesForTest;
      expect(clues, hasLength(2));
      expect(clues[0].id, 'ceiling_crack');
      expect(clues[1].id, 'wet_floor');
    });

    testWidgets('setTextBlockData 호출 시 _roomEnvironmentClues 초기화 검증',
        (tester) async {
      final encounter = _encounterWithEnvironment();
      final eventBus = GameEventBus();
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
              initialBlockData: const [TextBlockData(text: '초기 텍스트')],
              speed: TextSpeed.instant,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 전투 설정 → 단서 저장
      gameScreenKey.currentState!.setCombatEncounter(encounter);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(
        gameScreenKey.currentState!.roomEnvironmentCluesForTest,
        hasLength(2),
      );

      // setTextBlockData로 비전투 콘텐츠 로드 → 단서 초기화
      gameScreenKey.currentState!.setTextBlockData(
        const [TextBlockData(text: '서술 텍스트')],
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(
        gameScreenKey.currentState!.roomEnvironmentCluesForTest,
        isEmpty,
      );
    });

    testWidgets('새 encounter 시작 시 환경 블록 교체 검증', (tester) async {
      final encounter1 = _encounterWithEnvironment();
      final encounter2 = const CombatEncounter(
        enemyName: '두 번째 적',
        environmentText: '불타는 회랑을 지난다.',
        environmentClues: [
          EnvironmentClue(
            id: 'fire_pillar',
            description: '불기둥이 솟아오른다',
            actionHint: '불기둥 뒤로 숨을 수 있다',
          ),
        ],
        introText: '두 번째 적이 나타났다!',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.defend,
              previewText: '적이 방어한다',
            ),
            playerChoices: [],
          ),
        ],
        victoryText: '승리!',
        defeatText: '패배...',
      );

      final eventBus = GameEventBus();
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
              initialBlockData: CombatFlowManager.toDynamicTextBlocks(encounter1),
              initialEncounter: encounter1,
              speed: TextSpeed.instant,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 첫 encounter의 환경 서술 확인
      expect(findRichText('낡은 석실에 발을 들인다'), findsOneWidget);

      // 두 번째 encounter로 교체
      gameScreenKey.currentState!.setCombatEncounter(encounter2);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 두 번째 환경 서술이 표시됨
      expect(findRichText('불타는 회랑을 지난다'), findsOneWidget);
      // 첫 번째 환경 서술은 없음
      expect(findRichText('낡은 석실에 발을 들인다'), findsNothing);
    });
  });
}
