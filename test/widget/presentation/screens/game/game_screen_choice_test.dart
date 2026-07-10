import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_card_widget.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_list_widget.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import '../../../../helpers/game_screen_test_helper.dart';
import '../../../../helpers/rich_text_finder.dart';

void main() {
  group('GameScreen choice integration', () {
    testWidgets('shows choices after text block completes', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: const [
          TextBlockData(
            text: '두 갈래 길이 보인다.',
            choices: [
              ChoiceData(
                  id: 'a', text: '왼쪽', resultTextBlocks: ['왼쪽으로 갔다.']),
              ChoiceData(
                  id: 'b', text: '오른쪽', resultTextBlocks: ['오른쪽으로 갔다.']),
            ],
          ),
        ],
      ));
      // Instant speed: text completes immediately
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Choices should be visible
      expect(find.byType(ChoiceListWidget), findsOneWidget);
      expect(find.textContaining('왼쪽'), findsOneWidget);
      expect(find.textContaining('오른쪽'), findsOneWidget);
    });

    testWidgets('does not show choices during text animation', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: const [
          TextBlockData(
            text: '긴 텍스트가 출력됩니다.',
            choices: [
              ChoiceData(id: 'a', text: '선택', resultTextBlocks: ['결과']),
            ],
          ),
        ],
        speed: TextSpeed.slow,
      ));
      // Don't settle — animation still in progress
      await tester.pump(const Duration(milliseconds: 100));

      // ChoiceListWidget is always in the tree, but during animation
      // it should be invisible (AnimatedOpacity opacity 0) and non-interactive
      final choiceList = tester.widget<ChoiceListWidget>(
        find.byType(ChoiceListWidget),
      );
      expect(choiceList.visible, isFalse);
    });

    testWidgets('selecting a choice shows result text', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: const [
          TextBlockData(
            text: '질문입니다.',
            choices: [
              ChoiceData(
                  id: 'a', text: '답변A', resultTextBlocks: ['결과A 텍스트.']),
              ChoiceData(
                  id: 'b', text: '답변B', resultTextBlocks: ['결과B 텍스트.']),
            ],
          ),
        ],
      ));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Tap choice A
      await tester.tap(find.textContaining('답변A'));
      await tester.pump();

      // Wait for highlight delay (400ms) + frame callback
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Choice history should appear with ">" prefix (rendered as RichText)
      expect(findRichText('> 답변A'), findsOneWidget);

      // Result text should be displayed via TypewriterWidget (RichText)
      expect(findRichText('결과A 텍스트.'), findsOneWidget);
    });

    testWidgets('background tap is ignored when choices visible',
        (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: const [
          TextBlockData(
            text: '선택하세요.',
            choices: [
              ChoiceData(id: 'a', text: '옵션', resultTextBlocks: ['결과']),
            ],
          ),
          TextBlockData(text: '이 텍스트는 아직 안 보여야 함'),
        ],
      ));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Choices are showing — tap background (GestureDetector area)
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Should still show choices, not advance
      expect(find.byType(ChoiceListWidget), findsOneWidget);
    });

    testWidgets('no choices block uses normal tap-to-advance', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: const [
          TextBlockData(text: '첫 번째 블록'),
          TextBlockData(text: '두 번째 블록'),
        ],
      ));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // No choices — tap GestureDetector to advance
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Second block is rendered via TypewriterWidget (RichText)
      expect(findRichText('두 번째 블록'), findsOneWidget);
    });

    testWidgets('empty choices list skips choice UI', (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: const [
          TextBlockData(text: '빈 선택지 블록', choices: []),
          TextBlockData(text: '다음 블록'),
        ],
      ));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // ChoiceListWidget is always in the tree but with empty choices
      // it renders SizedBox.shrink(), so no ChoiceCardWidget instances exist
      expect(find.byType(ChoiceCardWidget), findsNothing);

      // Tap to advance normally
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Second block rendered via TypewriterWidget (RichText)
      expect(findRichText('다음 블록'), findsOneWidget);
    });
  });
}
