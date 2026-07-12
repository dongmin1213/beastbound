import 'package:soul_dungeon/core/models/card_relic_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 카드 전투 유물 풀 — DESIGN.md §8 기반 20종.
class CardRelicPool {
  CardRelicPool._();

  /// 1. 핏빛 반지 — 전투 시작: 힘 +2.
  static const bloodRing = CardRelicData(
    id: 'cr_blood_ring',
    name: '핏빛 반지',
    description: '전투 시작 시 힘 +2',
    rarity: Rarity.rare,
    trigger: RelicTrigger.combatStart,
    effectType: 'gainStrength',
    effectValue: 2,
  );

  /// 2. 마력석 — 매 턴 시작: 1장 추가 드로우.
  static const magicStone = CardRelicData(
    id: 'cr_magic_stone',
    name: '마력석',
    description: '매 턴 시작 시 1장 추가 드로우',
    rarity: Rarity.rare,
    trigger: RelicTrigger.turnStart,
    effectType: 'bonusDraw',
    effectValue: 1,
  );

  /// 3. 가시 방패 — 블록 10+ 보유 시: 가시 2.
  static const thornShield = CardRelicData(
    id: 'cr_thorn_shield',
    name: '가시 방패',
    description: '블록 10+ 보유 시 가시 2',
    rarity: Rarity.rare,
    trigger: RelicTrigger.onBlock,
    effectType: 'thornOnBlock',
    effectValue: 2,
    conditionValue: 10,
  );

  /// 4. 독약병 — 전투 시작: 독 항아리 카드 손패에 추가.
  static const poisonVial = CardRelicData(
    id: 'cr_poison_vial',
    name: '독약병',
    description: '전투 시작 시 독 항아리 카드 손패에 추가',
    rarity: Rarity.rare,
    trigger: RelicTrigger.combatStart,
    effectType: 'addPoisonJar',
    effectValue: 1,
  );

  /// 5. 바람의 부적 — 도망 시도: 성공률 +30%.
  static const windAmulet = CardRelicData(
    id: 'cr_wind_amulet',
    name: '바람의 부적',
    description: '도망 시도 시 성공률 +30%',
    rarity: Rarity.common,
    trigger: RelicTrigger.onFlee,
    effectType: 'fleeBonus',
    effectValue: 30,
  );

  /// 6. 영혼석 — 적 처치 시: HP 5 회복.
  static const soulStone = CardRelicData(
    id: 'cr_soul_stone',
    name: '영혼석',
    description: '적 처치 시 HP 5 회복',
    rarity: Rarity.rare,
    trigger: RelicTrigger.onKill,
    effectType: 'healOnKill',
    effectValue: 5,
  );

  /// 7. 파괴의 망치 — 야성 High 진입: 다음 Attack 데미지 +8.
  static const destructionHammer = CardRelicData(
    id: 'cr_destruction_hammer',
    name: '파괴의 망치',
    description: '야성 High 진입 시 다음 Attack 데미지 +8',
    rarity: Rarity.legendary,
    trigger: RelicTrigger.onMomentumHigh,
    effectType: 'bonusAttackDamage',
    effectValue: 8,
  );

  /// 8. 거울 조각 — 턴 시작: 10% 확률로 손패 1장 복사.
  static const mirrorShard = CardRelicData(
    id: 'cr_mirror_shard',
    name: '거울 조각',
    description: '턴 시작 시 20% 확률로 손패 1장 복사',
    rarity: Rarity.legendary,
    trigger: RelicTrigger.turnStart,
    effectType: 'mirrorCopy',
    effectValue: 1,
    conditionValue: 20,
  );

  // ── 추가 Rare (7종) ──

  /// 9. 화염의 반지 — 모든 Attack에 화상 1 추가.
  static const flameRing = CardRelicData(
    id: 'cr_flame_ring',
    name: '화염의 반지',
    description: '모든 Attack에 화상 1 추가',
    rarity: Rarity.rare,
    trigger: RelicTrigger.onAttack,
    effectType: 'addBurnOnAttack',
    effectValue: 1,
  );

  /// 10. 얼음 수정 — 매 턴 적 1체 약화 1턴.
  static const iceCrystal = CardRelicData(
    id: 'cr_ice_crystal',
    name: '얼음 수정',
    description: '매 턴 적 1체 약화 1턴',
    rarity: Rarity.rare,
    trigger: RelicTrigger.turnStart,
    effectType: 'weakenEnemyPerTurn',
    effectValue: 1,
  );

  /// 11. 치유의 펜던트 — 매 턴 HP 2 회복.
  static const healingPendant = CardRelicData(
    id: 'cr_healing_pendant',
    name: '치유의 펜던트',
    description: '매 턴 HP 2 회복',
    rarity: Rarity.rare,
    trigger: RelicTrigger.turnStart,
    effectType: 'healPerTurn',
    effectValue: 2,
  );

