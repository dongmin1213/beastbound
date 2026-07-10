import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_list_widget.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_preview_widget.dart';

import '../../../../helpers/game_screen_test_helper.dart';
import '../../../../helpers/rich_text_finder.dart';

/// TextSpan 트리에서 특정 텍스트를 포함하며 특정 색상을 가진 span이 있는지 재귀 검색.
///
/// CombatResultRenderer는 TextSpan(children: [...])로 텍스트를 분할하므로
/// 부모의 .text가 null이고 자식 span에 실제 텍스트가 있다.
bool _textSpanHasTextWithColor(TextSpan span, String text, Color color) {
  if ((span.text?.contains(text) ?? false) && span.style?.color == color) {
    return true;
  }
  if (span.children != null) {
    for (final child in span.children!) {
      if (child is TextSpan && _textSpanHasTextWithColor(child, text, color)) {
        return true;
      }
    }
  }
  return false;
}

/// 2턴 전투 데이터 생성
CombatEncounter _twoTurnCombat() {
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
        playerChoices: [
          ChoiceData(id: 't1_a', text: '공격한다', resultTextBlocks: ['일격!']),
          ChoiceData(id: 't1_d', text: '방어한다', resultTextBlocks: ['막았다!']),
          ChoiceData(
              id: 't1_o', text: '관찰한다', resultTextBlocks: ['패턴 파악!']),
        ],
      ),
      CombatTurnData(
        turnNumber: 2,
        enemyAction: EnemyAction(
          type: EnemyActionType.defend,
          previewText: '적이 방어 자세를 취한다',
        ),
        playerChoices: [
          ChoiceData(
              id: 't2_a', text: '공격한다', resultTextBlocks: ['돌파 실패!']),
          ChoiceData(
              id: 't2_d', text: '방어한다', resultTextBlocks: ['대치 상태!']),
          ChoiceData(
              id: 't2_o', text: '관찰한다', resultTextBlocks: ['약점 발견!']),
        ],
      ),
    ],
    victoryText: '적을 물리쳤다!',
    defeatText: '패배했다.',
  );
}

