import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 공통 시작 카드 7장 — 모든 직업의 초기 덱에 포함.
class StarterCards {
  StarterCards._();

  static const strike1 = CardData(
    id: 'starter_strike_1',
    name: '타격',
    type: CardType.attack,
    apCost: 1,
    damage: 6,
    description: '6 데미지',
  );

  static const strike2 = CardData(
    id: 'starter_strike_2',
    name: '타격',
    type: CardType.attack,
    apCost: 1,
    damage: 6,
    description: '6 데미지',
  );

  static const strike3 = CardData(
    id: 'starter_strike_3',
    name: '타격',
    type: CardType.attack,
    apCost: 1,
    damage: 6,
    description: '6 데미지',
  );

  static const defend1 = CardData(
    id: 'starter_defend_1',
    name: '방어',
    type: CardType.skill,
    apCost: 1,
    block: 5,
    description: '블록 5',
  );

  static const defend2 = CardData(
    id: 'starter_defend_2',
    name: '방어',
    type: CardType.skill,
    apCost: 1,
    block: 5,
    description: '블록 5',
  );

  static const vigilance = CardData(
    id: 'starter_vigilance',
    name: '경계',
    type: CardType.skill,
    apCost: 1,
    damage: 3,
    block: 3,
    description: '3 데미지 + 블록 3',
  );

  static const brace = CardData(
    id: 'starter_brace',
    name: '기합',
    type: CardType.skill,
    apCost: 0,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.draw, value: 1),
      CardEffect(type: CardEffectType.momentumGain, value: 5),
    ],
    description: '1장 드로우 + 야성 +5. 소진',
  );

  /// 공통 시작 덱 (7장).
  static const List<CardData> all = [
    strike1,
    strike2,
    strike3,
    defend1,
    defend2,
    vigilance,
    brace,
  ];

  /// 업그레이드 버전 — 타격 8d, 방어 7b.
  static const strikeUpgraded = CardData(
    id: 'starter_strike_1+',
    name: '타격+',
    type: CardType.attack,
    apCost: 1,
    damage: 8,
    description: '8 데미지',
    upgraded: true,
  );

  static const defendUpgraded = CardData(
    id: 'starter_defend_1+',
    name: '방어+',
    type: CardType.skill,
    apCost: 1,
    block: 7,
    description: '블록 7',
    upgraded: true,
  );

  static const vigilanceUpgraded = CardData(
    id: 'starter_vigilance+',
    name: '경계+',
    type: CardType.skill,
    apCost: 1,
    damage: 4,
    block: 5,
    description: '4 데미지 + 블록 5',
    upgraded: true,
  );

  static const braceUpgraded = CardData(
    id: 'starter_brace+',
    name: '기합+',
    type: CardType.skill,
    apCost: 0,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.draw, value: 2),
      CardEffect(type: CardEffectType.momentumGain, value: 8),
    ],
    description: '2장 드로우 + 야성 +8. 소진',
    upgraded: true,
  );
}
