import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/combat_reward_event.dart';

void main() {
  group('CombatRewardEvent', () {
    test('creates with required goldAmount', () {
      final event =
          CombatRewardEvent(goldAmount: 20, rewardTag: 'elite_loot');

      expect(event.goldAmount, 20);
      expect(event.rewardTag, 'elite_loot');
    });

    test('rewardTag defaults to null', () {
      final event = CombatRewardEvent(goldAmount: 10);

      expect(event.goldAmount, 10);
      expect(event.rewardTag, isNull);
    });

    test('timestamp is set on creation', () {
      final before = DateTime.now();
      final event = CombatRewardEvent(goldAmount: 10);
      final after = DateTime.now();

      expect(
        event.timestamp.isAfter(before) ||
            event.timestamp.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        event.timestamp.isBefore(after) ||
            event.timestamp.isAtSameMomentAs(after),
        isTrue,
      );
    });
  });
}
