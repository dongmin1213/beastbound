import 'package:soul_dungeon/core/events/game_event.dart';

/// 유령 NPC 만남 이벤트 — 유령 NPC와 상호작용 시 emit.
/// AudioBloc, NarratorBloc 등 크로스 시스템 반응에 사용.
class GhostEncounteredEvent extends GameEvent {
  final String ghostJobId;
  final int ghostDeathFloor;
  final String reactionLevel; // familiar, curious, distant

  GhostEncounteredEvent({
    required this.ghostJobId,
    required this.ghostDeathFloor,
    required this.reactionLevel,
  });

  @override
  String toString() =>
      'GhostEncounteredEvent(ghostJobId: $ghostJobId, ghostDeathFloor: $ghostDeathFloor, reactionLevel: $reactionLevel)';
}
