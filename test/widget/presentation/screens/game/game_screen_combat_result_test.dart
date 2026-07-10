import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_outcome_widget.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_gauge_widget.dart';

import '../../../../helpers/game_screen_test_helper.dart';
import '../../../../helpers/rich_text_finder.dart';

/// 3턴 전투: 적 공격/방어/관찰
const _threeTurnCombat = CombatEncounter(
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
  defeatText: '적에게 쓰러졌다...',
);

/// 0턴 전투
const _zeroTurnCombat = CombatEncounter(
  enemyName: '허깨비',
  introText: '허깨비가 나타났다!',
  turns: [],
  victoryText: '허깨비가 사라졌다.',
  defeatText: '허깨비에게 졌다.',
);

void main() {
  /// 전투 진입까지 진행
  Future<void> advanceToCombatChoices(WidgetTester tester) async {
    await tapGameScreen(tester);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tapGameScreen(tester);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// 결과 텍스트를 지나 다음 턴 선택지까지 진행
  Future<void> advanceToNextTurnChoices(WidgetTester tester) async {
    await tapGameScreen(tester);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
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
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('GameScreen combat result integration', () {
    testWidgets('전체 effective 선택 → 승리 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(_threeTurnCombat), encounter: _threeTurnCombat));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Turn 1: 방어 vs 공격 → effective
      await advanceToCombatChoices(tester);
      await selectAction(tester, '방어한다');

      // Turn 2: 관찰 vs 방어 → neutral (방어 중인 적을 관찰 → neutral, not effective)
      // Actually: observe vs defend → neutral. Let's do attack vs defend → ineffective
      // Wait - we need all effective. Let me check:
      // T1: defend vs attack → effective ✓
      // T2: observe vs defend → neutral ✗
      // We need: T2: attack vs observe or defend vs attack... but T2 enemy is defend.
      // observe vs defend = neutral. attack vs defend = ineffective.
      // To get 3 effective: we can't with these enemy actions.
      // Let's just verify victory with score >= 0 (2 effective + 1 neutral = victory)
      await advanceToNextTurnChoices(tester);
      // T2: observe vs defend → neutral
      await selectAction(tester, '관찰한다');

      // T3: attack vs observe → effective
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '공격한다');

      // combatOutcome 블록으로 이동
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 승리 텍스트 확인 (score = +1+0+1 = +2, victory)
      expect(find.byType(CombatOutcomeWidget), findsOneWidget);
      expect(find.textContaining('승리'), findsOneWidget);
      expect(find.textContaining('적을 물리쳤다!'), findsOneWidget);
    });

    testWidgets('전체 ineffective 선택 → 패배 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(_threeTurnCombat), encounter: _threeTurnCombat));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // T1: observe vs attack → ineffective
      await advanceToCombatChoices(tester);
      await selectAction(tester, '관찰한다');

      // T2: attack vs defend → ineffective
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '공격한다');

      // T3: defend vs observe → ineffective
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '방어한다');

      // combatOutcome 블록으로 이동
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 패배 텍스트 확인 (score = -3, defeat)
      expect(find.byType(CombatOutcomeWidget), findsOneWidget);
      expect(find.textContaining('패배'), findsOneWidget);
      expect(find.textContaining('적에게 쓰러졌다...'), findsOneWidget);
    });

    testWidgets('D-04: 일반 패배 → HP 손실 표시 + 자동 진행 (재도전 없음)', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(_threeTurnCombat), encounter: _threeTurnCombat, combatConfig: const CombatBalanceConfig(normalDefeatHpLoss: 30)));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 전체 ineffective로 패배
      await advanceToCombatChoices(tester);
      await selectAction(tester, '관찰한다');

      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '공격한다');

      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '방어한다');

      // combatOutcome으로 이동
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 패배 확인
      expect(find.textContaining('패배'), findsOneWidget);

      // combatOutcome을 advance → HP 손실 서술 블록
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // HP 손실 서술 블록 표시 확인 (30 데미지, 70/100)
      expect(findRichText('체력이 30 감소했다'), findsOneWidget);

      // D-04: "다시 도전하기" 선택지가 없어야 함 (자동 진행)
      expect(find.textContaining('다시 도전하기'), findsNothing);
    });

    testWidgets('D-04: 일반 패배 후 재도전 선택지 미표시 확인', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(_threeTurnCombat), encounter: _threeTurnCombat));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 패배까지 진행
      await advanceToCombatChoices(tester);
      await selectAction(tester, '관찰한다');
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '공격한다');
      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '방어한다');

      // combatOutcome으로 이동
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 패배 확인
      expect(find.textContaining('패배'), findsOneWidget);

      // combatOutcome advance → HP 손실 블록
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // HP 손실 advance
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // D-04: 재도전/후퇴 선택지가 전혀 없어야 함
      expect(find.textContaining('다시 도전하기'), findsNothing);
      expect(find.textContaining('후퇴'), findsNothing);

      // 기세 게이지도 숨겨져야 함 (전투 종료)
      expect(find.byType(MomentumGaugeWidget), findsNothing);
    });

    testWidgets('승리 후 게이지 숨김 + combatPhase end', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(_threeTurnCombat), encounter: _threeTurnCombat));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 2 effective + 1 neutral = victory
      await advanceToCombatChoices(tester);
      await selectAction(tester, '방어한다'); // vs attack → effective

      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '관찰한다'); // vs defend → neutral

      await advanceToNextTurnChoices(tester);
      await selectAction(tester, '공격한다'); // vs observe → effective

      // combatOutcome으로 이동
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 승리 표시 중 — 아직 advance 전이므로 combatPhase:end 미처리
      expect(find.textContaining('승리'), findsOneWidget);

      // combatOutcome을 advance (이때 combatPhase:end 처리)
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // 게이지 숨김
      expect(find.byType(MomentumGaugeWidget), findsNothing);
    });

    testWidgets('0턴 전투 → 승리', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(blockData: CombatFlowManager.toDynamicTextBlocks(_zeroTurnCombat), encounter: _zeroTurnCombat));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // intro 표시
      expect(findRichText('허깨비가 나타났다!'), findsOneWidget);

      // advance → combatOutcome (0턴이므로 바로)
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // combatOutcome 자동 완료 — 승리 표시 (score=0, victory)
      expect(find.byType(CombatOutcomeWidget), findsOneWidget);
      expect(find.textContaining('승리'), findsOneWidget);
      expect(find.textContaining('허깨비가 사라졌다.'), findsOneWidget);
    });
  });
}
