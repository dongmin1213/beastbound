import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// DungeonBloc 상태 (sealed class — switch exhaustiveness 보장).
sealed class DungeonBlocState extends Equatable {
  const DungeonBlocState();
}

/// 초기 상태 (맵 미생성).
final class DungeonInitial extends DungeonBlocState {
  const DungeonInitial();

  @override
  List<Object?> get props => [];
}

/// 층 맵 준비 완료 — 미니맵 표시, 경로 선택 가능.
final class DungeonFloorReady extends DungeonBlocState {
  final FloorMap floorMap;
  final String currentNodeId;
  final Set<String> visitedNodeIds;
  final bool minimapVisible;

  const DungeonFloorReady({
    required this.floorMap,
    required this.currentNodeId,
    required this.visitedNodeIds,
    this.minimapVisible = true,
  });

  @override
  List<Object?> get props =>
      [floorMap, currentNodeId, visitedNodeIds, minimapVisible];
}

/// 방 진입 완료 — 미니맵 숨김, 방 콘텐츠 표시.
final class DungeonRoomEntered extends DungeonBlocState {
  final FloorMap floorMap;
  final String currentNodeId;
  final RoomType roomType;
  final Set<String> visitedNodeIds;
  final bool minimapVisible;

  const DungeonRoomEntered({
    required this.floorMap,
    required this.currentNodeId,
    required this.roomType,
    required this.visitedNodeIds,
    this.minimapVisible = false,
  });

  @override
  List<Object?> get props =>
      [floorMap, currentNodeId, roomType, visitedNodeIds, minimapVisible];
}

/// 에러 상태.
final class DungeonBlocError extends DungeonBlocState {
  final String error;

  const DungeonBlocError(this.error);

  @override
  List<Object?> get props => [error];
}
