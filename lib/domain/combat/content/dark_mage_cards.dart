import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 흑마법사 카드 — 저주 + 손패 조작. 시작 5장.
class DarkMageCards {
  DarkMageCards._();

  /// 저주의 볼트 — 1AP, 10 데미지 + 약화 1 + 취약 1. 시작.
  static const curseBolt = CardData(
    id: 'dark_mage_curse_bolt',
    name: '저주의 볼트',
    jobId: 'darkMage',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: '10 데미지 + 약화 1 + 취약 1',
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 1),
      CardEffect(type: CardEffectType.applyVulnerable, value: 1),
    ],
  );

  /// 어둠의 방벽 — 1AP, 블록 8 + 독 3. 시작.
  static const darkBarrier = CardData(
    id: 'dark_mage_dark_barrier',
    name: '어둠의 방벽',
    jobId: 'darkMage',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 독 3',
    effects: [CardEffect(type: CardEffectType.applyPoison, value: 3)],
  );

  /// 흑마법 증폭 — 0AP, 2장 드로우 + 다음 Attack +50%. 시작.
  static const darkAmplify = CardData(
    id: 'dark_mage_dark_amplify',
    name: '흑마법 증폭',
    jobId: 'darkMage',
    type: CardType.skill,
    apCost: 0,
    description: '2장 드로우 + 다음 Attack +50%',
    effects: [
      CardEffect(type: CardEffectType.draw, value: 2),
      CardEffect(type: CardEffectType.nextAttackDamageBoost, value: 50),
    ],
  );

  /// 정신 지배 — 2AP, 15 데미지 + 기절 1턴. 소진. 시작.
  static const mindControl = CardData(
    id: 'dark_mage_mind_control',
    name: '정신 지배',
    jobId: 'darkMage',
    type: CardType.attack,
    apCost: 2,
    damage: 15,
    description: '15 데미지 + 기절 1턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.stunEnemy, value: 1)],
  );

  /// 암흑의 힘 — 2AP, 매 턴 독 2 + 드로우 +1. Power. 시작.
  static const darkPower = CardData(
    id: 'dark_mage_dark_power',
    name: '암흑의 힘',
    jobId: 'darkMage',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 독 2 + 드로우 +1',
    effects: [CardEffect(type: CardEffectType.poisonPerTurnAndDraw, value: 2, duration: 1)],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    curseBolt,
    darkBarrier,
    darkAmplify,
    mindControl,
    darkPower,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const curseBoltPlus = CardData(
    id: 'dark_mage_curse_bolt+',
    name: '저주의 볼트+',
    jobId: 'darkMage',
    type: CardType.attack,
    apCost: 1,
    damage: 14,
    description: '14 데미지 + 약화 2 + 취약 2',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 2),
      CardEffect(type: CardEffectType.applyVulnerable, value: 2),
    ],
  );

  static const darkBarrierPlus = CardData(
    id: 'dark_mage_dark_barrier+',
    name: '어둠의 방벽+',
    jobId: 'darkMage',
    type: CardType.skill,
    apCost: 1,
    block: 12,
    description: '블록 12 + 독 5',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.applyPoison, value: 5)],
  );

  static const darkAmplifyPlus = CardData(
    id: 'dark_mage_dark_amplify+',
    name: '흑마법 증폭+',
    jobId: 'darkMage',
    type: CardType.skill,
    apCost: 0,
    description: '3장 드로우 + 다음 Attack +75%',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.draw, value: 3),
      CardEffect(type: CardEffectType.nextAttackDamageBoost, value: 75),
    ],
  );

  static const mindControlPlus = CardData(
    id: 'dark_mage_mind_control+',
    name: '정신 지배+',
    jobId: 'darkMage',
    type: CardType.attack,
    apCost: 2,
    damage: 22,
    description: '22 데미지 + 기절 1턴. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.stunEnemy, value: 1)],
  );

  static const darkPowerPlus = CardData(
    id: 'dark_mage_dark_power+',
    name: '암흑의 힘+',
    jobId: 'darkMage',
    type: CardType.power,
    apCost: 2,
    description: '매 턴 독 3 + 드로우 +1',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.poisonPerTurnAndDraw, value: 3, duration: 1)],
  );
}
