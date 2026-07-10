import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 방랑자 카드 — 랜덤 + 적응 + 카드 생성. 시작 5장 + 보상 10장 = 15장.
class WandererCards {
  WandererCards._();

  /// 즉흥 타격 — 1AP, 4~12 랜덤 데미지. 시작.
  static const improviseStrike = CardData(
    id: 'wanderer_improvise_strike',
    name: '즉흥 타격',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 1,
    description: '4~12 랜덤 데미지',
    effects: [CardEffect(type: CardEffectType.randomDamage, value: 4, duration: 12)],
  );

  /// 적응 — 1AP, 6 블록 + 1장 드로우. 시작.
  static const adapt = CardData(
    id: 'wanderer_adapt',
    name: '적응',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '6 블록 + 1장 드로우',
    effects: [CardEffect(type: CardEffectType.draw, value: 1)],
  );

  /// 운의 동전 — 0AP, 60% 2장 드로우 / 40% 자해 5. Exhaust. 시작.
  static const luckyCoin = CardData(
    id: 'wanderer_lucky_coin',
    name: '운의 동전',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 0,
    description: '60% 확률 2장 드로우 / 40% 자해 5. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.coinFlip, value: 2, duration: 5)],
  );

  /// 방랑자의 지혜 — 1AP, 매 턴 버린 카드 중 랜덤 1장 복귀 + HP 2 회복. 시작.
  static const wisdom = CardData(
    id: 'wanderer_wisdom',
    name: '방랑자의 지혜',
    jobId: 'wanderer',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 버린 카드 중 랜덤 1장 복귀 + HP 2 회복',
    effects: [
      CardEffect(type: CardEffectType.retrieveRandomPerTurn, value: 1),
      CardEffect(type: CardEffectType.healPerTurn, value: 2),
    ],
  );

  /// 모방 — 2AP, 적 마지막 행동 파워만큼 데미지. 시작.
  static const mimic = CardData(
    id: 'wanderer_mimic',
    name: '모방',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 2,
    description: '적 마지막 행동 파워만큼 데미지',
    effects: [CardEffect(type: CardEffectType.mimicEnemyDamage, value: 100)],
  );

  /// 카드 생성 — 1AP, 랜덤 무색 카드 1장 추가. Exhaust. 보상.
  static const conjure = CardData(
    id: 'wanderer_conjure',
    name: '카드 생성',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    description: '랜덤 무색 카드 1장 손패에 추가. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 1)],
  );

  /// 연속 적응 — 1AP, 이번 턴 사용한 카드 수 × 2 블록. 보상.
  static const chainAdapt = CardData(
    id: 'wanderer_chain_adapt',
    name: '연속 적응',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    description: '이번 턴 사용한 카드 수 × 2 블록',
    effects: [CardEffect(type: CardEffectType.blockPerCardPlayed, value: 2)],
  );

  /// 대혼란 — 2AP, 적에게 랜덤 디버프 2개 + 5 데미지. 보상.
  static const chaos = CardData(
    id: 'wanderer_chaos',
    name: '대혼란',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 2,
    damage: 5,
    description: '5 데미지 + 랜덤 디버프 2개',
    effects: [CardEffect(type: CardEffectType.randomDebuffs, value: 2)],
    targetType: CardTargetType.all,
  );

  /// 생존 본능 — 1AP, HP 12 회복 + 블록 6. 보상.
  static const survivalInstinct = CardData(
    id: 'wanderer_survival_instinct',
    name: '생존 본능',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: 'HP 12 회복 + 블록 6',
    effects: [CardEffect(type: CardEffectType.heal, value: 12)],
  );

  /// 노련한 일격 — 1AP, 소진된 카드 수 × 4 데미지. 보상.
  static const veteranStrike = CardData(
    id: 'wanderer_veteran_strike',
    name: '노련한 일격',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 1,
    description: '소진된 카드 수 × 4 데미지',
    effects: [CardEffect(type: CardEffectType.damagePerExhaust, value: 4)],
  );