  /// 12. 카드 주머니 — 전투 시작 시 랜덤 무색 카드 1장 추가.
  static const cardBag = CardRelicData(
    id: 'cr_card_bag',
    name: '카드 주머니',
    description: '전투 시작 시 랜덤 무색 카드 1장 추가',
    rarity: Rarity.rare,
    trigger: RelicTrigger.combatStart,
    effectType: 'addRandomCard',
    effectValue: 1,
  );

  /// 13. 행운의 금화 — 전투 승리 시 골드 +8.
  static const luckyCoin = CardRelicData(
    id: 'cr_lucky_coin',
    name: '행운의 금화',
    description: '전투 승리 시 골드 +8',
    rarity: Rarity.common,
    trigger: RelicTrigger.onKill,
    effectType: 'bonusGold',
    effectValue: 8,
  );

  /// 14. 가시 팔찌 — 가시 1 (영구).
  static const thornBracelet = CardRelicData(
    id: 'cr_thorn_bracelet',
    name: '가시 팔찌',
    description: '가시 1 (영구)',
    rarity: Rarity.common,
    trigger: RelicTrigger.combatStart,
    effectType: 'addThorn',
    effectValue: 1,
  );

  /// 15. 야성의 보석 — 전투 시작 시 야성 +10.
  static const momentumGem = CardRelicData(
    id: 'cr_momentum_gem',
    name: '야성의 보석',
    description: '전투 시작 시 야성 +10',
    rarity: Rarity.rare,
    trigger: RelicTrigger.combatStart,
    effectType: 'momentumBonus',
    effectValue: 10,
  );

  // ── 추가 Legendary (5종) ──

  /// 16. 시간의 모래시계 — 5턴마다 AP +1.
  static const timeHourglass = CardRelicData(
    id: 'cr_time_hourglass',
    name: '시간의 모래시계',
    description: '5턴마다 AP +1',
    rarity: Rarity.legendary,
    trigger: RelicTrigger.turnStart,
    effectType: 'periodicApBonus',
    effectValue: 1,
    conditionValue: 5,
  );

  /// 17. 불사조 날개 — HP 0 시 1회 부활 (HP 10% 회복).
  static const phoenixFeather = CardRelicData(
    id: 'cr_phoenix_feather',
    name: '불사조 날개',
    description: 'HP 0 시 1회 부활 (HP 10% 회복)',
    rarity: Rarity.legendary,
    trigger: RelicTrigger.onHit,
    effectType: 'reviveOnce',
    effectValue: 10,
  );

  /// 18. 공허의 조각 — 소진 카드 5장마다 모든 적 10 데미지.
  static const voidShard = CardRelicData(
    id: 'cr_void_shard',
    name: '공허의 조각',
    description: '소진 카드 5장마다 모든 적 10 데미지',
    rarity: Rarity.legendary,
    trigger: RelicTrigger.passive,
    effectType: 'exhaustDamage',
    effectValue: 10,
    conditionValue: 5,
  );

  /// 19. 고대의 왕관 — 전투 시작 시 힘+2, 민첩+2.
  static const ancientCrown = CardRelicData(
    id: 'cr_ancient_crown',
    name: '고대의 왕관',
    description: '전투 시작 시 힘+2, 민첩+2',
    rarity: Rarity.legendary,
    trigger: RelicTrigger.combatStart,
    effectType: 'doubleStatBonus',
    effectValue: 2,
  );

  /// 20. 저주받은 검 — 힘+4, 매 턴 HP -2.
  static const cursedBlade = CardRelicData(
    id: 'cr_cursed_blade',
    name: '저주받은 검',
    description: '힘+4, 매 턴 HP -2',
    rarity: Rarity.legendary,
    trigger: RelicTrigger.combatStart,
    effectType: 'strengthWithHpCost',
    effectValue: 4,
    conditionValue: 2,
  );

  /// 전체 20종.
  static const List<CardRelicData> all = [
    bloodRing,
    magicStone,
    thornShield,
    poisonVial,
    windAmulet,
    soulStone,
    destructionHammer,
    mirrorShard,
    flameRing,
    iceCrystal,
    healingPendant,
    cardBag,
    luckyCoin,
    thornBracelet,
    momentumGem,
    timeHourglass,
    phoenixFeather,
    voidShard,
    ancientCrown,
    cursedBlade,
  ];

  /// ID 목록 → CardRelicData 목록 (존재하는 것만).
  static List<CardRelicData> resolveIds(List<String> ids) {
    return ids.map(findById).whereType<CardRelicData>().toList();
  }

  /// ID로 조회.
  static CardRelicData? findById(String id) {
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }
}
