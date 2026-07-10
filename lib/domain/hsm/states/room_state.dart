import 'package:soul_dungeon/core/models/game_enums.dart';

/// HSM RoomState — 현재 방 nodeId + RoomType (불변).
class RoomState {
  final String nodeId;
  final RoomType roomType;

  const RoomState({
    required this.nodeId,
    required this.roomType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomState &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          roomType == other.roomType;

  @override
  int get hashCode => Object.hash(nodeId, roomType);

  @override
  String toString() => 'RoomState(nodeId: $nodeId, roomType: $roomType)';
}
