import 'package:soul_dungeon/core/models/card_blessing_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 카드 전투 축복 풀 — DESIGN.md §7 기반 33종.
class CardBlessingPool {
  CardBlessingPool._();

  // ── Common (8종) ──

  /// 1. 가시 — 피격 시 공격자에게 3 데미지.
  static const thorn = CardBlessingData(
    id: 'cb_thorn',
    name: '가시',
    description: '피격 시 공격자에게 5 데미지',
    rarity: Rarity.common,
    trigger: BlessingTrigger.onHit,
    effectType: 'thornDamage',
    effectValue: 5,
  );

  /// 2. 분노 — 블록 안 된 피격 시 무료 타격 손패 추가.
  static const rage = CardBlessingData(
    id: 'cb_rage',
    name: '분노',
    description: '블록 안 된 피격 시 무료 타격 손패 추가',
    rarity: Rarity.common,
    trigger: BlessingTrigger.onHit,
    effectType: 'freeStrike',
    effectValue: 1,
  );

  /// 3. 신속 — 매 턴 첫 카드 AP -1.
  static const swift = CardBlessingData(
    id: 'cb_swift',
    name: '신속',
    description: '매 턴 첫 카드 AP -1',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.onCardPlay,
    effectType: 'firstCardApDiscount',
    effectValue: 1,
  );

  /// 4. 흡혈 — 공격 데미지 12% HP 회복.
  static const leech = CardBlessingData(
    id: 'cb_leech',
    name: '흡혈',
    description: '공격 데미지 12% HP 회복',
    rarity: Rarity.common,
    trigger: BlessingTrigger.onAttack,
    effectType: 'lifeSteal',
    effectValue: 12,
  );

  /// 5. 인내 — 블록이 다음 턴에 50% 유지.
  static const patience = CardBlessingData(
    id: 'cb_patience',
    name: '인내',
    description: '블록이 다음 턴에 50% 유지',
    rarity: Rarity.common,
    trigger: BlessingTrigger.turnStart,
    effectType: 'retainBlock',
    effectValue: 50,
  );

  /// 6. 날카로움 — 힘 +1 (영구).
  static const sharp = CardBlessingData(
    id: 'cb_sharp',
    name: '날카로움',
    description: '힘 +1 (영구)',
    rarity: Rarity.common,
    trigger: BlessingTrigger.combatStart,
    effectType: 'gainStrength',
    effectValue: 1,
  );

  /// 7. 단단함 — 민첩 +1 (영구).
  static const tough = CardBlessingData(
    id: 'cb_tough',
    name: '단단함',
    description: '민첩 +1 (영구)',
    rarity: Rarity.common,
    trigger: BlessingTrigger.combatStart,
    effectType: 'gainDexterity',
    effectValue: 1,
  );

  /// 8. 빠른 발 — 매 턴 시작 시 +1 드로우.
  static const quickFeet = CardBlessingData(
    id: 'cb_quick_feet',
    name: '빠른 발',
    description: '매 턴 시작 시 +1 드로우',
    rarity: Rarity.common,
    trigger: BlessingTrigger.turnStart,
    effectType: 'bonusDraw',
    effectValue: 1,
  );

  // ── Rare (11종) ──

  /// 9. 독의 대가 — 독 데미지 2배.
  static const poisonMaster = CardBlessingData(
    id: 'cb_poison_master',
    name: '독의 대가',
    description: '독 데미지 2배',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.passive,
    effectType: 'poisonMultiplier',
    effectValue: 2,
  );

  /// 10. 잔상 — Attack 카드 25% 확률 복사본 생성.
  static const afterimage = CardBlessingData(
    id: 'cb_afterimage',
    name: '잔상',
    description: 'Attack 카드 25% 확률 복사본 생성',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.onAttack,
    effectType: 'copyAttackChance',
    effectValue: 25,
  );

  /// 11. 반사 신경 — 매 턴 시작 시 블록 3 자동 획득.
  static const reflex = CardBlessingData(
    id: 'cb_reflex',
    name: '반사 신경',
    description: '매 턴 시작 시 블록 3 자동 획득',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.turnStart,
    effectType: 'autoBlock',
    effectValue: 3,
  );

  /// 12. 집념 — 버린 카드 1장 다음 턴 손패 복귀.
  static const tenacity = CardBlessingData(
    id: 'cb_tenacity',
    name: '집념',
    description: '버린 카드 1장 다음 턴 손패 복귀',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.turnStart,
    effectType: 'retrieveDiscard',
    effectValue: 1,
  );

