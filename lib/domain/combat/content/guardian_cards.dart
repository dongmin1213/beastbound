import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 수호자 카드 — 블록 유지 + 가시 + 반격. 시작 5장 + 보상 10장 = 15장.
class GuardianCards {
  GuardianCards._();

  /// 방패 타격 — 1AP, 5 데미지 + 5 블록. 시작.
  static const shieldBash = CardData(
    id: 'guardian_shield_bash',
    name: '방패 타격',
    jobId: 'guardian',
    type: CardType.attack,
    apCost: 1,
    damage: 5,
    block: 5,
    description: '5 데미지 + 5 블록',
  );

  /// 철벽 방어 — 1AP, 10 블록 + 블록 40% 유지. 시작.
  static const ironGuard = CardData(
    id: 'guardian_iron_guard',
    name: '철벽 방어',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '10 블록 + 다음 턴 블록 40% 유지',
    effects: [CardEffect(type: CardEffectType.blockRetain, value: 40)],
  );

  /// 가시 갑옷 — 1AP, 가시 2 (영구). 시작.
  static const thornArmor = CardData(
    id: 'guardian_thorn_armor',
    name: '가시 갑옷',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 1,
    description: '가시 2 (영구)',
    effects: [CardEffect(type: CardEffectType.gainThorn, value: 2)],
  );

