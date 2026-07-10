import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';

void main() {
  group('MysteryOutcome', () {
    test('TreasureOutcome has positive goldChange and zero hpChange', () {
      const outcome = TreasureOutcome(
        goldReward: 20,
        narrativeText: '보물!',
      );

      expect(outcome.goldChange, 20);
      expect(outcome.hpChange, 0);
      expect(outcome.goldReward, 20);
      expect(outcome.narrativeText, '보물!');
    });

    test('TrapOutcome has zero goldChange and negative hpChange', () {
      const outcome = TrapOutcome(
        hpLoss: 15,
        narrativeText: '함정!',
      );

      expect(outcome.goldChange, 0);
      expect(outcome.hpChange, -15);
      expect(outcome.hpLoss, 15);
      expect(outcome.narrativeText, '함정!');
    });

    test('equality and hashCode work correctly', () {
      const a = TreasureOutcome(goldReward: 20, narrativeText: '보물!');
      const b = TreasureOutcome(goldReward: 20, narrativeText: '보물!');
      const c = TreasureOutcome(goldReward: 30, narrativeText: '보물!');
      const trap = TrapOutcome(hpLoss: 20, narrativeText: '함정!');

      // 동일 필드 → 동등
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);

      // 다른 필드 → 비동등
      expect(a, isNot(equals(c)));

      // 다른 타입 → 비동등
      expect(a, isNot(equals(trap)));

      // CombatOutcome, EventOutcome, MinorOutcome goldChange/hpChange 확인
      const combat = EncounterOutcome(goldReward: 15, narrativeText: '전투!');
      expect(combat.goldChange, 15);
      expect(combat.hpChange, 0);

      const event = EventOutcome(goldReward: 5, narrativeText: '이벤트!');
      expect(event.goldChange, 5);
      expect(event.hpChange, 0);

      const minor = MinorOutcome(goldReward: 3, narrativeText: '잔돈!');
      expect(minor.goldChange, 3);
      expect(minor.hpChange, 0);
    });
  });
}
