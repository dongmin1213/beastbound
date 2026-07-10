import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_outcome_widget.dart';

void main() {
  Widget buildWidget(TextBlockData blockData) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: CombatOutcomeWidget(
          blockData: blockData,
        ),
      ),
    );
  }

  /// flutter_animate 타이머 정리를 위한 헬퍼.
  /// CombatOutcomeWidget이 내부적으로 flutter_animate를 사용하므로
  /// 테스트 종료 전에 모든 애니메이션 타이머를 완료해야 한다.
  Future<void> pumpAndFinishAnimations(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  }

  final victoryBlock = TextBlockData(
    text: '✦ 승리 — 적이 쓰러졌다!',
    blockType: TextBlockType.combatOutcome,
    metadata: const {
      'combatPhase': 'end',
      'combatOutcome': 'victory',
      'resultScore': 2,
    },
  );

  final defeatBlock = TextBlockData(
    text: '✧ 패배 — 당신이 쓰러졌다...',
    blockType: TextBlockType.combatOutcome,
    metadata: const {
      'combatPhase': 'end',
      'combatOutcome': 'defeat',
      'resultScore': -1,
    },
  );

  group('CombatOutcomeWidget', () {
    testWidgets('승리 텍스트 렌더링', (tester) async {
      await tester.pumpWidget(buildWidget(victoryBlock));
      await pumpAndFinishAnimations(tester);

      expect(find.text('✦ 승리 — 적이 쓰러졌다!'), findsOneWidget);
    });

    testWidgets('승리 시 골드 색상 적용', (tester) async {
      await tester.pumpWidget(buildWidget(victoryBlock));
      await pumpAndFinishAnimations(tester);

      final textWidget = tester.widget<Text>(
        find.text('✦ 승리 — 적이 쓰러졌다!'),
      );
      expect(textWidget.style?.color, AppTheme.combatVictoryColor);
      // fontSize는 ResponsiveScale에 의해 화면 크기에 비례 (기준: 18)
      expect(textWidget.style?.fontSize, isNotNull);
      expect(textWidget.style?.fontSize, greaterThanOrEqualTo(18 * 0.88));
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('패배 텍스트 렌더링', (tester) async {
      await tester.pumpWidget(buildWidget(defeatBlock));
      await pumpAndFinishAnimations(tester);

      expect(find.text('✧ 패배 — 당신이 쓰러졌다...'), findsOneWidget);
    });

    testWidgets('패배 시 레드 색상 적용', (tester) async {
      await tester.pumpWidget(buildWidget(defeatBlock));
      await pumpAndFinishAnimations(tester);

      final textWidget = tester.widget<Text>(
        find.text('✧ 패배 — 당신이 쓰러졌다...'),
      );
      expect(textWidget.style?.color, AppTheme.combatDefeatColor);
    });

    testWidgets('반응형 폰트 크기 범위 검증 (테스트 환경 800x600)', (tester) async {
      await tester.pumpWidget(buildWidget(victoryBlock));
      await pumpAndFinishAnimations(tester);

      final textWidget = tester.widget<Text>(
        find.text('✦ 승리 — 적이 쓰러졌다!'),
      );
      // 테스트 환경(800x600): scaleFontSize(18) = 18 * 1.15 = 20.7 (clamp 상한)
      expect(textWidget.style?.fontSize, closeTo(20.7, 0.1));
    });
  });
}
