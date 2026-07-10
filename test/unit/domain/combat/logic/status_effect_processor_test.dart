import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/logic/status_effect_processor.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('StatusEffectProcessor.addEffect', () {
    test('빈 리스트에 추가', () {
      const poison = StatusEffect(type: StatusEffectType.poison, stacks: 3);
      final result = StatusEffectProcessor.addEffect([], poison);
      expect(result, hasLength(1));
      expect(result.first.stacks, 3);
    });

    test('같은 타입 — 스택 합산', () {
      const existing = StatusEffect(type: StatusEffectType.poison, stacks: 3);
      const added = StatusEffect(type: StatusEffectType.poison, stacks: 2);
      final result = StatusEffectProcessor.addEffect([existing], added);
      expect(result, hasLength(1));
      expect(result.first.stacks, 5);
    });

    test('다른 타입 — 별도 추가', () {
      const poison = StatusEffect(type: StatusEffectType.poison, stacks: 3);
      const strength = StatusEffect(type: StatusEffectType.strength, stacks: 2);
      final result = StatusEffectProcessor.addEffect([poison], strength);
      expect(result, hasLength(2));
    });

    test('turnsRemaining — 더 긴 쪽 유지', () {
      const existing = StatusEffect(
        type: StatusEffectType.weak,
        stacks: 1,
        turnsRemaining: 2,
      );
      const added = StatusEffect(
        type: StatusEffectType.weak,
        stacks: 1,
        turnsRemaining: 3,
      );
      final result = StatusEffectProcessor.addEffect([existing], added);
      expect(result.first.stacks, 2);
      expect(result.first.turnsRemaining, 3);
    });
  });

  group('StatusEffectProcessor.tick', () {
    test('독 — 데미지 반환', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.poison, stacks: 5),
      ];
      final result = StatusEffectProcessor.tick(effects);
      expect(result.damage, 5);
      expect(result.heal, 0);
    });

    test('화상 — 데미지 + 스택 감소', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.burn, stacks: 3),
      ];
      final result = StatusEffectProcessor.tick(effects);
      expect(result.damage, 3);
      expect(result.effects.first.stacks, 2);
    });

    test('재생 — 힐 반환', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.regenerate, stacks: 4),
      ];
      final result = StatusEffectProcessor.tick(effects);
      expect(result.heal, 4);
      expect(result.damage, 0);
    });

    test('약화 만료 — 리스트에서 제거', () {
      final effects = [
        const StatusEffect(
          type: StatusEffectType.weak,
          stacks: 1,
          turnsRemaining: 1,
        ),
      ];
      final result = StatusEffectProcessor.tick(effects);
      expect(result.effects, isEmpty);
    });

    test('힘 — 영구, 변화 없음', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.strength, stacks: 3),
      ];
      final result = StatusEffectProcessor.tick(effects);
      expect(result.effects, hasLength(1));
      expect(result.effects.first.stacks, 3);
    });

    test('복합 — 독+화상+재생', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.poison, stacks: 3),
        const StatusEffect(type: StatusEffectType.burn, stacks: 2),
        const StatusEffect(type: StatusEffectType.regenerate, stacks: 5),
      ];
      final result = StatusEffectProcessor.tick(effects);
      expect(result.damage, 5); // 독 3 + 화상 2
      expect(result.heal, 5); // 재생 5
    });
  });

  group('StatusEffectProcessor.stacks', () {
    test('해당 타입 스택 합산', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.strength, stacks: 2),
        const StatusEffect(type: StatusEffectType.strength, stacks: 3),
      ];
      expect(StatusEffectProcessor.stacks(effects, StatusEffectType.strength), 5);
    });

    test('없으면 0', () {
      expect(StatusEffectProcessor.stacks([], StatusEffectType.poison), 0);
    });
  });

  group('StatusEffectProcessor.hasActive', () {
    test('활성 효과 있음', () {
      final effects = [
        const StatusEffect(
          type: StatusEffectType.weak,
          stacks: 1,
          turnsRemaining: 2,
        ),
      ];
      expect(StatusEffectProcessor.hasActive(effects, StatusEffectType.weak), true);
    });

    test('만료 효과만 — false', () {
      final effects = [
        const StatusEffect(
          type: StatusEffectType.weak,
          stacks: 1,
          turnsRemaining: 0,
        ),
      ];
      expect(StatusEffectProcessor.hasActive(effects, StatusEffectType.weak), false);
    });
  });

  group('StatusEffectProcessor.clearDebuffs', () {
    test('디버프 제거, 버프 유지', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.poison, stacks: 3),
        const StatusEffect(type: StatusEffectType.strength, stacks: 2),
        const StatusEffect(
          type: StatusEffectType.weak,
          stacks: 1,
          turnsRemaining: 2,
        ),
      ];
      final result = StatusEffectProcessor.clearDebuffs(effects);
      expect(result, hasLength(1));
      expect(result.first.type, StatusEffectType.strength);
    });
  });

  group('StatusEffectProcessor.removeExpired', () {
    test('만료 효과 제거', () {
      final effects = [
        const StatusEffect(type: StatusEffectType.burn, stacks: 0),
        const StatusEffect(type: StatusEffectType.strength, stacks: 2),
      ];
      final result = StatusEffectProcessor.removeExpired(effects);
      expect(result, hasLength(1));
      expect(result.first.type, StatusEffectType.strength);
    });
  });
}
