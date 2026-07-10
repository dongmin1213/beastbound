import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 만물일체 카드 — 전 스탯 동기화 + 완벽한 균형. 시작 5장.
class OneWithAllCards {
  OneWithAllCards._();

  /// 완전한 일격 — 1AP, (힘+민첩+가시) × 2 데미지. 시작.
  static const perfectStrike = CardData(
    id: 'one_with_all_perfect_strike',
    name: '완전한 일격',
    jobId: 'oneWithAll',
    type: CardType.attack,
    apCost: 1,
    description: '(힘 + 민첩 + 가시) × 2 데미지',
    effects: [CardEffect(type: CardEffectType.allStatsDamage, value: 2)],
  );

  /// 만물의 조화 — 2AP, 매 턴 최저 스탯 +3 + HP 3 회복. Power. 시작.
  static const harmonyOfAll = CardData(
    id: 'one_with_all_harmony_of_all',
    name: '만물의 조화',
    jobId: 'oneWithAll',
    type: CardType.power,
    apCost: 2,
    description: '매 턴: 최저 스탯 +3, HP 3 회복',
    effects: [
      CardEffect(type: CardEffectType.boostLowestStatPerTurn, value: 3),
      CardEffect(type: CardEffectType.healPerTurn, value: 3),
    ],
  );

  /// 공명 폭발 — 2AP, 이번 턴 사용 카드 수 × 5 데미지. 시작.
  static const resonanceExplosion = CardData(
    id: 'one_with_all_resonance_explosion',
    name: '공명 폭발',
    jobId: 'oneWithAll',
    type: CardType.attack,
    apCost: 2,
    description: '이번 턴 사용 카드 수 × 5 데미지',
    effects: [CardEffect(type: CardEffectType.cardsPlayedDamage, value: 5)],
  );

  /// 절대 균형 — 1AP, HP와 블록 균등화 + 1장 드로우. 시작.
  static const absoluteBalance = CardData(
    id: 'one_with_all_absolute_balance',
    name: '절대 균형',
    jobId: 'oneWithAll',
    type: CardType.skill,
    apCost: 1,
    description: 'HP와 블록 균등화 + 1장 드로우',
    effects: [
      CardEffect(type: CardEffectType.equalizeHpAndBlock, value: 1),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 초월 — 3AP, 힘 +2, 민첩 +2, 가시 +1, 재생 2. Power. 시작.
  static const transcendence = CardData(
    id: 'one_with_all_transcendence',
    name: '초월',
    jobId: 'oneWithAll',
    type: CardType.power,
    apCost: 3,
    description: '힘 +2, 민첩 +2, 가시 +1, 재생 2',
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 2),
      CardEffect(type: CardEffectType.gainDexterity, value: 2),
      CardEffect(type: CardEffectType.gainThorn, value: 1),
      CardEffect(type: CardEffectType.gainRegenerate, value: 2),
    ],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    perfectStrike,
    harmonyOfAll,
    resonanceExplosion,
    absoluteBalance,
    transcendence,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const perfectStrikePlus = CardData(
    id: 'one_with_all_perfect_strike+',
    name: '완전한 일격+',
    jobId: 'oneWithAll',
    type: CardType.attack,
    apCost: 1,
    description: '(힘 + 민첩 + 가시) × 3 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.allStatsDamage, value: 3)],
  );

  static const harmonyOfAllPlus = CardData(
    id: 'one_with_all_harmony_of_all+',
    name: '만물의 조화+',
    jobId: 'oneWithAll',
    type: CardType.power,
    apCost: 2,
    description: '매 턴: 최저 스탯 +4, HP 5 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.boostLowestStatPerTurn, value: 4),
      CardEffect(type: CardEffectType.healPerTurn, value: 5),
    ],
  );

  static const resonanceExplosionPlus = CardData(
    id: 'one_with_all_resonance_explosion+',
    name: '공명 폭발+',
    jobId: 'oneWithAll',
    type: CardType.attack,
    apCost: 2,
    description: '이번 턴 사용 카드 수 × 7 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.cardsPlayedDamage, value: 7)],
  );

  static const absoluteBalancePlus = CardData(
    id: 'one_with_all_absolute_balance+',
    name: '절대 균형+',
    jobId: 'oneWithAll',
    type: CardType.skill,
    apCost: 1,
    description: 'HP와 블록 균등화 + 2장 드로우',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.equalizeHpAndBlock, value: 1),
      CardEffect(type: CardEffectType.draw, value: 2),
    ],
  );

  static const transcendencePlus = CardData(
    id: 'one_with_all_transcendence+',
    name: '초월+',
    jobId: 'oneWithAll',
    type: CardType.power,
    apCost: 3,
    description: '힘 +3, 민첩 +3, 가시 +2, 재생 3',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainStrength, value: 3),
      CardEffect(type: CardEffectType.gainDexterity, value: 3),
      CardEffect(type: CardEffectType.gainThorn, value: 2),
      CardEffect(type: CardEffectType.gainRegenerate, value: 3),
    ],
  );
}
