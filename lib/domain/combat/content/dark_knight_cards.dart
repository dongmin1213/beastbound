import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 암흑기사 카드 — 은신 + 반격. 시작 5장.
class DarkKnightCards {
  DarkKnightCards._();

  /// 그림자 참격 — 1AP, 10 데미지 + 블록 5. 시작.
  static const shadowSlash = CardData(
    id: 'dark_knight_shadow_slash',
    name: '그림자 참격',
    jobId: 'darkKnight',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    block: 5,
    description: '10 데미지 + 블록 5',
  );

  /// 암흑 방패 — 1AP, 블록 10 + 40% 회피. 시작.
  static const darkShield = CardData(
    id: 'dark_knight_dark_shield',
    name: '암흑 방패',
    jobId: 'darkKnight',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '블록 10 + 이번 턴 40% 회피',
    effects: [CardEffect(type: CardEffectType.dodgeChance, value: 40)],
  );

  /// 반격의 일섬 — 2AP, 블록 × 50% 데미지 + 블록 50% 유지. 시작.
  static const counterSlash = CardData(
    id: 'dark_knight_counter_slash',
    name: '반격의 일섬',
    jobId: 'darkKnight',
    type: CardType.attack,
    apCost: 2,
    description: '블록 × 50% 데미지 + 블록 50% 유지',
    effects: [CardEffect(type: CardEffectType.blockToDamagePartialRetain, value: 50, duration: 50)],
  );

  /// 어둠의 갑옷 — 1AP, 25% 회피 + 가시 2. Power. 시작.
  static const darkArmor = CardData(
    id: 'dark_knight_dark_armor',
    name: '어둠의 갑옷',
    jobId: 'darkKnight',
    type: CardType.power,
    apCost: 1,
    description: '25% 회피 + 가시 2',
    effects: [
      CardEffect(type: CardEffectType.dodgeChance, value: 25),
      CardEffect(type: CardEffectType.gainThorn, value: 2),
    ],
  );

  /// 암흑 기사의 맹세 — 2AP, 블록 유지 60% + 힘 +1. Power. 시작.
  static const darkKnightOath = CardData(
    id: 'dark_knight_dark_knight_oath',
    name: '암흑 기사의 맹세',
    jobId: 'darkKnight',
    type: CardType.power,
    apCost: 2,
    description: '블록 유지 60% + 힘 +1',
    effects: [CardEffect(type: CardEffectType.blockRetainPercentAndStrength, value: 1, condition: '60')],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    shadowSlash,
    darkShield,
    counterSlash,
    darkArmor,
    darkKnightOath,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const shadowSlashPlus = CardData(
    id: 'dark_knight_shadow_slash+',
    name: '그림자 참격+',
    jobId: 'darkKnight',
    type: CardType.attack,
    apCost: 1,
    damage: 14,
    block: 8,
    description: '14 데미지 + 블록 8',
    upgraded: true,
  );

  static const darkShieldPlus = CardData(
    id: 'dark_knight_dark_shield+',
    name: '암흑 방패+',
    jobId: 'darkKnight',
    type: CardType.skill,
    apCost: 1,
    block: 14,
    description: '블록 14 + 이번 턴 50% 회피',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.dodgeChance, value: 50)],
  );

  static const counterSlashPlus = CardData(
    id: 'dark_knight_counter_slash+',
    name: '반격의 일섬+',
    jobId: 'darkKnight',
    type: CardType.attack,
    apCost: 2,
    description: '블록 × 70% 데미지 + 블록 60% 유지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockToDamagePartialRetain, value: 70, duration: 60)],
  );

  static const darkArmorPlus = CardData(
    id: 'dark_knight_dark_armor+',
    name: '어둠의 갑옷+',
    jobId: 'darkKnight',
    type: CardType.power,
    apCost: 1,
    description: '30% 회피 + 가시 3',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.dodgeChance, value: 30),
      CardEffect(type: CardEffectType.gainThorn, value: 3),
    ],
  );

  static const darkKnightOathPlus = CardData(
    id: 'dark_knight_dark_knight_oath+',
    name: '암흑 기사의 맹세+',
    jobId: 'darkKnight',
    type: CardType.power,
    apCost: 2,
    description: '블록 유지 75% + 힘 +2',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockRetainPercentAndStrength, value: 2, condition: '75')],
  );
}
