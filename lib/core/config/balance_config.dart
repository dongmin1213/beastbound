import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/config/config_utils.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/config/floor_config.dart';
import 'package:soul_dungeon/core/config/tutorial_config.dart';
import 'package:soul_dungeon/core/error/game_error.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';

class TextSpeedConfig {
  final int charsPerSecondSlow;
  final int charsPerSecondNormal;
  final int charsPerSecondFast;

  const TextSpeedConfig({
    this.charsPerSecondSlow = 20,
    this.charsPerSecondNormal = 40,
    this.charsPerSecondFast = 80,
  });

  factory TextSpeedConfig.fromJson(Map<String, dynamic> json) {
    return TextSpeedConfig(
      charsPerSecondSlow: clampInt(json['chars_per_second_slow'], 1, 200, 20, 'chars_per_second_slow'),
      charsPerSecondNormal: clampInt(json['chars_per_second_normal'], 1, 200, 40, 'chars_per_second_normal'),
      charsPerSecondFast: clampInt(json['chars_per_second_fast'], 1, 500, 80, 'chars_per_second_fast'),
    );
  }
}

/// 티어별 효과 텍스트 설정 — balance.json tier_effects에서 로드.
/// 전체/부분/필드별 3단계 기본값 폴백.
class TierEffectConfig {
  final String highEffectiveText;
  final String highNeutralText;
  final String lowIneffectiveText;
  final String lowCounterText;

  const TierEffectConfig({
    this.highEffectiveText = '결정적 일격!',
    this.highNeutralText = '밀어붙인다!',
    this.lowIneffectiveText = '힘이 빠진다...',
    this.lowCounterText = '적이 반격한다!',
  });

  factory TierEffectConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TierEffectConfig();
    final high = json['high'] as Map<String, dynamic>? ?? {};
    final low = json['low'] as Map<String, dynamic>? ?? {};
    return TierEffectConfig(
      highEffectiveText: high['effective_text'] as String? ?? '결정적 일격!',
      highNeutralText: high['neutral_text'] as String? ?? '밀어붙인다!',
      lowIneffectiveText: low['ineffective_text'] as String? ?? '힘이 빠진다...',
      lowCounterText: low['counter_text'] as String? ?? '적이 반격한다!',
    );
  }
}

class MomentumConfig {
  final int initialValue;
  final int min;
  final int max;
  final int actionSwitchBonus;
  final int sameActionPenalty;
  final int sameActionStreakPenalty;
  final int environmentMomentumBonus;
  final int specialActionMomentumBonus;
  final int thresholdLow;
  final int thresholdMedium;
  final int thresholdHigh;
  final TierEffectConfig tierEffects;

  const MomentumConfig({
    this.initialValue = 30,
    this.min = 0,
    this.max = 100,
    this.actionSwitchBonus = 12,
    this.sameActionPenalty = -15,
    this.sameActionStreakPenalty = -25,
    this.environmentMomentumBonus = 20,
    this.specialActionMomentumBonus = 20,
    this.thresholdLow = 10,
    this.thresholdMedium = 30,
    this.thresholdHigh = 80,
    this.tierEffects = const TierEffectConfig(),
  });

