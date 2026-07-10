import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/completed_block_renderer.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

void main() {
  group('CompletedBlockRenderer — dispositionHint', () {
    test('TextBlockType.dispositionHint enum 존재', () {
      expect(TextBlockType.dispositionHint, isNotNull);
      expect(TextBlockType.values.contains(TextBlockType.dispositionHint), true);
    });

    testWidgets('dispositionHint 스타일 렌더링 — italic + white54', (tester) async {
      const block = CompletedBlock(
        text: '영혼 속에서 싸움의 불꽃이 희미하게 타오르고 있다.',
        blockType: TextBlockType.dispositionHint,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  CompletedBlockRenderer.build(context, block),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(block.text));
      expect(textWidget.style?.fontStyle, FontStyle.italic);
      expect(textWidget.style?.color, Colors.white54);
    });
  });

  group('CompletedBlockRenderer — classChange', () {
    test('TextBlockType.classChange enum 존재', () {
      expect(TextBlockType.classChange, isNotNull);
      expect(TextBlockType.values.contains(TextBlockType.classChange), true);
    });

    testWidgets('classChange 스타일 렌더링 — bold + amber', (tester) async {
      const block = CompletedBlock(
        text: '영혼의 깊은 곳에서 전사의 힘이 깨어난다.',
        blockType: TextBlockType.classChange,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  CompletedBlockRenderer.build(context, block),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(block.text));
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.amber);
    });
  });
}
