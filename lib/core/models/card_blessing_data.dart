import 'package:soul_dungeon/core/models/game_enums.dart';

/// 축복 트리거 — 축복 효과가 발동하는 시점.
enum BlessingTrigger {
  combatStart,
  turnStart,
  onAttack,
  onHit,
  onCardPlay,
  onKill,
  turnEnd,
  onShuffle,
  passive,
}

/// 카드 전투 축복 데이터 — 트리거 + 효과.
class CardBlessingData {
  final String id;
  final String name;
  final String description;
  final Rarity rarity;
  final BlessingTrigger trigger;
  final String effectType;
  final int effectValue;

  /// 추가 효과 값 (시간의 모래: 주기, 유리대포: HP 감소 등).
  final int? secondaryValue;

  const CardBlessingData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.trigger,
    required this.effectType,
    required this.effectValue,
    this.secondaryValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CardBlessingData && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
