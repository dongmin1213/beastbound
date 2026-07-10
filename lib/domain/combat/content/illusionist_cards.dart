import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 환술사 카드 — 카드 복사 + 생성 + 환영. 시작 5장 + 보상 10장 = 15장.
class IllusionistCards {
  IllusionistCards._();

  /// 환영 타격 — 1AP, 7 데미지 + 랜덤 카드 1장 생성. 시작.
  static const phantomStrike = CardData(
    id: 'illusionist_phantom_strike',
    name: '환영 타격',
    jobId: 'illusionist',
    type: CardType.attack,
    apCost: 1,
    damage: 7,
    description: '7 데미지 + 랜덤 카드 1장 생성',
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 1)],
  );

  /// 거울 방패 — 1AP, 블록 8 + 적 마지막 행동 복사. 시작.
  static const mirrorShield = CardData(
    id: 'illusionist_mirror_shield',
    name: '거울 방패',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 적 마지막 행동 복사',
    effects: [CardEffect(type: CardEffectType.mimicEnemyDamage, value: 1)],
  );

  /// 분신술 — 1AP, 마지막 카드 복사. Exhaust. 시작.
  static const clone = CardData(
    id: 'illusionist_clone',
    name: '분신술',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    description: '마지막 플레이 카드 복사. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.copyLastAttack, value: 1)],
  );

  /// 환각 — 1AP, 약화 2턴 + 취약 1턴 + 블록 4. 시작.
  static const hallucination = CardData(
    id: 'illusionist_hallucination',
    name: '환각',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    block: 4,
    description: '적 약화 2턴 + 취약 1턴 + 블록 4',
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 2),
      CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 1),
    ],
  );

  /// 마법 카드 — 0AP, 랜덤 무색 카드 1장 손패 추가. 시작.
  static const magicCard = CardData(
    id: 'illusionist_magic_card',
    name: '마법 카드',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 0,
    description: '랜덤 카드 1장 손패 추가',
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 1)],
  );

  /// 차원 전환 — 2AP, Power. 매 턴 손패 1장 랜덤 변환. 보상.
  static const dimensionShift = CardData(
    id: 'illusionist_dimension_shift',
    name: '차원 전환',
    jobId: 'illusionist',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 손패 1장을 랜덤 카드로 변환',
    effects: [CardEffect(type: CardEffectType.transformHandPerTurn, value: 1)],
  );

  /// 완벽한 복제 — 2AP, 마지막 카드 2번 재실행. Exhaust. 보상.
  static const perfectCopy = CardData(
    id: 'illusionist_perfect_copy',
    name: '완벽한 복제',
    jobId: 'illusionist',
    type: CardType.attack,
    apCost: 2,
    description: '마지막 사용 카드 2번 재실행. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.replayLastCard, value: 2)],
  );

  /// 허상의 군단 — 3AP, Power. 매 턴 랜덤 Attack 1장 생성. 보상.
  static const phantomArmy = CardData(
    id: 'illusionist_phantom_army',
    name: '허상의 군단',
    jobId: 'illusionist',
    type: CardType.power,
    apCost: 3,
    description: '매 턴 랜덤 공격 카드 1장 생성',
    effects: [CardEffect(type: CardEffectType.generateAttackPerTurn, value: 1)],
  );

  /// 환영의 벽 — 1AP, 블록 10 + 랜덤 카드 1장 생성. 보상.
  static const phantomWall = CardData(
    id: 'illusionist_phantom_wall',
    name: '환영의 벽',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '블록 10 + 랜덤 카드 1장 생성',
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 1)],
  );

  /// 다중 분신 — 2AP, 마지막 카드 복사 3번. Exhaust. 보상.
  static const multiClone = CardData(
    id: 'illusionist_multi_clone',
    name: '다중 분신',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 2,
    description: '마지막 카드 복사 3번. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.replayLastCard, value: 3)],
  );

  /// 현실 왜곡 — 1AP, 8 데미지 + 약화 1턴 + 카드 1장 생성. 보상.
  static const realityWarp = CardData(
    id: 'illusionist_reality_warp',
    name: '현실 왜곡',
    jobId: 'illusionist',
    type: CardType.attack,
    apCost: 1,
    damage: 8,
    description: '8 데미지 + 약화 1턴 + 카드 1장 생성',
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 1),
      CardEffect(type: CardEffectType.generateRandomCard, value: 1),
    ],
  );

  /// 거울의 미로 — 2AP, Power. 피격 시 40% 확률 데미지 반사 + 반사 시 HP 3 회복. 보상.
  static const mirrorMaze = CardData(
    id: 'illusionist_mirror_maze',
    name: '거울의 미로',
    jobId: 'illusionist',
    type: CardType.power,
    apCost: 2,
    description: '피격 시 40% 확률 데미지 반사 + 반사 시 HP 3 회복',
    effects: [
      CardEffect(type: CardEffectType.reflectDamageChance, value: 40),
      CardEffect(type: CardEffectType.healOnReflect, value: 3),
    ],
  );

  /// 환각 폭풍 — 3AP, 10 데미지 + 약화 3턴 + 취약 2턴. Exhaust. 보상.
  static const hallucinationStorm = CardData(
    id: 'illusionist_hallucination_storm',
    name: '환각 폭풍',
    jobId: 'illusionist',
    type: CardType.attack,
    apCost: 3,
    damage: 10,
    description: '10 데미지 + 약화 3턴 + 취약 2턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 3),
      CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 2),
    ],
    targetType: CardTargetType.all,
  );

  /// 무한 거울 — 1AP, 마지막 Attack 카드 복사. Exhaust. 보상.
  static const infiniteMirror = CardData(
    id: 'illusionist_infinite_mirror',
    name: '무한 거울',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    description: '마지막 Attack 카드 복사. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.copyLastAttack, value: 0)],
  );

  /// 환영의 분신 — 1AP, 블록 6 + 다음 피격 시 데미지 50% 감소 + 랜덤 카드 1장. 보상.
  static const phantom = CardData(
    id: 'illusionist_phantom',
    name: '환영의 분신',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '블록 6 + 다음 피격 50% 감소 + 랜덤 카드 1장',
    effects: [
      CardEffect(type: CardEffectType.nextHitDamageReduction, value: 50),
      CardEffect(type: CardEffectType.generateRandomCard, value: 1),
    ],
  );

  /// 시작 카드 5장 (환술사 전용).
  static const List<CardData> starter = [
    phantomStrike,
    mirrorShield,
    clone,
    hallucination,
    magicCard,
  ];

  /// 보상 카드 10장.
  static const List<CardData> rewards = [
    dimensionShift,
    perfectCopy,
    phantomArmy,
    phantomWall,
    multiClone,
    realityWarp,
    mirrorMaze,
    hallucinationStorm,
    infiniteMirror,
    phantom,
  ];

  /// 전체 15장.
  static const List<CardData> all = [
    phantomStrike,
    mirrorShield,
    clone,
    hallucination,
    magicCard,
    dimensionShift,
    perfectCopy,
    phantomArmy,
    phantomWall,
    multiClone,
    realityWarp,
    mirrorMaze,
    hallucinationStorm,
    infiniteMirror,
    phantom,
  ];

  // ── 업그레이드 버전 ──

  static const phantomStrikePlus = CardData(
    id: 'illusionist_phantom_strike+',
    name: '환영 타격+',
    jobId: 'illusionist',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: '10 데미지 + 랜덤 카드 1장 생성',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 1)],
  );

  static const mirrorShieldPlus = CardData(
    id: 'illusionist_mirror_shield+',
    name: '거울 방패+',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    block: 12,
    description: '블록 12 + 적 마지막 행동 복사',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.mimicEnemyDamage, value: 1)],
  );

  static const clonePlus = CardData(
    id: 'illusionist_clone+',
    name: '분신술+',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 0,
    description: '마지막 플레이 카드 복사. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.copyLastAttack, value: 1)],
  );

  static const hallucinationPlus = CardData(
    id: 'illusionist_hallucination+',
    name: '환각+',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '적 약화 2턴 + 취약 2턴 + 블록 6',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 2),
      CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 2),
    ],
  );

  static const magicCardPlus = CardData(
    id: 'illusionist_magic_card+',
    name: '마법 카드+',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 0,
    description: '랜덤 카드 2장 손패 추가',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 2)],
  );

  static const dimensionShiftPlus = CardData(
    id: 'illusionist_dimension_shift+',
    name: '차원 전환+',
    jobId: 'illusionist',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 손패 1장을 랜덤 카드로 변환',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.transformHandPerTurn, value: 1)],
  );

  static const perfectCopyPlus = CardData(
    id: 'illusionist_perfect_copy+',
    name: '완벽한 복제+',
    jobId: 'illusionist',
    type: CardType.attack,
    apCost: 2,
    description: '마지막 사용 카드 3번 재실행. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.replayLastCard, value: 3)],
  );

  static const phantomArmyPlus = CardData(
    id: 'illusionist_phantom_army+',
    name: '허상의 군단+',
    jobId: 'illusionist',
    type: CardType.power,
    apCost: 3,
    description: '매 턴 랜덤 공격 카드 2장 생성',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.generateAttackPerTurn, value: 2)],
  );

  static const phantomWallPlus = CardData(
    id: 'illusionist_phantom_wall+',
    name: '환영의 벽+',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    block: 14,
    description: '블록 14 + 랜덤 카드 2장 생성',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 2)],
  );

  static const multiClonePlus = CardData(
    id: 'illusionist_multi_clone+',
    name: '다중 분신+',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 2,
    description: '마지막 카드 복사 4번. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.replayLastCard, value: 4)],
  );

  static const realityWarpPlus = CardData(
    id: 'illusionist_reality_warp+',
    name: '현실 왜곡+',
    jobId: 'illusionist',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    description: '12 데미지 + 약화 2턴 + 카드 1장 생성',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 2),
      CardEffect(type: CardEffectType.generateRandomCard, value: 1),
    ],
  );

  static const mirrorMazePlus = CardData(
    id: 'illusionist_mirror_maze+',
    name: '거울의 미로+',
    jobId: 'illusionist',
    type: CardType.power,
    apCost: 2,
    description: '피격 시 50% 확률 데미지 반사 + 반사 시 HP 5 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.reflectDamageChance, value: 50),
      CardEffect(type: CardEffectType.healOnReflect, value: 5),
    ],
  );

  static const hallucinationStormPlus = CardData(
    id: 'illusionist_hallucination_storm+',
    name: '환각 폭풍+',
    jobId: 'illusionist',
    type: CardType.attack,
    apCost: 3,
    damage: 15,
    description: '15 데미지 + 약화 4턴 + 취약 3턴. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    targetType: CardTargetType.all,
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 4),
      CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 3),
    ],
  );

  static const infiniteMirrorPlus = CardData(
    id: 'illusionist_infinite_mirror+',
    name: '무한 거울+',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 0,
    description: '마지막 Attack 카드 복사. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.copyLastAttack, value: 0)],
  );

  /// 환영의 분신+ — 블록 8 + 다음 피격 50% 감소 + 랜덤 카드 1장.
  static const phantomPlus = CardData(
    id: 'illusionist_phantom+',
    name: '환영의 분신+',
    jobId: 'illusionist',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 다음 피격 50% 감소 + 랜덤 카드 1장',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.nextHitDamageReduction, value: 50),
      CardEffect(type: CardEffectType.generateRandomCard, value: 1),
    ],
  );
}