  /// 도발 — 1AP, 6 블록 + 적 약화 1턴. 시작.
  static const taunt = CardData(
    id: 'guardian_taunt',
    name: '도발',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '6 블록 + 적 약화 1턴',
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 1)],
  );

  /// 반격 태세 — 2AP, 12 블록 + 다음 턴 블록 60% 유지. 시작.
  static const counterStance = CardData(
    id: 'guardian_counter_stance',
    name: '반격 태세',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 2,
    block: 12,
    description: '12 블록 + 다음 턴 블록 60% 유지',
    effects: [CardEffect(type: CardEffectType.blockRetain, value: 60)],
  );

  /// 철벽 진영 — 2AP, 매 턴 시작 시 4 블록. 보상.
  static const fortress = CardData(
    id: 'guardian_fortress',
    name: '철벽 진영',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 시작 시 4 블록',
    effects: [CardEffect(type: CardEffectType.blockPerTurnStart, value: 4)],
  );

  /// 가시 폭발 — 1AP, 현재 가시 × 3 데미지. 보상.
  static const thornBurst = CardData(
    id: 'guardian_thorn_burst',
    name: '가시 폭발',
    jobId: 'guardian',
    type: CardType.attack,
    apCost: 1,
    description: '현재 가시 × 3 데미지',
    effects: [CardEffect(type: CardEffectType.thornMultiplierDamage, value: 3)],
  );

  /// 불굴 — 2AP, HP <40% 시 매 턴 시작 시 블록 15. 보상.
  static const unyielding = CardData(
    id: 'guardian_unyielding',
    name: '불굴',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 2,
    description: 'HP <40% 시 매 턴 시작 시 블록 15',
    effects: [
      CardEffect(
        type: CardEffectType.blockPerTurnStartConditional,
        value: 15,
        condition: 'lowHp',
      ),
    ],
  );

  /// 방벽 돌진 — 1AP, 현재 블록의 60% 데미지, 블록 유지. 보상.
  static const wallCharge = CardData(
    id: 'guardian_wall_charge',
    name: '방벽 돌진',
    jobId: 'guardian',
    type: CardType.attack,
    apCost: 1,
    description: '현재 블록의 60% 데미지, 블록 유지',
    effects: [CardEffect(type: CardEffectType.retribution, value: 60)],
  );

  /// 쇠사슬 — 1AP, 블록 4 + 적 약화 2턴. 보상.
  static const chains = CardData(
    id: 'guardian_chains',
    name: '쇠사슬',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 4,
    description: '블록 4 + 적 약화 2턴',
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 2)],
  );

  /// 보호의 맹세 — 2AP, 가시 +1, 매 턴 블록 3. 보상.
  static const oathOfProtection = CardData(
    id: 'guardian_oath_of_protection',
    name: '보호의 맹세',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 2,
    description: '가시 +1, 매 턴 블록 3',
    effects: [
      CardEffect(type: CardEffectType.gainThorn, value: 1),
      CardEffect(type: CardEffectType.blockPerTurnStart, value: 3),
    ],
  );

  /// 강철 의지 — 1AP, 블록 7 + 1장 드로우. 보상.
  static const steelWill = CardData(
    id: 'guardian_steel_will',
    name: '강철 의지',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 7,
    description: '블록 7 + 1장 드로우',
    effects: [CardEffect(type: CardEffectType.draw, value: 1)],
  );

  /// 대반격 — 2AP, 현재 블록의 40% 데미지. 보상.
  static const grandCounter = CardData(
    id: 'guardian_grand_counter',
    name: '대반격',
    jobId: 'guardian',
    type: CardType.attack,
    apCost: 2,
    description: '현재 블록의 40% 데미지',
    effects: [CardEffect(type: CardEffectType.retribution, value: 40)],
  );

  /// 요새화 — 1AP, 블록 5. 다음 턴 블록 80% 유지. 보상.
  static const fortify = CardData(
    id: 'guardian_fortify',
    name: '요새화',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 5,
    description: '블록 5. 다음 턴 블록 80% 유지',
    effects: [CardEffect(type: CardEffectType.blockRetain, value: 80)],
  );

  /// 철벽의 의지 — 2AP, Power. 블록 ≥15이면 피해 -3 + 매 턴 블록 3. 보상.
  static const ironWillPower = CardData(
    id: 'guardian_iron_will',
    name: '철벽의 의지',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 2,
    description: '블록 ≥15이면 피해 -3 + 매 턴 블록 3',
    effects: [
      CardEffect(type: CardEffectType.damageReductionWhenBlock, value: 3, condition: '15'),
      CardEffect(type: CardEffectType.blockPerTurnStart, value: 3),
    ],
  );

  /// 시작 카드 5장 (공통 제외, 수호자 전용).
  static const List<CardData> starter = [
    shieldBash,
    ironGuard,
    thornArmor,
    taunt,
    counterStance,
  ];

  /// 보상 카드 10장.
  static const List<CardData> rewards = [
    fortress,
    thornBurst,
    unyielding,
    wallCharge,
    chains,
    oathOfProtection,
    steelWill,
    grandCounter,
    fortify,
    ironWillPower,
  ];

  /// 전체 15장.
  static const List<CardData> all = [
    shieldBash,
    ironGuard,
    thornArmor,
    taunt,
    counterStance,
    fortress,
    thornBurst,
    unyielding,
    wallCharge,
    chains,
    oathOfProtection,
    steelWill,
    grandCounter,
    fortify,
    ironWillPower,
  ];

  // ── 업그레이드 버전 ──

  /// 방패 타격+ — 1AP, 8 데미지 + 8 블록.
  static const shieldBashPlus = CardData(
    id: 'guardian_shield_bash+',
    name: '방패 타격+',
    jobId: 'guardian',
    type: CardType.attack,
    apCost: 1,
    damage: 8,
    block: 8,
    description: '8 데미지 + 8 블록',
    upgraded: true,
  );

  /// 철벽 방어+ — 1AP, 14 블록 + 블록 50% 유지.
  static const ironGuardPlus = CardData(
    id: 'guardian_iron_guard+',
    name: '철벽 방어+',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 14,
    description: '14 블록 + 다음 턴 블록 50% 유지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockRetain, value: 50)],
  );

  /// 가시 갑옷+ — 1AP, 가시 3.
  static const thornArmorPlus = CardData(
    id: 'guardian_thorn_armor+',
    name: '가시 갑옷+',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 1,
    description: '가시 3 (영구)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainThorn, value: 3)],
  );

  /// 도발+ — 1AP, 8 블록 + 적 약화 2턴.
  static const tauntPlus = CardData(
    id: 'guardian_taunt+',
    name: '도발+',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '8 블록 + 적 약화 2턴',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 2)],
  );

  /// 반격 태세+ — 2AP, 16 블록 + 블록 60% 유지.
  static const counterStancePlus = CardData(
    id: 'guardian_counter_stance+',
    name: '반격 태세+',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 2,
    block: 16,
    description: '16 블록 + 다음 턴 블록 60% 유지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockRetain, value: 60)],
  );

  /// 철벽 진영+ — 2AP, 매 턴 6 블록.
  static const fortressPlus = CardData(
    id: 'guardian_fortress+',
    name: '철벽 진영+',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 시작 시 6 블록',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockPerTurnStart, value: 6)],
  );

  /// 가시 폭발+ — 1AP, 가시 × 5 데미지.
  static const thornBurstPlus = CardData(
    id: 'guardian_thorn_burst+',
    name: '가시 폭발+',
    jobId: 'guardian',
    type: CardType.attack,
    apCost: 1,
    description: '현재 가시 × 5 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.thornMultiplierDamage, value: 5)],
  );

  /// 불굴+ — 2AP, HP <40% 시 매 턴 블록 20.
  static const unyieldingPlus = CardData(
    id: 'guardian_unyielding+',
    name: '불굴+',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 2,
    description: 'HP <40% 시 매 턴 시작 시 블록 20',
    upgraded: true,
    effects: [
      CardEffect(
        type: CardEffectType.blockPerTurnStartConditional,
        value: 20,
        condition: 'lowHp',
      ),
    ],
  );

  /// 방벽 돌진+ — 1AP, 현재 블록의 80% 데미지, 블록 유지.
  static const wallChargePlus = CardData(
    id: 'guardian_wall_charge+',
    name: '방벽 돌진+',
    jobId: 'guardian',
    type: CardType.attack,
    apCost: 1,
    description: '현재 블록의 80% 데미지, 블록 유지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.retribution, value: 80)],
  );

  /// 쇠사슬+ — 1AP, 블록 6 + 적 약화 3턴.
  static const chainsPlus = CardData(
    id: 'guardian_chains+',
    name: '쇠사슬+',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '블록 6 + 적 약화 3턴',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 3)],
  );

  /// 보호의 맹세+ — 2AP, 가시 +2, 매 턴 블록 4.
  static const oathOfProtectionPlus = CardData(
    id: 'guardian_oath_of_protection+',
    name: '보호의 맹세+',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 2,
    description: '가시 +2, 매 턴 블록 4',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainThorn, value: 2),
      CardEffect(type: CardEffectType.blockPerTurnStart, value: 4),
    ],
  );

  /// 강철 의지+ — 1AP, 블록 10 + 2장 드로우.
  static const steelWillPlus = CardData(
    id: 'guardian_steel_will+',
    name: '강철 의지+',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '블록 10 + 2장 드로우',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.draw, value: 2)],
  );

  /// 대반격+ — 2AP, 현재 블록의 50% 데미지.
  static const grandCounterPlus = CardData(
    id: 'guardian_grand_counter+',
    name: '대반격+',
    jobId: 'guardian',
    type: CardType.attack,
    apCost: 2,
    description: '현재 블록의 50% 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.retribution, value: 50)],
  );

  /// 요새화+ — 1AP, 블록 8. 다음 턴 블록 80% 유지.
  static const fortifyPlus = CardData(
    id: 'guardian_fortify+',
    name: '요새화+',
    jobId: 'guardian',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8. 다음 턴 블록 80% 유지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockRetain, value: 80)],
  );

  /// 철벽의 의지+ — 피해 -4, 매 턴 블록 4.
  static const ironWillPowerPlus = CardData(
    id: 'guardian_iron_will+',
    name: '철벽의 의지+',
    jobId: 'guardian',
    type: CardType.power,
    apCost: 2,
    description: '블록 ≥15이면 피해 -4 + 매 턴 블록 4',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.damageReductionWhenBlock, value: 4, condition: '15'),
      CardEffect(type: CardEffectType.blockPerTurnStart, value: 4),
    ],
  );
}
