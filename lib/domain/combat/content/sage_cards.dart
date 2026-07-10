import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 현자 카드 — 카드 조작 + 폭발. 시작 5장 + 보상 11장 = 16장.
class SageCards {
  SageCards._();

  /// 마력탄 — 1AP, 10 데미지 (적 블록 무시). 시작.
  static const magicBolt = CardData(
    id: 'sage_magic_bolt',
    name: '마력탄',
    jobId: 'sage',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: '10 데미지 (관통)',
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 0)],
  );

  /// 분석 — 1AP, 적 행동 3턴 공개 + 1장 드로우. 시작.
  static const analysis = CardData(
    id: 'sage_analysis',
    name: '분석',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 1,
    description: '적 행동 3턴 공개 + 1장 드로우',
    effects: [
      CardEffect(type: CardEffectType.revealIntent, value: 3),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 집중 — 0AP, 이번 턴 AP +1, 블록 4, 다음 턴 AP -1. 시작.
  static const focus = CardData(
    id: 'sage_focus',
    name: '집중',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 0,
    block: 4,
    description: '이번 턴 AP +1, 블록 4, 다음 턴 AP -1',
    effects: [
      CardEffect(type: CardEffectType.apGain, value: 1),
      CardEffect(type: CardEffectType.apPenaltyNextTurn, value: 1),
    ],
  );

  /// 마나 순환 — 1AP, 손패 전부 버리고 같은 수 +1장 드로우. 시작.
  static const manaCycle = CardData(
    id: 'sage_mana_cycle',
    name: '마나 순환',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 1,
    description: '손패 전부 버리고 같은 수 +1장 드로우',
    effects: [CardEffect(type: CardEffectType.cycleHand, value: 1)],
  );

  /// 마력 폭발 — 3AP, 손패 수 × 8 데미지. Exhaust. 시작.
  static const magicExplosion = CardData(
    id: 'sage_magic_explosion',
    name: '마력 폭발',
    jobId: 'sage',
    type: CardType.attack,
    apCost: 3,
    description: '손패 수 × 8 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.damagePerHandCard, value: 8)],
  );

  /// 연쇄 번개 — 2AP, 7 데미지 × 3회. 보상.
  static const chainLightning = CardData(
    id: 'sage_chain_lightning',
    name: '연쇄 번개',
    jobId: 'sage',
    type: CardType.attack,
    apCost: 2,
    description: '7 데미지 × 3회',
    effects: [CardEffect(type: CardEffectType.multiHit, value: 7, duration: 3)],
    targetType: CardTargetType.all,
  );

  /// 시간 왜곡 — 2AP, 버림 더미에서 2장 손패로 복귀 + 블록 5. 보상.
  static const timeDistortion = CardData(
    id: 'sage_time_distortion',
    name: '시간 왜곡',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 2,
    block: 5,
    description: '버림 더미에서 2장 손패로 복귀 + 블록 5',
    effects: [CardEffect(type: CardEffectType.retrieveFromDiscard, value: 2)],
  );

  /// 마력 충전 — 1AP, 힘 +1 (영구). 보상.
  static const manaCharge = CardData(
    id: 'sage_mana_charge',
    name: '마력 충전',
    jobId: 'sage',
    type: CardType.power,
    apCost: 1,
    description: '힘 +1 (영구)',
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 1)],
  );

  /// 마력 방벽 — 1AP, 블록 6 + 손패 수 × 3 추가 블록. 보상.
  static const manaBarrier = CardData(
    id: 'sage_mana_barrier',
    name: '마력 방벽',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '블록 6 + 손패 수 × 3 추가 블록',
    effects: [CardEffect(type: CardEffectType.handSizeBlock, value: 3)],
  );

  /// 정신 집중 — 1AP, 파워: 매 턴 드로우 +1. 보상.
  static const mindFocus = CardData(
    id: 'sage_mind_focus',
    name: '정신 집중',
    jobId: 'sage',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 드로우 +1',
    effects: [CardEffect(type: CardEffectType.drawPerTurn, value: 1)],
  );

  /// 차원 절단 — 2AP, 15 데미지 (관통). 보상.
  static const dimensionCut = CardData(
    id: 'sage_dimension_cut',
    name: '차원 절단',
    jobId: 'sage',
    type: CardType.attack,
    apCost: 2,
    damage: 15,
    description: '15 데미지 (관통)',
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 0)],
  );

  /// 마력 환류 — 0AP, 이번 턴 Skill 수 × 6 데미지. 보상.
  static const manaReflux = CardData(
    id: 'sage_mana_reflux',
    name: '마력 환류',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 0,
    description: '이번 턴 Skill 수 × 6 데미지',
    effects: [CardEffect(type: CardEffectType.skillCountDamage, value: 6)],
  );

  /// 지식의 탑 — 3AP, 파워: 매 턴 드로우 +1. 보상.
  static const towerOfKnowledge = CardData(
    id: 'sage_tower_of_knowledge',
    name: '지식의 탑',
    jobId: 'sage',
    type: CardType.power,
    apCost: 3,
    description: '매 턴 드로우 +1',
    effects: [CardEffect(type: CardEffectType.drawPerTurn, value: 1)],
  );

  /// 마나 과부하 — 0AP, AP +2, HP -5. 소진. 보상.
  static const manaOverload = CardData(
    id: 'sage_mana_overload',
    name: '마나 과부하',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 0,
    description: 'AP +2, HP -5. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.apGain, value: 2),
      CardEffect(type: CardEffectType.selfDamage, value: 5),
    ],
  );

  /// 마력 흡수 — 1AP, 블록 8 + 다음 Skill AP -1. 보상.
  static const manaAbsorb = CardData(
    id: 'sage_mana_absorb',
    name: '마력 흡수',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 다음 Skill AP -1',
    effects: [CardEffect(type: CardEffectType.nextSkillApDiscount, value: 1)],
  );

  /// 마나 보호막 — 2AP, Power. 관통 초과 데미지의 25%를 블록 전환. 보상.
  static const manaShield = CardData(
    id: 'sage_mana_shield',
    name: '마나 보호막',
    jobId: 'sage',
    type: CardType.power,
    apCost: 2,
    description: '관통 초과 데미지의 25%를 블록으로 전환',
    effects: [CardEffect(type: CardEffectType.overflowToBlock, value: 25)],
  );

  /// 시작 카드 5장 (공통 제외, 현자 전용).
  static const List<CardData> starter = [
    magicBolt,
    analysis,
    focus,
    manaCycle,
    magicExplosion,
  ];

  /// 보상 카드 11장.
  static const List<CardData> rewards = [
    chainLightning,
    timeDistortion,
    manaCharge,
    manaBarrier,
    mindFocus,
    dimensionCut,
    manaReflux,
    towerOfKnowledge,
    manaOverload,
    manaAbsorb,
    manaShield,
  ];

  /// 전체 16장.
  static const List<CardData> all = [
    magicBolt,
    analysis,
    focus,
    manaCycle,
    magicExplosion,
    chainLightning,
    timeDistortion,
    manaCharge,
    manaBarrier,
    mindFocus,
    dimensionCut,
    manaReflux,
    towerOfKnowledge,
    manaOverload,
    manaAbsorb,
    manaShield,
  ];

  // ── 업그레이드 버전 ──

  static const magicBoltPlus = CardData(
    id: 'sage_magic_bolt+',
    name: '마력탄+',
    jobId: 'sage',
    type: CardType.attack,
    apCost: 1,
    damage: 14,
    description: '14 데미지 (관통)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 0)],
  );

  static const analysisPlus = CardData(
    id: 'sage_analysis+',
    name: '분석+',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 1,
    block: 4,
    description: '적 행동 3턴 공개 + 1장 드로우 + 블록 4',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.revealIntent, value: 3),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 집중+ — 0AP, AP +1, 블록 6 (패널티 없음).
  static const focusPlus = CardData(
    id: 'sage_focus+',
    name: '집중+',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 0,
    block: 6,
    description: '이번 턴 AP +1, 블록 6',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.apGain, value: 1)],
  );

  static const manaCyclePlus = CardData(
    id: 'sage_mana_cycle+',
    name: '마나 순환+',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 1,
    description: '손패 전부 버리고 같은 수 +2장 드로우',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.cycleHand, value: 2)],
  );

  static const magicExplosionPlus = CardData(
    id: 'sage_magic_explosion+',
    name: '마력 폭발+',
    jobId: 'sage',
    type: CardType.attack,
    apCost: 3,
    description: '손패 수 × 10 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.damagePerHandCard, value: 10)],
  );

  static const chainLightningPlus = CardData(
    id: 'sage_chain_lightning+',
    name: '연쇄 번개+',
    jobId: 'sage',
    type: CardType.attack,
    apCost: 2,
    description: '7 데미지 × 4회',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.multiHit, value: 7, duration: 4)],
    targetType: CardTargetType.all,
  );

  static const timeDistortionPlus = CardData(
    id: 'sage_time_distortion+',
    name: '시간 왜곡+',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 2,
    block: 7,
    description: '버림 더미에서 3장 손패로 복귀 + 블록 7',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.retrieveFromDiscard, value: 3)],
  );

  static const manaChargePlus = CardData(
    id: 'sage_mana_charge+',
    name: '마력 충전+',
    jobId: 'sage',
    type: CardType.power,
    apCost: 1,
    description: '힘 +2 (영구)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 2)],
  );

  /// 마력 방벽+ — 1AP, 블록 8 + 손패 수 × 3 추가 블록.
  static const manaBarrierPlus = CardData(
    id: 'sage_mana_barrier+',
    name: '마력 방벽+',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 손패 수 × 3 추가 블록',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.handSizeBlock, value: 3)],
  );

  /// 정신 집중+ — 1AP, 파워: 매 턴 드로우 +2.
  static const mindFocusPlus = CardData(
    id: 'sage_mind_focus+',
    name: '정신 집중+',
    jobId: 'sage',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 드로우 +2',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.drawPerTurn, value: 2)],
  );

  /// 차원 절단+ — 2AP, 22 데미지 (관통).
  static const dimensionCutPlus = CardData(
    id: 'sage_dimension_cut+',
    name: '차원 절단+',
    jobId: 'sage',
    type: CardType.attack,
    apCost: 2,
    damage: 22,
    description: '22 데미지 (관통)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 0)],
  );

  /// 마력 환류+ — 0AP, 이번 턴 Skill 수 × 8 데미지.
  static const manaRefluxPlus = CardData(
    id: 'sage_mana_reflux+',
    name: '마력 환류+',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 0,
    description: '이번 턴 Skill 수 × 8 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.skillCountDamage, value: 8)],
  );

  /// 지식의 탑+ — 3AP, 파워: 매 턴 드로우 +2.
  static const towerOfKnowledgePlus = CardData(
    id: 'sage_tower_of_knowledge+',
    name: '지식의 탑+',
    jobId: 'sage',
    type: CardType.power,
    apCost: 3,
    description: '매 턴 드로우 +2',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.drawPerTurn, value: 2)],
  );

  /// 마나 과부하+ — 0AP, AP +3, HP -5. 소진.
  static const manaOverloadPlus = CardData(
    id: 'sage_mana_overload+',
    name: '마나 과부하+',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 0,
    description: 'AP +3, HP -5. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.apGain, value: 3),
      CardEffect(type: CardEffectType.selfDamage, value: 5),
    ],
  );

  static const manaAbsorbPlus = CardData(
    id: 'sage_mana_absorb+',
    name: '마력 흡수+',
    jobId: 'sage',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '블록 10 + 다음 Skill AP -1',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.nextSkillApDiscount, value: 1)],
  );

  static const manaShieldPlus = CardData(
    id: 'sage_mana_shield+',
    name: '마나 보호막+',
    jobId: 'sage',
    type: CardType.power,
    apCost: 2,
    description: '관통 초과 데미지의 30%를 블록으로 전환',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.overflowToBlock, value: 30)],
  );
}
