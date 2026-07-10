import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 명계왕 카드 — 강화된 즉사 + 극한 HP 드레인. 시작 5장.
class NetherKingCards {
  NetherKingCards._();

  /// 사신의 대낫 — 2AP, 20 데미지. 적 HP ≤25% 즉사. 시작.
  static const deathScythe = CardData(
    id: 'nether_king_death_scythe',
    name: '사신의 대낫',
    jobId: 'netherKing',
    type: CardType.attack,
    apCost: 2,
    damage: 20,
    description: '20 데미지. 적 HP ≤25% 시 즉사',
    effects: [CardEffect(type: CardEffectType.executeHpPercentInstantKill, value: 25)],
  );

  /// 영혼 착취 — 1AP, HP -5, 15 데미지, 60% 흡혈. 시작.
  static const soulExploit = CardData(
    id: 'nether_king_soul_exploit',
    name: '영혼 착취',
    jobId: 'netherKing',
    type: CardType.attack,
    apCost: 1,
    damage: 15,
    description: 'HP -5, 15 데미지, 60% 흡혈',
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 5),
      CardEffect(type: CardEffectType.lifesteal, value: 60),
    ],
  );

  /// 명계의 지배 — 2AP, 매 턴 HP -5, 힘 +3. Power. 시작.
  static const netherDominion = CardData(
    id: 'nether_king_nether_dominion',
    name: '명계의 지배',
    jobId: 'netherKing',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 HP -5, 힘 +3',
    effects: [
      CardEffect(type: CardEffectType.selfDamagePerTurn, value: 5),
      CardEffect(type: CardEffectType.strengthPerTurn, value: 3),
    ],
  );

  /// 저승의 심판 — 3AP, 잃은 HP × 1.5 데미지. 소진. 시작.
  static const netherJudgment = CardData(
    id: 'nether_king_nether_judgment',
    name: '저승의 심판',
    jobId: 'netherKing',
    type: CardType.attack,
    apCost: 3,
    description: '잃은 HP × 1.5 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.lostHpMultiplierDamage, value: 150)],
  );

  /// 불멸 — 1AP, HP <20% 시 블록 20 + HP 10 회복. 소진. 시작.
  static const immortal = CardData(
    id: 'nether_king_immortal',
    name: '불멸',
    jobId: 'netherKing',
    type: CardType.skill,
    apCost: 1,
    description: 'HP <20% 시 블록 20 + HP 10 회복. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.emergencyBlockAndHeal, value: 20, duration: 10, condition: '20')],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    deathScythe,
    soulExploit,
    netherDominion,
    netherJudgment,
    immortal,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const deathScythePlus = CardData(
    id: 'nether_king_death_scythe+',
    name: '사신의 대낫+',
    jobId: 'netherKing',
    type: CardType.attack,
    apCost: 2,
    damage: 28,
    description: '28 데미지. 적 HP ≤30% 시 즉사',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.executeHpPercentInstantKill, value: 30)],
  );

  static const soulExploitPlus = CardData(
    id: 'nether_king_soul_exploit+',
    name: '영혼 착취+',
    jobId: 'netherKing',
    type: CardType.attack,
    apCost: 1,
    damage: 20,
    description: 'HP -5, 20 데미지, 70% 흡혈',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.selfDamage, value: 5),
      CardEffect(type: CardEffectType.lifesteal, value: 70),
    ],
  );

  static const netherDominionPlus = CardData(
    id: 'nether_king_nether_dominion+',
    name: '명계의 지배+',
    jobId: 'netherKing',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 HP -5, 힘 +4',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.selfDamagePerTurn, value: 5),
      CardEffect(type: CardEffectType.strengthPerTurn, value: 4),
    ],
  );

  static const netherJudgmentPlus = CardData(
    id: 'nether_king_nether_judgment+',
    name: '저승의 심판+',
    jobId: 'netherKing',
    type: CardType.attack,
    apCost: 3,
    description: '잃은 HP × 2.0 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.lostHpMultiplierDamage, value: 200)],
  );

  static const immortalPlus = CardData(
    id: 'nether_king_immortal+',
    name: '불멸+',
    jobId: 'netherKing',
    type: CardType.skill,
    apCost: 1,
    description: 'HP <25% 시 블록 30 + HP 15 회복. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.emergencyBlockAndHeal, value: 30, duration: 15, condition: '25')],
  );
}
