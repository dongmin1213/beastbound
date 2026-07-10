import 'package:soul_dungeon/domain/progression/soul/soul_upgrade_data.dart';

/// 소울 업그레이드 풀 — 사용 가능한 전체 업그레이드 목록.
class SoulUpgradePool {
  SoulUpgradePool._();

  static const List<SoulUpgradeData> all = [
    // ── 덱 강화 ──
    SoulUpgradeData(
      id: 'soul_starting_deck_upgrade',
      name: '단련된 검',
      description: '시작 덱의 기본 카드가 강화됩니다.',
      basePrice: 30,
      maxLevel: 1,
      effectType: SoulUpgradeEffect.startingDeckUpgrade,
    ),

    // ── 생존력 ──
    SoulUpgradeData(
      id: 'soul_max_hp_1',
      name: '강인한 육체 I',
      description: '최대 HP +8',
      basePrice: 20,
      maxLevel: 3,
      priceExponent: 1.3,
      effectType: SoulUpgradeEffect.maxHpBonus,
    ),

    // ── 경제 ──
    SoulUpgradeData(
      id: 'soul_starting_gold',
      name: '숨겨진 노자',
      description: '시작 골드 +20',
      basePrice: 25,
      maxLevel: 2,
      priceExponent: 1.3,
      effectType: SoulUpgradeEffect.startingGoldBonus,
    ),

    // ── 카드 해금 ──
    SoulUpgradeData(
      id: 'soul_unlock_card_whirlwind',
      name: '소용돌이 해금',
      description: '카드 보상에 "소용돌이" 등장 가능.',
      basePrice: 40,
      maxLevel: 1,
      effectType: SoulUpgradeEffect.unlockCard,
      unlockedCardId: 'whirlwind',
    ),
    SoulUpgradeData(
      id: 'soul_unlock_card_meditation',
      name: '명상 해금',
      description: '카드 보상에 "명상" 등장 가능.',
      basePrice: 40,
      maxLevel: 1,
      effectType: SoulUpgradeEffect.unlockCard,
      unlockedCardId: 'meditation',
    ),

    // ── 소울 획득 ──
    SoulUpgradeData(
      id: 'soul_gain_boost',
      name: '영혼 친화',
      description: '소울 획득량 +20%',
      basePrice: 40,
      maxLevel: 2,
      priceExponent: 1.3,
      effectType: SoulUpgradeEffect.soulGainMultiplier,
    ),

    // ── 상점 ──
    SoulUpgradeData(
      id: 'soul_shop_discount',
      name: '단골 손님',
      description: '상점 가격 15% 할인.',
      basePrice: 35,
      maxLevel: 2,
      priceExponent: 1.3,
      effectType: SoulUpgradeEffect.shopDiscount,
    ),

    // ── 추가 HP ──
    SoulUpgradeData(
      id: 'soul_max_hp_2',
      name: '강인한 육체 II',
      description: '최대 HP +12 (강인한 육체 I 완료 후 해금)',
      basePrice: 60,
      maxLevel: 1,
      effectType: SoulUpgradeEffect.maxHpBonus,
    ),

    // ── 신규: 시작 모멘텀 ──
    SoulUpgradeData(
      id: 'soul_starting_momentum',
      name: '전투의 감각',
      description: '전투 시작 모멘텀 +10',
      basePrice: 30,
      maxLevel: 2,
      priceExponent: 1.3,
      effectType: SoulUpgradeEffect.startingMomentum,
    ),

    // ── 신규: 엘리트 보상 ──
    SoulUpgradeData(
      id: 'soul_elite_reward',
      name: '현상금 사냥꾼',
      description: '엘리트 처치 골드 보상 +30%',
      basePrice: 35,
      maxLevel: 2,
      priceExponent: 1.3,
      effectType: SoulUpgradeEffect.eliteRewardBonus,
    ),

    // ── 신규: 무료 카드 제거 ──
    SoulUpgradeData(
      id: 'soul_free_card_removal',
      name: '덱 정리술',
      description: '층당 1회 무료 카드 제거.',
      basePrice: 50,
      maxLevel: 1,
      effectType: SoulUpgradeEffect.freeCardRemoval,
    ),

    // ── 신규: 휴식 회복 ──
    SoulUpgradeData(
      id: 'soul_rest_heal',
      name: '깊은 휴식',
      description: '휴식 회복량 +5%',
      basePrice: 25,
      maxLevel: 2,
      priceExponent: 1.3,
      effectType: SoulUpgradeEffect.restHealBonus,
    ),
  ];

  /// 현재 구매 가능한 업그레이드 — maxLevel 미도달 + 선행 조건 충족.
  static List<SoulUpgradeData> available(Map<String, int> upgradeLevels) {
    return all.where((upgrade) {
      final currentLevel = upgradeLevels[upgrade.id] ?? 0;
      if (currentLevel >= upgrade.maxLevel) return false;

      // 선행 조건: soul_max_hp_2는 soul_max_hp_1이 maxLevel이어야 해금
      if (upgrade.id == 'soul_max_hp_2') {
        final hp1Level = upgradeLevels['soul_max_hp_1'] ?? 0;
        if (hp1Level < 3) return false;
      }

      return true;
    }).toList();
  }

  /// ID로 업그레이드 데이터 검색.
  static SoulUpgradeData? byId(String id) {
    for (final upgrade in all) {
      if (upgrade.id == id) return upgrade;
    }
    return null;
  }

  /// 업그레이드 레벨에서 런 시작 보너스 계산.
  static ({int hpBonus, int goldBonus, int momentumBonus}) startingBonuses(
      Map<String, int> levels) {
    int hpBonus = 0;
    int goldBonus = 0;
    int momentumBonus = 0;

    // soul_max_hp_1: 레벨당 +8 HP (기존 +5에서 상향)
    hpBonus += (levels['soul_max_hp_1'] ?? 0) * 8;
    // soul_max_hp_2: +12 HP (기존 +10에서 상향)
    hpBonus += (levels['soul_max_hp_2'] ?? 0) * 12;
    // soul_starting_gold: 레벨당 +20 골드 (기존 +15에서 상향)
    goldBonus += (levels['soul_starting_gold'] ?? 0) * 20;
    // soul_starting_momentum: 레벨당 +10 모멘텀
    momentumBonus += (levels['soul_starting_momentum'] ?? 0) * 10;

    return (hpBonus: hpBonus, goldBonus: goldBonus, momentumBonus: momentumBonus);
  }

  /// 소울 획득량 배율 (soul_gain_boost 반영).
  static double soulGainMultiplier(Map<String, int> levels) {
    final level = levels['soul_gain_boost'] ?? 0;
    return 1.0 + level * 0.2; // +20% per level
  }

  /// 상점 할인율 (soul_shop_discount 반영).
  static double shopDiscountRate(Map<String, int> levels) {
    final level = levels['soul_shop_discount'] ?? 0;
    return level * 0.15; // 15% per level (기존 10%에서 상향)
  }

  /// 엘리트 보상 배율 (soul_elite_reward 반영).
  static double eliteRewardMultiplier(Map<String, int> levels) {
    final level = levels['soul_elite_reward'] ?? 0;
    return 1.0 + level * 0.3; // +30% per level
  }

  /// 무료 카드 제거 보유 여부.
  static bool hasFreeCardRemoval(Map<String, int> levels) {
    return (levels['soul_free_card_removal'] ?? 0) >= 1;
  }

  /// 휴식 추가 회복률.
  static double restHealBonusRate(Map<String, int> levels) {
    final level = levels['soul_rest_heal'] ?? 0;
    return level * 0.05; // +5% per level
  }
}
