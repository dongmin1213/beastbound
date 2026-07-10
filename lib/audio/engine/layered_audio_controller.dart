import 'package:soul_dungeon/audio/engine/sound_layer_manager.dart';

/// 오디오 레이어 레벨 (L0~L3).
///
/// L0: 침묵 (모든 사운드 정지).
/// L1: 앰비언스만 (음악/SFX 정지).
/// L2: 앰비언스 + SFX (음악 정지).
/// L3: 앰비언스 + SFX + 음악 (모든 레이어 활성).
enum AudioLayer { l0, l1, l2, l3 }

/// 기세 기반 오디오 레이어 결정 + 적용.
///
/// [MomentumConfig] 임계값(thresholdLow/Medium/High)에 따라
/// momentum → [AudioLayer] 매핑:
///   momentum < thresholdLow(10) → L0
///   momentum < thresholdMedium(30) → L1
///   momentum < thresholdHigh(80) → L2
///   momentum >= thresholdHigh(80) → L3
class LayeredAudioController {
  /// 기세 값 → 오디오 레이어 결정.
  static AudioLayer layerForMomentum(
    int momentum, {
    int thresholdLow = 10,
    int thresholdMedium = 30,
    int thresholdHigh = 80,
  }) {
    if (momentum < thresholdLow) return AudioLayer.l0;
    if (momentum < thresholdMedium) return AudioLayer.l1;
    if (momentum < thresholdHigh) return AudioLayer.l2;
    return AudioLayer.l3;
  }

  /// 레이어에 따라 [SoundLayerManager] 제어.
  ///
  /// 앰비언스 레이어 제거 후 BGM은 항상 유지.
  /// 기세 레이어는 SFX 허용 여부만 결정 (isSfxAllowed 참조).
  static void applyLayer(AudioLayer layer, SoundLayerManager manager) {
    // BGM은 기세에 관계없이 유지 — CombatStarted/Ended/FloorCompleted가 제어.
    // SFX 허용 여부는 isSfxAllowed()로 별도 판단.
  }

  /// 현재 레이어에서 SFX 재생이 허용되는지 확인.
  ///
  /// L0/L1: SFX 비활성, L2/L3: SFX 활성.
  static bool isSfxAllowed(AudioLayer layer) =>
      layer == AudioLayer.l2 || layer == AudioLayer.l3;
}