  /// 행운의 주사위 — 0AP, 랜덤 효과. 소진. 보상.
  static const luckyDice = CardData(
    id: 'wanderer_lucky_dice',
    name: '행운의 주사위',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 0,
    description: '랜덤: 힘+2 / 블록10 / 드로우2 / HP8. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.coinFlip, value: 2, duration: 5)],
  );

  /// 순간 포착 — 1AP, 12 데미지 (관통). 보상.
  static const seizeMoment = CardData(
    id: 'wanderer_seize_moment',
    name: '순간 포착',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    description: '12 데미지 (관통)',
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 0)],
  );

  /// 방랑자의 비전 — 2AP, 파워: 매 턴 랜덤 무색 카드 1장 생성. 보상.
  static const vision = CardData(
    id: 'wanderer_vision',
    name: '방랑자의 비전',
    jobId: 'wanderer',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 랜덤 무색 카드 1장 생성',
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 1)],
  );

  /// 되돌리기 — 1AP, 버림더미에서 2장 손패로 복귀. 보상.
  static const rewind = CardData(
    id: 'wanderer_rewind',
    name: '되돌리기',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    description: '버림더미에서 2장 손패로 복귀',
    effects: [CardEffect(type: CardEffectType.retrieveFromDiscard, value: 2)],
  );

  /// 방랑자의 본능 — 1AP, Power. 피격 턴 종료 시 HP 4 회복. 보상.
  static const instinct = CardData(
    id: 'wanderer_instinct',
    name: '방랑자의 본능',
    jobId: 'wanderer',
    type: CardType.power,
    apCost: 1,
    description: '피격 턴 종료 시 HP 4 회복',
    effects: [CardEffect(type: CardEffectType.healOnDamageTaken, value: 4)],
  );

  /// 시작 카드 5장 (공통 제외, 방랑자 전용).
  static const List<CardData> starter = [
    improviseStrike,
    adapt,
    luckyCoin,
    wisdom,
    mimic,
  ];

  /// 보상 카드 10장.
  static const List<CardData> rewards = [
    conjure,
    chainAdapt,
    chaos,
    survivalInstinct,
    veteranStrike,
    luckyDice,
    seizeMoment,
    vision,
    rewind,
    instinct,
  ];

  /// 전체 15장.
  static const List<CardData> all = [
    improviseStrike,
    adapt,
    luckyCoin,
    wisdom,
    mimic,
    conjure,
    chainAdapt,
    chaos,
    survivalInstinct,
    veteranStrike,
    luckyDice,
    seizeMoment,
    vision,
    rewind,
    instinct,
  ];

  // ── 업그레이드 버전 ──

  /// 즉흥 타격+ — 1AP, 6~16 랜덤 데미지.
  static const improviseStrikePlus = CardData(
    id: 'wanderer_improvise_strike+',
    name: '즉흥 타격+',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 1,
    description: '6~16 랜덤 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.randomDamage, value: 6, duration: 16)],
  );

  /// 적응+ — 1AP, 8 블록 + 2장 드로우.
  static const adaptPlus = CardData(
    id: 'wanderer_adapt+',
    name: '적응+',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '8 블록 + 2장 드로우',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.draw, value: 2)],
  );

  /// 운의 동전+ — 0AP, 60% 3장 드로우 / 40% 자해 3. Exhaust.
  static const luckyCoinPlus = CardData(
    id: 'wanderer_lucky_coin+',
    name: '운의 동전+',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 0,
    description: '60% 확률 3장 드로우 / 40% 자해 3. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.coinFlip, value: 3, duration: 3)],
  );

  /// 방랑자의 지혜+ — 매 턴 2장 복귀 + HP 3 회복.
  static const wisdomPlus = CardData(
    id: 'wanderer_wisdom+',
    name: '방랑자의 지혜+',
    jobId: 'wanderer',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 버린 카드 중 랜덤 2장 복귀 + HP 3 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.retrieveRandomPerTurn, value: 2),
      CardEffect(type: CardEffectType.healPerTurn, value: 3),
    ],
  );

  /// 모방+ — 적 마지막 행동 × 1.5 데미지.
  static const mimicPlus = CardData(
    id: 'wanderer_mimic+',
    name: '모방+',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 2,
    description: '적 마지막 행동 × 1.5 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.mimicEnemyDamage, value: 150)],
  );

  /// 카드 생성+ — 랜덤 무색 카드 2장 추가. Exhaust.
  static const conjurePlus = CardData(
    id: 'wanderer_conjure+',
    name: '카드 생성+',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    description: '랜덤 무색 카드 2장 손패에 추가. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 2)],
  );

  /// 연속 적응+ — 카드 수 × 3 블록.
  static const chainAdaptPlus = CardData(
    id: 'wanderer_chain_adapt+',
    name: '연속 적응+',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    description: '이번 턴 사용한 카드 수 × 3 블록',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockPerCardPlayed, value: 3)],
  );

  /// 대혼란+ — 랜덤 디버프 3개 + 8 데미지.
  static const chaosPlus = CardData(
    id: 'wanderer_chaos+',
    name: '대혼란+',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 2,
    damage: 8,
    description: '8 데미지 + 랜덤 디버프 3개',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.randomDebuffs, value: 3)],
    targetType: CardTargetType.all,
  );

  /// 생존 본능+ — 1AP, HP 16 회복 + 블록 8.
  static const survivalInstinctPlus = CardData(
    id: 'wanderer_survival_instinct+',
    name: '생존 본능+',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: 'HP 16 회복 + 블록 8',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.heal, value: 16)],
  );

  /// 노련한 일격+ — 1AP, 소진된 카드 수 × 6 데미지.
  static const veteranStrikePlus = CardData(
    id: 'wanderer_veteran_strike+',
    name: '노련한 일격+',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 1,
    description: '소진된 카드 수 × 6 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.damagePerExhaust, value: 6)],
  );

  /// 행운의 주사위+ — 0AP, 강화 랜덤 효과. 소진.
  static const luckyDicePlus = CardData(
    id: 'wanderer_lucky_dice+',
    name: '행운의 주사위+',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 0,
    description: '랜덤: 힘+3 / 블록14 / 드로우3 / HP12. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.coinFlip, value: 3, duration: 3)],
  );

  /// 순간 포착+ — 1AP, 16 데미지 (관통).
  static const seizeMomentPlus = CardData(
    id: 'wanderer_seize_moment+',
    name: '순간 포착+',
    jobId: 'wanderer',
    type: CardType.attack,
    apCost: 1,
    damage: 16,
    description: '16 데미지 (관통)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 0)],
  );

  /// 방랑자의 비전+ — 2AP, 파워: 매 턴 랜덤 무색 카드 2장 생성.
  static const visionPlus = CardData(
    id: 'wanderer_vision+',
    name: '방랑자의 비전+',
    jobId: 'wanderer',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 랜덤 무색 카드 2장 생성',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 2)],
  );

  /// 되돌리기+ — 1AP, 버림더미에서 3장 손패로 복귀.
  static const rewindPlus = CardData(
    id: 'wanderer_rewind+',
    name: '되돌리기+',
    jobId: 'wanderer',
    type: CardType.skill,
    apCost: 1,
    description: '버림더미에서 3장 손패로 복귀',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.retrieveFromDiscard, value: 3)],
  );

  /// 방랑자의 본능+ — 피격 턴 종료 시 HP 6 회복.
  static const instinctPlus = CardData(
    id: 'wanderer_instinct+',
    name: '방랑자의 본능+',
    jobId: 'wanderer',
    type: CardType.power,
    apCost: 1,
    description: '피격 턴 종료 시 HP 6 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.healOnDamageTaken, value: 6)],
  );
}
