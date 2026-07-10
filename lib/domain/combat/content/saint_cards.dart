import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 성자 카드 — 철벽 지구전. 블록 + 응보. 시작 5장 + 보상 3장 = 8장.
class SaintCards {
  SaintCards._();

  /// 신성 일격 — 1AP, 8 데미지 + 4 블록. 시작.
  static const divineStrike = CardData(
    id: 'saint_divine_strike',
    name: '신성 일격',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 1,
    damage: 8,
    block: 4,
    description: '8 데미지 + 4 블록',
  );

  /// 치유 — 1AP, 12 회복. 소진. 시작.
  static const heal = CardData(
    id: 'saint_heal',
    name: '치유',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 1,
    description: '12 회복. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.heal, value: 12)],
  );

  /// 기도 — 0AP, 8 블록 + 1장 드로우. 시작.
  static const prayer = CardData(
    id: 'saint_prayer',
    name: '기도',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 0,
    block: 8,
    description: '8 블록 + 1장 드로우',
    effects: [CardEffect(type: CardEffectType.draw, value: 1)],
  );

  /// 성벽 — 2AP, 15 블록. 시작.
  static const holyWall = CardData(
    id: 'saint_holy_wall',
    name: '성벽',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 2,
    block: 15,
    description: '15 블록',
  );

  /// 신성 보호막 — 2AP, 파워: 매 턴 시작 시 3 블록. 시작.
  static const divineShield = CardData(
    id: 'saint_divine_shield',
    name: '신성 보호막',
    jobId: 'saint',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 시작 시 3 블록',
    effects: [CardEffect(type: CardEffectType.blockPerTurnStart, value: 3)],
  );

