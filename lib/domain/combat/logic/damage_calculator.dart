import 'dart:math';
import 'package:soul_dungeon/domain/combat/models/combat_damage.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 데미지 계산 — 힘/약화/취약/블록 적용. 순수 함수.
class DamageCalculator {
  DamageCalculator._();

  static const double weakMultiplier = 0.75;
  static const double vulnerableMultiplier = 1.5;

  /// 플레이어 → 적 데미지 계산.
  static DamageResult calculatePlayerDamage({
    required int baseDamage,
    required int strength,
    required bool isWeakened,
    required bool targetIsVulnerable,
    required int targetBlock,
  }) {
    // 1. 기본 데미지 + 힘 보너스
    int rawWithStrength = baseDamage + strength;
    if (rawWithStrength < 0) rawWithStrength = 0;

    // 2. 약화 적용 (공격자)
    int afterWeak = isWeakened
        ? (rawWithStrength * weakMultiplier).toInt()
        : rawWithStrength;

    // 3. 취약 적용 (피격 대상)
    int finalDamage = targetIsVulnerable
        ? (afterWeak * vulnerableMultiplier).toInt()
        : afterWeak;

    // 4. 블록 흡수
    final blockAbsorbed = min(targetBlock, finalDamage);
    final hpLost = max(0, finalDamage - targetBlock);

    return DamageResult(
      rawDamage: baseDamage,
      strengthBonus: strength,
      isWeakened: isWeakened,
      isVulnerable: targetIsVulnerable,
      finalDamage: finalDamage,
      blockAbsorbed: blockAbsorbed,
      hpLost: hpLost,
    );
  }

  /// 적 → 플레이어 데미지 계산.
  static DamageResult calculateEnemyDamage({
    required int baseDamage,
    required int enemyStrength,
    required bool enemyIsWeakened,
    required bool playerIsVulnerable,
    required int playerBlock,
  }) {
    return calculatePlayerDamage(
      baseDamage: baseDamage,
      strength: enemyStrength,
      isWeakened: enemyIsWeakened,
      targetIsVulnerable: playerIsVulnerable,
      targetBlock: playerBlock,
    );
  }

  /// 상태 효과 리스트에서 특정 타입의 총 스택 수.
  static int totalStacks(
    List<StatusEffect> effects,
    StatusEffectType type,
  ) {
    return effects
        .where((e) => e.type == type)
        .fold(0, (sum, e) => sum + e.stacks);
  }

  /// 상태 효과가 활성인지 확인.
  static bool hasEffect(
    List<StatusEffect> effects,
    StatusEffectType type,
  ) {
    return effects.any((e) => e.type == type && !e.isExpired);
  }
}
