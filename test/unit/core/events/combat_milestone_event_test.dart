import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/combat_milestone_event.dart';

void main() {
  group('CombatMilestoneEvent', () {
    test('stores type hit', () {
      final event = CombatMilestoneEvent(type: CombatMilestoneType.hit);
      expect(event.type, CombatMilestoneType.hit);
    });

    test('stores type block', () {
      final event = CombatMilestoneEvent(type: CombatMilestoneType.block);
      expect(event.type, CombatMilestoneType.block);
    });

    test('stores type victory', () {
      final event = CombatMilestoneEvent(type: CombatMilestoneType.victory);
      expect(event.type, CombatMilestoneType.victory);
    });

    test('stores type defeat', () {
      final event = CombatMilestoneEvent(type: CombatMilestoneType.defeat);
      expect(event.type, CombatMilestoneType.defeat);
    });

    test('enum has 4 values', () {
      expect(CombatMilestoneType.values.length, 4);
    });
  });
}
