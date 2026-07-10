import 'dart:math' as math;

/// 소울 화폐 계산기.
///
/// 사망/클리어 보상 및 업그레이드 가격 계산.
/// 모든 결과는 [_maxSoul] 이하로 cap된다.
class SoulCalculator {
  SoulCalculator._();

  static const int _maxSoul = 999999999;

  /// 사망 시 소울 보상: floorReached x soulBaseGain.
  static int calculateDeathReward(int floorReached, int soulBaseGain) {
    return (floorReached * soulBaseGain).clamp(0, _maxSoul);
  }

  /// 클리어 시 소울 보상: soulBaseGain x 10.
  static int calculateClearReward(int soulBaseGain) {
    return (soulBaseGain * 10).clamp(0, _maxSoul);
  }

  /// 업그레이드 가격: (basePrice x (currentLevel + 1)^exponent).toInt().
  ///
  /// currentLevel 0 (미구매) -> basePrice x 1^exp = basePrice.
  /// currentLevel 1 (1회 구매) -> basePrice x 2^exp.
  static int upgradePrice(int basePrice, int currentLevel, double exponent) {
    final raw = basePrice * math.pow(currentLevel + 1, exponent);
    if (raw.isInfinite || raw.isNaN || raw > _maxSoul) return _maxSoul;
    return raw.toInt().clamp(0, _maxSoul);
  }
}