  factory MomentumConfig.fromJson(Map<String, dynamic> json) {
    final thresholds = json['thresholds'] is Map<String, dynamic>
        ? json['thresholds'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawLow = clampInt(thresholds['low'], 0, 100, 10, 'thresholds.low');
    final rawMedium = clampInt(thresholds['medium'], 0, 100, 30, 'thresholds.medium');
    final rawHigh = clampInt(thresholds['high'], 0, 100, 80, 'thresholds.high');

    // 임계값 순서 검증: low < medium < high
    final validOrder = rawLow < rawMedium && rawMedium < rawHigh;
    if (!validOrder) {
      GameLogger.warning(
        LogSystem.core,
        'Momentum thresholds out of order ($rawLow/$rawMedium/$rawHigh), using defaults',
      );
    }

    return MomentumConfig(
      initialValue: clampInt(json['initial_value'], 0, 100, 30, 'initial_value'),
      min: clampInt(json['min'], 0, 100, 0, 'min'),
      max: clampInt(json['max'], 1, 1000, 100, 'max'),
      actionSwitchBonus: clampInt(json['action_switch_bonus'], 0, 100, 12, 'action_switch_bonus'),
      sameActionPenalty: clampInt(json['same_action_penalty'], -100, 0, -15, 'same_action_penalty'),
      sameActionStreakPenalty:
          clampInt(json['same_action_streak_penalty'], -100, 0, -25, 'same_action_streak_penalty'),
      environmentMomentumBonus:
          clampInt(json['environment_momentum_bonus'], 0, 100, 20, 'environment_momentum_bonus'),
      specialActionMomentumBonus:
          clampInt(json['special_action_momentum_bonus'], 0, 100, 20, 'special_action_momentum_bonus'),
      thresholdLow: validOrder ? rawLow : 10,
      thresholdMedium: validOrder ? rawMedium : 30,
      thresholdHigh: validOrder ? rawHigh : 80,
      tierEffects: TierEffectConfig.fromJson(
        json['tier_effects'] as Map<String, dynamic>?,
      ),
    );
  }
}

class CombatBalanceConfig {
  final int basePlayerHp;
  /// 현재 미사용 — 실제 보스 HP는 boss_enemies.dart × FloorsConfig.enemyHpMultiplier.
  final double bossHpMultiplier;

  /// 현재 미사용 — 실제 엘리트 HP는 floor_enemies.dart × FloorsConfig.enemyHpMultiplier.
  final double eliteHpMultiplier;
  final double momentumCarryoverRatio;
  final int normalTurnCount;
  final int eliteTurnCount;
  final int normalVictoryThreshold;
  final int eliteVictoryThreshold;
  final int normalDefeatHpLoss;
  final int eliteDefeatHpLoss;
  final int bossTurnCountPhase1;
  final int bossTurnCountPhase2;
  final int bossVictoryThreshold;
  final int bossDefeatHpLoss;
  /// 재생 스택 최대치 (대사제는 예외 적용).
  final int maxRegenStacks;

  const CombatBalanceConfig({
    this.basePlayerHp = 100,
    this.bossHpMultiplier = 3.0,
    this.eliteHpMultiplier = 1.8,
    this.momentumCarryoverRatio = 0.5,
    this.normalTurnCount = 3,
    this.eliteTurnCount = 5,
    this.normalVictoryThreshold = 0,
    this.eliteVictoryThreshold = 1,
    this.normalDefeatHpLoss = 9999,
    this.eliteDefeatHpLoss = 9999,
    this.bossTurnCountPhase1 = 3,
    this.bossTurnCountPhase2 = 4,
    this.bossVictoryThreshold = 0,
    this.bossDefeatHpLoss = 9999,
    this.maxRegenStacks = 8,
  });

