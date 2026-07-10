import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 조율사 카드 — 균형 + 적응 + 다속성 시너지. 시작 5장 + 보상 9장 = 14장.
class HarmonistCards {
  HarmonistCards._();

  /// 균형 타격 — 1AP, 블록 수치만큼 추가 데미지. 시작.
  static const balancedStrike = CardData(
    id: 'harmonist_balanced_strike',
    name: '균형 타격',
    jobId: 'harmonist',
    type: CardType.attack,
    apCost: 1,
    description: '현재 블록만큼 데미지',
    effects: [CardEffect(type: CardEffectType.retribution, value: 100)],
  );

  /// 조율 — 1AP, 힘 +1, 민첩 +1, 블록 4. 시작.
  static const attune = CardData(
    id: 'harmonist_attune',
    name: '조율',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 1,
    block: 4,
    description: '힘 +1, 민첩 +1, 블록 4',
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 1),
      CardEffect(type: CardEffectType.gainDexterity, value: 1),
    ],
  );

  /// 공명 — 1AP, 이번 턴 플레이 카드 수 × 4 블록. 시작.
  static const resonance = CardData(
    id: 'harmonist_resonance',
    name: '공명',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 1,
    description: '이번 턴 플레이한 카드 수 × 4 블록',
    effects: [CardEffect(type: CardEffectType.blockPerCardPlayed, value: 4)],
  );

  /// 적응의 일격 — 1AP, 적 마지막 행동이 공격이면 12, 아니면 6 데미지. 시작.
  static const adaptiveStrike = CardData(
    id: 'harmonist_adaptive_strike',
    name: '적응의 일격',
    jobId: 'harmonist',
    type: CardType.attack,
    apCost: 1,
    description: '적 공격 시 12, 아니면 6 데미지',
    effects: [CardEffect(type: CardEffectType.adaptiveDamage, value: 12, duration: 6)],
  );

  /// 흡수 — 1AP, 적 힘 1 흡수 (적 -1, 자신 +1) + HP 3 회복. 시작.
  static const absorb = CardData(
    id: 'harmonist_absorb',
    name: '흡수',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 1,
    description: '적 힘 1 흡수 (적 -1, 자신 +1) + HP 3 회복',
    effects: [
      CardEffect(type: CardEffectType.absorbStrength, value: 1),
      CardEffect(type: CardEffectType.heal, value: 3),
    ],
  );

  /// 완전한 조화 — 2AP, Power. Attack/Skill/Power 모두 사용 시 AP +1. 보상.
  static const perfectHarmony = CardData(
    id: 'harmonist_perfect_harmony',
    name: '완전한 조화',
    jobId: 'harmonist',
    type: CardType.power,
    apCost: 2,
    description: 'Attack/Skill/Power 모두 플레이 시 AP +1',
    effects: [CardEffect(type: CardEffectType.allTypesApBonus, value: 1)],
  );

  /// 평형 — 0AP, HP와 블록을 평균으로 조율. Exhaust. 보상.
  static const equilibrium = CardData(
    id: 'harmonist_equilibrium',
    name: '평형',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 0,
    description: 'HP와 블록을 평균으로 조율. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.equalizeHpBlock, value: 1)],
  );

  /// 만물일체 — 3AP, Power. 매 턴 시작 가장 낮은 스탯 +2. 보상.
  static const oneness = CardData(
    id: 'harmonist_oneness',
    name: '만물일체',
    jobId: 'harmonist',
    type: CardType.power,
    apCost: 3,
    description: '매 턴 시작: 가장 낮은 스탯 +2',
    effects: [CardEffect(type: CardEffectType.boostLowestStat, value: 2)],
  );

  /// 내면의 조화 — 1AP, HP 8 회복 + 블록 6. 보상.
  static const innerHarmony = CardData(
    id: 'harmonist_inner_harmony',
    name: '내면의 조화',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 1,
    block: 7,
    description: 'HP 10 회복 + 블록 7',
    effects: [CardEffect(type: CardEffectType.heal, value: 10)],
  );

  /// 흐름 전환 — 0AP, 힘 ↔ 민첩 교환. 보상.
  static const flowShift = CardData(
    id: 'harmonist_flow_shift',
    name: '흐름 전환',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 0,
    description: '힘 ↔ 민첩 교환',
    effects: [CardEffect(type: CardEffectType.swapStrDex, value: 0)],
  );

  /// 공명 파동 — 2AP, (힘 + 민첩) 합산 데미지. 보상.
  static const resonanceWave = CardData(
    id: 'harmonist_resonance_wave',
    name: '공명 파동',
    jobId: 'harmonist',
    type: CardType.attack,
    apCost: 2,
    description: '(힘 + 민첩) 합산 데미지',
    effects: [CardEffect(type: CardEffectType.statSumDamage, value: 100)],
  );

  /// 완전한 방어 — 2AP, 블록 10 + 가시 1 + 재생 1 (3턴). 보상.
  static const perfectDefense = CardData(
    id: 'harmonist_perfect_defense',
    name: '완전한 방어',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 2,
    block: 10,
    description: '블록 10 + 가시 1 + 재생 1 (3턴)',
    effects: [
      CardEffect(type: CardEffectType.gainThorn, value: 1),
      CardEffect(type: CardEffectType.gainRegenerate, value: 1, duration: 3),
    ],
  );

  /// 조율의 파장 — 1AP, Power. 힘 +1, 민첩 +1. 보상.
  static const tuningWave = CardData(
    id: 'harmonist_tuning_wave',
    name: '조율의 파장',
    jobId: 'harmonist',
    type: CardType.power,
    apCost: 1,
    description: '힘 +1, 민첩 +1',
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 1),
      CardEffect(type: CardEffectType.gainDexterity, value: 1),
    ],
  );

  /// 만물귀일 — 3AP, (힘+민첩+블록+가시) 합산 데미지. Exhaust. 보상.
  static const allAsOne = CardData(
    id: 'harmonist_all_as_one',
    name: '만물귀일',
    jobId: 'harmonist',
    type: CardType.attack,
    apCost: 3,
    description: '(힘+민첩+블록+가시) 합산 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.statSumDamage, value: 100, condition: 'withBlockAndThorn')],
  );

  /// 시작 카드 5장 (조율사 전용).
  static const List<CardData> starter = [
    balancedStrike,
    attune,
    resonance,
    adaptiveStrike,
    absorb,
  ];

  /// 보상 카드 9장.
  static const List<CardData> rewards = [
    perfectHarmony,
    equilibrium,
    oneness,
    innerHarmony,
    flowShift,
    resonanceWave,
    perfectDefense,
    tuningWave,
    allAsOne,
  ];

  /// 전체 14장.
  static const List<CardData> all = [
    balancedStrike,
    attune,
    resonance,
    adaptiveStrike,
    absorb,
    perfectHarmony,
    equilibrium,
    oneness,
    innerHarmony,
    flowShift,
    resonanceWave,
    perfectDefense,
    tuningWave,
    allAsOne,
  ];

  // ── 업그레이드 버전 ──

  static const balancedStrikePlus = CardData(
    id: 'harmonist_balanced_strike+',
    name: '균형 타격+',
    jobId: 'harmonist',
    type: CardType.attack,
    apCost: 1,
    description: '현재 블록 × 1.5 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.retribution, value: 150)],
  );

  static const attunePlus = CardData(
    id: 'harmonist_attune+',
    name: '조율+',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 1,
    block: 7,
    description: '힘 +2, 민첩 +2, 블록 7',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 2),
      CardEffect(type: CardEffectType.gainDexterity, value: 2),
    ],
  );

  static const resonancePlus = CardData(
    id: 'harmonist_resonance+',
    name: '공명+',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 1,
    description: '이번 턴 플레이한 카드 수 × 5 블록',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockPerCardPlayed, value: 5)],
  );

  static const adaptiveStrikePlus = CardData(
    id: 'harmonist_adaptive_strike+',
    name: '적응의 일격+',
    jobId: 'harmonist',
    type: CardType.attack,
    apCost: 1,
    description: '적 공격 시 16, 아니면 8 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.adaptiveDamage, value: 16, duration: 8)],
  );

  static const absorbPlus = CardData(
    id: 'harmonist_absorb+',
    name: '흡수+',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 1,
    description: '적 힘 2 흡수 (적 -2, 자신 +2) + HP 5 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.absorbStrength, value: 2),
      CardEffect(type: CardEffectType.heal, value: 5),
    ],
  );

  static const perfectHarmonyPlus = CardData(
    id: 'harmonist_perfect_harmony+',
    name: '완전한 조화+',
    jobId: 'harmonist',
    type: CardType.power,
    apCost: 1,
    description: 'Attack/Skill/Power 모두 플레이 시 AP +1',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.allTypesApBonus, value: 1)],
  );

  static const equilibriumPlus = CardData(
    id: 'harmonist_equilibrium+',
    name: '평형+',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 0,
    description: 'HP와 블록을 평균으로 조율 + 1장 드로우. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.equalizeHpBlock, value: 1),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  static const onenessPlus = CardData(
    id: 'harmonist_oneness+',
    name: '만물일체+',
    jobId: 'harmonist',
    type: CardType.power,
    apCost: 3,
    description: '매 턴 시작: 가장 낮은 스탯 +3',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.boostLowestStat, value: 3)],
  );

  static const innerHarmonyPlus = CardData(
    id: 'harmonist_inner_harmony+',
    name: '내면의 조화+',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: 'HP 14 회복 + 블록 10',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.heal, value: 14)],
  );

  static const flowShiftPlus = CardData(
    id: 'harmonist_flow_shift+',
    name: '흐름 전환+',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 0,
    description: '힘 ↔ 민첩 교환 + 1장 드로우',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.swapStrDex, value: 0),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  static const resonanceWavePlus = CardData(
    id: 'harmonist_resonance_wave+',
    name: '공명 파동+',
    jobId: 'harmonist',
    type: CardType.attack,
    apCost: 2,
    description: '(힘 + 민첩) × 1.5 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.statSumDamage, value: 150)],
  );

  static const perfectDefensePlus = CardData(
    id: 'harmonist_perfect_defense+',
    name: '완전한 방어+',
    jobId: 'harmonist',
    type: CardType.skill,
    apCost: 2,
    block: 15,
    description: '블록 15 + 가시 2 + 재생 1 (3턴)',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainThorn, value: 2),
      CardEffect(type: CardEffectType.gainRegenerate, value: 1, duration: 3),
    ],
  );

  static const tuningWavePlus = CardData(
    id: 'harmonist_tuning_wave+',
    name: '조율의 파장+',
    jobId: 'harmonist',
    type: CardType.power,
    apCost: 1,
    description: '힘 +2, 민첩 +2',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 2),
      CardEffect(type: CardEffectType.gainDexterity, value: 2),
    ],
  );

  static const allAsOnePlus = CardData(
    id: 'harmonist_all_as_one+',
    name: '만물귀일+',
    jobId: 'harmonist',
    type: CardType.attack,
    apCost: 3,
    description: '(힘+민첩+블록+가시) × 1.5 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.statSumDamage, value: 150, condition: 'withBlockAndThorn')],
  );
}
