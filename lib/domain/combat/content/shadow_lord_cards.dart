import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 그림자군주 카드 — 최대 독 + 완전 은신. 시작 5장.
class ShadowLordCards {
  ShadowLordCards._();

  /// 그림자 폭풍 — 2AP, 5 데미지 × 4회 + 각 히트 독 2. 시작.
  static const shadowStorm = CardData(
    id: 'shadow_lord_shadow_storm',
    name: '그림자 폭풍',
    jobId: 'shadowLord',
    type: CardType.attack,
    apCost: 2,
    description: '5 데미지 × 4회 + 각 히트 독 2',
    effects: [CardEffect(type: CardEffectType.multiHitWithPoison, value: 5, duration: 4, condition: '2')],
  );

  /// 완전 은신 — 1AP, 이번 턴 무적 + 1장 드로우. 3턴 쿨다운. 시작.
  static const perfectStealth = CardData(
    id: 'shadow_lord_perfect_stealth',
    name: '완전 은신',
    jobId: 'shadowLord',
    type: CardType.skill,
    apCost: 1,
    description: '이번 턴 무적 + 1장 드로우. 3턴 쿨다운',
    effects: [
      CardEffect(type: CardEffectType.immuneThisTurn, value: 1),
      CardEffect(type: CardEffectType.draw, value: 1),
      CardEffect(type: CardEffectType.cooldownAfterUse, value: 3),
    ],
  );

  /// 독의 지배 — 1AP, 독 효과 +50% Power. 시작.
  static const poisonDominion = CardData(
    id: 'shadow_lord_poison_dominion',
    name: '독의 지배',
    jobId: 'shadowLord',
    type: CardType.power,
    apCost: 1,
    description: '독 효과 +50%',
    effects: [CardEffect(type: CardEffectType.poisonEffectivenessBoost, value: 50)],
  );

  /// 암살 — 2AP, 적 독 × 3 데미지. 소진. 시작.
  static const assassination = CardData(
    id: 'shadow_lord_assassination',
    name: '암살',
    jobId: 'shadowLord',
    type: CardType.attack,
    apCost: 2,
    description: '적 독 스택 × 3 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.poisonStackMultiplierDamage, value: 3)],
  );

  /// 그림자 왕좌 — 2AP, 40% 회피 + 매 턴 독 3. Power. 시작.
  static const shadowThrone = CardData(
    id: 'shadow_lord_shadow_throne',
    name: '그림자 왕좌',
    jobId: 'shadowLord',
    type: CardType.power,
    apCost: 2,
    description: '40% 회피 + 매 턴 독 3',
    effects: [CardEffect(type: CardEffectType.poisonPerTurnAndDodge, value: 3, condition: '40')],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    shadowStorm,
    perfectStealth,
    poisonDominion,
    assassination,
    shadowThrone,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const shadowStormPlus = CardData(
    id: 'shadow_lord_shadow_storm+',
    name: '그림자 폭풍+',
    jobId: 'shadowLord',
    type: CardType.attack,
    apCost: 2,
    description: '7 데미지 × 4회 + 각 히트 독 3',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.multiHitWithPoison, value: 7, duration: 4, condition: '3')],
  );

  static const perfectStealthPlus = CardData(
    id: 'shadow_lord_perfect_stealth+',
    name: '완전 은신+',
    jobId: 'shadowLord',
    type: CardType.skill,
    apCost: 1,
    description: '이번 턴 무적 + 2장 드로우. 2턴 쿨다운',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.immuneThisTurn, value: 1),
      CardEffect(type: CardEffectType.draw, value: 2),
      CardEffect(type: CardEffectType.cooldownAfterUse, value: 2),
    ],
  );

  static const poisonDominionPlus = CardData(
    id: 'shadow_lord_poison_dominion+',
    name: '독의 지배+',
    jobId: 'shadowLord',
    type: CardType.power,
    apCost: 1,
    description: '독 효과 +75%',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.poisonEffectivenessBoost, value: 75)],
  );

  static const assassinationPlus = CardData(
    id: 'shadow_lord_assassination+',
    name: '암살+',
    jobId: 'shadowLord',
    type: CardType.attack,
    apCost: 2,
    description: '적 독 스택 × 4 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.poisonStackMultiplierDamage, value: 4)],
  );

  static const shadowThronePlus = CardData(
    id: 'shadow_lord_shadow_throne+',
    name: '그림자 왕좌+',
    jobId: 'shadowLord',
    type: CardType.power,
    apCost: 2,
    description: '50% 회피 + 매 턴 독 4',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.poisonPerTurnAndDodge, value: 4, condition: '50')],
  );
}
