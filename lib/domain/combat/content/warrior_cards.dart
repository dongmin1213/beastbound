import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 전사 카드 — 흡혈 전사. 시작 5장 + 보상 10장 = 15장.
class WarriorCards {
  WarriorCards._();

  /// 강타 — 2AP, HP -3, 18 데미지. 시작.
  static const heavyStrike = CardData(
    id: 'warrior_heavy_strike',
    name: '강타',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 2,
    damage: 18,
    description: 'HP -3, 18 데미지',
    effects: [CardEffect(type: CardEffectType.selfDamage, value: 3)],
  );

  /// 전쟁함성 — 1AP, 힘 +2 (영구). 시작.
  static const warCry = CardData(
    id: 'warrior_war_cry',
    name: '전쟁함성',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 1,
    description: '힘 +2',
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 2)],
  );

  /// 돌진 — 1AP, 8 데미지 + 힘 +1 + 1장 드로우. 시작.
  static const charge = CardData(
    id: 'warrior_charge',
    name: '돌진',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 1,
    damage: 8,
    description: '8 데미지 + 힘 +1 + 1장 드로우',
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 1),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 맹공 — 1AP, 기세 티어 × 5 데미지 + 기세 +5. 시작.
  static const onslaught = CardData(
    id: 'warrior_onslaught',
    name: '맹공',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 1,
    description: '기세 티어 × 5 데미지 + 기세 +5',
    effects: [
      CardEffect(type: CardEffectType.conditionalDamage, value: 5, condition: 'momentumTier'),
      CardEffect(type: CardEffectType.momentumGain, value: 5),
    ],
  );

  /// 분쇄 — 2AP, 10 데미지. HP <50% 시 힘 +2. 시작.
  static const crush = CardData(
    id: 'warrior_crush',
    name: '분쇄',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 2,
    damage: 10,
    description: '10 데미지. HP <50% 시 힘 +2',
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 2, condition: 'lowHp')],
  );

  /// 광전사 — 1AP, HP <50% 시 힘 +3 + 모든 Attack에 15% 흡혈. 보상.
  static const berserker = CardData(
    id: 'warrior_berserker',
    name: '광전사',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 1,
    description: 'HP <50% 시 힘 +3 + 모든 공격에 15% 흡혈',
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 3, condition: 'lowHp'),
      CardEffect(type: CardEffectType.lifestealOnAllAttacks, value: 15),
    ],
  );

  /// 피의 맹세 — 0AP, HP -4, 힘 +3, 1장 드로우. Exhaust. 보상.
  static const bloodOath = CardData(
    id: 'warrior_blood_oath',
    name: '피의 맹세',
    jobId: 'warrior',
    type: CardType.skill,
    apCost: 0,
    description: 'HP -4, 힘 +3, 1장 드로우. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 4),
      CardEffect(type: CardEffectType.gainStrength, value: 3),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 회전참 — 2AP, 5 데미지 × 3회. 보상.
  static const spinSlash = CardData(
    id: 'warrior_spin_slash',
    name: '회전참',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 2,
    description: '5 데미지 × 3회',
    effects: [CardEffect(type: CardEffectType.multiHit, value: 5, duration: 3)],
    targetType: CardTargetType.all,
  );

  /// 피의 일격 — 1AP, 12 데미지, 준 데미지의 40% HP 회복. 보상.
  static const bloodStrike = CardData(
    id: 'warrior_blood_strike',
    name: '피의 일격',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    description: '12 데미지. 준 데미지의 40% HP 회복',
    effects: [CardEffect(type: CardEffectType.lifesteal, value: 40)],
  );

  /// 분노의 함성 — 1AP, 블록 8 + 힘 +1. 보상.
  static const rageShout = CardData(
    id: 'warrior_rage_shout',
    name: '분노의 함성',
    jobId: 'warrior',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 힘 +1',
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 1)],
  );

  /// 철의 의지 — 2AP, 매 턴: 잃은 HP의 5%만큼 블록 획득. 보상.
  static const ironWill = CardData(
    id: 'warrior_iron_will',
    name: '철의 의지',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 2,
    description: '매 턴: 잃은 HP의 5%만큼 블록 획득',
    effects: [CardEffect(type: CardEffectType.lostHpToBlockPerTurn, value: 5)],
  );

  /// 처형 — 2AP, 적 HP ≤50%: 30 데미지, 아니면 10. 보상.
  static const execute = CardData(
    id: 'warrior_execute',
    name: '처형',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 2,
    description: '적 HP ≤50%: 30 데미지, 아니면 10',
    effects: [
      CardEffect(type: CardEffectType.conditionalDamageEnemyHp, value: 30, duration: 10),
    ],
  );

  /// 전장의 고동 — 0AP, 이번 턴 공격 횟수 × 4 HP 회복. 보상.
  static const battlePulse = CardData(
    id: 'warrior_battle_pulse',
    name: '전장의 고동',
    jobId: 'warrior',
    type: CardType.skill,
    apCost: 0,
    description: '이번 턴 공격 횟수 × 4 HP 회복',
    effects: [CardEffect(type: CardEffectType.healPerAttackPlayed, value: 4)],
  );

  /// 전투의 고동 — 1AP, Power. 힘 ≥2일 때 매 턴 시작 시 HP 3 회복. 보상.
  static const warPulse = CardData(
    id: 'warrior_war_pulse',
    name: '전투의 고동',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 1,
    description: '힘 ≥2일 때 매 턴 HP 3 회복',
    effects: [
      CardEffect(type: CardEffectType.healPerTurnConditional, value: 3, condition: 'strengthGte2'),
    ],
  );

  /// 각성 — 2AP, 힘 +3. HP ≤50% 시 추가 힘 +2. 보상.
  static const awakening = CardData(
    id: 'warrior_awakening',
    name: '각성',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 2,
    description: '힘 +3. HP ≤50% 시 추가 힘 +2',
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 3),
      CardEffect(type: CardEffectType.gainStrength, value: 2, condition: 'lowHp'),
    ],
  );

  /// 시작 카드 5장 (공통 제외, 전사 전용).
  static const List<CardData> starter = [
    heavyStrike,
    warCry,
    charge,
    onslaught,
    crush,
  ];

  /// 보상 카드 10장.
  static const List<CardData> rewards = [
    berserker,
    bloodOath,
    spinSlash,
    bloodStrike,
    rageShout,
    ironWill,
    execute,
    battlePulse,
    warPulse,
    awakening,
  ];

  /// 전체 15장.
  static const List<CardData> all = [
    heavyStrike,
    warCry,
    charge,
    onslaught,
    crush,
    berserker,
    bloodOath,
    spinSlash,
    bloodStrike,
    rageShout,
    ironWill,
    execute,
    battlePulse,
    warPulse,
    awakening,
  ];

  // ── 업그레이드 버전 ──

  static const heavyStrikePlus = CardData(
    id: 'warrior_heavy_strike+',
    name: '강타+',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 2,
    damage: 24,
    description: 'HP -3, 24 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.selfDamage, value: 3)],
  );

  static const warCryPlus = CardData(
    id: 'warrior_war_cry+',
    name: '전쟁함성+',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 1,
    description: '힘 +3',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 3)],
  );

  static const chargePlus = CardData(
    id: 'warrior_charge+',
    name: '돌진+',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 1,
    damage: 11,
    description: '11 데미지 + 힘 +1 + 1장 드로우',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 1),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  static const onslaughtPlus = CardData(
    id: 'warrior_onslaught+',
    name: '맹공+',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 1,
    description: '기세 티어 × 7 데미지 + 기세 +8',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.conditionalDamage, value: 7, condition: 'momentumTier'),
      CardEffect(type: CardEffectType.momentumGain, value: 8),
    ],
  );

  static const crushPlus = CardData(
    id: 'warrior_crush+',
    name: '분쇄+',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 2,
    damage: 14,
    description: '14 데미지. HP <50% 시 힘 +3',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 3, condition: 'lowHp')],
  );

  static const berserkerPlus = CardData(
    id: 'warrior_berserker+',
    name: '광전사+',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 1,
    description: 'HP <50% 시 힘 +4 + 모든 공격에 20% 흡혈',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 4, condition: 'lowHp'),
      CardEffect(type: CardEffectType.lifestealOnAllAttacks, value: 20),
    ],
  );

  static const bloodOathPlus = CardData(
    id: 'warrior_blood_oath+',
    name: '피의 맹세+',
    jobId: 'warrior',
    type: CardType.skill,
    apCost: 0,
    description: 'HP -4, 힘 +4, 1장 드로우. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 4),
      CardEffect(type: CardEffectType.gainStrength, value: 4),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  static const spinSlashPlus = CardData(
    id: 'warrior_spin_slash+',
    name: '회전참+',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 2,
    description: '6 데미지 × 3회',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.multiHit, value: 6, duration: 3)],
    targetType: CardTargetType.all,
  );

  static const bloodStrikePlus = CardData(
    id: 'warrior_blood_strike+',
    name: '피의 일격+',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 1,
    damage: 16,
    description: '16 데미지. 준 데미지의 50% HP 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.lifesteal, value: 50)],
  );

  static const rageShoutPlus = CardData(
    id: 'warrior_rage_shout+',
    name: '분노의 함성+',
    jobId: 'warrior',
    type: CardType.skill,
    apCost: 1,
    block: 12,
    description: '블록 12 + 힘 +2',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 2)],
  );

  static const ironWillPlus = CardData(
    id: 'warrior_iron_will+',
    name: '철의 의지+',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 2,
    description: '매 턴: 잃은 HP의 8%만큼 블록 획득',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.lostHpToBlockPerTurn, value: 8)],
  );

  static const executePlus = CardData(
    id: 'warrior_execute+',
    name: '처형+',
    jobId: 'warrior',
    type: CardType.attack,
    apCost: 2,
    description: '적 HP ≤50%: 35 데미지, 아니면 12',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.conditionalDamageEnemyHp, value: 35, duration: 12),
    ],
  );

  static const battlePulsePlus = CardData(
    id: 'warrior_battle_pulse+',
    name: '전장의 고동+',
    jobId: 'warrior',
    type: CardType.skill,
    apCost: 0,
    description: '이번 턴 공격 횟수 × 6 HP 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.healPerAttackPlayed, value: 6)],
  );

  static const warPulsePlus = CardData(
    id: 'warrior_war_pulse+',
    name: '전투의 고동+',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 1,
    description: '힘 ≥2일 때 매 턴 HP 4 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.healPerTurnConditional, value: 4, condition: 'strengthGte2'),
    ],
  );

  static const awakeningPlus = CardData(
    id: 'warrior_awakening+',
    name: '각성+',
    jobId: 'warrior',
    type: CardType.power,
    apCost: 2,
    description: '힘 +4. HP ≤50% 시 추가 힘 +3',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 4),
      CardEffect(type: CardEffectType.gainStrength, value: 3, condition: 'lowHp'),
    ],
  );
}