  factory CombatBalanceConfig.fromJson(Map<String, dynamic> json) {
    return CombatBalanceConfig(
      basePlayerHp: clampInt(json['base_player_hp'], 1, 9999, 100, 'base_player_hp'),
      bossHpMultiplier:
          clampDouble(json['boss_hp_multiplier'], 0.1, 100.0, 3.0, 'boss_hp_multiplier'),
      eliteHpMultiplier:
          clampDouble(json['elite_hp_multiplier'], 0.1, 100.0, 1.8, 'elite_hp_multiplier'),
      momentumCarryoverRatio:
          clampDouble(json['momentum_carryover_ratio'], 0.0, 1.0, 0.5, 'momentum_carryover_ratio'),
      normalTurnCount:
          clampInt(json['normal_turn_count'], 1, 20, 3, 'normal_turn_count'),
      eliteTurnCount:
          clampInt(json['elite_turn_count'], 1, 20, 5, 'elite_turn_count'),
      normalVictoryThreshold:
          clampInt(json['normal_victory_threshold'], -10, 10, 0, 'normal_victory_threshold'),
      eliteVictoryThreshold:
          clampInt(json['elite_victory_threshold'], 0, 10, 1, 'elite_victory_threshold'),
      normalDefeatHpLoss:
          clampInt(json['normal_defeat_hp_loss'], 1, 99999, 9999, 'normal_defeat_hp_loss'),
      eliteDefeatHpLoss:
          clampInt(json['elite_defeat_hp_loss'], 1, 99999, 9999, 'elite_defeat_hp_loss'),
      bossTurnCountPhase1:
          clampInt(json['boss_turn_count_phase1'], 1, 20, 3, 'boss_turn_count_phase1'),
      bossTurnCountPhase2:
          clampInt(json['boss_turn_count_phase2'], 1, 20, 4, 'boss_turn_count_phase2'),
      bossVictoryThreshold:
          clampInt(json['boss_victory_threshold'], 0, 10, 0, 'boss_victory_threshold'),
      bossDefeatHpLoss:
          clampInt(json['boss_defeat_hp_loss'], 1, 99999, 9999, 'boss_defeat_hp_loss'),
      maxRegenStacks:
          clampInt(json['max_regen_stacks'], 1, 9999, 8, 'max_regen_stacks'),
    );
  }
}

/// 연쇄 보너스 밸런스 설정.
class ChainBonusConfig {
  final int chain2BonusPercent;
  final int chain3BonusPercent;
  final int chainDrawBonus;
  final int chain3MomentumBonus;

  const ChainBonusConfig({
    this.chain2BonusPercent = 20,
    this.chain3BonusPercent = 45,
    this.chainDrawBonus = 1,
    this.chain3MomentumBonus = 10,
  });

  factory ChainBonusConfig.fromJson(Map<String, dynamic> json) {
    return ChainBonusConfig(
      chain2BonusPercent: clampInt(json['chain_2_bonus_percent'], 0, 200, 20, 'chain_2_bonus_percent'),
      chain3BonusPercent: clampInt(json['chain_3_bonus_percent'], 0, 200, 45, 'chain_3_bonus_percent'),
      chainDrawBonus: clampInt(json['chain_draw_bonus'], 0, 10, 1, 'chain_draw_bonus'),
      chain3MomentumBonus: clampInt(json['chain_3_momentum_bonus'], 0, 100, 10, 'chain_3_momentum_bonus'),
    );
  }
}

/// 카드 전투 밸런스 설정.
class CardCombatBalanceConfig {
  final int initialHandSize;
  final int drawPerTurn;
  final int apLow;
  final int apMid;
  final int apHigh;
  final int eliteTurnLimit;
  final int bossTurnLimit;
  final int cardRewardCount;

  const CardCombatBalanceConfig({
    this.initialHandSize = 5,
    this.drawPerTurn = 4,
    this.apLow = 2,
    this.apMid = 3,
    this.apHigh = 4,
    this.eliteTurnLimit = 20,
    this.bossTurnLimit = 30,
    this.cardRewardCount = 3,
  });

  /// 기세 티어(1=Low,2=Mid,3=High) → AP.
  int apForTier(int tier) => switch (tier) {
        1 => apLow,
        2 => apMid,
        _ => apHigh,
      };

  factory CardCombatBalanceConfig.fromJson(Map<String, dynamic> json) {
    return CardCombatBalanceConfig(
      initialHandSize: clampInt(json['initial_hand_size'], 1, 20, 5, 'initial_hand_size'),
      drawPerTurn: clampInt(json['draw_per_turn'], 1, 20, 4, 'draw_per_turn'),
      apLow: clampInt(json['ap_low'], 1, 10, 2, 'ap_low'),
      apMid: clampInt(json['ap_mid'], 1, 10, 3, 'ap_mid'),
      apHigh: clampInt(json['ap_high'], 1, 10, 4, 'ap_high'),
      eliteTurnLimit: clampInt(json['elite_turn_limit'], 1, 100, 20, 'elite_turn_limit'),
      bossTurnLimit: clampInt(json['boss_turn_limit'], 1, 100, 30, 'boss_turn_limit'),
      cardRewardCount: clampInt(json['card_reward_count'], 1, 10, 3, 'card_reward_count'),
    );
  }
}

/// 도주 밸런스 설정.
class FleeConfig {
  final double baseSuccessRate;
  final int apCost;
  final double hpPenaltyPercent;
  final int goldPenalty;
  final double windAmuletBonus;

