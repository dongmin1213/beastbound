import 'package:soul_dungeon/domain/narrative/bloc/narrator_state.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/text_effect.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

/// 서술자 신뢰도 기반 표시값 계산 -- presentation only.
///
/// domain 실제 값 절대 변경 금지. 이 함수는 UI 표시 전용.
class NarratorDisplay {
  NarratorDisplay._();

  /// 서술자 왜곡 HP. NarratorReliable이면 실제값, NarratorDistorted면 오프셋 적용.
  static int displayHp(int realHp, NarratorState? narratorState) {
    if (narratorState == null || narratorState is NarratorReliable) {
      return realHp;
    }
    final distorted = narratorState as NarratorDistorted;
    return (realHp + distorted.hpLieOffset).clamp(1, 999);
  }

  /// 기세 값 -> 텍스트 속도 매핑.
  ///
  /// 기세 높을수록 빠르게, 낮으면 느리게.
  static TextSpeed textSpeedForMomentum(int momentum) {
    if (momentum >= 80) return TextSpeed.fast;
    if (momentum >= 30) return TextSpeed.normal;
    return TextSpeed.slow;
  }

  /// 서술자 왜곡 레벨 -> TextEffect 매핑 (presentation only).
  ///
  /// 2층: 미세 글리치 (확률 5%)
  /// 3층: 가벼운 자모 분리 (level 1)
  /// 4~5층: 심한 자모 분리 (level 2)
  static TextEffect? textEffectForDistortion(int cardDistortionLevel,
      {double microGlitchProbability = 0.0}) {
    if (cardDistortionLevel == 0 && microGlitchProbability > 0) {
      return GlitchEffect(probability: microGlitchProbability);
    }
    return switch (cardDistortionLevel) {
      0 => null,
      1 => const JamoSplitEffect(splitLevel: 1),
      _ => const JamoSplitEffect(splitLevel: 2),
    };
  }
}
