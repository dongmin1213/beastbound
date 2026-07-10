import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/models/combat_damage.dart';

void main() {
  group('DamageResult', () {
    test('기본 생성 — 순수 데미지', () {
      const result = DamageResult(
        rawDamage: 6,
        finalDamage: 6,
        hpLost: 6,
      );
      expect(result.rawDamage, 6);
      expect(result.strengthBonus, 0);
      expect(result.isWeakened, false);
      expect(result.isVulnerable, false);
      expect(result.finalDamage, 6);
      expect(result.blockAbsorbed, 0);
      expect(result.hpLost, 6);
    });

    test('힘 보너스 적용', () {
      const result = DamageResult(
        rawDamage: 6,
        strengthBonus: 3,
        finalDamage: 9,
        hpLost: 9,
      );
      expect(result.strengthBonus, 3);
      expect(result.finalDamage, 9);
    });

    test('약화 적용 — 데미지 감소', () {
      const result = DamageResult(
        rawDamage: 8,
        isWeakened: true,
        finalDamage: 6, // 8 * 0.75 = 6
        hpLost: 6,
      );
      expect(result.isWeakened, true);
      expect(result.finalDamage, 6);
    });

    test('취약 적용 — 피격 데미지 증가', () {
      const result = DamageResult(
        rawDamage: 10,
        isVulnerable: true,
        finalDamage: 15, // 10 * 1.5 = 15
        hpLost: 15,
      );
      expect(result.isVulnerable, true);
      expect(result.finalDamage, 15);
    });

    test('블록 흡수 — HP 감소량 줄어듦', () {
      const result = DamageResult(
        rawDamage: 10,
        finalDamage: 10,
        blockAbsorbed: 5,
        hpLost: 5,
      );
      expect(result.blockAbsorbed, 5);
      expect(result.hpLost, 5);
    });

    test('블록이 데미지 초과 — HP 감소 0', () {
      const result = DamageResult(
        rawDamage: 6,
        finalDamage: 6,
        blockAbsorbed: 6,
        hpLost: 0,
      );
      expect(result.hpLost, 0);
    });

    test('Equatable 동등성', () {
      const r1 = DamageResult(
        rawDamage: 6,
        finalDamage: 6,
        hpLost: 6,
      );
      const r2 = DamageResult(
        rawDamage: 6,
        finalDamage: 6,
        hpLost: 6,
      );
      expect(r1, equals(r2));
    });
  });
}
