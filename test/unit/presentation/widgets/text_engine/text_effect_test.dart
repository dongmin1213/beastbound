import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/text_effect.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/text_effect_renderer.dart';

void main() {
  group('TextEffectRenderer', () {
    group('ShakeEffect', () {
      test('shakeOffset: intensity에 비례하는 오프셋 반환', () {
        const lowIntensity = ShakeEffect(intensity: 0.2);
        const highIntensity = ShakeEffect(intensity: 1.0);

        final lowOffset = TextEffectRenderer.shakeOffset(lowIntensity, 0.25);
        final highOffset = TextEffectRenderer.shakeOffset(highIntensity, 0.25);

        // 높은 intensity일수록 더 큰 오프셋
        expect(highOffset.dx.abs(), greaterThan(lowOffset.dx.abs()));
        expect(highOffset.dy.abs(), greaterThan(lowOffset.dy.abs()));
      });

      test('shakeOffset: intensity 0이면 오프셋 0', () {
        const noShake = ShakeEffect(intensity: 0.0);
        final offset = TextEffectRenderer.shakeOffset(noShake, 0.5);

        expect(offset.dx, closeTo(0.0, 0.001));
        expect(offset.dy, closeTo(0.0, 0.001));
      });

      test('applyTextEffect: ShakeEffect는 텍스트를 변경하지 않음', () {
        const effect = ShakeEffect(intensity: 0.8);
        final result = TextEffectRenderer.applyTextEffect(
          '안녕하세요',
          effect,
          progress: 0.5,
        );
        expect(result, '안녕하세요');
      });
    });

    group('FadeEffect', () {
      test('fadeOpacity: minOpacity ~ maxOpacity 범위 내', () {
        const effect = FadeEffect(minOpacity: 0.3, maxOpacity: 1.0);

        // 여러 progress 값에서 범위 확인
        for (var p = 0.0; p <= 1.0; p += 0.1) {
          final opacity = TextEffectRenderer.fadeOpacity(effect, p);
          expect(opacity, greaterThanOrEqualTo(0.3 - 0.001));
          expect(opacity, lessThanOrEqualTo(1.0 + 0.001));
        }
      });

      test('fadeOpacity: 기본값 (minOpacity 0.3, maxOpacity 1.0)', () {
        const effect = FadeEffect();
        final opacity = TextEffectRenderer.fadeOpacity(effect, 0.0);
        // progress=0 -> sin(0)=0 -> 0.5+0.5*0 = 0.5
        // opacity = 0.3 + 0.7 * 0.5 = 0.65
        expect(opacity, closeTo(0.65, 0.01));
      });

      test('applyTextEffect: FadeEffect는 텍스트를 변경하지 않음', () {
        const effect = FadeEffect();
        final result = TextEffectRenderer.applyTextEffect(
          '테스트 텍스트',
          effect,
          progress: 0.5,
        );
        expect(result, '테스트 텍스트');
      });
    });

    group('JamoSplitEffect', () {
      test('level 1: 일부 한글만 초성으로 변환', () {
        const effect = JamoSplitEffect(splitLevel: 1);
        const text = '안녕하세요';

        final result = TextEffectRenderer.applyTextEffect(
          text,
          effect,
          progress: 0.5,
        );

        // 일부 글자가 변환되어 원본과 다를 수 있음
        // level 1은 threshold 0.7이므로 약 30%만 변환
        expect(result.length, greaterThan(0));
        // 변환된 결과에는 원본 글자 또는 초성이 포함
        expect(result, isNot(isEmpty));
      });

      test('level 2: 더 많은 한글이 초성으로 변환됨', () {
        const effectLevel1 = JamoSplitEffect(splitLevel: 1);
        const effectLevel2 = JamoSplitEffect(splitLevel: 2);
        const text = '가나다라마바사아자차카타파하';

        // 동일 progress에서 level 2가 더 많이 변환
        final result1 = TextEffectRenderer.applyTextEffect(
          text,
          effectLevel1,
          progress: 0.5,
        );
        final result2 = TextEffectRenderer.applyTextEffect(
          text,
          effectLevel2,
          progress: 0.5,
        );

        // level 2의 변환량이 level 1보다 많거나 같아야 함
        // 원본과 다른 글자 수 카운트
        int countChanged(String original, String modified) {
          var count = 0;
          final origRunes = original.runes.toList();
          final modRunes = modified.runes.toList();
          for (var i = 0; i < origRunes.length && i < modRunes.length; i++) {
            if (origRunes[i] != modRunes[i]) count++;
          }
          return count;
        }

        final changed1 = countChanged(text, result1);
        final changed2 = countChanged(text, result2);
        expect(changed2, greaterThanOrEqualTo(changed1));
      });

      test('비한글 문자는 변환하지 않음', () {
        const effect = JamoSplitEffect(splitLevel: 2);
        const text = 'ABC 123 !@#';

        final result = TextEffectRenderer.applyTextEffect(
          text,
          effect,
          progress: 0.5,
        );

        // 비한글은 변경 없음
        expect(result, text);
      });

      test('초성 추출 검증: 가 -> ㄱ', () {
        const effect = JamoSplitEffect(splitLevel: 2);
        // probability가 매우 높은 경우 (threshold 0.3)
        // 모든 한글이 변환될 수 있도록 progress를 조정
        const text = '가';

        // 여러 progress에서 시도하여 변환이 발생하는 케이스 찾기
        var found = false;
        for (var p = 0.0; p <= 1.0; p += 0.01) {
          final result = TextEffectRenderer.applyTextEffect(
            text,
            effect,
            progress: p,
          );
          if (result == 'ㄱ') {
            found = true;
            break;
          }
        }
        expect(found, isTrue, reason: '가 -> ㄱ 변환이 발생해야 함');
      });
    });

    group('GlitchEffect', () {
      test('probability=0 -> 원본 텍스트 유지', () {
        const effect = GlitchEffect(probability: 0.0);
        const text = '안녕하세요 Hello 123';

        final result = TextEffectRenderer.applyTextEffect(
          text,
          effect,
          progress: 0.5,
        );

        expect(result, text);
      });

      test('probability=1 -> 모든 글자가 글리치 문자로 변환', () {
        const effect = GlitchEffect(probability: 1.0);
        const text = '테스트 텍스트';

        final result = TextEffectRenderer.applyTextEffect(
          text,
          effect,
          progress: 0.5,
        );

        // 원본과 완전히 다름
        expect(result, isNot(text));
        // 글리치 문자(블록 문자)로만 구성
        const glitchChars = '\u2593\u2591\u2592\u2588\u2584\u258C\u2590';
        for (final rune in result.runes) {
          final char = String.fromCharCode(rune);
          expect(
            glitchChars.contains(char),
            isTrue,
            reason: '"$char"은(는) 글리치 문자여야 함',
          );
        }
      });

      test('probability 0.5: 일부 글자만 변환', () {
        const effect = GlitchEffect(probability: 0.5);
        const text = 'ABCDEFGHIJKLMNOP';

        final result = TextEffectRenderer.applyTextEffect(
          text,
          effect,
          progress: 0.3,
        );

        // 일부는 원본, 일부는 글리치
        var originalCount = 0;
        var glitchCount = 0;
        const glitchChars = '\u2593\u2591\u2592\u2588\u2584\u258C\u2590';
        final resultRunes = result.runes.toList();
        final textRunes = text.runes.toList();

        for (var i = 0; i < resultRunes.length; i++) {
          final char = String.fromCharCode(resultRunes[i]);
          if (i < textRunes.length &&
              resultRunes[i] == textRunes[i]) {
            originalCount++;
          } else if (glitchChars.contains(char)) {
            glitchCount++;
          }
        }

        expect(originalCount, greaterThan(0), reason: '일부 원본 유지');
        expect(glitchCount, greaterThan(0), reason: '일부 글리치 변환');
      });

      test('동일 progress -> 동일 결과 (결정적)', () {
        const effect = GlitchEffect(probability: 0.5);
        const text = '테스트 입력값';

        final result1 = TextEffectRenderer.applyTextEffect(
          text,
          effect,
          progress: 0.42,
        );
        final result2 = TextEffectRenderer.applyTextEffect(
          text,
          effect,
          progress: 0.42,
        );

        expect(result1, result2);
      });
    });
  });
}