  const FleeConfig({
    this.baseSuccessRate = 0.4,
    this.apCost = 1,
    this.hpPenaltyPercent = 0.20,
    this.goldPenalty = 20,
    this.windAmuletBonus = 0.3,
  });

  factory FleeConfig.fromJson(Map<String, dynamic> json) {
    return FleeConfig(
      baseSuccessRate: clampDouble(json['base_success_rate'], 0.0, 1.0, 0.4, 'base_success_rate'),
      apCost: clampInt(json['ap_cost'], 0, 10, 1, 'ap_cost'),
      hpPenaltyPercent: clampDouble(json['hp_penalty_percent'], 0.0, 1.0, 0.20, 'hp_penalty_percent'),
      goldPenalty: clampInt(json['gold_penalty'], 0, 9999, 20, 'gold_penalty'),
      windAmuletBonus: clampDouble(json['wind_amulet_bonus'], 0.0, 1.0, 0.3, 'wind_amulet_bonus'),
    );
  }
}

class EconomyConfig {
  final int baseGoldPerCombat;
  final double eliteGoldMultiplier;
  final int shopPriceBase;
  final double shopPriceFloorMultiplier;
  final int soulBaseGain;
  final double soulPriceCurveExponent;
  final double bossGoldMultiplier;

  const EconomyConfig({
    this.baseGoldPerCombat = 8,
    this.eliteGoldMultiplier = 3.0,
    this.shopPriceBase = 20,
    this.shopPriceFloorMultiplier = 1.2,
    this.soulBaseGain = 8,
    this.soulPriceCurveExponent = 1.3,
    this.bossGoldMultiplier = 3.0,
  });

  factory EconomyConfig.fromJson(Map<String, dynamic> json) {
    return EconomyConfig(
      baseGoldPerCombat: clampInt(json['base_gold_per_combat'], 0, 9999, 8, 'base_gold_per_combat'),
      eliteGoldMultiplier:
          clampDouble(json['elite_gold_multiplier'], 0.1, 100.0, 3.0, 'elite_gold_multiplier'),
      shopPriceBase: clampInt(json['shop_price_base'], 1, 9999, 20, 'shop_price_base'),
      shopPriceFloorMultiplier:
          clampDouble(json['shop_price_floor_multiplier'], 0.1, 10.0, 1.2, 'shop_price_floor_multiplier'),
      soulBaseGain: clampInt(json['soul_base_gain'], 0, 9999, 8, 'soul_base_gain'),
      soulPriceCurveExponent:
          clampDouble(json['soul_price_curve_exponent'], 0.1, 10.0, 1.3, 'soul_price_curve_exponent'),
      bossGoldMultiplier:
          clampDouble(json['boss_gold_multiplier'], 0.1, 100.0, 3.0, 'boss_gold_multiplier'),
    );
  }
}

class MysteryConfig {
  final int treasureGold;
  final int trapHpLoss;
  final int combatGold;
  final int eventGold;
  final int minorGold;
  final int weightTreasure;
  final int weightTrap;
  final int weightCombat;
  final int weightEvent;
  final int weightMinor;

  const MysteryConfig({
    this.treasureGold = 15,
    this.trapHpLoss = 20,
    this.combatGold = 15,
    this.eventGold = 5,
    this.minorGold = 2,
    this.weightTreasure = 15,
    this.weightTrap = 20,
    this.weightCombat = 30,
    this.weightEvent = 15,
    this.weightMinor = 20,
  });

