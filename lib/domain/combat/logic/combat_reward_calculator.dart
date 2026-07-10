import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/combat/models/combat_reward.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 순수 보상 계산기 — RoomType + EconomyConfig → CombatReward.
/// 상태 없음. switch exhaustiveness로 새 RoomType 추가 시 컴파일 에러 강제.
class CombatRewardCalculator {
  CombatRewardCalculator._();

  static CombatReward calculate({
    required RoomType roomType,
    required EconomyConfig economyConfig,
    double goldMultiplier = 1.0,
    double eliteRewardMultiplier = 1.0,
  }) {
    final baseGold = economyConfig.baseGoldPerCombat;
    final raw = switch (roomType) {
      RoomType.elite => CombatReward(
          goldAmount: (baseGold * economyConfig.eliteGoldMultiplier * eliteRewardMultiplier).round(),
          rewardTag: 'elite_loot',
        ),
      RoomType.boss => CombatReward(
          goldAmount: (baseGold * economyConfig.bossGoldMultiplier).round(),
          rewardTag: 'boss_loot',
        ),
      RoomType.combat ||
      RoomType.event ||
      RoomType.mystery ||
      RoomType.shop ||
      RoomType.npc ||
      RoomType.rest =>
        CombatReward(goldAmount: baseGold),
    };
    if (goldMultiplier == 1.0) return raw;
    return CombatReward(
      goldAmount: (raw.goldAmount * goldMultiplier).round(),
      rewardTag: raw.rewardTag,
    );
  }
}
