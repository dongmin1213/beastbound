import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/logic/damage_calculator.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('DamageCalculator.calculatePlayerDamage', () {
    test('순수 데미지 — 힘 0, 약화 없음, 취약 없음, 블록 0', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 6,
        strength: 0,
        isWeakened: false,
        targetIsVulnerable: false,
        targetBlock: 0,
      );
      expect(result.rawDamage, 6);
      expect(result.finalDamage, 6);
      expect(result.hpLost, 6);
      expect(result.blockAbsorbed, 0);
    });

    test('힘 보너스 — baseDamage + strength', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 6,
        strength: 3,
        isWeakened: false,
        targetIsVulnerable: false,
        targetBlock: 0,
      );
      expect(result.finalDamage, 9);
      expect(result.strengthBonus, 3);
    });

    test('약화 — 데미지 × 0.75', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 8,
        strength: 0,
        isWeakened: true,
        targetIsVulnerable: false,
        targetBlock: 0,
      );
      expect(result.finalDamage, 6); // 8 * 0.75 = 6
      expect(result.isWeakened, true);
    });

    test('취약 — 데미지 × 1.5', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 10,
        strength: 0,
        isWeakened: false,
        targetIsVulnerable: true,
        targetBlock: 0,
      );
      expect(result.finalDamage, 15); // 10 * 1.5 = 15
      expect(result.isVulnerable, true);
    });

    test('약화 + 취약 — × 0.75 → × 1.5', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 8,
        strength: 0,
        isWeakened: true,
        targetIsVulnerable: true,
        targetBlock: 0,
      );
      // 8 * 0.75 = 6 → 6 * 1.5 = 9
      expect(result.finalDamage, 9);
    });

    test('블록 흡수 — 부분 흡수', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 10,
        strength: 0,
        isWeakened: false,
        targetIsVulnerable: false,
        targetBlock: 4,
      );
      expect(result.blockAbsorbed, 4);
      expect(result.hpLost, 6);
    });

    test('블록 완전 흡수 — hpLost 0', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 6,
        strength: 0,
        isWeakened: false,
        targetIsVulnerable: false,
        targetBlock: 10,
      );
      expect(result.blockAbsorbed, 6);
      expect(result.hpLost, 0);
    });

    test('힘 + 약화 + 취약 + 블록 조합', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 6,
        strength: 4,
        isWeakened: true,
        targetIsVulnerable: true,
        targetBlock: 3,
      );
      // (6 + 4) = 10, 약화: 10 * 0.75 = 7, 취약: 7 * 1.5 = 10
      // 블록 3 흡수 → hpLost = 7
      expect(result.finalDamage, 10);
      expect(result.blockAbsorbed, 3);
      expect(result.hpLost, 7);
    });

    test('음수 힘 — baseDamage + 음수 = 최소 0', () {
      final result = DamageCalculator.calculatePlayerDamage(
        baseDamage: 2,
        strength: -5,
        isWeakened: false,
        targetIsVulnerable: false,
        targetBlock: 0,
      );
      expect(result.finalDamage, 0);
      expect(result.hpLost, 0);
    });
  });

  group('DamageCalculator.calculateEnemyDamage', () {
    test('적 → 플레이어 데미지', () {
      final result = DamageCalculator.calculateEnemyDamage(
        baseDamage: 8,
        enemyStrength: 0,
        enemyIsWeakened: false,
        playerIsVulnerable: false,
        playerBlock: 5,
      );
      expect(result.finalDamage, 8);
      expect(result.blockAbsorbed, 5);
      expect(result.hpLost, 3);
    });

    test('적 약화 — 공격 데미지 감소', () {
      final result = DamageCalculator.calculateEnemyDamage(
        baseDamage: 12,
        enemyStrength: 0,
        enemyIsWeakened: true,
        playerIsVulnerable: false,
        playerBlock: 0,
      );
      expect(result.finalDamage, 9); // 12 * 0.75 = 9
    });

    test('플레이어 취약 — 받는 데미지 증가', () {
      final result = DamageCalculator.calculateEnemyDamage(
        baseDamage: 10,
        enemyStrength: 0,
        enemyIsWeakened: false,
        playerIsVulnerable: true,
        playerBlock: 0,
      );
      expect(result.finalDamage, 15); // 10 * 1.5 = 15
    });
  });

  group('DamageCalculator.totalStacks', () {
    test('해당 타입 스택 합산', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.poison, stacks: 3),
        const StatusEffect(type: StatusEffectType.poison, stacks: 2),
        const StatusEffect(type: StatusEffectType.strength, stacks: 4),
      ];
      expect(DamageCalculator.totalStacks(effects, StatusEffectType.poison), 5);
      expect(DamageCalculator.totalStacks(effects, StatusEffectType.strength), 4);
    });

    test('해당 타입 없으면 0', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.strength, stacks: 2),
      ];
      expect(DamageCalculator.totalStacks(effects, StatusEffectType.poison), 0);
    });
  });

  group('DamageCalculator.hasEffect', () {
    test('활성 효과 있음', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.weak, stacks: 1, turnsRemaining: 2),
      ];
      expect(DamageCalculator.hasEffect(effects, StatusEffectType.weak), true);
    });

    test('만료된 효과 — false', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.weak, stacks: 1, turnsRemaining: 0),
      ];
      expect(DamageCalculator.hasEffect(effects, StatusEffectType.weak), false);
    });

    test('해당 타입 없음 — false', () {
      expect(DamageCalculator.hasEffect([], StatusEffectType.poison), false);
    });
  });
}
