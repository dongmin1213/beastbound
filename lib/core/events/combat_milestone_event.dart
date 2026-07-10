import 'package:soul_dungeon/core/events/game_event.dart';

/// 전투 마일스톤 타입.
enum CombatMilestoneType { hit, block, victory, defeat }

/// 전투 마일스톤 이벤트 — 전투 중 주요 순간에 emit.
/// AudioBloc이 구독하여 combat_hit/block/victory/defeat SFX 재생.
class CombatMilestoneEvent extends GameEvent {
  final CombatMilestoneType type;

  CombatMilestoneEvent({required this.type});

  @override
  String toString() => 'CombatMilestoneEvent(type: ${type.name})';
}
