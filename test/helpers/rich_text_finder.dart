import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// TextSpan 트리에서 특정 텍스트 포함 여부를 재귀 검색.
bool _textSpanContains(TextSpan span, String text) {
  if (span.text?.contains(text) ?? false) return true;
  if (span.children != null) {
    for (final child in span.children!) {
      if (child is TextSpan && _textSpanContains(child, text)) return true;
    }
  }
  return false;
}

/// RichText 위젯에서 특정 텍스트를 포함하는 것을 찾는 헬퍼.
///
/// TypewriterWidget은 RichText로 렌더링하고,
/// CompletedBlockRenderer는 RichText(children: [...]) 또는 Text로 렌더링한다.
/// Text는 내부적으로 RichText를 생성하므로 RichText만 탐색하여
/// 동일 텍스트에 대한 중복 매칭(Text+RichText)을 방지한다.
/// TextSpan.children도 재귀 탐색한다.
Finder findRichText(String text) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is RichText) {
        final textSpan = widget.text;
        if (textSpan is TextSpan) {
          return _textSpanContains(textSpan, text);
        }
      }
      return false;
    },
    description: 'RichText containing "$text"',
  );
}
