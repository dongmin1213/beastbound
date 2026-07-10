import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 마검사 카드 — 마법 강화 물리 공격. 시작 5장.
class SpellBladeCards {
  SpellBladeCards._();

  /// 마력 검격 — 1AP, 12 관통 데미지 + 1장 드로우. 시작.
  static const arcaneSlash = CardData(
    id: 'spell_blade_arcane_slash',
    name: '마력 검격',
    jobId: 'spellBlade',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    description: '12 관통 데미지 + 1장 드로우',
    effects: [
      CardEffect(type: CardEffectType.ignoreBlock, value: 1),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 마법 강화 — 1AP, 힘 +2 + 블록 5. 시작.
  static const magicEnhance = CardData(
    id: 'spell_blade_magic_enhance',
    name: '마법 강화',
    jobId: 'spellBlade',
    type: CardType.skill,
    apCost: 1,
    block: 5,
    description: '힘 +2 + 블록 5',
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 2)],
  );

  /// 연쇄 마검 — 2AP, 8 데미지 × 3회 (관통). 시작.
  static const chainArcane = CardData(
    id: 'spell_blade_chain_arcane',
    name: '연쇄 마검',
    jobId: 'spellBlade',
    type: CardType.attack,
    apCost: 2,
    description: '8 관통 데미지 × 3회',
    effects: [CardEffect(type: CardEffectType.multiHitPiercing, value: 8, duration: 3)],
  );

  /// 마력 방패 — 1AP, 블록 8 + 손패 수 × 2 블록. 시작.
  static const manaShield = CardData(
    id: 'spell_blade_mana_shield',
    name: '마력 방패',
    jobId: 'spellBlade',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 손패 수 × 2 블록',
    effects: [CardEffect(type: CardEffectType.handSizeBlock, value: 2)],
  );

  /// 마검 각성 — 2AP, 모든 Attack 관통 + 매 턴 드로우 +1. Power. 시작.
  static const arcaneAwakening = CardData(
    id: 'spell_blade_arcane_awakening',
    name: '마검 각성',
    jobId: 'spellBlade',
    type: CardType.power,
    apCost: 2,
    description: '모든 Attack 관통 + 매 턴 드로우 +1',
    effects: [
      CardEffect(type: CardEffectType.allAttackPiercing, value: 1),
      CardEffect(type: CardEffectType.drawPerTurn, value: 1),
    ],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    arcaneSlash,
    magicEnhance,
    chainArcane,
    manaShield,
    arcaneAwakening,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const arcaneSlashPlus = CardData(
    id: 'spell_blade_arcane_slash+',
    name: '마력 검격+',
    jobId: 'spellBlade',
    type: CardType.attack,
    apCost: 1,
    damage: 16,
    description: '16 관통 데미지 + 1장 드로우',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.ignoreBlock, value: 1),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  static const magicEnhancePlus = CardData(
    id: 'spell_blade_magic_enhance+',
    name: '마법 강화+',
    jobId: 'spellBlade',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '힘 +3 + 블록 8',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainStrength, value: 3)],
  );

  static const chainArcanePlus = CardData(
    id: 'spell_blade_chain_arcane+',
    name: '연쇄 마검+',
    jobId: 'spellBlade',
    type: CardType.attack,
    apCost: 2,
    description: '10 관통 데미지 × 3회',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.multiHitPiercing, value: 10, duration: 3)],
  );

  static const manaShieldPlus = CardData(
    id: 'spell_blade_mana_shield+',
    name: '마력 방패+',
    jobId: 'spellBlade',
    type: CardType.skill,
    apCost: 1,
    block: 12,
    description: '블록 12 + 손패 수 × 3 블록',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.handSizeBlock, value: 3)],
  );

  static const arcaneAwakeningPlus = CardData(
    id: 'spell_blade_arcane_awakening+',
    name: '마검 각성+',
    jobId: 'spellBlade',
    type: CardType.power,
    apCost: 2,
    description: '모든 Attack 관통 + 매 턴 드로우 +2',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.allAttackPiercing, value: 1),
      CardEffect(type: CardEffectType.drawPerTurn, value: 2),
    ],
  );
}
