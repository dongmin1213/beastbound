import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 차원술사 카드 — 무한 복제 + 적 행동 복사. 시작 5장.
class DimensionMageCards {
  DimensionMageCards._();

  /// 차원 폭풍 — 2AP, 10 데미지 + 마지막 Attack 복제. 시작.
  static const dimensionStorm = CardData(
    id: 'dimension_mage_dimension_storm',
    name: '차원 폭풍',
    jobId: 'dimensionMage',
    type: CardType.attack,
    apCost: 2,
    damage: 10,
    description: '10 데미지 + 마지막 Attack 카드 복제',
    effects: [CardEffect(type: CardEffectType.copyLastAttackToHand, value: 1)],
  );

  /// 완벽한 복제 — 1AP, 마지막 카드 2회 복제. 소진. 시작.
  static const perfectClone = CardData(
    id: 'dimension_mage_perfect_clone',
    name: '완벽한 복제',
    jobId: 'dimensionMage',
    type: CardType.skill,
    apCost: 1,
    description: '마지막 카드 2회 복제. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.copyLastCardMultiple, value: 2)],
  );

  /// 환영 군단 — 2AP, 매 턴 랜덤 Attack 카드 생성. Power. 시작.
  static const phantomLegion = CardData(
    id: 'dimension_mage_phantom_legion',
    name: '환영 군단',
    jobId: 'dimensionMage',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 랜덤 Attack 카드 생성',
    effects: [CardEffect(type: CardEffectType.generateAttackPerTurn, value: 1)],
  );

  /// 차원 방벽 — 1AP, 블록 10 + 랜덤 카드 생성. 시작.
  static const dimensionBarrier = CardData(
    id: 'dimension_mage_dimension_barrier',
    name: '차원 방벽',
    jobId: 'dimensionMage',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '블록 10 + 랜덤 카드 1장 생성',
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 1)],
  );

  /// 현실 붕괴 — 3AP, 12 데미지 + 약화 3 + 취약 2 + 복제. 소진. 시작.
  static const realityCollapse = CardData(
    id: 'dimension_mage_reality_collapse',
    name: '현실 붕괴',
    jobId: 'dimensionMage',
    type: CardType.attack,
    apCost: 3,
    damage: 12,
    description: '12 데미지 + 약화 3 + 취약 2 + 복제. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 3),
      CardEffect(type: CardEffectType.applyVulnerable, value: 2),
      CardEffect(type: CardEffectType.copyLastAttackToHand, value: 1),
    ],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    dimensionStorm,
    perfectClone,
    phantomLegion,
    dimensionBarrier,
    realityCollapse,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const dimensionStormPlus = CardData(
    id: 'dimension_mage_dimension_storm+',
    name: '차원 폭풍+',
    jobId: 'dimensionMage',
    type: CardType.attack,
    apCost: 2,
    damage: 15,
    description: '15 데미지 + 마지막 Attack 카드 복제',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.copyLastAttackToHand, value: 1)],
  );

  static const perfectClonePlus = CardData(
    id: 'dimension_mage_perfect_clone+',
    name: '완벽한 복제+',
    jobId: 'dimensionMage',
    type: CardType.skill,
    apCost: 1,
    description: '마지막 카드 3회 복제. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.copyLastCardMultiple, value: 3)],
  );

  static const phantomLegionPlus = CardData(
    id: 'dimension_mage_phantom_legion+',
    name: '환영 군단+',
    jobId: 'dimensionMage',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 랜덤 Attack 카드 2장 생성',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.generateAttackPerTurn, value: 2)],
  );

  static const dimensionBarrierPlus = CardData(
    id: 'dimension_mage_dimension_barrier+',
    name: '차원 방벽+',
    jobId: 'dimensionMage',
    type: CardType.skill,
    apCost: 1,
    block: 14,
    description: '블록 14 + 랜덤 카드 2장 생성',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 2)],
  );

  static const realityCollapsePlus = CardData(
    id: 'dimension_mage_reality_collapse+',
    name: '현실 붕괴+',
    jobId: 'dimensionMage',
    type: CardType.attack,
    apCost: 3,
    damage: 18,
    description: '18 데미지 + 약화 3 + 취약 3 + 복제. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 3),
      CardEffect(type: CardEffectType.applyVulnerable, value: 3),
      CardEffect(type: CardEffectType.copyLastAttackToHand, value: 1),
    ],
  );
}
