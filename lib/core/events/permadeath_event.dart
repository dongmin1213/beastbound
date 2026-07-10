import 'package:soul_dungeon/core/events/game_event.dart';

/// HP 0 도달 시 발행. defeatedBy에 CombatEncounter.enemyName 전달.
/// 향후 E6 유령 NPC 시스템의 GhostNpc.deathCause로 사용.
class PermadeathEvent extends GameEvent {
  final int finalHp;
  final String defeatedBy;

  PermadeathEvent({required this.finalHp, required this.defeatedBy});

  @override
  String toString() => 'PermadeathEvent(finalHp: $finalHp, defeatedBy: $defeatedBy)';
}
