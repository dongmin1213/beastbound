import 'package:soul_dungeon/domain/combat/content/environment_cards.dart';
import 'package:soul_dungeon/core/models/card_data.dart';

/// 환경 카드 결정 — 층/보스별 base + observed 버전 매핑.
class EnvironmentCardResolver {
  EnvironmentCardResolver._();

  /// 층별 일반 환경 카드 (base).
  static CardData? baseForFloor(int floor) {
    return switch (floor) {
      1 => EnvironmentCards.ceilingCollapse,
      2 => EnvironmentCards.swampMiasma,
      3 => EnvironmentCards.manaCrystal,
      4 => EnvironmentCards.altarFlame,
      5 => EnvironmentCards.abyssalRift,
      _ => null,
    };
  }

  /// 층별 일반 환경 카드 (observed/upgraded).
  static CardData? observedForFloor(int floor) {
    return switch (floor) {
      1 => EnvironmentCards.ceilingCollapsePlus,
      2 => EnvironmentCards.swampMiasmaPlus,
      3 => EnvironmentCards.manaCrystalPlus,
      4 => EnvironmentCards.altarFlamePlus,
      5 => EnvironmentCards.abyssalRiftPlus,
      _ => null,
    };
  }

  /// 보스 전용 환경 카드 (base).
  static CardData? baseForBoss(String bossId) {
    return switch (bossId) {
      'boss_slime_king' => EnvironmentCards.acidPool,
      'boss_spider_lord' => EnvironmentCards.webReversal,
      'boss_orc_general' => EnvironmentCards.trapTrigger,
      'boss_vampire_lord' => EnvironmentCards.holyWater,
      'boss_dungeon_master' => EnvironmentCards.primordialLight,
      _ => null,
    };
  }

  /// 보스 전용 환경 카드 (observed/upgraded).
  static CardData? observedForBoss(String bossId) {
    return switch (bossId) {
      'boss_slime_king' => EnvironmentCards.acidPoolPlus,
      'boss_spider_lord' => EnvironmentCards.webReversalPlus,
      'boss_orc_general' => EnvironmentCards.trapTriggerPlus,
      'boss_vampire_lord' => EnvironmentCards.holyWaterPlus,
      'boss_dungeon_master' => EnvironmentCards.primordialLightPlus,
      _ => null,
    };
  }

  /// 전투 환경 카드 결정 (보스 우선, 없으면 층별).
  static CardData? resolveBase({
    required int floor,
    String? bossId,
  }) {
    if (bossId != null) {
      return baseForBoss(bossId) ?? baseForFloor(floor);
    }
    return baseForFloor(floor);
  }

  /// 전투 환경 카드 결정 (observed 버전).
  static CardData? resolveObserved({
    required int floor,
    String? bossId,
  }) {
    if (bossId != null) {
      return observedForBoss(bossId) ?? observedForFloor(floor);
    }
    return observedForFloor(floor);
  }
}
