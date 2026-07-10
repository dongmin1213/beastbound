import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 심판자 카드 — 정화 + 독 전환. 시작 5장.
class ArbiterCards {
  ArbiterCards._();

  /// 정의의 심판 — 1AP, 10 데미지 + 디버프 1개 제거. 시작.
  static const justiceJudgment = CardData(
    id: 'arbiter_justice_judgment',
    name: '정의의 심판',
    jobId: 'arbiter',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: '10 데미지 + 디버프 1개 제거',
    effects: [CardEffect(type: CardEffectType.cleanse, value: 1)],
  );

  /// 정화의 물결 — 1AP, 디버프 전체 제거 + HP 8 회복. 시작.
  static const purifyWave = CardData(
    id: 'arbiter_purify_wave',
    name: '정화의 물결',
    jobId: 'arbiter',
    type: CardType.skill,
    apCost: 1,
    description: '디버프 전체 제거 + HP 8 회복',
    effects: [
      CardEffect(type: CardEffectType.cleanse, value: 99),
      CardEffect(type: CardEffectType.heal, value: 8),
    ],
  );

  /// 독을 삼키는 빛 — 2AP, 적 독 → 데미지 + HP 회복 전환. 시작.
  static const poisonAbsorbLight = CardData(
    id: 'arbiter_poison_absorb_light',
    name: '독을 삼키는 빛',
    jobId: 'arbiter',
    type: CardType.attack,
    apCost: 2,
    description: '적 독 스택을 데미지 + HP 회복으로 전환',
    effects: [CardEffect(type: CardEffectType.convertPoisonToDamageAndHeal, value: 1)],
  );

  /// 심판자의 눈 — 1AP, 블록 8 + 의도 공개 + 1장 드로우. 시작.
  static const arbiterEye = CardData(
    id: 'arbiter_arbiter_eye',
    name: '심판자의 눈',
    jobId: 'arbiter',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 적 의도 공개 + 1장 드로우',
    effects: [
      CardEffect(type: CardEffectType.revealIntentAndDraw, value: 1),
    ],
  );

  /// 절대 정의 — 2AP, 정화 시 적에게 5 데미지. Power. 시작.
  static const absoluteJustice = CardData(
    id: 'arbiter_absolute_justice',
    name: '절대 정의',
    jobId: 'arbiter',
    type: CardType.power,
    apCost: 2,
    description: '정화할 때마다 적에게 5 데미지',
    effects: [CardEffect(type: CardEffectType.damageOnCleanse, value: 5)],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    justiceJudgment,
    purifyWave,
    poisonAbsorbLight,
    arbiterEye,
    absoluteJustice,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const justiceJudgmentPlus = CardData(
    id: 'arbiter_justice_judgment+',
    name: '정의의 심판+',
    jobId: 'arbiter',
    type: CardType.attack,
    apCost: 1,
    damage: 14,
    description: '14 데미지 + 디버프 2개 제거',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.cleanse, value: 2)],
  );

  static const purifyWavePlus = CardData(
    id: 'arbiter_purify_wave+',
    name: '정화의 물결+',
    jobId: 'arbiter',
    type: CardType.skill,
    apCost: 1,
    description: '디버프 전체 제거 + HP 12 회복',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.cleanse, value: 99),
      CardEffect(type: CardEffectType.heal, value: 12),
    ],
  );

  static const poisonAbsorbLightPlus = CardData(
    id: 'arbiter_poison_absorb_light+',
    name: '독을 삼키는 빛+',
    jobId: 'arbiter',
    type: CardType.attack,
    apCost: 2,
    description: '적 독 스택을 데미지 × 1.5 + HP 회복으로 전환',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.convertPoisonToDamageAndHeal, value: 150)],
  );

  static const arbiterEyePlus = CardData(
    id: 'arbiter_arbiter_eye+',
    name: '심판자의 눈+',
    jobId: 'arbiter',
    type: CardType.skill,
    apCost: 1,
    block: 12,
    description: '블록 12 + 적 의도 공개 + 2장 드로우',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.revealIntentAndDraw, value: 2),
    ],
  );

  static const absoluteJusticePlus = CardData(
    id: 'arbiter_absolute_justice+',
    name: '절대 정의+',
    jobId: 'arbiter',
    type: CardType.power,
    apCost: 2,
    description: '정화할 때마다 적에게 8 데미지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.damageOnCleanse, value: 8)],
  );
}
