import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 티어 효과 수준 — 기세 단계에 따른 행동 효과 변화.
enum TierEffectLevel {
  enhanced,   // 기세 높음 — 효과 증폭
  neutral,    // 기세 중간 — 기본
  diminished, // 기세 낮음 — 효과 감소
}

/// 티어 적용 결과 — 원래 ActionResult + 티어 효과 정보.
class TierModifiedResult extends Equatable {
  final ActionResult originalResult;
  final TierEffectLevel effectLevel;
  final String? effectText;

  const TierModifiedResult({
    required this.originalResult,
    required this.effectLevel,
    this.effectText,
  });

  @override
  List<Object?> get props => [originalResult, effectLevel, effectText];
}
