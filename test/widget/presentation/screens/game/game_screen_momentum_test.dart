import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_gauge_widget.dart';

import '../../../../helpers/game_screen_test_helper.dart';

/// O-03: 기세 게이지는 2층부터 표시 → 테스트에서 2층으로 설정.
final _floor2State = PlayerRunState.initial(maxHp: 80).copyWith(currentFloor: 2);

/// 3턴 전투 데이터 (동적 결과, 기세 테스트용)
CombatEncounter _threeTurnCombat() {
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
      CombatTurnData(
        turnNumber: 2,
        enemyAction: EnemyAction(
          type: EnemyActionType.defend,
          previewText: '적이 방어 자세를 취한다',
        ),
        playerChoices: [],
      ),
      CombatTurnData(
        turnNumber: 3,
        enemyAction: EnemyAction(
          type: EnemyActionType.observe,
          previewText: '적이 관찰한다',
        ),
        playerChoices: [],
      ),
    ],
    victoryText: '적을 물리쳤다!',
    defeatText: '패배했다.',
  );
}

void main() {
  /// 전투 진입까지 진행 (intro → turn divider → preview → tap to choices)
  Future<void> advanceToCombatChoices(WidgetTester tester) async {
    // Advance past intro
    await tapGameScreen(tester);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Turn divider auto-advances, preview auto-completes → tap to choices
    await tapGameScreen(tester);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// 결과 텍스트를 지나 다음 턴 선택지까지 진행
  Future<void> advanceToNextTurnChoices(WidgetTester tester) async {
    // Tap to advance past result (combatResult auto-completes)
    await tapGameScreen(tester);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Turn divider auto-advances, preview auto-completes → tap to choices
    await tapGameScreen(tester);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// 행동을 선택 (400ms 딜레이 + async CombatBloc 처리 포함)
  Future<void> selectAction(WidgetTester tester, String actionText) async {
    await tester.tap(find.textContaining(actionText));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // pumpAndSettle는 내부적으로 pump(100ms)씩 반복 — 시간 전진 필수
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('GameScreen momentum integration', () {
    testWidgets('전투 시작 시 게이지 표시 확인', (tester) async {
      final blocks =
          CombatFlowManager.toDynamicTextBlocks(_threeTurnCombat());
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, initialRunState: _floor2State, momentumConfig: const MomentumConfig(initialValue: 0)));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 전투 전: 게이지 미표시
      expect(find.byType(MomentumGaugeWidget), findsNothing);

      // 전투 진입
      await advanceToCombatChoices(tester);

      // 전투 중: 게이지 표시
      expect(find.byType(MomentumGaugeWidget), findsOneWidget);
      // 초기값 0 표시
      expect(find.text('기세 0'), findsOneWidget);
    });

    testWidgets('행동 전환 → 기세 상승 확인', (tester) async {
      final encounter = _threeTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter, initialRunState: _floor2State, momentumConfig: const MomentumConfig(initialValue: 0)));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Turn 1: 첫 턴
      await advanceToCombatChoices(tester);

      // 공격 선택 (첫 턴: delta 0)
      await selectAction(tester, '공격한다');

      // Turn 2
      await advanceToNextTurnChoices(tester);

      // 방어 선택 (전환: +12)
      await selectAction(tester, '방어한다');

      // 기세 값 확인: 0 + 0(첫턴) + 12(전환) = 12
      expect(find.text('기세 12'), findsOneWidget);
    });

    testWidgets('같은 행동 2연속 → 기세 하락 확인', (tester) async {
      final encounter = _threeTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter, initialRunState: _floor2State, momentumConfig: const MomentumConfig(initialValue: 0)));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Turn 1: 공격 (첫 턴: delta 0)
      await advanceToCombatChoices(tester);
      await selectAction(tester, '공격한다');

      // Turn 2: 공격 (2연속: -15) → 기세 0 + 0 + (-15) = 0 (클램핑)
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '공격한다');

      // 기세는 0 이하 클램핑 → 0
      expect(find.text('기세 0'), findsOneWidget);
    });

    testWidgets('기세 값 0/100 클램핑 확인', (tester) async {
      // 큰 보너스로 100 초과 테스트
      const highBonusConfig = MomentumConfig(
        initialValue: 0,
        actionSwitchBonus: 60,
      );

      final encounter = _threeTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: blocks,
        momentumConfig: highBonusConfig,
        encounter: encounter,
        initialRunState: _floor2State,
      ));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Turn 1: 공격 (첫 턴: 0)
      await advanceToCombatChoices(tester);
      await selectAction(tester, '공격한다');

      // Turn 2: 방어 (전환: +60) → 60
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '방어한다');

      expect(find.text('기세 60'), findsOneWidget);

      // Turn 3: 공격 (전환: +60) → 120 → 100 (클램핑)
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '공격한다');

      expect(find.text('기세 100'), findsOneWidget);
    });

    testWidgets('서술 선택지 → 기세 무변동 확인', (tester) async {
      // 서술 선택지(actionType null) + 전투 혼합 블록
      final combatBlocks =
          CombatFlowManager.toDynamicTextBlocks(_threeTurnCombat());

      final allBlocks = <TextBlockData>[
        const TextBlockData(
          text: '길을 선택하라.',
          choices: [
            ChoiceData(
              id: 'narrative',
              text: '왼쪽으로',
              resultTextBlocks: ['왼쪽으로 갔다.'],
            ),
          ],
        ),
        const TextBlockData(text: '전투가 시작된다.'),
        ...combatBlocks,
      ];

      await tester.pumpWidget(buildGameScreenWidget(blockData: allBlocks, initialRunState: _floor2State));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 서술 선택지 선택
      await tester.tap(find.textContaining('왼쪽으로'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 게이지 미표시 (전투 전)
      expect(find.byType(MomentumGaugeWidget), findsNothing);
    });

    testWidgets('타이머 경합: 연속 행동 → 마지막 delta만 표시', (tester) async {
      final encounter = _threeTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter, initialRunState: _floor2State));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Turn 1: 공격 (첫 턴: delta 0)
      await advanceToCombatChoices(tester);
      await selectAction(tester, '공격한다');

      // Turn 2로 진행
      await advanceToNextTurnChoices(tester);

      // 방어 선택 (전환: +12)
      await selectAction(tester, '방어한다');

      // +12 delta 표시 확인
      expect(find.text('+12'), findsOneWidget);

      // 1.5초 대기 → delta 사라짐
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(); // setState 반영

      // delta 텍스트 사라짐
      expect(find.text('+12'), findsNothing);
    });

    testWidgets('전투 종료 후 게이지 숨김 확인', (tester) async {
      // 1턴 전투 (빠른 종료)
      const oneTurnCombat = CombatEncounter(
        enemyName: '약한 적',
        introText: '적 등장!',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '적이 공격한다',
            ),
            playerChoices: [],
          ),
        ],
        victoryText: '승리!',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(oneTurnCombat);
      await tester.pumpWidget(
          buildGameScreenWidget(blockData: blocks, encounter: oneTurnCombat, initialRunState: _floor2State));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 전투 진입
      await advanceToCombatChoices(tester);
      expect(find.byType(MomentumGaugeWidget), findsOneWidget);

      // 행동 선택
      await selectAction(tester, '공격한다');

      // 결과 지나기
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 승리 텍스트 표시 (normal type with combatPhase: 'end')
      // 승리 텍스트를 지나면 게이지 숨김
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 전투 종료 후 게이지 숨김
      expect(find.byType(MomentumGaugeWidget), findsNothing);
    });

    testWidgets('consecutiveCount 경계: 공격→공격→방어 시 리셋 확인',
        (tester) async {
      final encounter = _threeTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter, initialRunState: _floor2State, momentumConfig: const MomentumConfig(initialValue: 0)));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Turn 1: 공격 (첫 턴: delta 0, consecutive=0)
      await advanceToCombatChoices(tester);
      await selectAction(tester, '공격한다');

      // Turn 2: 공격 (2연속: -15, consecutive=1→2)
      // 기세: 0 + 0 - 15 = 0 (클램핑)
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '공격한다');

      // Turn 3: 방어 (전환: +12, consecutive 리셋→0)
      // 기세: 0 + 12 = 12
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '방어한다');

      // 기세 12 확인 (전환 보너스 적용)
      expect(find.text('기세 12'), findsOneWidget);
    });
  });
}
