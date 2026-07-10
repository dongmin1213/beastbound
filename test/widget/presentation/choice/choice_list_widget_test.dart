import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_card_widget.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_list_widget.dart';

void main() {
  const choices = [
    ChoiceData(id: 'a', text: '왼쪽 길', resultTextBlocks: ['어둠이 깊어진다.']),
    ChoiceData(id: 'b', text: '오른쪽 길', resultTextBlocks: ['빛이 보인다.']),
    ChoiceData(id: 'c', text: '관찰한다', resultTextBlocks: ['문양이 보인다.']),
  ];

  Widget buildList({
    List<ChoiceData> choiceList = choices,
    bool visible = true,
    ValueChanged<ChoiceData>? onChoiceSelected,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: ChoiceListWidget(
          choices: choiceList,
          visible: visible,
          onChoiceSelected: onChoiceSelected ?? (_) {},
        ),
      ),
    );
  }

  group('ChoiceListWidget', () {
    testWidgets('renders all choices', (tester) async {
      await tester.pumpWidget(buildList());
      await tester.pumpAndSettle();

      expect(find.textContaining('왼쪽 길'), findsOneWidget);
      expect(find.textContaining('오른쪽 길'), findsOneWidget);
      expect(find.textContaining('관찰한다'), findsOneWidget);
    });

    testWidgets('renders single choice', (tester) async {
      await tester.pumpWidget(buildList(
        choiceList: const [
          ChoiceData(id: 'only', text: '계속', resultTextBlocks: []),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('계속'), findsOneWidget);
    });

    testWidgets('renders nothing for empty choices', (tester) async {
      await tester.pumpWidget(buildList(choiceList: const []));
      await tester.pumpAndSettle();

      expect(find.byType(ChoiceCardWidget), findsNothing);
    });

    testWidgets('calls onChoiceSelected when choice tapped', (tester) async {
      ChoiceData? selected;

      await tester.pumpWidget(buildList(
        onChoiceSelected: (choice) => selected = choice,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('오른쪽 길'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'b');
    });

    testWidgets('disables other choices after selection', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(buildList(
        onChoiceSelected: (_) => callCount++,
      ));
      await tester.pumpAndSettle();

      // Select first choice
      await tester.tap(find.textContaining('왼쪽 길'));
      await tester.pump();

      expect(callCount, 1);

      // Try to tap another choice — should be ignored
      await tester.tap(find.textContaining('오른쪽 길'));
      await tester.pump();

      expect(callCount, 1);
    });

    testWidgets('not visible when visible is false', (tester) async {
      await tester.pumpWidget(buildList(visible: false));
      await tester.pumpAndSettle();

      // List wraps children with IgnorePointer when not visible
      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(ChoiceListWidget),
          matching: find.byType(IgnorePointer),
        ).first,
      );

      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('visible when visible is true', (tester) async {
      await tester.pumpWidget(buildList(visible: true));
      await tester.pumpAndSettle();

      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(ChoiceListWidget),
          matching: find.byType(IgnorePointer),
        ).first,
      );

      expect(ignorePointer.ignoring, isFalse);
    });
  });
}
