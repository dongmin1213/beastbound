import 'dart:math';

import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 희귀도 4단계 보상 풀 — 가중치 기반 희귀도 결정 유틸리티.
///
/// 모든 보상 시스템(상점, NPC, 이벤트, 전투 드롭)에서 공용 사용.
/// RarityConfig의 가중치를 기반으로 결정론적(시드) 또는 비결정론적 희귀도 생성.
class RewardPool {
  RewardPool._();

  /// RarityConfig 가중치 기반으로 희귀도 결정.
  ///
  /// 가중치 합계 기준 누적 확률로 계산.
  /// [rng]: 외부 Random 인스턴스 (시드 결정론적 생성 지원).
  static Rarity rollRarity(RarityConfig config, Random rng) {
    final total = config.totalWeight;
    if (total <= 0) return Rarity.common;

    final roll = rng.nextInt(total);
    var cumulative = 0;

    cumulative += config.weightCommon;
    if (roll < cumulative) return Rarity.common;

    cumulative += config.weightRare;
    if (roll < cumulative) return Rarity.rare;

    cumulative += config.weightLegendary;
    if (roll < cumulative) return Rarity.legendary;

    return Rarity.cursed;
  }

  /// 희귀도에 따른 가격 배율 반환.
  static double getPriceMultiplier(RarityConfig config, Rarity rarity) {
    return switch (rarity) {
      Rarity.common => config.priceMultiplierCommon,
      Rarity.rare => config.priceMultiplierRare,
      Rarity.legendary => config.priceMultiplierLegendary,
      Rarity.cursed => config.priceMultiplierCursed,
    };
  }

  /// 기본 가격 × 희귀도 배율 계산.
  static int calculatePrice(
      RarityConfig config, int basePrice, Rarity rarity) {
    final multiplier = getPriceMultiplier(config, rarity);
    return (basePrice * multiplier).round();
  }

  /// cursed 제외 희귀도 결정 (NPC 등 저주 아이템 미지원 컨텍스트).
  static Rarity rollRarityNoCursed(RarityConfig config, Random rng) {
    final total =
        config.weightCommon + config.weightRare + config.weightLegendary;
    if (total <= 0) return Rarity.common;

    final roll = rng.nextInt(total);
    var cumulative = 0;

    cumulative += config.weightCommon;
    if (roll < cumulative) return Rarity.common;

    cumulative += config.weightRare;
    if (roll < cumulative) return Rarity.rare;

    return Rarity.legendary;
  }
}