void main() {
  group('GameScreen combat integration', () {
    testWidgets('turn divider auto-advances without tap', (tester) async {
      final blocks = CombatFlowManager.toTextBlocks(_twoTurnCombat());
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Intro text completes → tap to advance
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Turn divider should auto-advance → combat preview should be visible
      // The turn divider "— 1턴 —" should appear in completed blocks
      expect(findRichText('적이 나타났다!'), findsOneWidget);
      // Turn divider was auto-advanced and is in completed blocks
      expect(find.text('═══════ 1턴 ═══════'), findsOneWidget);
    });

    testWidgets('combat preview shows with correct action type',
        (tester) async {
      final blocks = CombatFlowManager.toTextBlocks(_twoTurnCombat());
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Combat preview widget should be visible (auto-advanced past divider)
      expect(find.byType(CombatPreviewWidget), findsWidgets);
    });

    testWidgets('choices appear after combat preview completes',
        (tester) async {
      final blocks = CombatFlowManager.toTextBlocks(_twoTurnCombat());
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Preview auto-completes → tap to advance to choices block
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Choices should be visible
      expect(find.byType(ChoiceListWidget), findsOneWidget);
      expect(find.textContaining('공격한다'), findsOneWidget);
      expect(find.textContaining('방어한다'), findsOneWidget);
      expect(find.textContaining('관찰한다'), findsOneWidget);
    });

    testWidgets('2-turn combat flows correctly: turn1 → turn2 → victory',
        (tester) async {
      final blocks = CombatFlowManager.toTextBlocks(_twoTurnCombat());
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // === Turn 1 ===
      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Turn divider auto-advanced, preview auto-completed → tap to choices
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select "공격한다"
      expect(find.byType(ChoiceListWidget), findsOneWidget);
      await tester.tap(find.textContaining('공격한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Result text should appear
      expect(findRichText('일격!'), findsOneWidget);
      // Choice history
      expect(findRichText('> 공격한다'), findsOneWidget);

      // === Turn 2 ===
      // Tap to advance past result text
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Turn 2 divider auto-advances, preview auto-completes → tap to choices
      expect(find.text('═══════ 2턴 ═══════'), findsOneWidget);

      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Turn 2 choices
      expect(find.byType(ChoiceListWidget), findsOneWidget);

      // Select "관찰한다"
      await tester.tap(find.textContaining('관찰한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Result
      expect(findRichText('약점 발견!'), findsOneWidget);

      // === Victory ===
      // Tap to advance past result → victory text
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Victory text displayed
      expect(findRichText('적을 물리쳤다!'), findsOneWidget);
    });

    testWidgets('0-turn combat shows intro then victory directly',
        (tester) async {
      const encounter = CombatEncounter(
        enemyName: '허깨비',
        introText: '허깨비가 나타났다!',
        turns: [],
        victoryText: '허깨비가 사라졌다.',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Intro
      expect(findRichText('허깨비가 나타났다!'), findsOneWidget);

      // Tap to advance → victory
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(findRichText('허깨비가 사라졌다.'), findsOneWidget);
    });

    testWidgets('completed combat preview uses correct color from metadata',
        (tester) async {
      final blocks = CombatFlowManager.toTextBlocks(_twoTurnCombat());
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Turn divider auto-advanced, preview auto-completed → tap to advance
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select choice to proceed
      await tester.tap(find.textContaining('공격한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // The completed combat preview should use attack color
      final completedPreview = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                AppTheme.combatPreviewBackground,
      );
      expect(completedPreview, findsWidgets);
    });

    testWidgets('turn divider renders in completed blocks with correct style',
        (tester) async {
      final blocks = CombatFlowManager.toTextBlocks(_twoTurnCombat());
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // "═══════ 1턴 ═══════" should be displayed and centered
      final dividerFinder = find.text('═══════ 1턴 ═══════');
      expect(dividerFinder, findsOneWidget);

      // Verify it's inside a Center widget
      expect(
        find.ancestor(of: dividerFinder, matching: find.byType(Center)),
        findsOneWidget,
      );
    });

    testWidgets('combat blocks integrate with narrative blocks',
        (tester) async {
      final combatBlocks = CombatFlowManager.toTextBlocks(_twoTurnCombat());
      final allBlocks = <TextBlockData>[
        const TextBlockData(text: '서술 텍스트입니다.'),
        ...combatBlocks,
      ];

      await tester.pumpWidget(buildGameScreenWidget(blockData: allBlocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // First: narrative text
      expect(findRichText('서술 텍스트입니다.'), findsOneWidget);

      // Tap to advance → combat intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(findRichText('적이 나타났다!'), findsOneWidget);
    });
  });

  group('GameScreen dynamic combat (actionType)', () {
    testWidgets(
        'dynamic choices with actionType generate interaction-based result',
        (tester) async {
      // 1턴: 적 공격, 플레이어 방어 → effective
      final encounter = _twoTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Advance past preview → choices
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Should see 3 dynamic choices with prefixes
      expect(find.byType(ChoiceListWidget), findsOneWidget);

      // Select defend (🛡 방어한다) vs enemy attack → effective
      await tester.tap(find.textContaining('방어한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Result should contain the dynamic interaction text
      expect(findRichText('적의 공격을 견고히 막아냈다!'), findsOneWidget);
    });

    testWidgets('dynamic combat result shows effective color (green)',
        (tester) async {
      final encounter = _twoTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Advance past preview → choices
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select defend vs enemy attack → effective
      await tester.tap(find.textContaining('방어한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Find the RichText with effective color
      // CombatResultRenderer uses TextSpan(children: [...]) so we must
      // search child spans for the text and check their style color.
      final resultFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final textSpan = widget.text;
          if (textSpan is TextSpan) {
            return _textSpanHasTextWithColor(
              textSpan,
              '막아냈다',
              AppTheme.combatResultEffectiveColor,
            );
          }
        }
        return false;
      });
      expect(resultFinder, findsOneWidget);
    });

    testWidgets('dynamic combat result shows ineffective color (red)',
        (tester) async {
      final encounter = _twoTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Advance past preview → choices
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select observe vs enemy attack → ineffective
      await tester.tap(find.textContaining('관찰한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Find the RichText with ineffective color
      // CombatResultRenderer uses TextSpan(children: [...]) so we must
      // search child spans for the text and check their style color.
      final resultFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final textSpan = widget.text;
          if (textSpan is TextSpan) {
            return _textSpanHasTextWithColor(
              textSpan,
              '아프다',
              AppTheme.combatResultIneffectiveColor,
            );
          }
        }
        return false;
      });
      expect(resultFinder, findsOneWidget);
    });

    testWidgets('2-turn dynamic combat flows correctly to victory',
        (tester) async {
      final encounter = _twoTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // === Turn 1 (enemy: attack) ===
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select attack vs attack → neutral
      await tester.tap(find.textContaining('공격한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(findRichText('양쪽의 공격이 맞부딪힌다!'), findsOneWidget);

      // === Turn 2 (enemy: defend) ===
      // Tap to advance past result (combatResult auto-completes)
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Turn 2 divider auto-advances, preview auto-completes → tap to choices
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select observe vs defend → neutral
      await tester.tap(find.textContaining('관찰한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(findRichText('방어 중인 적을 안전하게 관찰한다.'), findsOneWidget);

      // === Victory ===
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(findRichText('적을 물리쳤다!'), findsOneWidget);
    });

    testWidgets(
        'legacy choices without actionType still use resultTextBlocks',
        (tester) async {
      // Use toTextBlocks (legacy) which doesn't set actionType
      final blocks = CombatFlowManager.toTextBlocks(_twoTurnCombat());
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro → turn divider → preview → choices
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select "공격한다" → should use legacy resultTextBlocks
      await tester.tap(find.textContaining('공격한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Legacy result text
      expect(findRichText('일격!'), findsOneWidget);
    });

    testWidgets('combat result auto-completes and advances on tap',
        (tester) async {
      final encounter = _twoTurnCombat();
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      await tester.pumpWidget(buildGameScreenWidget(blockData: blocks, encounter: encounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance to choices
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select attack vs attack
      await tester.tap(find.textContaining('공격한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Result is showing, should auto-complete (no typewriter)
      // Tap should advance to next block (turn 2 divider)
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Turn 2 divider should now be visible
      expect(find.text('═══════ 2턴 ═══════'), findsOneWidget);
    });

    testWidgets(
        'actionType choice without enemy preview metadata falls back to attack',
        (tester) async {
      // 적 행동 예고 없이 바로 actionType 선택지 → 폴백 테스트
      // CombatBloc은 encounter의 턴 정보에서 적 행동을 가져옴
      const fallbackEncounter = CombatEncounter(
        enemyName: '폴백 적',
        introText: '전투 시작',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '',
            ),
            playerChoices: [],
          ),
        ],
        victoryText: '',
        defeatText: '',
      );
      final blocks = <TextBlockData>[
        const TextBlockData(
          text: '전투 시작',
        ),
        TextBlockData(
          text: '행동을 선택하라',
          choices: [
            ChoiceData(
              id: 'no_preview_attack',
              text: '⚔ 공격한다',
              resultTextBlocks: const [],
              actionType: 'attack',
            ),
          ],
        ),
        const TextBlockData(text: '전투 종료'),
      ];

      await tester.pumpWidget(
          buildGameScreenWidget(blockData: blocks, encounter: fallbackEncounter));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Advance past intro
      await tapGameScreen(tester);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Select attack (no combatPreview in completed blocks → fallback to enemy attack)
      // attack vs attack(fallback) → neutral
      await tester.tap(find.textContaining('⚔ 공격한다'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Should show neutral result (attack vs attack fallback)
      expect(findRichText('양쪽의 공격이 맞부딪힌다!'), findsOneWidget);
    });
  });
}
