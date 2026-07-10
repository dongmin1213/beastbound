import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 상태 효과 인스턴스 — 적/플레이어에 적용된 버프/디버프.
class StatusEffect extends Equatable {
  final StatusEffectType type;
  final int stacks;

  /// 남은 턴 수. null = 영구 (힘/민첩/가시 등).
  final int? turnsRemaining;

  const StatusEffect({
    required this.type,
    required this.stacks,
    this.turnsRemaining,
  });

  bool get isExpired =>
      (turnsRemaining != null && turnsRemaining! <= 0) ||
      stacks <= 0;

  bool get isDebuff => type.isDebuff;
  bool get isBuff => type.isBuff;

  /// 턴 경과 후 상태 업데이트. 만료 시 null 반환.
  StatusEffect? tick() {
    switch (type) {
      case StatusEffectType.poison:
        // 독: 매 턴 1 스택 감소 (데미지 적용 후)
        final newPoisonStacks = stacks - 1;
        if (newPoisonStacks <= 0) return null;
        if (turnsRemaining != null) {
          final remaining = turnsRemaining! - 1;
          return remaining <= 0
              ? null
              : copyWith(stacks: newPoisonStacks, turnsRemaining: remaining);
        }
        return copyWith(stacks: newPoisonStacks);
      case StatusEffectType.burn:
        // 화상: 매 턴 1 스택 감소
        final newStacks = stacks - 1;
        return newStacks <= 0 ? null : copyWith(stacks: newStacks);
      case StatusEffectType.weak:
      case StatusEffectType.vulnerable:
        // 약화/취약: 턴 카운트 감소
        if (turnsRemaining != null) {
          final remaining = turnsRemaining! - 1;
          return remaining <= 0 ? null : copyWith(turnsRemaining: remaining);
        }
        return this;
      case StatusEffectType.strength:
      case StatusEffectType.dexterity:
      case StatusEffectType.thorn:
        // 영구 버프: 감소 없음
        return this;
      case StatusEffectType.regenerate:
        // 재생: turnsRemaining이 있으면 감소, 없으면 영구
        if (turnsRemaining != null) {
          final remaining = turnsRemaining! - 1;
          return remaining <= 0 ? null : copyWith(turnsRemaining: remaining);
        }
        return this;
    }
  }

  /// 스택 추가.
  StatusEffect addStacks(int amount) {
    return copyWith(stacks: stacks + amount);
  }

  StatusEffect copyWith({
    StatusEffectType? type,
    int? stacks,
    int? turnsRemaining,
  }) {
    return StatusEffect(
      type: type ?? this.type,
      stacks: stacks ?? this.stacks,
      turnsRemaining: turnsRemaining ?? this.turnsRemaining,
    );
  }

  @override
  List<Object?> get props => [type, stacks, turnsRemaining];
}
