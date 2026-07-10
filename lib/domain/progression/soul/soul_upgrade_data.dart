/// 소울 업그레이드 정의 — 영구 메타 강화 항목.
class SoulUpgradeData {
  final String id;
  final String name;
  final String description;
  final int basePrice;
  final int maxLevel;
  final double priceExponent;
  final SoulUpgradeEffect effectType;

  /// 효과가 카드를 해금하는 경우 해당 카드 ID.
  final String? unlockedCardId;

  const SoulUpgradeData({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.maxLevel = 1,
    this.priceExponent = 1.5,
    required this.effectType,
    this.unlockedCardId,
  });
}

/// 소울 업그레이드 효과 타입.
enum SoulUpgradeEffect {
  /// 시작 덱 강화 (Strike → Strike+).
  startingDeckUpgrade,

  /// 최대 HP 증가.
  maxHpBonus,

  /// 시작 골드 증가.
  startingGoldBonus,

  /// 카드 보상 추가 해금.
  unlockCard,

  /// 소울 획득량 증가.
  soulGainMultiplier,

  /// 상점 할인.
  shopDiscount,

  /// 시작 모멘텀 증가.
  startingMomentum,

  /// 엘리트 보상 증가.
  eliteRewardBonus,

  /// 무료 카드 제거 (층당 1회).
  freeCardRemoval,

  /// 휴식 회복량 증가.
  restHealBonus,
}
