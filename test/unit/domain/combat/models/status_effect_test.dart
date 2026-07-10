import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('StatusEffect', () {
    test('독 — isDebuff true', () {
      const poison = StatusEffect(
        type: StatusEffectType.poison,
        stacks: 3,
      );
      expect(poison.isDebuff, true);
      expect(poison.isBuff, false);
    });

    test('힘 — isBuff true', () {
      const strength = StatusEffect(
        type: StatusEffectType.strength,
        stacks: 2,
      );
      expect(strength.isBuff, true);
      expect(strength.isDebuff, false);
    });

    test('isExpired — stacks 0이면 만료', () {
      const expired = StatusEffect(
        type: StatusEffectType.burn,
        stacks: 0,
      );
      expect(expired.isExpired, true);
    });

    test('isExpired — turnsRemaining 0이면 만료', () {
      const expired = StatusEffect(
        type: StatusEffectType.weak,
        stacks: 1,
        turnsRemaining: 0,
      );
      expect(expired.isExpired, true);
    });

    test('isExpired — stacks > 0, turnsRemaining > 0이면 유효', () {
      const active = StatusEffect(
        type: StatusEffectType.vulnerable,
        stacks: 1,
        turnsRemaining: 2,
      );
      expect(active.isExpired, false);
    });

    test('addStacks — 스택 추가', () {
      const poison = StatusEffect(
        type: StatusEffectType.poison,
        stacks: 3,
      );
      final added = poison.addStacks(2);
      expect(added.stacks, 5);
      expect(added.type, StatusEffectType.poison);
    });

    group('tick', () {
      test('독 — turnsRemaining 감소 + stacks 1 감소', () {
        const poison = StatusEffect(
          type: StatusEffectType.poison,
          stacks: 3,
          turnsRemaining: 2,
        );
        final ticked = poison.tick()!;
        expect(ticked.stacks, 2);
        expect(ticked.turnsRemaining, 1);
      });

      test('독 — turnsRemaining 없으면 stacks만 1 감소', () {
        const poison = StatusEffect(
          type: StatusEffectType.poison,
          stacks: 3,
        );
        final ticked = poison.tick()!;
        expect(ticked.stacks, 2);
      });

      test('독 — stacks 1이면 tick 후 만료 (turnsRemaining 무관)', () {
        const poison = StatusEffect(
          type: StatusEffectType.poison,
          stacks: 1,
        );
        expect(poison.tick(), isNull);
      });

      test('독 — turnsRemaining 1이면 tick 후 만료', () {
        const poison = StatusEffect(
          type: StatusEffectType.poison,
          stacks: 3,
          turnsRemaining: 1,
        );
        expect(poison.tick(), isNull);
      });

      test('화상 — stacks 1씩 감소', () {
        const burn = StatusEffect(
          type: StatusEffectType.burn,
          stacks: 3,
        );
        final ticked = burn.tick()!;
        expect(ticked.stacks, 2);
      });

      test('화상 — stacks 1이면 tick 후 만료', () {
        const burn = StatusEffect(
          type: StatusEffectType.burn,
          stacks: 1,
        );
        expect(burn.tick(), isNull);
      });

      test('약화 — turnsRemaining 감소', () {
        const weak = StatusEffect(
          type: StatusEffectType.weak,
          stacks: 1,
          turnsRemaining: 2,
        );
        final ticked = weak.tick()!;
        expect(ticked.turnsRemaining, 1);
      });

      test('약화 — turnsRemaining 1이면 tick 후 만료', () {
        const weak = StatusEffect(
          type: StatusEffectType.weak,
          stacks: 1,
          turnsRemaining: 1,
        );
        expect(weak.tick(), isNull);
      });

      test('취약 — turnsRemaining 감소', () {
        const vuln = StatusEffect(
          type: StatusEffectType.vulnerable,
          stacks: 1,
          turnsRemaining: 3,
        );
        final ticked = vuln.tick()!;
        expect(ticked.turnsRemaining, 2);
      });

      test('힘 — 영구, 변화 없음', () {
        const str = StatusEffect(
          type: StatusEffectType.strength,
          stacks: 4,
        );
        final ticked = str.tick()!;
        expect(ticked.stacks, 4);
      });

      test('민첩 — 영구, 변화 없음', () {
        const dex = StatusEffect(
          type: StatusEffectType.dexterity,
          stacks: 2,
        );
        final ticked = dex.tick()!;
        expect(ticked.stacks, 2);
      });

      test('가시 — 영구, 변화 없음', () {
        const thorn = StatusEffect(
          type: StatusEffectType.thorn,
          stacks: 3,
        );
        final ticked = thorn.tick()!;
        expect(ticked.stacks, 3);
      });

      test('재생 — turnsRemaining이 있으면 감소', () {
        const regen = StatusEffect(
          type: StatusEffectType.regenerate,
          stacks: 3,
          turnsRemaining: 2,
        );
        final ticked = regen.tick()!;
        expect(ticked.turnsRemaining, 1);
      });

      test('재생 — turnsRemaining 없으면 영구', () {
        const regen = StatusEffect(
          type: StatusEffectType.regenerate,
          stacks: 5,
        );
        final ticked = regen.tick()!;
        expect(ticked.stacks, 5);
      });
    });

    test('copyWith', () {
      const original = StatusEffect(
        type: StatusEffectType.poison,
        stacks: 3,
        turnsRemaining: 5,
      );
      final copied = original.copyWith(stacks: 6);
      expect(copied.stacks, 6);
      expect(copied.type, StatusEffectType.poison);
      expect(copied.turnsRemaining, 5);
    });

    test('Equatable 동등성', () {
      const e1 = StatusEffect(
        type: StatusEffectType.weak,
        stacks: 1,
        turnsRemaining: 2,
      );
      const e2 = StatusEffect(
        type: StatusEffectType.weak,
        stacks: 1,
        turnsRemaining: 2,
      );
      expect(e1, equals(e2));
    });
  });
}
