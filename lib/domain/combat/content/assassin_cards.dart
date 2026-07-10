import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 암살자 카드 — 독 + 선제 + 은신. 시작 5장 + 보상 11장 = 16장.
class AssassinCards {
  AssassinCards._();

  /// 기습 — 1AP, 12 데미지. 1턴째만 사용 가능. Innate. 시작.
  static const ambush = CardData(
    id: 'assassin_ambush',
    name: '기습',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    description: '12 데미지. 1턴째만. 적 HP ≤15% 즉사',
    keywords: {CardKeyword.innate},
    effects: [
      CardEffect(type: CardEffectType.playRestriction, value: 0, condition: 'firstTurnOnly'),
      CardEffect(type: CardEffectType.executeHpPercent, value: 15),
    ],
  );

  /// 독날 — 1AP, 6 데미지 + 독 3. 시작.
  static const poisonBlade = CardData(
    id: 'assassin_poison_blade',
    name: '독날',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 1,
    damage: 6,
    description: '6 데미지 + 독 3',
    effects: [CardEffect(type: CardEffectType.applyPoison, value: 3)],
  );

  /// 은신 — 1AP, 블록 3 + 이번 턴 피해 무효. 2턴 쿨다운. 시작.
  static const stealth = CardData(
    id: 'assassin_stealth',
    name: '은신',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    block: 3,
    description: '블록 3 + 이번 턴 피해 무효. 2턴 쿨다운',
    effects: [
      CardEffect(type: CardEffectType.immuneThisTurn, value: 0),
      CardEffect(type: CardEffectType.cooldownAfterUse, value: 2),
    ],
  );

  /// 그림자 — 1AP, 다음 공격 데미지 2배. 시작.
  static const shadow = CardData(
    id: 'assassin_shadow',
    name: '그림자',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    description: '다음 공격 데미지 2배',
    effects: [CardEffect(type: CardEffectType.doubleNextAttack, value: 0)],
  );

  /// 연환격 — 0AP, 4 데미지. 이번 턴 공격 후에만. 시작.
  static const chainStrike = CardData(
    id: 'assassin_chain_strike',
    name: '연환격',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 0,
    damage: 4,
    description: '4 데미지. 공격 후에만',
    effects: [
      CardEffect(
          type: CardEffectType.playRestriction, value: 0, condition: 'chainAttackOnly'),
    ],
  );

  /// 독안개 — 1AP, 매 턴 시작 시 적에게 독 2. Power. 보상.
  static const poisonCloud = CardData(
    id: 'assassin_poison_cloud',
    name: '독안개',
    jobId: 'assassin',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 시작 시 적에게 독 2',
    effects: [CardEffect(type: CardEffectType.setPoisonPerTurn, value: 2)],
    targetType: CardTargetType.all,
  );

  /// 암살 — 2AP, 독 수치 × 2 데미지. Exhaust. 보상.
  static const assassination = CardData(
    id: 'assassin_assassination',
    name: '암살',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 2,
    description: '적 독 × 2 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.poisonMultiplierDamage, value: 2)],
  );

  /// 그림자 분신 — 1AP, 마지막 공격 복사. Exhaust. 보상.
  static const shadowClone = CardData(
    id: 'assassin_shadow_clone',
    name: '그림자 분신',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    description: '마지막 공격 카드 복사. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.copyLastAttack, value: 0)],
  );

  /// 독 폭발 — 1AP, 적 독 스택 전부 즉시 데미지 전환. 보상.
  static const poisonBurst = CardData(
    id: 'assassin_poison_burst',
    name: '독 폭발',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 1,
    description: '적 독 스택 전부 즉시 데미지 전환',
    effects: [CardEffect(type: CardEffectType.poisonBurst, value: 100)],
    targetType: CardTargetType.all,
  );

  /// 그림자 걸음 — 1AP, 블록 6 + 이번 턴 60% 피격 회피 + 회피 시 기세 +10. 보상.
  static const shadowStep = CardData(
    id: 'assassin_shadow_step',
    name: '그림자 걸음',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '블록 6 + 이번 턴 60% 피격 회피 + 회피 시 기세 +10',
    effects: [
      CardEffect(type: CardEffectType.dodgeChance, value: 60),
      CardEffect(type: CardEffectType.momentumGainOnDodge, value: 10),
    ],
  );