  /// 13. 연쇄 — 0 AP 카드 사용 시 1장 드로우.
  static const chain = CardBlessingData(
    id: 'cb_chain',
    name: '연쇄',
    description: '0 AP 카드 사용 시 1장 드로우',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.onCardPlay,
    effectType: 'zeroApDraw',
    effectValue: 1,
  );

  /// 14. 과부하 — AP +1, 매 턴 HP -5.
  static const overload = CardBlessingData(
    id: 'cb_overload',
    name: '과부하',
    description: 'AP +1, 매 턴 HP -5',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.turnStart,
    effectType: 'bonusApWithHpCost',
    effectValue: 1,
    secondaryValue: 5,
  );

  /// 15. 기세 폭발 — 기세 High 진입 시 적 15 데미지.
  static const momentumBurst = CardBlessingData(
    id: 'cb_momentum_burst',
    name: '기세 폭발',
    description: '기세 High 진입 시 적 15 데미지',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.passive,
    effectType: 'momentumHighDamage',
    effectValue: 15,
  );

  /// 16. 최적화 — 첫 턴 Innate 카드 2장 추가 드로우.
  static const optimize = CardBlessingData(
    id: 'cb_optimize',
    name: '최적화',
    description: '첫 턴 Innate 카드 2장 추가 드로우',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.combatStart,
    effectType: 'innateBonusDraw',
    effectValue: 2,
  );

  /// 23. 화염 핏줄 — 모든 Attack에 화상 2 추가.
  static const flameBlood = CardBlessingData(
    id: 'cb_flame_blood',
    name: '화염 핏줄',
    description: '모든 Attack에 화상 2 추가',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.onAttack,
    effectType: 'attackBurn',
    effectValue: 2,
  );

  /// 24. 유리대포 — 힘 +5, 최대 HP -20.
  static const glassCannon = CardBlessingData(
    id: 'cb_glass_cannon',
    name: '유리대포',
    description: '힘 +5, 최대 HP -20',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.combatStart,
    effectType: 'strengthWithHpPenalty',
    effectValue: 5,
    secondaryValue: 20,
  );

  /// 25. 시간의 모래 — 5턴마다 AP +2 (해당 턴만).
  static const sandsOfTime = CardBlessingData(
    id: 'cb_sands_of_time',
    name: '시간의 모래',
    description: '5턴마다 AP +2 (해당 턴만)',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.turnStart,
    effectType: 'periodicBonusAp',
    effectValue: 2,
    secondaryValue: 5,
  );

  // ── 추가 Rare (5종) ──

  /// 26. 흡혈귀 — 모든 Attack에 10% 흡혈.
  static const vampire = CardBlessingData(
    id: 'cb_vampire',
    name: '흡혈귀',
    description: '모든 공격·독·화상 데미지의 15% HP 회복',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.onAttack,
    effectType: 'globalLifesteal',
    effectValue: 15,
  );

  /// 27. 강철 피부 — 매 턴 시작 시 블록 5.
  static const ironSkin = CardBlessingData(
    id: 'cb_iron_skin',
    name: '강철 피부',
    description: '매 턴 시작 시 블록 5',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.turnStart,
    effectType: 'autoBlock',
    effectValue: 5,
  );

  /// 28. 기세의 달인 — 기세 변동량 +30%.
  static const momentumMaster = CardBlessingData(
    id: 'cb_momentum_master',
    name: '기세의 달인',
    description: '기세 변동량 +30%',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.passive,
    effectType: 'momentumAmplify',
    effectValue: 30,
  );

  /// 29. 카드의 달인 — 카드 사용 시 10% 확률 AP 환불.
  static const cardMaster = CardBlessingData(
    id: 'cb_card_master',
    name: '카드의 달인',
    description: '카드 사용 시 10% 확률 AP 환불',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.onCardPlay,
    effectType: 'apRefundChance',
    effectValue: 10,
  );

  /// 30. 처형인 — 적 HP 20% 이하 시 데미지 2배.
  static const executioner = CardBlessingData(
    id: 'cb_executioner',
    name: '처형인',
    description: '적 HP 20% 이하 시 데미지 2배',
    rarity: Rarity.rare,
    trigger: BlessingTrigger.onAttack,
    effectType: 'executeDamage',
    effectValue: 20,
  );

  // ── Legendary (6+3종) ──

  /// 17. 피의 계약 — 카드 업그레이드 시 비용 없음 (HP -10 대신).
  static const bloodContract = CardBlessingData(
    id: 'cb_blood_contract',
    name: '피의 계약',
    description: '카드 업그레이드 시 비용 없음 (HP -10 대신)',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.passive,
    effectType: 'freeUpgradeHpCost',
    effectValue: 10,
  );

