import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_reward_calculator.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CombatRewardCalculator', () {
    const economyConfig = EconomyConfig();

    test('elite room returns double gold and elite_loot tag', () {
      final reward = CombatRewardCalculator.calculate(
        roomType: RoomType.elite,
        economyConfig: economyConfig,
      );

      expect(reward.goldAmount, 24); // 8 * 3.0
      expect(reward.rewardTag, 'elite_loot');
    });

    test('combat room returns base gold and no tag', () {
      final reward = CombatRewardCalculator.calculate(
        roomType: RoomType.combat,
        economyConfig: economyConfig,
      );

      expect(reward.goldAmount, 8);
      expect(reward.rewardTag, isNull);
    });

    test('boss room returns baseGold × bossGoldMultiplier + boss_loot tag', () {
      final reward = CombatRewardCalculator.calculate(
        roomType: RoomType.boss,
        economyConfig: economyConfig,
      );

      expect(reward.goldAmount, 24); // 8 * 3.0
      expect(reward.rewardTag, 'boss_loot');
    });

    test('event room returns base gold and no tag', () {
      final reward = CombatRewardCalculator.calculate(
        roomType: RoomType.event,
        economyConfig: economyConfig,
      );

      expect(reward.goldAmount, 8);
      expect(reward.rewardTag, isNull);
    });

    test('mystery room returns base gold and no tag', () {
      final reward = CombatRewardCalculator.calculate(
        roomType: RoomType.mystery,
        economyConfig: economyConfig,
      );

      expect(reward.goldAmount, 8);
      expect(reward.rewardTag, isNull);
    });
  });
}
