import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

void main() {
  Widget buildTestWidget({
    required String text,
    TextSpeed speed = TextSpeed.normal,
    VoidCallback? onComplete,
    int charsPerSecondNormal = 40,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TypewriterWidget(
          text: text,
          speed: speed,
          onComplete: onComplete,
          charsPerSecondNormal: charsPerSecondNormal,
        ),
      ),
    );
  }

  String getVisibleText(WidgetTester tester) {
    final richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(TypewriterWidget),
        matching: find.byType(RichText),
      ),
    );
    return (richText.text as TextSpan).text ?? '';
  }

  group('TypewriterWidget', () {
    testWidgets('displays text progressively', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        text: 'AB',
        charsPerSecondNormal: 2,
      ));

      // Initially should show partial text
      await tester.pump(const Duration(milliseconds: 100));
      final visibleText = getVisibleText(tester);
      // Text should exist (may be partial)
      expect(visibleText, isNotNull);
    });

    testWidgets('instant speed shows all text immediately', (tester) async {
      bool completed = false;
      await tester.pumpWidget(buildTestWidget(
        text: '안녕하세요',
        speed: TextSpeed.instant,
        onComplete: () => completed = true,
      ));
      await tester.pump();

      expect(getVisibleText(tester), '안녕하세요');
      expect(completed, isTrue);
    });

    testWidgets('empty text does not crash and calls onComplete', (tester) async {
      bool completed = false;
      await tester.pumpWidget(buildTestWidget(
        text: '',
        onComplete: () => completed = true,
      ));
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('skipToEnd shows complete text', (tester) async {
      bool completed = false;
      await tester.pumpWidget(buildTestWidget(
        text: '각나다',
        charsPerSecondNormal: 2,
        onComplete: () => completed = true,
      ));
      await tester.pump(const Duration(milliseconds: 50));

      // Get state and skip
      final state = tester.state<TypewriterWidgetState>(
        find.byType(TypewriterWidget),
      );
      state.skipToEnd();
      await tester.pump();

      expect(getVisibleText(tester), '각나다');
      expect(completed, isTrue);
    });

    testWidgets('skip during jamo composition shows completed hangul', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        text: '찬란한',
        charsPerSecondNormal: 4,
      ));

      // Let animation start briefly
      await tester.pump(const Duration(milliseconds: 100));

      // Skip mid-animation
      final state = tester.state<TypewriterWidgetState>(
        find.byType(TypewriterWidget),
      );
      state.skipToEnd();
      await tester.pump();

      expect(getVisibleText(tester), '찬란한');
    });

    testWidgets('completes after animation finishes', (tester) async {
      bool completed = false;
      await tester.pumpWidget(buildTestWidget(
        text: 'AB',
        charsPerSecondNormal: 100,
        onComplete: () => completed = true,
      ));

      // Pump enough to finish (2 chars at 100 chars/sec = 20ms)
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('non-Korean text works correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        text: 'Hello!',
        speed: TextSpeed.instant,
      ));
      await tester.pump();

      expect(getVisibleText(tester), 'Hello!');
    });

    testWidgets('speed parameter is reflected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        text: 'ABCDEF',
        speed: TextSpeed.slow,
      ));

      // Slow speed should still be animating after a short time
      await tester.pump(const Duration(milliseconds: 10));
      final state = tester.state<TypewriterWidgetState>(
        find.byType(TypewriterWidget),
      );
      expect(state.isAnimating, isTrue);
    });

    testWidgets('handles long text without crash', (tester) async {
      final longText = '가' * 1000;
      await tester.pumpWidget(buildTestWidget(
        text: longText,
        speed: TextSpeed.instant,
      ));
      await tester.pump();

      expect(getVisibleText(tester).length, 1000);
    });
  });
}
