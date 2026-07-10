import 'package:soul_dungeon/core/events/game_event.dart';

/// 방 콘텐츠 완료 시 발행 — HSM이 ExplorationPhase로 복귀.
class RoomCompletedEvent extends GameEvent {
  final String nodeId;

  RoomCompletedEvent({required this.nodeId});

  @override
  String toString() => 'RoomCompletedEvent(nodeId: $nodeId)';
}
