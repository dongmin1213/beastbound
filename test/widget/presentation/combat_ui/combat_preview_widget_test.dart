import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_preview_widget.dart';

/// Extract the text content from the first RichText in the widget tree.
String _richTextContent(WidgetTester tester) {
  final richText = tester.widget<RichText>(find.byType(RichText).first);
  final span = richText.text as TextSpan;
  return span.text ?? '';
}

/// Extract the text color from the first RichText in the widget tree.
Color? _richTextColor(WidgetTester tester) {
  final richText = tester.widget<RichText>(find.byType(RichText).first);
  final span = richText.text as TextSpan;
  return span.style?.color;
}

void main() {
  Widget buildTestWidget(EnemyAction action) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: CombatPreviewWidget(action: action),
      ),
    );
  }

  group('CombatPreviewWidget', () {
    testWidgets('displays attack preview with prefix and text', (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.attack,
        previewText: '적이 강하게 내려치려 한다',
      );
      await tester.pumpWidget(buildTestWidget(action));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final text = _richTextContent(tester);
      expect(text, contains('⚔'));
      expect(text, contains('적이 강하게 내려치려 한다'));
    });

    testWidgets('displays defend preview with prefix and text', (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.defend,
        previewText: '적이 방어 자세를 취한다',
      );
      await tester.pumpWidget(buildTestWidget(action));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final text = _richTextContent(tester);
      expect(text, contains('🛡'));
      expect(text, contains('적이 방어 자세를 취한다'));
    });

    testWidgets('displays observe preview with prefix and text',
        (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.observe,
        previewText: '적이 조용히 관찰한다',
      );
      await tester.pumpWidget(buildTestWidget(action));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final text = _richTextContent(tester);
      expect(text, contains('👁'));
      expect(text, contains('적이 조용히 관찰한다'));
    });

    testWidgets('uses attack color for attack type', (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.attack,
        previewText: '공격',
      );
      await tester.pumpWidget(buildTestWidget(action));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(_richTextColor(tester), AppTheme.combatPreviewAttackColor);
    });

    testWidgets('uses defend color for defend type', (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.defend,
        previewText: '방어',
      );
      await tester.pumpWidget(buildTestWidget(action));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(_richTextColor(tester), AppTheme.combatPreviewDefendColor);
    });

    testWidgets('uses observe color for observe type', (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.observe,
        previewText: '관찰',
      );
      await tester.pumpWidget(buildTestWidget(action));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(_richTextColor(tester), AppTheme.combatPreviewObserveColor);
    });

    testWidgets('handles empty preview text without crash', (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.attack,
        previewText: '',
      );
      await tester.pumpWidget(buildTestWidget(action));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final text = _richTextContent(tester);
      expect(text, contains('⚔'));
    });

    testWidgets('fades in with AnimatedOpacity', (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.attack,
        previewText: '공격',
      );
      await tester.pumpWidget(buildTestWidget(action));

      // Initially opacity should be animating
      final animatedOpacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(animatedOpacity, isNotNull);

      // After animation settles
      await tester.pump();
      await tester.pump();
      await tester.pump();
      final settledOpacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(settledOpacity.opacity, 1.0);
    });

    testWidgets('has combat preview background', (tester) async {
      const action = EnemyAction(
        type: EnemyActionType.attack,
        previewText: '공격',
      );
      await tester.pumpWidget(buildTestWidget(action));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, AppTheme.combatPreviewBackground);
    });
  });
}
