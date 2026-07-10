import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 대사제 카드 — 무한 재생 + 완전 정화. 시작 5장.
class HighPriestCards {
  HighPriestCards._();

  /// 대정화 — 2AP, 디버프 전체 제거 + HP 15 회복 + 블록 10. 시작.
  static const grandPurify = CardData(
    id: 'high_priest_grand_purify',
    name: '대정화',
    jobId: 'highPriest',
    type: CardType.skill,
    apCost: 2,
    block: 10,
    description: '디버프 전체 제거 + HP 15 회복 + 블록 10',
    effects: [
      CardEffect(type: CardEffectType.cleanse, value: 99),
      CardEffect(type: CardEffectType.heal, value: 15),
    ],
  );

  /// 천상의 빛 — 1AP, 12 데미지 + HP 8 회복. 시작.
  static const celestialLight = CardData(
    id: 'high_priest_celestial_light',
    name: '천상의 빛',
    jobId: 'highPriest',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    description: '12 데미지 + HP 8 회복',
    effects: [CardEffect(type: CardEffectType.heal, value: 8)],
  );

  /// 성스러운 보호 — 1AP, 블록 12 + 재생 3 (3턴). 시작.
  static const sacredProtection = CardData(
    id: 'high_priest_sacred_protection',
    name: '성스러운 보호',
    jobId: 'highPriest',
    type: CardType.skill,
    apCost: 1,
    block: 12,
    description: '블록 12 + 재생 3 (3턴)',
    effects: [CardEffect(type: CardEffectType.gainRegenerate, value: 3, duration: 3)],
  );

  /// 신벌 — 3AP, 30 데미지 + 약화 2 + 취약 2. 소진. 시작.
  static const divinePunishment = CardData(
    id: 'high_priest_divine_punishment',
    name: '신벌',
    jobId: 'highPriest',
    type: CardType.attack,
    apCost: 3,
    damage: 30,
    description: '30 데미지 + 약화 2 + 취약 2. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 2),
      CardEffect(type: CardEffectType.applyVulnerable, value: 2),
    ],
  );

  /// 축복의 오라 — 2AP, 매 턴: HP 4 회복 + 블록 5. 시작.
  static const blessingAura = CardData(
    id: 'high_priest_blessing_aura',
    name: '축복의 오라',
    jobId: 'highPriest',
    type: CardType.power,
    apCost: 2,
    description: '매 턴: HP 4 회복 + 블록 5',
    effects: [
      CardEffect(type: CardEffectType.healPerTurn, value: 4),
      CardEffect(type: CardEffectType.blockPerTurnFixed, value: 5),
    ],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    grandPurify,
    celestialLight,
    sacredProtection,
    divinePunishment,
    blessingAura,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const grandPurifyPlus = CardData(
    id: 'high_priest_grand_purify+',
    name: '대정화+',
    jobId: 'highPriest',
    type: CardType.skill,
    apCost: 2,
    block: 15,
    description: '디버프 전체 제거 + HP 20 회복 + 블록 15',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.cleanse, value: 99),
      CardEffect(type: CardEffectType.heal, value: 20),
    ],
  );

  static const celestialLightPlus = CardData(
    id: 'high_priest_celestial_light+',
    name: '천상의 빛+',
    jobId: 'highPriest',
    type: CardType.attack,
    apCost: 1,
    damage: 16,
    description: '16 데미지 + HP 12 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.heal, value: 12)],
  );

  static const sacredProtectionPlus = CardData(
    id: 'high_priest_sacred_protection+',
    name: '성스러운 보호+',
    jobId: 'highPriest',
    type: CardType.skill,
    apCost: 1,
    block: 16,
    description: '블록 16 + 재생 4 (3턴)',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.gainRegenerate, value: 4, duration: 3)],
  );

  static const divinePunishmentPlus = CardData(
    id: 'high_priest_divine_punishment+',
    name: '신벌+',
    jobId: 'highPriest',
    type: CardType.attack,
    apCost: 3,
    damage: 40,
    description: '40 데미지 + 약화 3 + 취약 3. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 3),
      CardEffect(type: CardEffectType.applyVulnerable, value: 3),
    ],
  );

  static const blessingAuraPlus = CardData(
    id: 'high_priest_blessing_aura+',
    name: '축복의 오라+',
    jobId: 'highPriest',
    type: CardType.power,
    apCost: 2,
    description: '매 턴: HP 6 회복 + 블록 8',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.healPerTurn, value: 6),
      CardEffect(type: CardEffectType.blockPerTurnFixed, value: 8),
    ],
  );
}