  /// 18. 무한 순환 — 덱 셔플 시 힘 +1, 민첩 +1.
  static const infiniteCycle = CardBlessingData(
    id: 'cb_infinite_cycle',
    name: '무한 순환',
    description: '덱 셔플 시 힘 +1, 민첩 +1',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.onShuffle,
    effectType: 'shuffleBuff',
    effectValue: 1,
  );

  /// 19. 완벽한 형태 — 매 턴 AP +1. 피격 시 이 효과 2턴 소멸.
  static const perfectForm = CardBlessingData(
    id: 'cb_perfect_form',
    name: '완벽한 형태',
    description: '매 턴 AP +1. 피격 시 이 효과 2턴 소멸',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.turnStart,
    effectType: 'conditionalBonusAp',
    effectValue: 1,
    secondaryValue: 2,
  );

  /// 20. 독식 — 적 처치 시 최대 HP +1 (영구, 이번 런).
  static const devour = CardBlessingData(
    id: 'cb_devour',
    name: '독식',
    description: '적 처치 시 최대 HP +1 (영구, 이번 런)',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.onKill,
    effectType: 'maxHpOnKill',
    effectValue: 1,
  );

  /// 21. 사신의 낫 — 적 HP <5% 시 즉사.
  static const reaper = CardBlessingData(
    id: 'cb_reaper',
    name: '사신의 낫',
    description: '적 HP <5% 시 즉사',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.onAttack,
    effectType: 'executeThreshold',
    effectValue: 5,
  );

  /// 22. 에코 — 매 턴 마지막 플레이 Attack 카드를 다음 턴 손패에 복사.
  static const echo = CardBlessingData(
    id: 'cb_echo',
    name: '에코',
    description: '매 턴 마지막 플레이 Attack 카드를 다음 턴 손패에 복사',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.turnEnd,
    effectType: 'copyLastPlayed',
    effectValue: 1,
  );

  // ── 추가 Legendary (3종) ──

  /// 31. 불멸 — 치명타 시 HP 1로 생존 (1회).
  static const immortal = CardBlessingData(
    id: 'cb_immortal',
    name: '불멸',
    description: '치명타 시 HP 1로 생존 (1회)',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.onHit,
    effectType: 'surviveLethal',
    effectValue: 1,
  );

  /// 32. 양날의 검 — 모든 데미지 +50%, 받는 데미지 +25%.
  static const doubleEdge = CardBlessingData(
    id: 'cb_double_edge',
    name: '양날의 검',
    description: '모든 데미지 +50%, 받는 데미지 +25%',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.passive,
    effectType: 'damageAmplify',
    effectValue: 50,
    secondaryValue: 25,
  );

  /// 33. 영혼 수확 — 적 처치 시 랜덤 카드 1장 생성.
  static const soulHarvest = CardBlessingData(
    id: 'cb_soul_harvest',
    name: '영혼 수확',
    description: '적 처치 시 랜덤 카드 1장 생성',
    rarity: Rarity.legendary,
    trigger: BlessingTrigger.onKill,
    effectType: 'generateCardOnKill',
    effectValue: 1,
  );

  /// 전체 33종.
  static const List<CardBlessingData> all = [
    thorn, rage, swift, leech, patience, sharp, tough, quickFeet,
    poisonMaster, afterimage, reflex, tenacity, chain, overload,
    momentumBurst, optimize, flameBlood, glassCannon, sandsOfTime,
    vampire, ironSkin, momentumMaster, cardMaster, executioner,
    bloodContract, infiniteCycle, perfectForm, devour, reaper, echo,
    immortal, doubleEdge, soulHarvest,
  ];

  /// 상점 저주 아이템 ID 집합 — 전투 효과는 축복으로 처리되지만 표시는 저주.
  static const cursedIds = {
    'cb_glass_cannon',
    'cb_overload',
    'cb_blood_contract',
  };

  /// ID로 조회.
  static CardBlessingData? findById(String id) {
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// ID 목록 → CardBlessingData 목록 (존재하는 것만).
  static List<CardBlessingData> resolveIds(List<String> ids) {
    return ids.map(findById).whereType<CardBlessingData>().toList();
  }

  /// 희귀도별 조회.
  static List<CardBlessingData> byRarity(Rarity rarity) {
    return all.where((b) => b.rarity == rarity).toList();
  }
}
