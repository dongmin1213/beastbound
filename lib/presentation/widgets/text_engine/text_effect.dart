/// 텍스트 시각 효과 -- sealed class.
///
/// presentation only. domain 값 변경 금지.
sealed class TextEffect {
  const TextEffect();
}

/// 흔들림 효과 -- 공포/긴장 표현.
class ShakeEffect extends TextEffect {
  final double intensity; // 0.0 ~ 1.0
  const ShakeEffect({this.intensity = 0.5});
}

/// 페이드 효과 -- 기억 흐림/서술자 불안정.
class FadeEffect extends TextEffect {
  final double minOpacity; // 0.0 ~ 1.0
  final double maxOpacity;
  const FadeEffect({this.minOpacity = 0.3, this.maxOpacity = 1.0});
}

/// 자모 분리 효과 -- 서술자 왜곡 (4~5층).
///
/// 완성형 한글을 자모로 분리해서 표시 후 재조합.
class JamoSplitEffect extends TextEffect {
  final int splitLevel; // 1=가벼운 왜곡, 2=심한 왜곡
  const JamoSplitEffect({this.splitLevel = 1});
}

/// 글리치 효과 -- 랜덤 문자 치환.
class GlitchEffect extends TextEffect {
  final double probability; // 각 글자가 글리치될 확률 (0.0~1.0)
  const GlitchEffect({this.probability = 0.1});
}
