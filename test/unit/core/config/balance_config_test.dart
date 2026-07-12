import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/error/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BalanceConfig', () {
    test('fromJson parses valid config', () {
      final config = BalanceConfig.fromJson({
        'schema_version': 1,
        'text': {
          'chars_per_second_slow': 20,
          'chars_per_second_normal': 40,
          'chars_per_second_fast': 80,
        },
      });

      expect(config.schemaVersion, 1);
      expect(config.text.charsPerSecondSlow, 20);
      expect(config.text.charsPerSecondNormal, 40);
      expect(config.text.charsPerSecondFast, 80);
    });

    test('fromJson uses defaults for missing text section', () {
      final config = BalanceConfig.fromJson({
        'schema_version': 1,
      });

      expect(config.text.charsPerSecondNormal, 40);
    });

    test('TextSpeedConfig clamps out-of-range values to fallback', () {
      final config = TextSpeedConfig.fromJson({
        'chars_per_second_slow': -5,
        'chars_per_second_normal': 999,
        'chars_per_second_fast': 'invalid',
      });

      expect(config.charsPerSecondSlow, 20);
      expect(config.charsPerSecondNormal, 40);
      expect(config.charsPerSecondFast, 80);
    });

    test('load returns Success from valid asset', () async {
      final bundle = TestAssetBundle();
      final result = await BalanceConfig.load(bundle: bundle);

      expect(result, isA<Success<BalanceConfig>>());
      final config = (result as Success<BalanceConfig>).data;
      expect(config.text.charsPerSecondNormal, 40);
    });

    test('load returns Failure for invalid JSON', () async {
      final bundle = InvalidAssetBundle();
      final result = await BalanceConfig.load(bundle: bundle);

      expect(result, isA<Failure<BalanceConfig>>());
    });

    test('load returns Success from v2 asset with combat/economy', () async {
      final bundle = TestAssetBundleV2();
      final result = await BalanceConfig.load(bundle: bundle);

      expect(result, isA<Success<BalanceConfig>>());
      final config = (result as Success<BalanceConfig>).data;
      expect(config.schemaVersion, 2);
      expect(config.momentum.environmentMomentumBonus, 25);
      expect(config.combat.basePlayerHp, 100);
      expect(config.economy.baseGoldPerCombat, 10);
    });

    test('fromJson uses defaults for missing momentum section', () {
      final config = BalanceConfig.fromJson({
        'schema_version': 1,
      });

      expect(config.momentum.initialValue, 30);
      expect(config.momentum.max, 100);
      expect(config.momentum.actionSwitchBonus, 12);
    });

    test('fromJson parses v2 config with combat and economy', () {
      final config = BalanceConfig.fromJson({
        'schema_version': 2,
        'text': {
          'chars_per_second_slow': 20,
          'chars_per_second_normal': 40,
          'chars_per_second_fast': 80,
        },
        'momentum': {
          'initial_value': 0,
          'min': 0,
          'max': 100,
          'action_switch_bonus': 15,
          'same_action_penalty': -10,
          'same_action_streak_penalty': -20,
          'environment_momentum_bonus': 25,
          'thresholds': {'low': 30, 'medium': 60, 'high': 80},
        },
        'combat': {
          'base_player_hp': 100,
          'boss_hp_multiplier': 2.5,
          'elite_hp_multiplier': 1.5,
          'momentum_carryover_ratio': 0.5,
        },
        'economy': {
          'base_gold_per_combat': 10,
          'elite_gold_multiplier': 2.0,
          'shop_price_base': 15,
          'shop_price_floor_multiplier': 1.15,
          'soul_base_gain': 5,
          'soul_price_curve_exponent': 1.5,
        },
      });

      expect(config.schemaVersion, 2);
      expect(config.momentum.environmentMomentumBonus, 25);
      expect(config.combat.basePlayerHp, 100);
      expect(config.combat.bossHpMultiplier, 2.5);
      expect(config.combat.eliteHpMultiplier, 1.5);
      expect(config.combat.momentumCarryoverRatio, 0.5);
      expect(config.economy.baseGoldPerCombat, 10);
      expect(config.economy.eliteGoldMultiplier, 2.0);
      expect(config.economy.shopPriceBase, 15);
      expect(config.economy.shopPriceFloorMultiplier, 1.15);
      expect(config.economy.soulBaseGain, 5);
      expect(config.economy.soulPriceCurveExponent, 1.5);
    });

    test('fromJson v1 migration: missing combat/economy uses defaults', () {
      final config = BalanceConfig.fromJson({
        'schema_version': 1,
        'text': {
          'chars_per_second_slow': 20,
          'chars_per_second_normal': 40,
          'chars_per_second_fast': 80,
        },
      });

      expect(config.schemaVersion, 1);
      expect(config.combat.basePlayerHp, 100);
      expect(config.combat.bossHpMultiplier, 3.0);
      expect(config.economy.baseGoldPerCombat, 8);
      expect(config.economy.soulBaseGain, 8);
    });

    test('fromJson parses momentum section', () {
      final config = BalanceConfig.fromJson({
        'schema_version': 1,
        'momentum': {
          'initial_value': 10,
          'min': 0,
          'max': 100,
          'action_switch_bonus': 20,
          'same_action_penalty': -15,
          'same_action_streak_penalty': -25,
          'environment_momentum_bonus': 30,
          'thresholds': {'low': 25, 'medium': 50, 'high': 75},
        },
      });

      expect(config.momentum.initialValue, 10);
      expect(config.momentum.actionSwitchBonus, 20);
      expect(config.momentum.sameActionPenalty, -15);
      expect(config.momentum.sameActionStreakPenalty, -25);
      expect(config.momentum.environmentMomentumBonus, 30);
      expect(config.momentum.thresholdLow, 25);
      expect(config.momentum.thresholdMedium, 50);
      expect(config.momentum.thresholdHigh, 75);
    });
  });

  group('MomentumConfig', () {
    test('fromJson parses valid config', () {
      final config = MomentumConfig.fromJson({
        'initial_value': 0,
        'min': 0,
        'max': 100,
        'action_switch_bonus': 15,
        'same_action_penalty': -10,
        'same_action_streak_penalty': -20,
        'environment_momentum_bonus': 25,
        'thresholds': {'low': 30, 'medium': 60, 'high': 80},
      });

      expect(config.initialValue, 0);
      expect(config.min, 0);
      expect(config.max, 100);
      expect(config.actionSwitchBonus, 15);
      expect(config.sameActionPenalty, -10);
      expect(config.sameActionStreakPenalty, -20);
      expect(config.environmentMomentumBonus, 25);
      expect(config.thresholdLow, 30);
      expect(config.thresholdMedium, 60);
      expect(config.thresholdHigh, 80);
    });

    test('fromJson uses defaults for missing fields', () {
      final config = MomentumConfig.fromJson({});

      expect(config.initialValue, 30);
      expect(config.min, 0);
      expect(config.max, 100);
      expect(config.actionSwitchBonus, 12);
      expect(config.sameActionPenalty, -15);
      expect(config.sameActionStreakPenalty, -25);
      expect(config.environmentMomentumBonus, 20);
      expect(config.thresholdLow, 10);
      expect(config.thresholdMedium, 30);
      expect(config.thresholdHigh, 80);
    });

    test('fromJson clamps out-of-range values to fallback', () {
      final config = MomentumConfig.fromJson({
        'initial_value': -5,
        'max': 0,
        'action_switch_bonus': 200,
        'same_action_penalty': 50,
        'same_action_streak_penalty': 'invalid',
        'environment_momentum_bonus': 200,
      });

      expect(config.initialValue, 30);
      expect(config.max, 100);
      expect(config.actionSwitchBonus, 12);
      expect(config.sameActionPenalty, -15);
      expect(config.sameActionStreakPenalty, -25);
      expect(config.environmentMomentumBonus, 20);
    });

    test('fromJson clamps environmentMomentumBonus negative to fallback', () {
      final config = MomentumConfig.fromJson({
        'environment_momentum_bonus': -5,
      });

      expect(config.environmentMomentumBonus, 20);
    });

    test('fromJson clamps environmentMomentumBonus invalid type to fallback', () {
      final config = MomentumConfig.fromJson({
        'environment_momentum_bonus': 'invalid',
      });

      expect(config.environmentMomentumBonus, 20);
    });

    test('fromJson falls back thresholds when order is invalid', () {
      final config = MomentumConfig.fromJson({
        'thresholds': {'low': 80, 'medium': 50, 'high': 30},
      });

      expect(config.thresholdLow, 10);
      expect(config.thresholdMedium, 30);
      expect(config.thresholdHigh, 80);
    });

    test('fromJson falls back thresholds when equal', () {
      final config = MomentumConfig.fromJson({
        'thresholds': {'low': 50, 'medium': 50, 'high': 50},
      });

      expect(config.thresholdLow, 10);
      expect(config.thresholdMedium, 30);
      expect(config.thresholdHigh, 80);
    });

    test('fromJson handles missing thresholds section', () {
      final config = MomentumConfig.fromJson({
        'initial_value': 0,
      });

      expect(config.thresholdLow, 10);
      expect(config.thresholdMedium, 30);
      expect(config.thresholdHigh, 80);
    });

    test('default constructor provides correct defaults', () {
      const config = MomentumConfig();

      expect(config.initialValue, 30);
      expect(config.min, 0);
      expect(config.max, 100);
      expect(config.actionSwitchBonus, 12);
      expect(config.sameActionPenalty, -15);
      expect(config.sameActionStreakPenalty, -25);
      expect(config.environmentMomentumBonus, 20);
      expect(config.thresholdLow, 10);
      expect(config.thresholdMedium, 30);
      expect(config.thresholdHigh, 80);
    });
  });

  group('CombatBalanceConfig', () {
    test('fromJson parses valid config', () {
      final config = CombatBalanceConfig.fromJson({
        'base_player_hp': 120,
        'boss_hp_multiplier': 3.0,
        'elite_hp_multiplier': 2.0,
        'momentum_carryover_ratio': 0.7,
      });

      expect(config.basePlayerHp, 120);
      expect(config.bossHpMultiplier, 3.0);
      expect(config.eliteHpMultiplier, 2.0);
      expect(config.momentumCarryoverRatio, 0.7);
    });

    test('fromJson clamps out-of-range values to fallback', () {
      final config = CombatBalanceConfig.fromJson({
        'base_player_hp': 0,
        'boss_hp_multiplier': 0.0,
        'elite_hp_multiplier': 200.0,
        'momentum_carryover_ratio': 2.0,
      });

      expect(config.basePlayerHp, 100);
      expect(config.bossHpMultiplier, 3.0);
      expect(config.eliteHpMultiplier, 1.8);
      expect(config.momentumCarryoverRatio, 0.5);
    });

    test('default constructor provides correct defaults', () {
      const config = CombatBalanceConfig();

      expect(config.basePlayerHp, 100);
      expect(config.bossHpMultiplier, 3.0);
      expect(config.eliteHpMultiplier, 1.8);
      expect(config.momentumCarryoverRatio, 0.5);
    });

    test('fromJson parses elite turn/victory fields', () {
      final config = CombatBalanceConfig.fromJson({
        'base_player_hp': 100,
        'boss_hp_multiplier': 2.5,
        'elite_hp_multiplier': 1.5,
        'momentum_carryover_ratio': 0.5,
        'normal_turn_count': 3,
        'elite_turn_count': 5,
        'elite_victory_threshold': 1,
      });

      expect(config.normalTurnCount, 3);
      expect(config.eliteTurnCount, 5);
      expect(config.eliteVictoryThreshold, 1);
    });

    test('fromJson clamps elite fields out-of-range to fallback', () {
      final config = CombatBalanceConfig.fromJson({
        'normal_turn_count': 0,
        'elite_turn_count': 25,
        'elite_victory_threshold': -1,
      });

      expect(config.normalTurnCount, 3);
      expect(config.eliteTurnCount, 5);
      expect(config.eliteVictoryThreshold, 1);
    });

    test('default constructor provides correct elite defaults', () {
      const config = CombatBalanceConfig();

      expect(config.normalTurnCount, 3);
      expect(config.eliteTurnCount, 5);
      expect(config.eliteVictoryThreshold, 1);
    });

    test('fromJson parses defeat HP loss fields', () {
      final config = CombatBalanceConfig.fromJson({
        'base_player_hp': 100,
        'normal_defeat_hp_loss': 30,
        'elite_defeat_hp_loss': 50,
      });

      expect(config.normalDefeatHpLoss, 30);
      expect(config.eliteDefeatHpLoss, 50);
    });

    test('fromJson uses defaults for missing defeat HP loss fields', () {
      final config = CombatBalanceConfig.fromJson({
        'base_player_hp': 100,
      });

      expect(config.normalDefeatHpLoss, 9999);
      expect(config.eliteDefeatHpLoss, 9999);
    });

    test('fromJson clamps defeat HP loss out-of-range to fallback', () {
      final config = CombatBalanceConfig.fromJson({
        'normal_defeat_hp_loss': 0,
        'elite_defeat_hp_loss': 150,
      });

      // normal_defeat_hp_loss: 0 is out of range (1..99999) → fallback 9999
      expect(config.normalDefeatHpLoss, 9999);
      // elite_defeat_hp_loss: 150 is valid → stored as-is
      expect(config.eliteDefeatHpLoss, 150);
    });

    // === Story 3-8: 보스 밸런스 설정 ===

    test('fromJson parses boss combat fields', () {
      final config = CombatBalanceConfig.fromJson({
        'base_player_hp': 100,
        'boss_turn_count_phase1': 3,
        'boss_turn_count_phase2': 4,
        'boss_victory_threshold': 0,
        'boss_defeat_hp_loss': 9999,
      });

      expect(config.bossTurnCountPhase1, 3);
      expect(config.bossTurnCountPhase2, 4);
      expect(config.bossVictoryThreshold, 0);
      expect(config.bossDefeatHpLoss, 9999);
    });

    test('fromJson uses defaults for missing boss fields', () {
      final config = CombatBalanceConfig.fromJson({
        'base_player_hp': 100,
      });

      expect(config.bossTurnCountPhase1, 3);
      expect(config.bossTurnCountPhase2, 4);
      expect(config.bossVictoryThreshold, 0);
      expect(config.bossDefeatHpLoss, 9999);
    });
  });

  group('EconomyConfig', () {
    test('fromJson parses valid config', () {
      final config = EconomyConfig.fromJson({
        'base_gold_per_combat': 15,
        'elite_gold_multiplier': 3.0,
        'shop_price_base': 50,
        'shop_price_floor_multiplier': 1.5,
        'soul_base_gain': 8,
        'soul_price_curve_exponent': 2.0,
      });

      expect(config.baseGoldPerCombat, 15);
      expect(config.eliteGoldMultiplier, 3.0);
      expect(config.shopPriceBase, 50);
      expect(config.shopPriceFloorMultiplier, 1.5);
      expect(config.soulBaseGain, 8);
      expect(config.soulPriceCurveExponent, 2.0);
    });

    test('fromJson clamps out-of-range values to fallback', () {
      final config = EconomyConfig.fromJson({
        'base_gold_per_combat': -1,
        'elite_gold_multiplier': 0.0,
        'shop_price_base': 0,
        'shop_price_floor_multiplier': 0.0,
        'soul_base_gain': 'invalid',
        'soul_price_curve_exponent': 99.0,
      });

      expect(config.baseGoldPerCombat, 8);
      expect(config.eliteGoldMultiplier, 3.0);
      expect(config.shopPriceBase, 20);
      expect(config.shopPriceFloorMultiplier, 1.2);
      expect(config.soulBaseGain, 8);
      expect(config.soulPriceCurveExponent, 1.3);
    });

    test('default constructor provides correct defaults', () {
      const config = EconomyConfig();

      expect(config.baseGoldPerCombat, 8);
      expect(config.eliteGoldMultiplier, 3.0);
      expect(config.shopPriceBase, 20);
      expect(config.shopPriceFloorMultiplier, 1.2);
      expect(config.soulBaseGain, 8);
      expect(config.soulPriceCurveExponent, 1.3);
      expect(config.bossGoldMultiplier, 3.0);
    });

    // === Story 3-8: 보스 경제 설정 ===

    test('fromJson parses bossGoldMultiplier', () {
      final config = EconomyConfig.fromJson({
        'base_gold_per_combat': 10,
        'boss_gold_multiplier': 3.0,
      });

      expect(config.bossGoldMultiplier, 3.0);
    });
  });

  group('MysteryConfig', () {
    test('fromJson parses valid config and uses defaults on missing section', () {
      // JSON 파싱 확인
      final config = MysteryConfig.fromJson({
        'treasure_gold': 25,
        'trap_hp_loss': 10,
        'combat_gold': 12,
        'event_gold': 8,
        'minor_gold': 2,
        'weight_treasure': 10,
        'weight_trap': 25,
        'weight_combat': 35,
        'weight_event': 10,
        'weight_minor': 20,
      });

      expect(config.treasureGold, 25);
      expect(config.trapHpLoss, 10);
      expect(config.combatGold, 12);
      expect(config.eventGold, 8);
      expect(config.minorGold, 2);
      expect(config.weightTreasure, 10);
      expect(config.weightTrap, 25);
      expect(config.weightCombat, 35);
      expect(config.weightEvent, 10);
      expect(config.weightMinor, 20);

      // BalanceConfig에서 mystery 섹션 누락 시 기본값 사용
      final balanceConfig = BalanceConfig.fromJson({
        'schema_version': 2,
      });
      expect(balanceConfig.mystery.treasureGold, 15);
      expect(balanceConfig.mystery.trapHpLoss, 20);
      expect(balanceConfig.mystery.weightCombat, 30);
    });
  });

  group('NpcConfig', () {
    test('fromJson parses valid config and uses defaults on missing section', () {
      // JSON 파싱 확인
      final config = NpcConfig.fromJson({
        'weight_trader': 50,
        'weight_sage': 25,
        'weight_wanderer': 25,
        'trade_item_count': 3,
        'dialogue_gold_reward': 10,
      });

      expect(config.npcWeightTrader, 50);
      expect(config.npcWeightSage, 25);
      expect(config.npcWeightWanderer, 25);
      expect(config.npcTradeItemCount, 3);
      expect(config.npcDialogueGoldReward, 10);

      // BalanceConfig에서 npc 섹션 누락 시 기본값 사용
      final balanceConfig = BalanceConfig.fromJson({
        'schema_version': 2,
      });
      expect(balanceConfig.npc.npcWeightTrader, 40);
      expect(balanceConfig.npc.npcWeightSage, 30);
      expect(balanceConfig.npc.npcWeightWanderer, 30);
      expect(balanceConfig.npc.npcTradeItemCount, 2);
      expect(balanceConfig.npc.npcDialogueGoldReward, 14);
    });
  });

  group('RestConfig', () {
    test('fromJson parses valid config and uses defaults on missing section', () {
      // JSON 파싱 확인
      final config = RestConfig.fromJson({
        'hp_recovery_percent': 0.5,
        'max_hp_increase': 15,
      });

      expect(config.hpRecoveryPercent, 0.5);
      expect(config.maxHpIncrease, 15);

      // 기본값 확인
      const defaultConfig = RestConfig();
      expect(defaultConfig.hpRecoveryPercent, 0.15);
      expect(defaultConfig.maxHpIncrease, 3);

      // BalanceConfig에서 rest 섹션 누락 시 기본값 사용
      final balanceConfig = BalanceConfig.fromJson({
        'schema_version': 2,
      });
      expect(balanceConfig.rest.hpRecoveryPercent, 0.15);
      expect(balanceConfig.rest.maxHpIncrease, 3);
    });

    test('fromJson clamps out-of-range values to fallback', () {
      // hpRecoveryPercent 범위 밖 → fallback 0.15
      final overPercent = RestConfig.fromJson({
        'hp_recovery_percent': 1.5,
        'max_hp_increase': 3,
      });
      expect(overPercent.hpRecoveryPercent, 0.15);

      final negativePercent = RestConfig.fromJson({
        'hp_recovery_percent': -0.5,
        'max_hp_increase': 3,
      });
      expect(negativePercent.hpRecoveryPercent, 0.15);

      // maxHpIncrease 범위 밖 → fallback 3
      final negativeIncrease = RestConfig.fromJson({
        'hp_recovery_percent': 0.15,
        'max_hp_increase': -5,
      });
      expect(negativeIncrease.maxHpIncrease, 3);

      // 잘못된 타입 → 기본값 폴백
      final invalidType = RestConfig.fromJson({
        'hp_recovery_percent': 'invalid',
        'max_hp_increase': 'bad',
      });
      expect(invalidType.hpRecoveryPercent, 0.15);
      expect(invalidType.maxHpIncrease, 3);
    });
  });

  group('EventConfig', () {
    test('fromJson parses valid config and uses defaults on missing section', () {
      // JSON 파싱 확인
      final config = EventConfig.fromJson({
        'gold_reward': 15,
        'hp_reward': 20,
        'hp_penalty': 8,
      });

      expect(config.goldReward, 15);
      expect(config.hpReward, 20);
      expect(config.hpPenalty, 8);

      // BalanceConfig에서 event 섹션 누락 시 기본값 사용
      final balanceConfig = BalanceConfig.fromJson({
        'schema_version': 2,
      });
      expect(balanceConfig.event.goldReward, 10);
      expect(balanceConfig.event.hpReward, 7);
      expect(balanceConfig.event.hpPenalty, 5);
    });

    test('fromJson uses defaults for missing or invalid fields', () {
      // 필드 누락 시 기본값 폴백
      final missing = EventConfig.fromJson({});
      expect(missing.goldReward, 10);
      expect(missing.hpReward, 7);
      expect(missing.hpPenalty, 5);

      // 범위 밖 값 → 기본값 폴백
      final outOfRange = EventConfig.fromJson({
        'gold_reward': -5,
        'hp_reward': 'invalid',
        'hp_penalty': -1,
      });
      expect(outOfRange.goldReward, 10);
      expect(outOfRange.hpReward, 7);
      expect(outOfRange.hpPenalty, 5);
    });
  });

  group('BuildConfig', () {
    test('fromJson uses defaults for missing fields', () {
      final config = BuildConfig.fromJson({});

      expect(config.wandererMinTotal, 10);
      expect(config.wandererMaxDeviation, 2);
    });

    test('fromJson parses custom values', () {
      final config = BuildConfig.fromJson({
        'wanderer_min_total': 15,
        'wanderer_max_deviation': 3,
      });

      expect(config.wandererMinTotal, 15);
      expect(config.wandererMaxDeviation, 3);
    });

    test('fromJson clamps out-of-range values to defaults', () {
      final config = BuildConfig.fromJson({
        'wanderer_min_total': -5,
        'wanderer_max_deviation': 999,
      });

      // clampInt returns fallback (not clamped edge) for out-of-range
      expect(config.wandererMinTotal, 10);
      expect(config.wandererMaxDeviation, 2);
    });
  });

  group('BalanceConfig dungeon fallback', () {
    test('fromJson returns default DungeonBalanceConfig when dungeon key is missing', () {
      final config = BalanceConfig.fromJson({
        'schema_version': 2,
        'text': {
          'chars_per_second_slow': 20,
          'chars_per_second_normal': 40,
          'chars_per_second_fast': 80,
        },
      });

      expect(config.dungeon.roomsPerFloor, 20);
      expect(config.dungeon.branchFactorMin, 2);
      expect(config.dungeon.branchFactorMax, 4);
      expect(config.dungeon.eliteMin, 1);
      expect(config.dungeon.eliteMax, 2);
      expect(config.dungeon.eliteMinDepth, 3);
    });
  });
}

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"schema_version":1,"text":{"chars_per_second_slow":20,"chars_per_second_normal":40,"chars_per_second_fast":80}}';
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

class TestAssetBundleV2 extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"schema_version":2,"text":{"chars_per_second_slow":20,"chars_per_second_normal":40,"chars_per_second_fast":80},"momentum":{"initial_value":0,"min":0,"max":100,"action_switch_bonus":15,"same_action_penalty":-10,"same_action_streak_penalty":-20,"environment_momentum_bonus":25,"thresholds":{"low":30,"medium":60,"high":80}},"combat":{"base_player_hp":100,"boss_hp_multiplier":2.5,"elite_hp_multiplier":1.5,"momentum_carryover_ratio":0.5,"normal_turn_count":3,"elite_turn_count":5,"elite_victory_threshold":1,"normal_defeat_hp_loss":30,"elite_defeat_hp_loss":50},"economy":{"base_gold_per_combat":10,"elite_gold_multiplier":2.0,"shop_price_base":15,"shop_price_floor_multiplier":1.15,"soul_base_gain":5,"soul_price_curve_exponent":1.5}}';
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

class InvalidAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return 'not valid json';
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}
