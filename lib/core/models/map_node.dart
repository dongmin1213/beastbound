import 'package:flutter/foundation.dart' show listEquals;

import 'package:soul_dungeon/core/models/game_enums.dart';

/// 맵 내 개별 노드 (불변).
/// 각 노드는 방 유형, 깊이, 연결 정보를 가짐.
class MapNode {
  final String id;
  final int depth;
  final RoomType roomType;
  final List<String> nextNodeIds;
  final List<String> prevNodeIds;

  const MapNode({
    required this.id,
    required this.depth,
    required this.roomType,
    this.nextNodeIds = const [],
    this.prevNodeIds = const [],
  });

  MapNode copyWith({
    String? id,
    int? depth,
    RoomType? roomType,
    List<String>? nextNodeIds,
    List<String>? prevNodeIds,
  }) {
    return MapNode(
      id: id ?? this.id,
      depth: depth ?? this.depth,
      roomType: roomType ?? this.roomType,
      nextNodeIds: nextNodeIds ?? this.nextNodeIds,
      prevNodeIds: prevNodeIds ?? this.prevNodeIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          depth == other.depth &&
          roomType == other.roomType &&
          listEquals(nextNodeIds, other.nextNodeIds) &&
          listEquals(prevNodeIds, other.prevNodeIds);

  @override
  int get hashCode => Object.hash(
        id,
        depth,
        roomType,
        Object.hashAll(nextNodeIds),
        Object.hashAll(prevNodeIds),
      );

  @override
  String toString() =>
      'MapNode(id: $id, depth: $depth, roomType: $roomType, '
      'next: $nextNodeIds, prev: $prevNodeIds)';

}
