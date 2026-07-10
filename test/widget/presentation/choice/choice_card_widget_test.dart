import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_card_widget.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

void main() {
  const testChoice = ChoiceData(
    id: 'test_choice',
    text: '왼쪽 길로 간다',
    resultTextBlocks: ['어둠이 깊어진다.'],
  );

  Widget buildCard({
    ChoiceData choice = testChoice,
    ChoiceCardState state = ChoiceCardState.idle,
    ValueChanged<ChoiceData>? onTap,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: ChoiceCardWidget(
          choice: choice,
          state: state,
          onTap: onTap ?? (_) {},
        ),
      ),
    );
  }

  group('ChoiceCardWidget', () {
    testWidgets('renders choice text', (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.textContaining('왼쪽 길로 간다'), findsOneWidget);
    });

    testWidgets('calls onTap with choice data when tapped in idle state',
        (tester) async {
      ChoiceData? tappedChoice;

      await tester.pumpWidget(buildCard(
        onTap: (choice) => tappedChoice = choice,
      ));

      await tester.tap(find.textContaining('왼쪽 길로 간다'));
      await tester.pump();

      expect(tappedChoice, isNotNull);
      expect(tappedChoice!.id, 'test_choice');
    });

    testWidgets('does not call onTap when in selected state', (tester) async {
      ChoiceData? tappedChoice;

      await tester.pumpWidget(buildCard(
        state: ChoiceCardState.selected,
        onTap: (choice) => tappedChoice = choice,
      ));

      await tester.tap(find.text('왼쪽 길로 간다'));
      await tester.pump();

      expect(tappedChoice, isNull);
    });

    testWidgets('does not call onTap when in disabled state', (tester) async {
      ChoiceData? tappedChoice;

      await tester.pumpWidget(buildCard(
        state: ChoiceCardState.disabled,
        onTap: (choice) => tappedChoice = choice,
      ));

      await tester.tap(find.textContaining('왼쪽 길로 간다'));
      await tester.pump();

      expect(tappedChoice, isNull);
    });

    testWidgets('rapid double-tap only calls onTap once', (tester) async {
      // Double-tap protection: card ignores taps when not idle.
      // ChoiceListWidget transitions state after first tap.
      int tapCount = 0;

      // First tap in idle state — fires
      await tester.pumpWidget(buildCard(
        state: ChoiceCardState.idle,
        onTap: (_) => tapCount++,
      ));
      await tester.tap(find.textContaining('왼쪽 길로 간다'));
      await tester.pump();
      expect(tapCount, 1);

      // Second tap after state changes to selected — ignored
      await tester.pumpWidget(buildCard(
        state: ChoiceCardState.selected,
        onTap: (_) => tapCount++,
      ));
      await tester.tap(find.text('왼쪽 길로 간다'));
      await tester.pump();
      expect(tapCount, 1);
    });

    testWidgets('applies idle styling', (tester) async {
      await tester.pumpWidget(buildCard(state: ChoiceCardState.idle));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Container with decoration renders as DecoratedBox in the widget tree
      final decoratedBox = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(ChoiceCardWidget),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      // normal-style idle: 층별 테마 배경 + full border
      // currentFloor 기본값 1 → FloorTheme.ruins
      final expectedBg = FloorThemeVisuals.fromFloor(1).frameBackground;
      expect(decoration.color, expectedBg);
      expect(decoration.border, isA<Border>());
    });

    testWidgets('applies selected styling', (tester) async {
      await tester.pumpWidget(buildCard(state: ChoiceCardState.selected));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final decoratedBox = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(ChoiceCardWidget),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, AppTheme.choiceSelectedBackground);
    });
  });
}
