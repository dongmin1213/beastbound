import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 검성 카드 — 극한 공격력 + 자해 극대화. 시작 5장.
class SwordSaintCards {
  SwordSaintCards._();

  /// 검기 — 1AP, 15 데미지 + 힘 +1. 시작.
  static const swordAura = CardData(
    id: 'sword_saint_sword_aura',
    name: '검기',
    jobId: 'swordSaint',
    type: CardType.attack,
    apCost: 1,
    damage: 15,
    description: '15 데미지 + 힘 +1',
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 1)],
  );

  /// 절명참 — 2AP, 25 데미지, HP -5. HP <30% 시 +15 데미지. 시작.
  static const fatalSlash = CardData(
    id: 'sword_saint_fatal_slash',
    name: '절명참',
    jobId: 'swordSaint',
    type: CardType.attack,
    apCost: 2,
    damage: 25,
    description: 'HP -5, 25 데미지. HP <30% 시 +15 데미지',
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 5),
      CardEffect(type: CardEffectType.conditionalDamage, value: 15, condition: 'lowHp'),
    ],
  );

  /// 검성의 기합 — 0AP, 2장 드로우 + 힘 +1. 소진. 시작.
  static const swordFocus = CardData(
    id: 'sword_saint_sword_focus',
    name: '검성의 기합',
    jobId: 'swordSaint',
    type: CardType.skill,
    apCost: 0,
    description: '2장 드로우 + 힘 +1. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.draw, value: 2),
      CardEffect(type: CardEffectType.gainStrength, value: 1),
    ],
  );

  /// 만검귀종 — 3AP, 8 데미지 × 4회. 시작.
  static const thousandBlades = CardData(
    id: 'sword_saint_thousand_blades',
    name: '만검귀종',
    jobId: 'swordSaint',
    type: CardType.attack,
    apCost: 3,
    description: '8 데미지 × 4회',
    effects: [CardEffect(type: CardEffectType.multiHit, value: 8, duration: 4)],
  );

  /// 검의 도 — 2AP, 힘 +2. 모든 Attack에 20% 흡혈. 시작.
  static const wayOfSword = CardData(
    id: 'sword_saint_way_of_sword',
    name: '검의 도',
    jobId: 'swordSaint',
    type: CardType.power,
    apCost: 2,
    description: '힘 +2. 모든 공격에 20% 흡혈',
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 2),
      CardEffect(type: CardEffectType.lifestealOnAllAttacks, value: 20),
    ],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    swordAura,
    fatalSlash,
    swordFocus,
    thousandBlades,
    wayOfSword,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const swordAuraPlus = CardData(
    id: 'sword_saint_sword_aura+',
    name: '검기+',
    jobId: 'swordSaint',
    type: CardType.attack,
    apCost: 1,
    damage: 20,
    description: '20 데미지 + 힘 +2',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 2)],
  );

  static const fatalSlashPlus = CardData(
    id: 'sword_saint_fatal_slash+',
    name: '절명참+',
    jobId: 'swordSaint',
    type: CardType.attack,
    apCost: 2,
    damage: 32,
    description: 'HP -5, 32 데미지. HP <30% 시 +20 데미지',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 5),
      CardEffect(type: CardEffectType.conditionalDamage, value: 20, condition: 'lowHp'),
    ],
  );

  static const swordFocusPlus = CardData(
    id: 'sword_saint_sword_focus+',
    name: '검성의 기합+',
    jobId: 'swordSaint',
    type: CardType.skill,
    apCost: 0,
    description: '3장 드로우 + 힘 +2. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.draw, value: 3),
      CardEffect(type: CardEffectType.gainStrength, value: 2),
    ],
  );

  static const thousandBladesPlus = CardData(
    id: 'sword_saint_thousand_blades+',
    name: '만검귀종+',
    jobId: 'swordSaint',
    type: CardType.attack,
    apCost: 3,
    description: '10 데미지 × 4회',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.multiHit, value: 10, duration: 4)],
  );

  static const wayOfSwordPlus = CardData(
    id: 'sword_saint_way_of_sword+',
    name: '검의 도+',
    jobId: 'swordSaint',
    type: CardType.power,
    apCost: 2,
    description: '힘 +3. 모든 공격에 25% 흡혈',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 3),
      CardEffect(type: CardEffectType.lifestealOnAllAttacks, value: 25),
    ],
  );
}
