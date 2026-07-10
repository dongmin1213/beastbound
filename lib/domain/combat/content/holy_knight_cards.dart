import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 성기사 카드 — 공격과 치유를 동시에. 시작 5장.
class HolyKnightCards {
  HolyKnightCards._();

  /// 성스러운 검 — 1AP, 10 데미지 + HP 5 회복. 시작.
  static const holySword = CardData(
    id: 'holy_knight_holy_sword',
    name: '성스러운 검',
    jobId: 'holyKnight',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: '10 데미지 + HP 5 회복',
    effects: [CardEffect(type: CardEffectType.heal, value: 5)],
  );

  /// 수호의 기도 — 1AP, 블록 10 + HP 5 회복. 시작.
  static const guardianPrayer = CardData(
    id: 'holy_knight_guardian_prayer',
    name: '수호의 기도',
    jobId: 'holyKnight',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '블록 10 + HP 5 회복',
    effects: [CardEffect(type: CardEffectType.heal, value: 5)],
  );

  /// 심판의 일격 — 2AP, 18 데미지 + 준 데미지의 30% HP 회복. 시작.
  static const judgmentStrike = CardData(
    id: 'holy_knight_judgment_strike',
    name: '심판의 일격',
    jobId: 'holyKnight',
    type: CardType.attack,
    apCost: 2,
    damage: 18,
    description: '18 데미지 + 준 데미지의 30% HP 회복',
    effects: [CardEffect(type: CardEffectType.healPercentOfDamageDealt, value: 30)],
  );

  /// 축복의 갑옷 — 1AP, 매 턴 블록 5 + HP 3 회복. Power. 시작.
  static const blessedArmor = CardData(
    id: 'holy_knight_blessed_armor',
    name: '축복의 갑옷',
    jobId: 'holyKnight',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 블록 5 + HP 3 회복',
    effects: [
      CardEffect(type: CardEffectType.blockPerTurnFixed, value: 5),
      CardEffect(type: CardEffectType.healPerTurn, value: 3),
    ],
  );

  /// 성전사의 맹세 — 2AP, 모든 Attack에 25% 흡혈. Power. 시작.
  static const crusaderOath = CardData(
    id: 'holy_knight_crusader_oath',
    name: '성전사의 맹세',
    jobId: 'holyKnight',
    type: CardType.power,
    apCost: 2,
    description: '모든 Attack에 25% 흡혈',
    effects: [CardEffect(type: CardEffectType.lifestealOnAllAttacks, value: 25)],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    holySword,
    guardianPrayer,
    judgmentStrike,
    blessedArmor,
    crusaderOath,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const holySwordPlus = CardData(
    id: 'holy_knight_holy_sword+',
    name: '성스러운 검+',
    jobId: 'holyKnight',
    type: CardType.attack,
    apCost: 1,
    damage: 14,
    description: '14 데미지 + HP 8 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.heal, value: 8)],
  );

  static const guardianPrayerPlus = CardData(
    id: 'holy_knight_guardian_prayer+',
    name: '수호의 기도+',
    jobId: 'holyKnight',
    type: CardType.skill,
    apCost: 1,
    block: 14,
    description: '블록 14 + HP 8 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.heal, value: 8)],
  );

  static const judgmentStrikePlus = CardData(
    id: 'holy_knight_judgment_strike+',
    name: '심판의 일격+',
    jobId: 'holyKnight',
    type: CardType.attack,
    apCost: 2,
    damage: 24,
    description: '24 데미지 + 준 데미지의 40% HP 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.healPercentOfDamageDealt, value: 40)],
  );

  static const blessedArmorPlus = CardData(
    id: 'holy_knight_blessed_armor+',
    name: '축복의 갑옷+',
    jobId: 'holyKnight',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 블록 8 + HP 5 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.blockPerTurnFixed, value: 8),
      CardEffect(type: CardEffectType.healPerTurn, value: 5),
    ],
  );

  static const crusaderOathPlus = CardData(
    id: 'holy_knight_crusader_oath+',
    name: '성전사의 맹세+',
    jobId: 'holyKnight',
    type: CardType.power,
    apCost: 2,
    description: '모든 Attack에 35% 흡혈',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.lifestealOnAllAttacks, value: 35)],
  );
}
