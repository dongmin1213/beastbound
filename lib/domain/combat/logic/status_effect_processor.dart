import 'dart:math';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 상태 효과 처리 — 독/화상/약화/취약/힘/민첩/가시/재생. 순수 함수.
class StatusEffectProcessor {
  StatusEffectProcessor._();

  /// 상태 효과 추가 (같은 타입이면 스택 합산).
  /// [regenCap]: 재생 스택 최대치. null이면 캡 없음 (대사제 등).
  static List<StatusEffect> addEffect(
    List<StatusEffect> effects,
    StatusEffect newEffect, {
    int? regenCap,
  }) {
    final result = List<StatusEffect>.from(effects);
    final existing = result.indexWhere((e) => e.type == newEffect.type);

    if (existing != -1) {
      // 같은 타입 — 스택 합산, turnsRemaining은 새 값 기준
      var merged = result[existing].addStacks(newEffect.stacks);
      // 재생 캡 적용
      if (regenCap != null &&
          newEffect.type == StatusEffectType.regenerate &&
          merged.stacks > regenCap) {
        merged = merged.copyWith(stacks: regenCap);
      }
      result[existing] = newEffect.turnsRemaining != null
          ? merged.copyWith(
              turnsRemaining: max(
                merged.turnsRemaining ?? 0,
                newEffect.turnsRemaining!,
              ),
            )
          : merged;
    } else {
      // 신규 추가 시도 — 재생 캡 초과면 추가 안 함
      if (regenCap != null && newEffect.type == StatusEffectType.regenerate) {
        final currentStacks = stacks(effects, StatusEffectType.regenerate);
        if (currentStacks >= regenCap) return result;
        final capped = newEffect.stacks.clamp(0, regenCap - currentStacks);
        result.add(newEffect.copyWith(stacks: capped));
      } else {
        result.add(newEffect);
      }
    }
    return result;
  }

  /// 턴 시작 틱 — 독/화상 데미지 반환 + 효과 갱신.
  static ({List<StatusEffect> effects, int damage, int heal}) tick(
    List<StatusEffect> effects,
  ) {
    int totalDamage = 0;
    int totalHeal = 0;
    final updated = <StatusEffect>[];

    for (final effect in effects) {
      // 독/화상: 틱 전 데미지 적용
      if (effect.type == StatusEffectType.poison) {
        totalDamage += effect.stacks;
      } else if (effect.type == StatusEffectType.burn) {
        totalDamage += effect.stacks;
      } else if (effect.type == StatusEffectType.regenerate) {
        totalHeal += effect.stacks;
      }

      final ticked = effect.tick();
      if (ticked != null) {
        updated.add(ticked);
      }
    }

    return (effects: updated, damage: totalDamage, heal: totalHeal);
  }

  /// 특정 타입의 총 스택 수.
  static int stacks(List<StatusEffect> effects, StatusEffectType type) {
    return effects
        .where((e) => e.type == type && !e.isExpired)
        .fold(0, (sum, e) => sum + e.stacks);
  }

  /// 특정 타입의 상태 효과가 활성인지.
  static bool hasActive(List<StatusEffect> effects, StatusEffectType type) {
    return effects.any((e) => e.type == type && !e.isExpired);
  }

  /// 모든 디버프 제거 (정화 등).
  static List<StatusEffect> clearDebuffs(List<StatusEffect> effects) {
    return effects.where((e) => e.isBuff).toList();
  }

  /// 만료된 효과 제거.
  static List<StatusEffect> removeExpired(List<StatusEffect> effects) {
    return effects.where((e) => !e.isExpired).toList();
  }
}
