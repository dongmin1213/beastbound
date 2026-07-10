import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/tier_effect.dart';

/// 기세 단계 × 행동 결과 → 티어 적용 결과를 계산하는 순수 함수 클래스.
///
/// domain/shared에 배치: 기세(momentum)와 전투(combat) 교차점의 크로스도메인 계산.
class TierEffectCalculator {
  final MomentumConfig config;

  const TierEffectCalculator({required this.config});

  /// (MomentumTier, ActionResult) → TierModifiedResult
  TierModifiedResult calculate(MomentumTier tier, ActionResult result) {
    return switch (tier) {
      MomentumTier.high => _highTierEffect(result),
      MomentumTier.medium => TierModifiedResult(
        originalResult: result,
        effectLevel: TierEffectLevel.neutral,
      ),
      MomentumTier.low => _lowTierEffect(result),
    };
  }

  TierModifiedResult _highTierEffect(ActionResult result) {
    return switch (result) {
      ActionResult.effective => TierModifiedResult(
        originalResult: result,
        effectLevel: TierEffectLevel.enhanced,
        effectText: config.tierEffects.highEffectiveText,
      ),
      ActionResult.neutral => TierModifiedResult(
        originalResult: result,
        effectLevel: TierEffectLevel.enhanced,
        effectText: config.tierEffects.highNeutralText,
      ),
      ActionResult.ineffective => TierModifiedResult(
        originalResult: result,
        effectLevel: TierEffectLevel.neutral,
      ),
    };
  }

  TierModifiedResult _lowTierEffect(ActionResult result) {
    return switch (result) {
      ActionResult.effective => TierModifiedResult(
        originalResult: result,
        effectLevel: TierEffectLevel.neutral,
      ),
      ActionResult.neutral => TierModifiedResult(
        originalResult: result,
        effectLevel: TierEffectLevel.diminished,
        effectText: config.tierEffects.lowCounterText,
      ),
      ActionResult.ineffective => TierModifiedResult(
        originalResult: result,
        effectLevel: TierEffectLevel.diminished,
        effectText: config.tierEffects.lowIneffectiveText,
      ),
    };
  }
}