  factory MysteryConfig.fromJson(Map<String, dynamic> json) {
    return MysteryConfig(
      treasureGold: clampInt(json['treasure_gold'], 0, 9999, 15, 'treasure_gold'),
      trapHpLoss: clampInt(json['trap_hp_loss'], 0, 9999, 20, 'trap_hp_loss'),
      combatGold: clampInt(json['combat_gold'], 0, 9999, 15, 'combat_gold'),
      eventGold: clampInt(json['event_gold'], 0, 9999, 5, 'event_gold'),
      minorGold: clampInt(json['minor_gold'], 0, 9999, 2, 'minor_gold'),
      weightTreasure: clampInt(json['weight_treasure'], 0, 100, 15, 'weight_treasure'),
      weightTrap: clampInt(json['weight_trap'], 0, 100, 20, 'weight_trap'),
      weightCombat: clampInt(json['weight_combat'], 0, 100, 30, 'weight_combat'),
      weightEvent: clampInt(json['weight_event'], 0, 100, 15, 'weight_event'),
      weightMinor: clampInt(json['weight_minor'], 0, 100, 20, 'weight_minor'),
    );
  }
}

class NpcConfig {
  final int npcWeightTrader;
  final int npcWeightSage;
  final int npcWeightWanderer;
  final int npcTradeItemCount;
  final int npcDialogueGoldReward;

  const NpcConfig({
    this.npcWeightTrader = 40,
    this.npcWeightSage = 30,
    this.npcWeightWanderer = 30,
    this.npcTradeItemCount = 2,
    this.npcDialogueGoldReward = 14,
  });

  factory NpcConfig.fromJson(Map<String, dynamic> json) {
    return NpcConfig(
      npcWeightTrader: clampInt(json['weight_trader'], 0, 100, 40, 'weight_trader'),
      npcWeightSage: clampInt(json['weight_sage'], 0, 100, 30, 'weight_sage'),
      npcWeightWanderer: clampInt(json['weight_wanderer'], 0, 100, 30, 'weight_wanderer'),
      npcTradeItemCount: clampInt(json['trade_item_count'], 1, 10, 2, 'trade_item_count'),
      npcDialogueGoldReward: clampInt(json['dialogue_gold_reward'], 0, 9999, 14, 'dialogue_gold_reward'),
    );
  }
}

class RestConfig {
  final double hpRecoveryPercent;
  final int maxHpIncrease;

  const RestConfig({
    this.hpRecoveryPercent = 0.15,
    this.maxHpIncrease = 3,
  })  : assert(hpRecoveryPercent >= 0 && hpRecoveryPercent <= 1.0),
        assert(maxHpIncrease >= 0);

  factory RestConfig.fromJson(Map<String, dynamic> json) {
    return RestConfig(
      hpRecoveryPercent: clampDouble(
        json['hp_recovery_percent'],
        0.0,
        1.0,
        0.15,
        'hp_recovery_percent',
      ),
      maxHpIncrease: clampInt(json['max_hp_increase'], 0, 9999, 3, 'max_hp_increase'),
    );
  }
}

class EventConfig {
  final int goldReward;
  final int hpReward;
  final int hpPenalty;

  const EventConfig({
    this.goldReward = 10,
    this.hpReward = 7,
    this.hpPenalty = 5,
  });

  factory EventConfig.fromJson(Map<String, dynamic> json) {
    return EventConfig(
      goldReward: clampInt(json['gold_reward'], 0, 9999, 10, 'gold_reward'),
      hpReward: clampInt(json['hp_reward'], 0, 9999, 7, 'hp_reward'),
      hpPenalty: clampInt(json['hp_penalty'], 0, 9999, 5, 'hp_penalty'),
    );
  }

  /// 층별 보상 스케일링 (1층=1.0x, +0.15x/층).
  EventConfig scaledForFloor(int floor) {
    final multiplier = 1.0 + (floor - 1) * 0.15;
    return EventConfig(
      goldReward: (goldReward * multiplier).round(),
      hpReward: (hpReward * multiplier).round(),
      hpPenalty: (hpPenalty * multiplier).round(),
    );
  }
}

class BuildConfig {
  final int wandererMinTotal;
  final int wandererMaxDeviation;

  const BuildConfig({
    this.wandererMinTotal = 10,
    this.wandererMaxDeviation = 2,
  });

