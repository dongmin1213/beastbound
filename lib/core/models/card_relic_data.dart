import 'package:soul_dungeon/core/models/game_enums.dart';

/// 유물 트리거 — 유물 효과가 발동하는 시점.
enum RelicTrigger {
  combatStart,
  turnStart,
  onAttack,
  onBlock,
  onFlee,
  onHit,
  onKill,
  onMomentumHigh,
  passive,
}

/// 카드 전투 유물 데이터 — 조건부 패시브.
class CardRelicData {
  final String id;
  final String name;
  final String description;
  final Rarity rarity;
  final RelicTrigger trigger;
  final String effectType;
  final int effectValue;

  /// 조건 임계값 (가시 방패: 블록 10+, 거울 조각: 10% 등).
  final int? conditionValue;

  const CardRelicData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.trigger,
    required this.effectType,
    required this.effectValue,
    this.conditionValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CardRelicData && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
