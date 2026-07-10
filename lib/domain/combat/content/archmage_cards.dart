import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 대현자 카드 — 완전한 손패/덱 컨트롤 + AP 조작. 시작 5장.
class ArchmageCards {
  ArchmageCards._();

  /// 차원절단 — 2AP, 20 데미지 (관통). 시작.
  static const dimensionSever = CardData(
    id: 'archmage_dimension_sever',
    name: '차원절단',
    jobId: 'archmage',
    type: CardType.attack,
    apCost: 2,
    damage: 20,
    description: '20 관통 데미지',
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 1)],
  );

  /// 시공간 왜곡 — 1AP, 버려진 카드 3장 복귀 + 블록 6. 시작.
  static const spacetimeWarp = CardData(
    id: 'archmage_spacetime_warp',
    name: '시공간 왜곡',
    jobId: 'archmage',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '버려진 카드 3장 복귀 + 블록 6',
    effects: [CardEffect(type: CardEffectType.retrieveFromDiscard, value: 3)],
  );

  /// 마력 증폭 — 0AP, AP +2, 1장 드로우. 소진. 시작.
  static const manaAmplify = CardData(
    id: 'archmage_mana_amplify',
    name: '마력 증폭',
    jobId: 'archmage',
    type: CardType.skill,
    apCost: 0,
    description: 'AP +2, 1장 드로우. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.apGain, value: 2),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 절대영도 — 3AP, 15 데미지 + 기절 1턴. 소진. 시작.
  static const absoluteZero = CardData(
    id: 'archmage_absolute_zero',
    name: '절대영도',
    jobId: 'archmage',
    type: CardType.attack,
    apCost: 3,
    damage: 15,
    description: '15 데미지 + 기절 1턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.stunEnemy, value: 1)],
  );

  /// 대마법진 — 2AP, 매 턴 드로우 +2, 모든 Skill AP -1. 시작.
  static const grandMagicCircle = CardData(
    id: 'archmage_grand_magic_circle',
    name: '대마법진',
    jobId: 'archmage',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 드로우 +2, 모든 Skill AP -1',
    effects: [
      CardEffect(type: CardEffectType.drawPerTurn, value: 2),
      CardEffect(type: CardEffectType.allSkillApDiscount, value: 1),
    ],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    dimensionSever,
    spacetimeWarp,
    manaAmplify,
    absoluteZero,
    grandMagicCircle,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const dimensionSeverPlus = CardData(
    id: 'archmage_dimension_sever+',
    name: '차원절단+',
    jobId: 'archmage',
    type: CardType.attack,
    apCost: 2,
    damage: 28,
    description: '28 관통 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 1)],
  );

  static const spacetimeWarpPlus = CardData(
    id: 'archmage_spacetime_warp+',
    name: '시공간 왜곡+',
    jobId: 'archmage',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '버려진 카드 4장 복귀 + 블록 10',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.retrieveFromDiscard, value: 4)],
  );

  static const manaAmplifyPlus = CardData(
    id: 'archmage_mana_amplify+',
    name: '마력 증폭+',
    jobId: 'archmage',
    type: CardType.skill,
    apCost: 0,
    description: 'AP +3, 2장 드로우. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.apGain, value: 3),
      CardEffect(type: CardEffectType.draw, value: 2),
    ],
  );

  static const absoluteZeroPlus = CardData(
    id: 'archmage_absolute_zero+',
    name: '절대영도+',
    jobId: 'archmage',
    type: CardType.attack,
    apCost: 3,
    damage: 22,
    description: '22 데미지 + 기절 1턴. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.stunEnemy, value: 1)],
  );

  static const grandMagicCirclePlus = CardData(
    id: 'archmage_grand_magic_circle+',
    name: '대마법진+',
    jobId: 'archmage',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 드로우 +3, 모든 Skill AP -1',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.drawPerTurn, value: 3),
      CardEffect(type: CardEffectType.allSkillApDiscount, value: 1),
    ],
  );
}