  factory BuildConfig.fromJson(Map<String, dynamic> json) {
    return BuildConfig(
      wandererMinTotal: clampInt(json['wanderer_min_total'], 1, 100, 10, 'wanderer_min_total'),
      wandererMaxDeviation: clampInt(json['wanderer_max_deviation'], 0, 100, 2, 'wanderer_max_deviation'),
    );
  }
}

class PrepConfig {
  final int startingGoldBonus;
  final int startingHpBonus;
  final String startingBlessingId;
  final String startingRelicId;
  final int mercyHpBonus;
  final int balancedGold;
  final int balancedHp;

  const PrepConfig({
    this.startingGoldBonus = 20,
    this.startingHpBonus = 15,
    this.startingBlessingId = 'blessing_001',
    this.startingRelicId = 'relic_001',
    this.mercyHpBonus = 10,
    this.balancedGold = 10,
    this.balancedHp = 8,
  });

  factory PrepConfig.fromJson(Map<String, dynamic> json) {
    return PrepConfig(
      startingGoldBonus: clampInt(json['starting_gold_bonus'], 0, 9999, 20, 'starting_gold_bonus'),
      startingHpBonus: clampInt(json['starting_hp_bonus'], 0, 9999, 15, 'starting_hp_bonus'),
      startingBlessingId: json['starting_blessing_id'] as String? ?? 'blessing_001',
      startingRelicId: json['starting_relic_id'] as String? ?? 'relic_001',
      mercyHpBonus: clampInt(json['mercy_hp_bonus'], 0, 9999, 10, 'mercy_hp_bonus'),
      balancedGold: clampInt(json['balanced_gold'], 0, 9999, 10, 'balanced_gold'),
      balancedHp: clampInt(json['balanced_hp'], 0, 9999, 8, 'balanced_hp'),
    );
  }
}

/// 희귀도 4단계 보상 가중치 및 가격 배율.
///
/// 4등급: common / rare / legendary / cursed.
/// 가중치 합계 기준으로 비율 결정 (정규화 불필요).
class RarityConfig {
  final int weightCommon;
  final int weightRare;
  final int weightLegendary;
  final int weightCursed;
  final double priceMultiplierCommon;
  final double priceMultiplierRare;
  final double priceMultiplierLegendary;
  final double priceMultiplierCursed;

  const RarityConfig({
    this.weightCommon = 55,
    this.weightRare = 30,
    this.weightLegendary = 10,
    this.weightCursed = 5,
    this.priceMultiplierCommon = 1.0,
    this.priceMultiplierRare = 1.5,
    this.priceMultiplierLegendary = 2.0,
    this.priceMultiplierCursed = 0.8,
  });

  int get totalWeight =>
      weightCommon + weightRare + weightLegendary + weightCursed;

  factory RarityConfig.fromJson(Map<String, dynamic> json) {
    return RarityConfig(
      weightCommon:
          clampInt(json['weight_common'], 0, 100, 55, 'weight_common'),
      weightRare: clampInt(json['weight_rare'], 0, 100, 30, 'weight_rare'),
      weightLegendary:
          clampInt(json['weight_legendary'], 0, 100, 10, 'weight_legendary'),
      weightCursed:
          clampInt(json['weight_cursed'], 0, 100, 5, 'weight_cursed'),
      priceMultiplierCommon: clampDouble(
          json['price_multiplier_common'], 0.1, 10.0, 1.0, 'price_multiplier_common'),
      priceMultiplierRare:
          clampDouble(json['price_multiplier_rare'], 0.1, 10.0, 1.5, 'price_multiplier_rare'),
      priceMultiplierLegendary:
          clampDouble(json['price_multiplier_legendary'], 0.1, 10.0, 2.0, 'price_multiplier_legendary'),
      priceMultiplierCursed:
          clampDouble(json['price_multiplier_cursed'], 0.1, 10.0, 0.8, 'price_multiplier_cursed'),
    );
  }
}

/// 오디오 밸런스 설정 — 3레이어(master/sfx/music) 볼륨 + 활성화 여부.
class AudioConfig {
  final double masterVolume;
  final double sfxVolume;
  final double musicVolume;
  final bool enabled;