  /// 급소 공격 — 2AP, 16 데미지 + 적 취약 1턴. 보상.
  static const vitalStrike = CardData(
    id: 'assassin_vital_strike',
    name: '급소 공격',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 2,
    damage: 16,
    description: '16 데미지 + 적 취약 1턴',
    effects: [CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 1)],
  );

  /// 독무화과 — 1AP, 독 5 + HP 8 회복. 보상.
  static const poisonFig = CardData(
    id: 'assassin_poison_fig',
    name: '독무화과',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    description: '독 5 + HP 8 회복',
    effects: [
      CardEffect(type: CardEffectType.applyPoison, value: 5),
      CardEffect(type: CardEffectType.heal, value: 8),
    ],
  );

  /// 칼날 비 — 2AP, 4 데미지 × 5회. 보상.
  static const bladeRain = CardData(
    id: 'assassin_blade_rain',
    name: '칼날 비',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 2,
    description: '4 데미지 × 5회',
    effects: [CardEffect(type: CardEffectType.multiHit, value: 4, duration: 5)],
    targetType: CardTargetType.all,
  );

  /// 어둠의 망토 — 2AP, 매 턴 시작: 30% 확률 피격 회피. 보상.
  static const darkCloak = CardData(
    id: 'assassin_dark_cloak',
    name: '어둠의 망토',
    jobId: 'assassin',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 시작: 30% 확률 피격 회피',
    effects: [CardEffect(type: CardEffectType.dodgeChance, value: 30)],
  );

  /// 독의 보호 — 1AP, Power. 적 독 스택 2당 받는 데미지 -1 (최대 -5). 보상.
  static const toxicGuard = CardData(
    id: 'assassin_toxic_guard',
    name: '독의 보호',
    jobId: 'assassin',
    type: CardType.power,
    apCost: 1,
    description: '적 독 스택 2당 받는 데미지 -1 (최대 -5)',
    effects: [CardEffect(type: CardEffectType.poisonDamageReduction, value: 2, condition: '5')],
  );

  /// 그림자 도약 — 0AP, 이번 턴 다음 피격 1회 무효. Exhaust. Innate. 보상.
  static const shadowLeap = CardData(
    id: 'assassin_shadow_leap',
    name: '그림자 도약',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 0,
    description: '이번 턴 다음 피격 1회 무효. 소진',
    keywords: {CardKeyword.exhaust, CardKeyword.innate},
    effects: [CardEffect(type: CardEffectType.immuneNextHits, value: 1)],
  );

  /// 시작 카드 5장 (공통 제외, 암살자 전용).
  static const List<CardData> starter = [
    ambush,
    poisonBlade,
    stealth,
    shadow,
    chainStrike,
  ];

  /// 보상 카드 11장.
  static const List<CardData> rewards = [
    poisonCloud,
    assassination,
    shadowClone,
    poisonBurst,
    shadowStep,
    vitalStrike,
    poisonFig,
    bladeRain,
    darkCloak,
    toxicGuard,
    shadowLeap,
  ];

  /// 전체 16장.
  static const List<CardData> all = [
    ambush,
    poisonBlade,
    stealth,
    shadow,
    chainStrike,
    poisonCloud,
    assassination,
    shadowClone,
    poisonBurst,
    shadowStep,
    vitalStrike,
    poisonFig,
    bladeRain,
    darkCloak,
    toxicGuard,
    shadowLeap,
  ];

  // ── 업그레이드 버전 ──

  static const ambushPlus = CardData(
    id: 'assassin_ambush+',
    name: '기습+',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 1,
    damage: 16,
    description: '16 데미지. 1턴째만. 적 HP ≤20% 즉사',
    upgraded: true,
    keywords: {CardKeyword.innate},
    effects: [
      CardEffect(type: CardEffectType.playRestriction, value: 0, condition: 'firstTurnOnly'),
      CardEffect(type: CardEffectType.executeHpPercent, value: 20),
    ],
  );

  static const poisonBladePlus = CardData(
    id: 'assassin_poison_blade+',
    name: '독날+',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 1,
    damage: 8,
    description: '8 데미지 + 독 4',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.applyPoison, value: 4)],
  );

  /// 은신+ — 블록 3 + 이번 턴 피해 무효 + 1장 드로우. 1턴 쿨다운.
  static const stealthPlus = CardData(
    id: 'assassin_stealth+',
    name: '은신+',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    block: 3,
    description: '블록 3 + 이번 턴 피해 무효 + 1장 드로우. 1턴 쿨다운',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.immuneThisTurn, value: 0),
      CardEffect(type: CardEffectType.draw, value: 1),
      CardEffect(type: CardEffectType.cooldownAfterUse, value: 1),
    ],
  );

  /// 그림자+ — + 1장 드로우.
  static const shadowPlus = CardData(
    id: 'assassin_shadow+',
    name: '그림자+',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    description: '다음 공격 데미지 2배 + 1장 드로우',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.doubleNextAttack, value: 0),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  static const chainStrikePlus = CardData(
    id: 'assassin_chain_strike+',
    name: '연환격+',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 0,
    damage: 7,
    description: '7 데미지. 공격 후에만',
    upgraded: true,
    effects: [
      CardEffect(
          type: CardEffectType.playRestriction, value: 0, condition: 'chainAttackOnly'),
    ],
  );

  /// 독안개+ — 독 3.
  static const poisonCloudPlus = CardData(
    id: 'assassin_poison_cloud+',
    name: '독안개+',
    jobId: 'assassin',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 시작 시 적에게 독 3',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.setPoisonPerTurn, value: 3)],
    targetType: CardTargetType.all,
  );

  /// 암살+ — × 3.
  static const assassinationPlus = CardData(
    id: 'assassin_assassination+',
    name: '암살+',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 2,
    description: '적 독 × 3 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.poisonMultiplierDamage, value: 3)],
  );

  /// 그림자 분신+ — Exhaust 없음.
  static const shadowClonePlus = CardData(
    id: 'assassin_shadow_clone+',
    name: '그림자 분신+',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    description: '마지막 공격 카드 복사',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.copyLastAttack, value: 0)],
  );

  static const poisonBurstPlus = CardData(
    id: 'assassin_poison_burst+',
    name: '독 폭발+',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 1,
    description: '적 독 × 1.5 즉시 데미지 전환',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.poisonBurst, value: 150)],
    targetType: CardTargetType.all,
  );

  static const shadowStepPlus = CardData(
    id: 'assassin_shadow_step+',
    name: '그림자 걸음+',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 이번 턴 70% 피격 회피 + 회피 시 기세 +15',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.dodgeChance, value: 70),
      CardEffect(type: CardEffectType.momentumGainOnDodge, value: 15),
    ],
  );

  static const vitalStrikePlus = CardData(
    id: 'assassin_vital_strike+',
    name: '급소 공격+',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 2,
    damage: 22,
    description: '22 데미지 + 적 취약 1턴',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 1)],
  );

  static const poisonFigPlus = CardData(
    id: 'assassin_poison_fig+',
    name: '독무화과+',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 1,
    description: '독 7 + HP 12 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.applyPoison, value: 7),
      CardEffect(type: CardEffectType.heal, value: 12),
    ],
  );

  static const bladeRainPlus = CardData(
    id: 'assassin_blade_rain+',
    name: '칼날 비+',
    jobId: 'assassin',
    type: CardType.attack,
    apCost: 2,
    description: '5 데미지 × 5회',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.multiHit, value: 5, duration: 5)],
    targetType: CardTargetType.all,
  );

  static const darkCloakPlus = CardData(
    id: 'assassin_dark_cloak+',
    name: '어둠의 망토+',
    jobId: 'assassin',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 시작: 40% 확률 피격 회피',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.dodgeChance, value: 40)],
  );


  /// 독의 보호+ — 독 스택 1당 -1 (최대 -8).
  static const toxicGuardPlus = CardData(
    id: 'assassin_toxic_guard+',
    name: '독의 보호+',
    jobId: 'assassin',
    type: CardType.power,
    apCost: 1,
    description: '적 독 스택 1당 받는 데미지 -1 (최대 -8)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.poisonDamageReduction, value: 1, condition: '8')],
  );

  /// 그림자 도약+ — 다음 피격 2회 무효.
  static const shadowLeapPlus = CardData(
    id: 'assassin_shadow_leap+',
    name: '그림자 도약+',
    jobId: 'assassin',
    type: CardType.skill,
    apCost: 0,
    description: '이번 턴 다음 피격 2회 무효. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust, CardKeyword.innate},
    effects: [CardEffect(type: CardEffectType.immuneNextHits, value: 2)],
  );

}
