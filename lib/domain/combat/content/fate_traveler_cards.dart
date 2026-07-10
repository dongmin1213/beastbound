import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 운명의 여행자 카드 — 극한 RNG + 카드 생성. 시작 5장.
class FateTravelerCards {
  FateTravelerCards._();

  /// 운명의 일격 — 1AP, 5~25 랜덤 데미지 + 랜덤 버프. 시작.
  static const fateStrike = CardData(
    id: 'fate_traveler_fate_strike',
    name: '운명의 일격',
    jobId: 'fateTraveler',
    type: CardType.attack,
    apCost: 1,
    description: '5~25 랜덤 데미지 + 랜덤 버프',
    effects: [
      CardEffect(type: CardEffectType.randomDamage, value: 5, duration: 25),
      CardEffect(type: CardEffectType.randomBuff, value: 1),
    ],
  );

  /// 카오스 카드 — 0AP, 랜덤 카드 2장 생성. 소진. 시작.
  static const chaosCard = CardData(
    id: 'fate_traveler_chaos_card',
    name: '카오스 카드',
    jobId: 'fateTraveler',
    type: CardType.skill,
    apCost: 0,
    description: '랜덤 카드 2장 생성. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 2)],
  );

  /// 시간 역행 — 2AP, 소진 파일에서 3장 복원. 시작.
  static const timeReverse = CardData(
    id: 'fate_traveler_time_reverse',
    name: '시간 역행',
    jobId: 'fateTraveler',
    type: CardType.skill,
    apCost: 2,
    description: '소진 파일에서 3장 복원',
    effects: [CardEffect(type: CardEffectType.retrieveFromExhaust, value: 3)],
  );

  /// 행운 폭발 — 1AP, 소진된 카드 수 × 5 데미지. 시작.
  static const luckyExplosion = CardData(
    id: 'fate_traveler_lucky_explosion',
    name: '행운 폭발',
    jobId: 'fateTraveler',
    type: CardType.attack,
    apCost: 1,
    description: '소진된 카드 수 × 5 데미지',
    effects: [CardEffect(type: CardEffectType.exhaustPileCountDamage, value: 5)],
  );

  /// 운명 조율 — 2AP, 매 턴 랜덤 카드 생성 + HP 3 회복. Power. 시작.
  static const fateTuning = CardData(
    id: 'fate_traveler_fate_tuning',
    name: '운명 조율',
    jobId: 'fateTraveler',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 랜덤 카드 생성 + HP 3 회복',
    effects: [CardEffect(type: CardEffectType.generateRandomCardAndHealPerTurn, value: 3)],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    fateStrike,
    chaosCard,
    timeReverse,
    luckyExplosion,
    fateTuning,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const fateStrikePlus = CardData(
    id: 'fate_traveler_fate_strike+',
    name: '운명의 일격+',
    jobId: 'fateTraveler',
    type: CardType.attack,
    apCost: 1,
    description: '10~30 랜덤 데미지 + 랜덤 버프',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.randomDamage, value: 10, duration: 30),
      CardEffect(type: CardEffectType.randomBuff, value: 1),
    ],
  );

  static const chaosCardPlus = CardData(
    id: 'fate_traveler_chaos_card+',
    name: '카오스 카드+',
    jobId: 'fateTraveler',
    type: CardType.skill,
    apCost: 0,
    description: '랜덤 카드 3장 생성. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.generateRandomCard, value: 3)],
  );

  static const timeReversePlus = CardData(
    id: 'fate_traveler_time_reverse+',
    name: '시간 역행+',
    jobId: 'fateTraveler',
    type: CardType.skill,
    apCost: 2,
    description: '소진 파일에서 5장 복원',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.retrieveFromExhaust, value: 5)],
  );

  static const luckyExplosionPlus = CardData(
    id: 'fate_traveler_lucky_explosion+',
    name: '행운 폭발+',
    jobId: 'fateTraveler',
    type: CardType.attack,
    apCost: 1,
    description: '소진된 카드 수 × 7 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.exhaustPileCountDamage, value: 7)],
  );

  static const fateTuningPlus = CardData(
    id: 'fate_traveler_fate_tuning+',
    name: '운명 조율+',
    jobId: 'fateTraveler',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 랜덤 카드 생성 + HP 5 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.generateRandomCardAndHealPerTurn, value: 5)],
  );
}