  const AudioConfig({
    this.masterVolume = 0.8,
    this.sfxVolume = 1.0,
    this.musicVolume = 0.7,
    this.enabled = true,
  });

  factory AudioConfig.fromJson(Map<String, dynamic> json) {
    return AudioConfig(
      masterVolume: clampDouble(json['master_volume'], 0.0, 1.0, 0.8, 'master_volume'),
      sfxVolume: clampDouble(json['sfx_volume'], 0.0, 1.0, 1.0, 'sfx_volume'),
      musicVolume: clampDouble(json['music_volume'], 0.0, 1.0, 0.7, 'music_volume'),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  AudioConfig copyWith({
    double? masterVolume,
    double? sfxVolume,
    double? musicVolume,
    bool? enabled,
  }) {
    return AudioConfig(
      masterVolume: masterVolume ?? this.masterVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// 메타 프로그레션 밸런스 설정.
class MetaProgressionConfig {
  /// 클리어 시 추가 소울 보너스.
  final int soulClearBonus;

  /// 사망 시 소울 보상 배율 (층 x base x multiplier).
  final int soulDeathMultiplier;

  const MetaProgressionConfig({
    this.soulClearBonus = 50,
    this.soulDeathMultiplier = 1,
  });

  factory MetaProgressionConfig.fromJson(Map<String, dynamic> json) {
    return MetaProgressionConfig(
      soulClearBonus: clampInt(
          json['soul_clear_bonus'], 0, 9999, 50, 'soul_clear_bonus'),
      soulDeathMultiplier: clampInt(
          json['soul_death_multiplier'], 0, 100, 1, 'soul_death_multiplier'),
    );
  }
}

class BalanceConfig {
  final int schemaVersion;
  final TextSpeedConfig text;
  final MomentumConfig momentum;
  final CombatBalanceConfig combat;
  final ChainBonusConfig chainBonus;
  final CardCombatBalanceConfig cardCombat;
  final FleeConfig flee;
  final EconomyConfig economy;
  final DungeonBalanceConfig dungeon;
  final MysteryConfig mystery;
  final NpcConfig npc;
  final RestConfig rest;
  final EventConfig event;
  final BuildConfig build;
  final PrepConfig prep;
  final RarityConfig rarity;
  final FloorsConfig floors;
  final TutorialConfig tutorial;
  final MetaProgressionConfig metaProgression;
  final AudioConfig audio;

  const BalanceConfig({
    this.schemaVersion = 2,
    this.text = const TextSpeedConfig(),
    this.momentum = const MomentumConfig(),
    this.combat = const CombatBalanceConfig(),
    this.chainBonus = const ChainBonusConfig(),
    this.cardCombat = const CardCombatBalanceConfig(),
    this.flee = const FleeConfig(),
    this.economy = const EconomyConfig(),
    this.dungeon = const DungeonBalanceConfig(),
    this.mystery = const MysteryConfig(),
    this.npc = const NpcConfig(),
    this.rest = const RestConfig(),
    this.event = const EventConfig(),
    this.build = const BuildConfig(),
    this.prep = const PrepConfig(),
    this.rarity = const RarityConfig(),
    this.floors = const FloorsConfig([]),
    this.tutorial = const TutorialConfig(),
    this.metaProgression = const MetaProgressionConfig(),
    this.audio = const AudioConfig(),
  });

  BalanceConfig copyWith({AudioConfig? audio}) {
    return BalanceConfig(
      schemaVersion: schemaVersion,
      text: text,
      momentum: momentum,
      combat: combat,
      chainBonus: chainBonus,
      cardCombat: cardCombat,
      flee: flee,
      economy: economy,
      dungeon: dungeon,
      mystery: mystery,
      npc: npc,
      rest: rest,
      event: event,
      build: build,
      prep: prep,
      rarity: rarity,
      floors: floors,
      tutorial: tutorial,
      metaProgression: metaProgression,
      audio: audio ?? this.audio,
    );
  }

  factory BalanceConfig.fromJson(Map<String, dynamic> json) {
    return BalanceConfig(
      schemaVersion: json['schema_version'] as int? ?? 1,
      text: json['text'] is Map<String, dynamic>
          ? TextSpeedConfig.fromJson(json['text'] as Map<String, dynamic>)
          : const TextSpeedConfig(),
      momentum: json['momentum'] is Map<String, dynamic>
          ? MomentumConfig.fromJson(json['momentum'] as Map<String, dynamic>)
          : const MomentumConfig(),
      combat: json['combat'] is Map<String, dynamic>
          ? CombatBalanceConfig.fromJson(
              json['combat'] as Map<String, dynamic>)
          : const CombatBalanceConfig(),
      chainBonus: json['chain_bonus'] is Map<String, dynamic>
          ? ChainBonusConfig.fromJson(
              json['chain_bonus'] as Map<String, dynamic>)
          : const ChainBonusConfig(),
      cardCombat: json['card_combat'] is Map<String, dynamic>
          ? CardCombatBalanceConfig.fromJson(
              json['card_combat'] as Map<String, dynamic>)
          : const CardCombatBalanceConfig(),
      flee: json['flee'] is Map<String, dynamic>
          ? FleeConfig.fromJson(json['flee'] as Map<String, dynamic>)
          : const FleeConfig(),
      economy: json['economy'] is Map<String, dynamic>
          ? EconomyConfig.fromJson(json['economy'] as Map<String, dynamic>)
          : const EconomyConfig(),
      dungeon: json['dungeon'] is Map<String, dynamic>
          ? DungeonBalanceConfig.fromJson(
              json['dungeon'] as Map<String, dynamic>)
          : const DungeonBalanceConfig(),
      mystery: json['mystery'] is Map<String, dynamic>
          ? MysteryConfig.fromJson(json['mystery'] as Map<String, dynamic>)
          : const MysteryConfig(),
      npc: json['npc'] is Map<String, dynamic>
          ? NpcConfig.fromJson(json['npc'] as Map<String, dynamic>)
          : const NpcConfig(),
      rest: json['rest'] is Map<String, dynamic>
          ? RestConfig.fromJson(json['rest'] as Map<String, dynamic>)
          : const RestConfig(),
      event: json['event'] is Map<String, dynamic>
          ? EventConfig.fromJson(json['event'] as Map<String, dynamic>)
          : const EventConfig(),
      build: json['build'] is Map<String, dynamic>
          ? BuildConfig.fromJson(json['build'] as Map<String, dynamic>)
          : const BuildConfig(),
      prep: json['prep'] is Map<String, dynamic>
          ? PrepConfig.fromJson(json['prep'] as Map<String, dynamic>)
          : const PrepConfig(),
      rarity: json['rarity'] is Map<String, dynamic>
          ? RarityConfig.fromJson(json['rarity'] as Map<String, dynamic>)
          : const RarityConfig(),
      floors: json['floors'] is List<dynamic>
          ? FloorsConfig.fromJson(json['floors'] as List<dynamic>)
          : const FloorsConfig([]),
      tutorial: json['tutorial'] is Map<String, dynamic>
          ? TutorialConfig.fromJson(
              json['tutorial'] as Map<String, dynamic>)
          : const TutorialConfig(),
      metaProgression: json['meta_progression'] is Map<String, dynamic>
          ? MetaProgressionConfig.fromJson(
              json['meta_progression'] as Map<String, dynamic>)
          : const MetaProgressionConfig(),
      audio: json['audio'] is Map<String, dynamic>
          ? AudioConfig.fromJson(json['audio'] as Map<String, dynamic>)
          : const AudioConfig(),
    );
  }

  static Future<Result<BalanceConfig>> load({
    AssetBundle? bundle,
    String path = 'assets/config/balance.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = BalanceConfig.fromJson(json);
      GameLogger.info(LogSystem.core, 'BalanceConfig loaded (schema v${config.schemaVersion})');
      return Success(config);
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load balance.json, using defaults', e);
      return Failure(GameError(
        message: 'Failed to load balance.json: $e',
        severity: ErrorSeverity.recoverable,
        system: 'core',
        cause: e,
      ));
    }
  }
}
