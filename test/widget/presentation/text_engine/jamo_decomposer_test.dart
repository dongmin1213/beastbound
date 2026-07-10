import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/jamo_decomposer.dart';

void main() {
  late JamoDecomposer decomposer;

  setUp(() {
    decomposer = JamoDecomposer();
  });

  group('JamoDecomposer.decompose', () {
    test('decomposes syllable with jongseong: 각 → [ㄱ, 가, 각]', () {
      final result = decomposer.decompose('각');
      expect(result, hasLength(3));
      expect(result[0], 'ᄀ'); // 초성 ㄱ (U+1100)
      expect(result[1], '가');
      expect(result[2], '각');
    });

    test('decomposes syllable without jongseong: 가 → [ㄱ, 가]', () {
      final result = decomposer.decompose('가');
      expect(result, hasLength(2));
      expect(result[0], 'ᄀ'); // 초성 ㄱ
      expect(result[1], '가');
    });

    test('decomposes complex syllable: 찬 → [ㅊ, 차, 찬]', () {
      final result = decomposer.decompose('찬');
      expect(result, hasLength(3));
      expect(result[2], '찬');
    });

    test('decomposes: 뒤 → [ㄷ(lead), 뒤]', () {
      final result = decomposer.decompose('뒤');
      expect(result, hasLength(2));
      expect(result[1], '뒤');
    });

    test('passes through non-Korean characters', () {
      expect(decomposer.decompose('A'), ['A']);
      expect(decomposer.decompose('1'), ['1']);
      expect(decomposer.decompose('!'), ['!']);
      expect(decomposer.decompose(' '), [' ']);
    });

    test('returns empty list for empty string', () {
      expect(decomposer.decompose(''), isEmpty);
    });

    test('passes through emoji', () {
      expect(decomposer.decompose('😀'), hasLength(1));
    });
  });

  group('JamoDecomposer.reverse', () {
    test('reverses decomposition: 각 → [각, 가, ㄱ]', () {
      final result = decomposer.reverse('각');
      expect(result, hasLength(3));
      expect(result[0], '각');
      expect(result[2], 'ᄀ');
    });

    test('reverses syllable without jongseong: 가 → [가, ㄱ]', () {
      final result = decomposer.reverse('가');
      expect(result, hasLength(2));
      expect(result[0], '가');
    });

    test('passes through non-Korean for reverse', () {
      expect(decomposer.reverse('A'), ['A']);
    });
  });
}
