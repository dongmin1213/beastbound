
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/ending/ending_text_content.dart';
import 'package:soul_dungeon/domain/ending/ending_types.dart';

void main() {
  group('EndingTextContent', () {
    test('모든 엔딩 타입에 텍스트 존재', () {
      for (final type in EndingType.values) {
        expect(
          EndingTextContent.textFor(type),
          isNotEmpty,
          reason: '${type.name} 엔딩 텍스트가 비어있음',
        );
      }
    });

    test('textFor — 5개 엔딩 각각 다른 텍스트', () {
      final texts = EndingType.values
          .map(EndingTextContent.textFor)
          .toSet();
      expect(texts.length, EndingType.values.length);
    });

    test('displayTextFor — 엔딩명 포함', () {
      for (final type in EndingType.values) {
        final display = EndingTextContent.displayTextFor(type);
        expect(display, contains(type.displayName));
        expect(display, contains(type.toneDescription));
      }
    });

    group('load()', () {
      test('load — valid JSON replaces defaults', () async {
        await EndingTextContent.load(bundle: _TestAssetBundle());

        expect(EndingTextContent.textFor(EndingType.slay), 'Test slay text');
        expect(
            EndingTextContent.textFor(EndingType.liberate), 'Test liberate text');
        expect(
            EndingTextContent.textFor(EndingType.coexist), 'Test coexist text');
        expect(EndingTextContent.textFor(EndingType.hidden), 'Test hidden text');
        expect(EndingTextContent.textFor(EndingType.transcend),
            'Test transcend text');

        // Reset to defaults for other tests.
        await EndingTextContent.load(bundle: _InvalidAssetBundle());
      });

      test('load — invalid JSON keeps defaults', () async {
        await EndingTextContent.load(bundle: _InvalidAssetBundle());

        // Defaults should still be intact — verify a known default text snippet.
        expect(EndingTextContent.textFor(EndingType.slay), contains('투쟁의 길'));
        expect(
            EndingTextContent.textFor(EndingType.liberate), contains('자비의 길'));
      });
    });
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"endings": ['
        '{"type": "slay", "text": "Test slay text"}, '
        '{"type": "liberate", "text": "Test liberate text"}, '
        '{"type": "coexist", "text": "Test coexist text"}, '
        '{"type": "hidden", "text": "Test hidden text"}, '
        '{"type": "transcend", "text": "Test transcend text"}'
        ']}';
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}

class _InvalidAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return 'not valid json';
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}