  /// 정화 — 1AP, 모든 디버프 제거 + 8 회복. 소진. 보상.
  static const purify = CardData(
    id: 'saint_purify',
    name: '정화',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 1,
    description: '모든 디버프 제거 + 8 회복. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.cleanse, value: 1),
      CardEffect(type: CardEffectType.heal, value: 8),
    ],
  );

  /// 응보 — 1AP, 현재 블록만큼 데미지 + 초과 데미지의 20% HP 회복. 보상.
  static const retribution = CardData(
    id: 'saint_retribution',
    name: '응보',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 1,
    description: '현재 블록만큼 데미지 + 초과 데미지의 20% HP 회복',
    effects: [
      CardEffect(type: CardEffectType.retribution, value: 100),
      CardEffect(type: CardEffectType.excessDamageLifesteal, value: 20),
    ],
  );

  /// 재생의 빛 — 2AP, 파워: 재생 3 (10턴). 보상.
  static const lightOfRegeneration = CardData(
    id: 'saint_light_of_regeneration',
    name: '재생의 빛',
    jobId: 'saint',
    type: CardType.power,
    apCost: 2,
    description: '재생 3 (10턴)',
    effects: [CardEffect(type: CardEffectType.gainRegenerate, value: 3, duration: 10)],
  );

  /// 심판 — 2AP, 현재 HP의 25% 데미지 (관통). 적 HP ≤30% 즉사. 소진. 보상.
  static const judgment = CardData(
    id: 'saint_judgment',
    name: '심판',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 2,
    description: '현재 HP의 25% 데미지 (관통). 적 HP ≤30% 즉사. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.hpPercentDamage, value: 25),
      CardEffect(type: CardEffectType.ignoreBlock, value: 0),
      CardEffect(type: CardEffectType.executeHpPercent, value: 30),
    ],
  );

  /// 신성 방벽 — 1AP, 블록 6 + 재생 1 (3턴). 보상.
  static const divineBarrier = CardData(
    id: 'saint_divine_barrier',
    name: '신성 방벽',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '블록 6 + 재생 1 (3턴)',
    effects: [CardEffect(type: CardEffectType.gainRegenerate, value: 1, duration: 3)],
  );

  /// 성스러운 빛 — 1AP, 10 데미지 + HP 5 회복. 보상.
  static const holyLight = CardData(
    id: 'saint_holy_light',
    name: '성스러운 빛',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: '10 데미지 + HP 5 회복',
    effects: [CardEffect(type: CardEffectType.heal, value: 5)],
  );

  /// 축복의 갑옷 — 2AP, 파워: 매 턴 HP 3 회복. 보상.
  static const blessedArmor = CardData(
    id: 'saint_blessed_armor',
    name: '축복의 갑옷',
    jobId: 'saint',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 HP 3 회복',
    effects: [CardEffect(type: CardEffectType.healPerTurn, value: 3)],
  );

  /// 천벌 — 3AP, 25 데미지 + 약화 2턴 + 취약 1턴. 보상.
  static const divinePunishment = CardData(
    id: 'saint_divine_punishment',
    name: '천벌',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 3,
    damage: 25,
    description: '25 데미지 + 약화 2턴 + 취약 1턴',
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 2),
      CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 1),
    ],
  );

  /// 헌신 — 0AP, HP -8, 2장 드로우. 소진. 보상.
  static const devotion = CardData(
    id: 'saint_devotion',
    name: '헌신',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 0,
    description: 'HP -8, 2장 드로우. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 8),
      CardEffect(type: CardEffectType.draw, value: 2),
    ],
  );

  /// 시작 카드 5장 (공통 제외, 성자 전용).
  static const List<CardData> starter = [
    divineStrike,
    heal,
    prayer,
    holyWall,
    divineShield,
  ];

  /// 보상 카드 9장.
  static const List<CardData> rewards = [
    purify,
    retribution,
    lightOfRegeneration,
    judgment,
    divineBarrier,
    holyLight,
    blessedArmor,
    divinePunishment,
    devotion,
  ];

  /// 전체 14장.
  static const List<CardData> all = [
    divineStrike,
    heal,
    prayer,
    holyWall,
    divineShield,
    purify,
    retribution,
    lightOfRegeneration,
    judgment,
    divineBarrier,
    holyLight,
    blessedArmor,
    divinePunishment,
    devotion,
  ];

  // ── 업그레이드 버전 ──

  /// 신성 일격+ — 1AP, 12 데미지 + 6 블록.
  static const divineStrikePlus = CardData(
    id: 'saint_divine_strike+',
    name: '신성 일격+',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    block: 6,
    description: '12 데미지 + 6 블록',
    upgraded: true,
  );

  /// 치유+ — 1AP, 18 회복. 소진.
  static const healPlus = CardData(
    id: 'saint_heal+',
    name: '치유+',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 1,
    description: '18 회복. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.heal, value: 18)],
  );

  /// 기도+ — 0AP, 12 블록 + 1장 드로우.
  static const prayerPlus = CardData(
    id: 'saint_prayer+',
    name: '기도+',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 0,
    block: 12,
    description: '12 블록 + 1장 드로우',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.draw, value: 1)],
  );

  /// 성벽+ — 2AP, 20 블록.
  static const holyWallPlus = CardData(
    id: 'saint_holy_wall+',
    name: '성벽+',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 2,
    block: 20,
    description: '20 블록',
    upgraded: true,
  );

  /// 신성 보호막+ — 2AP, 파워: 매 턴 시작 시 5 블록.
  static const divineShieldPlus = CardData(
    id: 'saint_divine_shield+',
    name: '신성 보호막+',
    jobId: 'saint',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 시작 시 5 블록',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockPerTurnStart, value: 5)],
  );

  /// 정화+ — 1AP, 모든 디버프 제거 + 12 회복. 소진.
  static const purifyPlus = CardData(
    id: 'saint_purify+',
    name: '정화+',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 1,
    description: '모든 디버프 제거 + 12 회복. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.cleanse, value: 1),
      CardEffect(type: CardEffectType.heal, value: 12),
    ],
  );

  /// 응보+ — 1AP, 현재 블록 × 150% 데미지 + 초과 데미지의 25% HP 회복.
  static const retributionPlus = CardData(
    id: 'saint_retribution+',
    name: '응보+',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 1,
    description: '현재 블록 × 150% 데미지 + 초과 데미지의 25% HP 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.retribution, value: 150),
      CardEffect(type: CardEffectType.excessDamageLifesteal, value: 25),
    ],
  );

  /// 재생의 빛+ — 2AP, 파워: 재생 5 (영구).
  static const lightOfRegenerationPlus = CardData(
    id: 'saint_light_of_regeneration+',
    name: '재생의 빛+',
    jobId: 'saint',
    type: CardType.power,
    apCost: 2,
    description: '재생 5 (12턴)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainRegenerate, value: 5, duration: 12)],
  );

  /// 심판+ — 2AP, 현재 HP의 30% 데미지 (관통). 적 HP ≤35% 즉사. 소진.
  static const judgmentPlus = CardData(
    id: 'saint_judgment+',
    name: '심판+',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 2,
    description: '현재 HP의 30% 데미지 (관통). 적 HP ≤35% 즉사. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.hpPercentDamage, value: 30),
      CardEffect(type: CardEffectType.ignoreBlock, value: 0),
      CardEffect(type: CardEffectType.executeHpPercent, value: 35),
    ],
  );

  /// 신성 방벽+ — 1AP, 블록 9 + 재생 2 (3턴).
  static const divineBarrierPlus = CardData(
    id: 'saint_divine_barrier+',
    name: '신성 방벽+',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 1,
    block: 9,
    description: '블록 9 + 재생 2 (3턴)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainRegenerate, value: 2, duration: 3)],
  );

  /// 성스러운 빛+ — 1AP, 14 데미지 + HP 7 회복.
  static const holyLightPlus = CardData(
    id: 'saint_holy_light+',
    name: '성스러운 빛+',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 1,
    damage: 14,
    description: '14 데미지 + HP 7 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.heal, value: 7)],
  );

  /// 축복의 갑옷+ — 2AP, 파워: 매 턴 HP 5 회복.
  static const blessedArmorPlus = CardData(
    id: 'saint_blessed_armor+',
    name: '축복의 갑옷+',
    jobId: 'saint',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 HP 5 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.healPerTurn, value: 5)],
  );

  /// 천벌+ — 3AP, 35 데미지 + 약화 3턴 + 취약 1턴.
  static const divinePunishmentPlus = CardData(
    id: 'saint_divine_punishment+',
    name: '천벌+',
    jobId: 'saint',
    type: CardType.attack,
    apCost: 3,
    damage: 35,
    description: '35 데미지 + 약화 3턴 + 취약 1턴',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 3),
      CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 1),
    ],
  );

  /// 헌신+ — 0AP, HP -5, 3장 드로우. 소진.
  static const devotionPlus = CardData(
    id: 'saint_devotion+',
    name: '헌신+',
    jobId: 'saint',
    type: CardType.skill,
    apCost: 0,
    description: 'HP -5, 3장 드로우. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 5),
      CardEffect(type: CardEffectType.draw, value: 3),
    ],
  );
}
