import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 사신 카드 — HP 소모 + 즉사 + 사망 트리거. 시작 5장 + 보상 9장 = 14장.
class ReaperCards {
  ReaperCards._();

  /// 사신의 낫 — 1AP, 12 데미지. 적 HP 20% 이하 즉사. 시작.
  static const scythe = CardData(
    id: 'reaper_scythe',
    name: '사신의 낫',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    description: '12 데미지. 적 HP 20% 이하 즉사',
    effects: [CardEffect(type: CardEffectType.executeHpPercent, value: 20)],
  );

  /// 영혼 수확 — 1AP, HP -3, 힘 +3, 1장 드로우. 시작.
  static const soulHarvest = CardData(
    id: 'reaper_soul_harvest',
    name: '영혼 수확',
    jobId: 'reaper',
    type: CardType.skill,
    apCost: 1,
    description: 'HP -3, 힘 +3, 1장 드로우',
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 3),
      CardEffect(type: CardEffectType.gainStrength, value: 3),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 사망 선고 — 2AP, 20 데미지. 적 사망 시 HP 10 회복. 시작.
  static const deathSentence = CardData(
    id: 'reaper_death_sentence',
    name: '사망 선고',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 2,
    damage: 20,
    description: '20 데미지. 적 사망 시 HP 10 회복',
    effects: [CardEffect(type: CardEffectType.healOnKill, value: 10)],
  );

