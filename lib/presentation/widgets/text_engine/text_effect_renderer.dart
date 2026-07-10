import 'dart:math';

import 'package:soul_dungeon/presentation/widgets/text_engine/text_effect.dart';

/// 텍스트 효과 렌더링 -- 순수 함수 (presentation only).
///
/// Flutter import 불필요. dart:math만 사용.
class TextEffectRenderer {
  TextEffectRenderer._();

  /// 텍스트에 효과 적용 -- 결과 텍스트 반환.
  ///
  /// [text] 원본 텍스트.
  /// [effect] 적용할 효과.
  /// [progress] 애니메이션 진행도 (0.0~1.0) -- 시간 기반 효과용.
  static String applyTextEffect(
    String text,
    TextEffect effect, {
    double progress = 0.0,
  }) {
    return switch (effect) {
      ShakeEffect() => text, // Shake는 위치 변경이므로 텍스트 자체는 안 바뀜
      FadeEffect() => text, // Fade는 투명도이므로 텍스트 자체는 안 바뀜
      JamoSplitEffect(:final splitLevel) =>
        _applyJamoSplit(text, splitLevel, progress),
      GlitchEffect(:final probability) =>
        _applyGlitch(text, probability, progress),
    };
  }

  /// 효과에 대한 오프셋 (ShakeEffect 전용).
  static ({double dx, double dy}) shakeOffset(
    ShakeEffect effect,
    double progress,
  ) {
    final angle = progress * 2 * pi * 3; // 3회전
    return (
      dx: sin(angle) * effect.intensity * 3.0,
      dy: cos(angle * 1.5) * effect.intensity * 2.0,
    );
  }

  /// 효과에 대한 투명도 (FadeEffect 전용).
  static double fadeOpacity(FadeEffect effect, double progress) {
    final range = effect.maxOpacity - effect.minOpacity;
    return effect.minOpacity + range * (0.5 + 0.5 * sin(progress * pi * 2));
  }

  static String _applyJamoSplit(String text, int level, double progress) {
    // level 1: 일부 글자만 자모 분리
    // level 2: 대부분 글자 자모 분리
    // progress가 1에 가까울수록 원본 복원
    final random = Random((progress * 1000).toInt());
    final threshold = level == 1 ? 0.7 : 0.3;
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (random.nextDouble() > threshold && _isHangul(rune)) {
        // 자모 분리 표시 (초성만)
        buffer.write(_extractChoseong(rune));
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static String _applyGlitch(String text, double probability, double progress) {
    final random = Random((progress * 1000).toInt());
    const glitchChars = '\u2593\u2591\u2592\u2588\u2584\u258C\u2590';
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      if (random.nextDouble() < probability) {
        buffer.write(glitchChars[random.nextInt(glitchChars.length)]);
      } else {
        buffer.write(String.fromCharCode(rune));
      }
    }
    return buffer.toString();
  }

  static bool _isHangul(int rune) => rune >= 0xAC00 && rune <= 0xD7A3;

  static String _extractChoseong(int rune) {
    const choseong = '\u3131\u3132\u3134\u3137\u3138\u3139\u3141\u3142\u3143'
        '\u3145\u3146\u3147\u3148\u3149\u314A\u314B\u314C\u314D\u314E';
    final index = (rune - 0xAC00) ~/ (21 * 28);
    return choseong[index];
  }
}
