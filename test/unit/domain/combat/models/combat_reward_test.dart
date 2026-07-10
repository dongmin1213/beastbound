import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/models/combat_reward.dart';

void main() {
  group('CombatReward', () {
    test('creates with required goldAmount and null rewardTag', () {
      const reward = CombatReward(goldAmount: 10);

      expect(reward.goldAmount, 10);
      expect(reward.rewardTag, isNull);
    });

    test('creates with goldAmount and rewardTag', () {
      const reward = CombatReward(goldAmount: 20, rewardTag: 'elite_loot');

      expect(reward.goldAmount, 20);
      expect(reward.rewardTag, 'elite_loot');
    });

    test('equality based on goldAmount and rewardTag', () {
      const a = CombatReward(goldAmount: 10, rewardTag: 'elite_loot');
      const b = CombatReward(goldAmount: 10, rewardTag: 'elite_loot');
      const c = CombatReward(goldAmount: 20, rewardTag: 'elite_loot');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
