import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// DungeonBloc 이벤트 (sealed class — switch exhaustiveness 보장).
sealed class DungeonBlocEvent extends Equatable {
  const DungeonBlocEvent();
}

/// 층 맵 생성 요청.
final class GenerateFloor extends DungeonBlocEvent {
  final int floor;
  final int seed;

  const GenerateFloor({required this.floor, required this.seed});

  @override
  List<Object?> get props => [floor, seed];
}

/// 노드 선택 (경로 이동).
final class SelectNode extends DungeonBlocEvent {
  final String nodeId;

  const SelectNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

/// 미니맵 표시 토글.
final class ToggleMinimap extends DungeonBlocEvent {
  const ToggleMinimap();

  @override
  List<Object?> get props => [];
}

/// 저장된 시드/노드/방문기록으로 층 맵 복원 (이어하기).
final class RestoreFloor extends DungeonBlocEvent {
  final int floor;
  final int seed;
  final String currentNodeId;
  final Set<String> visitedNodeIds;

  const RestoreFloor({
    required this.floor,
    required this.seed,
    required this.currentNodeId,
    required this.visitedNodeIds,
  });

  @override
  List<Object?> get props => [floor, seed, currentNodeId, visitedNodeIds];
}

/// 이어하기 시 비전투 방 재진입 (DungeonFloorReady → DungeonRoomEntered 전환).
final class RestoreRoom extends DungeonBlocEvent {
  final RoomType roomType;

  const RestoreRoom({required this.roomType});

  @override
  List<Object?> get props => [roomType];
}

/// 방 콘텐츠 완료 → 탐색 모드 복귀.
final class CompleteRoom extends DungeonBlocEvent {
  const CompleteRoom();

  @override
  List<Object?> get props => [];
}

/// 이어하기로 복원된 전투 완료 → DungeonFloorReady 상태에서 nodeId/visitedNodeIds 갱신.
final class CompleteCombatRoom extends DungeonBlocEvent {
  final String nodeId;

  const CompleteCombatRoom({required this.nodeId});

  @override
  List<Object?> get props => [nodeId];
}
