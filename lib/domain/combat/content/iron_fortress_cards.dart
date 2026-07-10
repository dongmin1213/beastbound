import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 철벽성주 카드 — 100% 블록 유지 + 반사 데미지. 시작 5장.
class IronFortressCards {
  IronFortressCards._();

  /// 절대방벽 — 2AP, 블록 20 + 100% 유지. 시작.
  static const absoluteBarrier = CardData(
    id: 'iron_fortress_absolute_barrier',
    name: '절대방벽',
    jobId: 'ironFortress',
    type: CardType.skill,
    apCost: 2,
    block: 20,
    description: '블록 20 + 100% 유지',
    effects: [CardEffect(type: CardEffectType.blockRetainFull, value: 1)],
  );

  /// 반사의 벽 — 1AP, 블록 8 + 이번 턴 30% 반사. 시작.
  static const reflectWall = CardData(
    id: 'iron_fortress_reflect_wall',
    name: '반사의 벽',
    jobId: 'ironFortress',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 이번 턴 받는 데미지 30% 반사',
    effects: [CardEffect(type: CardEffectType.reflectDamagePercent, value: 30)],
  );

  /// 철벽돌진 — 1AP, 블록 × 70% 데미지, 블록 유지. 시작.
  static const fortressCharge = CardData(
    id: 'iron_fortress_fortress_charge',
    name: '철벽돌진',
    jobId: 'ironFortress',
    type: CardType.attack,
    apCost: 1,
    description: '블록 × 70% 데미지, 블록 유지',
    effects: [CardEffect(type: CardEffectType.blockToDamageKeepBlock, value: 70)],
  );

  /// 가시요새 — 2AP, 가시 +3, 매 턴 블록 +5. Power. 시작.
  static const thornFortress = CardData(
    id: 'iron_fortress_thorn_fortress',
    name: '가시요새',
    jobId: 'ironFortress',
    type: CardType.power,
    apCost: 2,
    description: '가시 +3, 매 턴 블록 +5',
    effects: [
      CardEffect(type: CardEffectType.gainThorn, value: 3),
      CardEffect(type: CardEffectType.blockPerTurnFixed, value: 5),
    ],
  );

  /// 수호자의 맹세 — 3AP, 블록 100% 유지. 블록 ≥20 시 피해 -3. Power. 시작.
  static const guardianOath = CardData(
    id: 'iron_fortress_guardian_oath',
    name: '수호자의 맹세',
    jobId: 'ironFortress',
    type: CardType.power,
    apCost: 3,
    description: '블록 100% 유지. 블록 ≥20 시 피해 -3',
    effects: [
      CardEffect(type: CardEffectType.blockRetainFull, value: 1),
      CardEffect(type: CardEffectType.damageReductionAtBlock, value: 3, condition: '20'),
    ],
  );

  /// 시작 카드 5장.
  static const List<CardData> starter = [
    absoluteBarrier,
    reflectWall,
    fortressCharge,
    thornFortress,
    guardianOath,
  ];

  /// 전체 5장.
  static const List<CardData> all = starter;

  // ── 업그레이드 버전 ──

  static const absoluteBarrierPlus = CardData(
    id: 'iron_fortress_absolute_barrier+',
    name: '절대방벽+',
    jobId: 'ironFortress',
    type: CardType.skill,
    apCost: 2,
    block: 28,
    description: '블록 28 + 100% 유지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockRetainFull, value: 1)],
  );

  static const reflectWallPlus = CardData(
    id: 'iron_fortress_reflect_wall+',
    name: '반사의 벽+',
    jobId: 'ironFortress',
    type: CardType.skill,
    apCost: 1,
    block: 12,
    description: '블록 12 + 이번 턴 받는 데미지 40% 반사',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.reflectDamagePercent, value: 40)],
  );

  static const fortressChargePlus = CardData(
    id: 'iron_fortress_fortress_charge+',
    name: '철벽돌진+',
    jobId: 'ironFortress',
    type: CardType.attack,
    apCost: 1,
    description: '블록 × 90% 데미지, 블록 유지',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.blockToDamageKeepBlock, value: 90)],
  );

  static const thornFortressPlus = CardData(
    id: 'iron_fortress_thorn_fortress+',
    name: '가시요새+',
    jobId: 'ironFortress',
    type: CardType.power,
    apCost: 2,
    description: '가시 +5, 매 턴 블록 +8',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.gainThorn, value: 5),
      CardEffect(type: CardEffectType.blockPerTurnFixed, value: 8),
    ],
  );

  static const guardianOathPlus = CardData(
    id: 'iron_fortress_guardian_oath+',
    name: '수호자의 맹세+',
    jobId: 'ironFortress',
    type: CardType.power,
    apCost: 3,
    description: '블록 100% 유지. 블록 ≥15 시 피해 -5',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.blockRetainFull, value: 1),
      CardEffect(type: CardEffectType.damageReductionAtBlock, value: 5, condition: '15'),
    ],
  );
}