  /// 죽음의 손길 — 1AP, HP -2, 10 데미지 + 50% 흡혈. 시작.
  static const deathTouch = CardData(
    id: 'reaper_death_touch',
    name: '죽음의 손길',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: 'HP -2, 10 데미지. 준 데미지의 50% 회복',
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 2),
      CardEffect(type: CardEffectType.lifesteal, value: 50),
    ],
  );

  /// 불멸의 의지 — 1AP, HP 25% 미만 시 블록 15 + HP 5 회복. Exhaust. 시작.
  static const immortalWill = CardData(
    id: 'reaper_immortal_will',
    name: '불멸의 의지',
    jobId: 'reaper',
    type: CardType.skill,
    apCost: 1,
    description: 'HP 25% 미만 시 블록 15 + HP 5 회복. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.conditionalBlock, value: 15, condition: 'criticalHp'),
      CardEffect(type: CardEffectType.heal, value: 5),
    ],
  );

  /// 명계의 문 — 2AP, Power. 매 턴 HP -2, 힘 +2 + 적 처치 시 HP 5 회복 (영구). 보상.
  static const netherGate = CardData(
    id: 'reaper_nether_gate',
    name: '명계의 문',
    jobId: 'reaper',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 HP -2, 힘 +2 + 적 처치 시 HP 5 회복',
    effects: [
      CardEffect(type: CardEffectType.selfDamagePerTurn, value: 2),
      CardEffect(type: CardEffectType.strengthPerTurn, value: 2),
      CardEffect(type: CardEffectType.healOnKill, value: 5),
    ],
  );

  /// 저승사자 — 3AP, 잃은 HP만큼 데미지. Exhaust. 보상.
  static const grim = CardData(
    id: 'reaper_grim',
    name: '저승사자',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 3,
    description: '잃은 HP만큼 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.damageEqualLostHp, value: 1)],
  );

  /// 혼백 분리 — 1AP, HP 절반 → 블록. Exhaust. 보상.
  static const soulSplit = CardData(
    id: 'reaper_soul_split',
    name: '혼백 분리',
    jobId: 'reaper',
    type: CardType.skill,
    apCost: 1,
    description: 'HP 절반을 블록으로 변환. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.splitHpToBlock, value: 50)],
  );

  /// 생명 약탈 — 1AP, 10 데미지 + 데미지의 50% HP 회복. 보상.
  static const lifeDrain = CardData(
    id: 'reaper_life_drain',
    name: '생명 약탈',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: '10 데미지 + 데미지의 50% HP 회복',
    effects: [CardEffect(type: CardEffectType.lifesteal, value: 50)],
  );

  /// 사신의 인장 — 1AP, Power. 힘 +2 (영구). 보상.
  static const deathMark = CardData(
    id: 'reaper_death_mark',
    name: '사신의 인장',
    jobId: 'reaper',
    type: CardType.power,
    apCost: 1,
    description: '힘 +2 (영구)',
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 2)],
  );

  /// 영혼 폭풍 — 2AP, 잃은 HP × 100% 데미지. Exhaust. 보상.
  static const soulStorm = CardData(
    id: 'reaper_soul_storm',
    name: '영혼 폭풍',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 2,
    description: '잃은 HP만큼 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.damageEqualLostHp, value: 100)],
  );

  /// 피의 갑옷 — 1AP, HP -3, 블록 15. 보상.
  static const bloodArmor = CardData(
    id: 'reaper_blood_armor',
    name: '피의 갑옷',
    jobId: 'reaper',
    type: CardType.skill,
    apCost: 1,
    block: 15,
    description: 'HP -3, 블록 15',
    effects: [CardEffect(type: CardEffectType.selfDamage, value: 3)],
  );

  /// 죽음의 춤 — 0AP, 5 데미지 × 2회. 보상.
  static const deathDance = CardData(
    id: 'reaper_death_dance',
    name: '죽음의 춤',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 0,
    description: '5 데미지 × 2회. 적 사망 시 HP 5 회복',
    effects: [
      CardEffect(type: CardEffectType.multiHit, value: 5, duration: 2),
      CardEffect(type: CardEffectType.healOnKill, value: 5),
    ],
  );

  /// 명계의 은혜 — 2AP, Power. 매 턴 HP -1, 매 턴 드로우 +1. 보상.
  static const netherGrace = CardData(
    id: 'reaper_nether_grace',
    name: '명계의 은혜',
    jobId: 'reaper',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 HP -1, 매 턴 드로우 +1',
    effects: [
      CardEffect(type: CardEffectType.selfDamagePerTurn, value: 1),
      CardEffect(type: CardEffectType.drawPerTurn, value: 1),
    ],
  );

  /// 시작 카드 5장 (사신 전용).
  static const List<CardData> starter = [
    scythe,
    soulHarvest,
    deathSentence,
    deathTouch,
    immortalWill,
  ];

  /// 보상 카드 9장.
  static const List<CardData> rewards = [
    netherGate,
    grim,
    soulSplit,
    lifeDrain,
    deathMark,
    soulStorm,
    bloodArmor,
    deathDance,
    netherGrace,
  ];

  /// 전체 14장.
  static const List<CardData> all = [
    scythe,
    soulHarvest,
    deathSentence,
    deathTouch,
    immortalWill,
    netherGate,
    grim,
    soulSplit,
    lifeDrain,
    deathMark,
    soulStorm,
    bloodArmor,
    deathDance,
    netherGrace,
  ];

  // ── 업그레이드 버전 ──

  static const scythePlus = CardData(
    id: 'reaper_scythe+',
    name: '사신의 낫+',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 1,
    damage: 16,
    description: '16 데미지. 적 HP 25% 이하 즉사',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.executeHpPercent, value: 25)],
  );

  static const soulHarvestPlus = CardData(
    id: 'reaper_soul_harvest+',
    name: '영혼 수확+',
    jobId: 'reaper',
    type: CardType.skill,
    apCost: 1,
    description: 'HP -2, 힘 +4, 1장 드로우',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 2),
      CardEffect(type: CardEffectType.gainStrength, value: 4),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  static const deathSentencePlus = CardData(
    id: 'reaper_death_sentence+',
    name: '사망 선고+',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 2,
    damage: 26,
    description: '26 데미지. 적 사망 시 HP 15 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.healOnKill, value: 15)],
  );

  static const deathTouchPlus = CardData(
    id: 'reaper_death_touch+',
    name: '죽음의 손길+',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 1,
    damage: 14,
    description: 'HP -2, 14 데미지. 준 데미지의 50% 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 2),
      CardEffect(type: CardEffectType.lifesteal, value: 50),
    ],
  );

  static const immortalWillPlus = CardData(
    id: 'reaper_immortal_will+',
    name: '불멸의 의지+',
    jobId: 'reaper',
    type: CardType.skill,
    apCost: 1,
    description: 'HP 25% 미만 시 블록 20 + HP 8 회복. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.conditionalBlock, value: 20, condition: 'criticalHp'),
      CardEffect(type: CardEffectType.heal, value: 8),
    ],
  );

  static const netherGatePlus = CardData(
    id: 'reaper_nether_gate+',
    name: '명계의 문+',
    jobId: 'reaper',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 HP -1, 힘 +3 + 적 처치 시 HP 8 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.selfDamagePerTurn, value: 1),
      CardEffect(type: CardEffectType.strengthPerTurn, value: 3),
      CardEffect(type: CardEffectType.healOnKill, value: 8),
    ],
  );

  static const grimPlus = CardData(
    id: 'reaper_grim+',
    name: '저승사자+',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 2,
    description: '잃은 HP만큼 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.damageEqualLostHp, value: 1)],
  );

  static const soulSplitPlus = CardData(
    id: 'reaper_soul_split+',
    name: '혼백 분리+',
    jobId: 'reaper',
    type: CardType.skill,
    apCost: 0,
    description: 'HP 절반을 블록으로 변환. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.splitHpToBlock, value: 50)],
  );

  static const lifeDrainPlus = CardData(
    id: 'reaper_life_drain+',
    name: '생명 약탈+',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 1,
    damage: 14,
    description: '14 데미지 + 데미지의 50% HP 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.lifesteal, value: 50)],
  );

  static const deathMarkPlus = CardData(
    id: 'reaper_death_mark+',
    name: '사신의 인장+',
    jobId: 'reaper',
    type: CardType.power,
    apCost: 1,
    description: '힘 +3 (영구)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 3)],
  );

  static const soulStormPlus = CardData(
    id: 'reaper_soul_storm+',
    name: '영혼 폭풍+',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 2,
    description: '잃은 HP × 1.5 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.damageEqualLostHp, value: 150)],
  );

  static const bloodArmorPlus = CardData(
    id: 'reaper_blood_armor+',
    name: '피의 갑옷+',
    jobId: 'reaper',
    type: CardType.skill,
    apCost: 1,
    block: 20,
    description: 'HP -2, 블록 20',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.selfDamage, value: 2)],
  );

  static const deathDancePlus = CardData(
    id: 'reaper_death_dance+',
    name: '죽음의 춤+',
    jobId: 'reaper',
    type: CardType.attack,
    apCost: 0,
    description: '6 데미지 × 2회. 적 사망 시 HP 8 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.multiHit, value: 6, duration: 2),
      CardEffect(type: CardEffectType.healOnKill, value: 8),
    ],
  );

  static const netherGracePlus = CardData(
    id: 'reaper_nether_grace+',
    name: '명계의 은혜+',
    jobId: 'reaper',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 HP -1, 매 턴 드로우 +1',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.selfDamagePerTurn, value: 1),
      CardEffect(type: CardEffectType.drawPerTurn, value: 1),
    ],
  );
}
