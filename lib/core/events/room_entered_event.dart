import 'package:soul_dungeon/core/events/game_event.dart';

/// DungeonBloc이 방 진입 시 발행.
/// core → domain 의존 방지를 위해 roomTypeName(String) 사용.
/// 소비자는 RoomType.values.byName(roomTypeName)으로 복원.
class RoomEnteredEvent extends GameEvent {
  final String nodeId;
  final String roomTypeName;

  RoomEnteredEvent({
    required this.nodeId,
    required this.roomTypeName,
  });

  @override
  String toString() => 'RoomEnteredEvent(nodeId: $nodeId, roomTypeName: $roomTypeName)';
}
