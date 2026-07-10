import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/events/dungeon_floor_ready_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/room_entered_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';

/// DungeonBloc — 던전 탐색/내비게이션 관리.
///
/// 생성자 주입: [DungeonGenerator], [GameEventBus].
/// **HsmController 미주입** — domain 간 직접 의존 금지.
/// [RoomEnteredEvent]를 GameEventBus로 발행, HsmController가 구독하여 Phase 전환.
class DungeonBloc extends Bloc<DungeonBlocEvent, DungeonBlocState> {
  final DungeonGenerator dungeonGenerator;
  final GameEventBus gameEventBus;

  DungeonBloc({
    required this.dungeonGenerator,
    required this.gameEventBus,
  }) : super(const DungeonInitial()) {
    on<GenerateFloor>(_onGenerateFloor);
    on<RestoreFloor>(_onRestoreFloor);
    on<RestoreRoom>(_onRestoreRoom);
    on<SelectNode>(_onSelectNode);
    on<ToggleMinimap>(_onToggleMinimap);
    on<CompleteRoom>(_onCompleteRoom);
    on<CompleteCombatRoom>(_onCompleteCombatRoom);
  }

  void _onGenerateFloor(GenerateFloor event, Emitter<DungeonBlocState> emit) {
    final result = dungeonGenerator.generateFloor(event.floor, event.seed);

    switch (result) {
      case Success(:final data):
        emit(DungeonFloorReady(
          floorMap: data,
          currentNodeId: data.startNodeId,
          visitedNodeIds: {data.startNodeId},
          minimapVisible: false,
        ));
        gameEventBus.emit(DungeonFloorReadyEvent(floorNumber: event.floor));
      case Failure(:final error):
        // 1차 실패 → 새 시드로 폴백 (무한 로딩 방지)
        GameLogger.warning(
          LogSystem.dungeon,
          'GenerateFloor failed: ${error.message}, retrying with new seed',
        );
        final fallbackSeed = DateTime.now().millisecondsSinceEpoch;
        final fallbackResult =
            dungeonGenerator.generateFloor(event.floor, fallbackSeed);
        switch (fallbackResult) {
          case Success(:final data):
            emit(DungeonFloorReady(
              floorMap: data,
              currentNodeId: data.startNodeId,
              visitedNodeIds: {data.startNodeId},
              minimapVisible: false,
            ));
            gameEventBus.emit(DungeonFloorReadyEvent(floorNumber: event.floor));
          case Failure(:final error):
            emit(DungeonBlocError(error.message));
        }
    }
  }

  void _onRestoreFloor(RestoreFloor event, Emitter<DungeonBlocState> emit) {
    final result = dungeonGenerator.generateFloor(event.floor, event.seed);

    switch (result) {
      case Success(:final data):
        // 저장된 nodeId가 맵에 존재하는지 검증
        final nodeExists = data.nodeById(event.currentNodeId) != null;
        if (nodeExists) {
          emit(DungeonFloorReady(
            floorMap: data,
            currentNodeId: event.currentNodeId,
            visitedNodeIds: event.visitedNodeIds,
            minimapVisible: false,
          ));
        } else {
          // 노드 불일치 → 새 맵처럼 시작 (폴백)
          GameLogger.warning(
            LogSystem.dungeon,
            'RestoreFloor: nodeId ${event.currentNodeId} not found, '
            'falling back to startNodeId',
          );
          emit(DungeonFloorReady(
            floorMap: data,
            currentNodeId: data.startNodeId,
            visitedNodeIds: {data.startNodeId},
            minimapVisible: false,
          ));
        }
        gameEventBus.emit(DungeonFloorReadyEvent(floorNumber: event.floor));
      case Failure(:final error):
        // 맵 생성 실패 → 새 시드로 폴백
        GameLogger.warning(
          LogSystem.dungeon,
          'RestoreFloor failed: ${error.message}, generating new floor',
        );
        final fallbackSeed = DateTime.now().millisecondsSinceEpoch;
        final fallbackResult =
            dungeonGenerator.generateFloor(event.floor, fallbackSeed);
        switch (fallbackResult) {
          case Success(:final data):
            emit(DungeonFloorReady(
              floorMap: data,
              currentNodeId: data.startNodeId,
              visitedNodeIds: {data.startNodeId},
              minimapVisible: false,
            ));
            gameEventBus.emit(DungeonFloorReadyEvent(floorNumber: event.floor));
          case Failure(:final error):
            emit(DungeonBlocError(error.message));
        }
    }
  }

  /// 이어하기 시 비전투 방 재진입 — DungeonFloorReady → DungeonRoomEntered 전환.
  void _onRestoreRoom(RestoreRoom event, Emitter<DungeonBlocState> emit) {
    final currentState = state;
    if (currentState is! DungeonFloorReady) {
      GameLogger.warning(
        LogSystem.dungeon,
        'RestoreRoom ignored: not in DungeonFloorReady state',
      );
      return;
    }

    emit(DungeonRoomEntered(
      floorMap: currentState.floorMap,
      currentNodeId: currentState.currentNodeId,
      roomType: event.roomType,
      visitedNodeIds: currentState.visitedNodeIds,
      minimapVisible: false,
    ));

    gameEventBus.emit(RoomEnteredEvent(
      nodeId: currentState.currentNodeId,
      roomTypeName: event.roomType.name,
    ));
  }

  void _onSelectNode(SelectNode event, Emitter<DungeonBlocState> emit) {
    final currentState = state;
    if (currentState is! DungeonFloorReady) {
      GameLogger.warning(
        LogSystem.dungeon,
        'SelectNode ignored: not in DungeonFloorReady state',
      );
      return;
    }

    final currentNode = currentState.floorMap.nodeById(currentState.currentNodeId);
    if (currentNode == null) return;

    if (!currentNode.nextNodeIds.contains(event.nodeId)) {
      GameLogger.warning(
        LogSystem.dungeon,
        'SelectNode(${event.nodeId}) rejected: not in nextNodeIds of ${currentState.currentNodeId}',
      );
      return;
    }

    // 이미 방문한 노드 재입장 방지
    if (currentState.visitedNodeIds.contains(event.nodeId)) {
      GameLogger.warning(
        LogSystem.dungeon,
        'SelectNode(${event.nodeId}) rejected: already visited',
      );
      return;
    }

    final targetNode = currentState.floorMap.nodeById(event.nodeId);
    if (targetNode == null) return;

    final updatedVisited = {...currentState.visitedNodeIds, event.nodeId};

    emit(DungeonRoomEntered(
      floorMap: currentState.floorMap,
      currentNodeId: event.nodeId,
      roomType: targetNode.roomType,
      visitedNodeIds: updatedVisited,
      minimapVisible: false,
    ));

    gameEventBus.emit(RoomEnteredEvent(
      nodeId: event.nodeId,
      roomTypeName: targetNode.roomType.name,
    ));
  }

  void _onToggleMinimap(ToggleMinimap event, Emitter<DungeonBlocState> emit) {
    final currentState = state;

    if (currentState is DungeonFloorReady) {
      emit(DungeonFloorReady(
        floorMap: currentState.floorMap,
        currentNodeId: currentState.currentNodeId,
        visitedNodeIds: currentState.visitedNodeIds,
        minimapVisible: !currentState.minimapVisible,
      ));
    }
  }

  void _onCompleteRoom(CompleteRoom event, Emitter<DungeonBlocState> emit) {
    final currentState = state;

    if (currentState is DungeonRoomEntered) {
      emit(DungeonFloorReady(
        floorMap: currentState.floorMap,
        currentNodeId: currentState.currentNodeId,
        visitedNodeIds: currentState.visitedNodeIds,
        minimapVisible: false,
      ));
    }
  }

  /// 이어하기로 복원된 전투 완료 — DungeonFloorReady에서 nodeId/visitedNodeIds 갱신.
  void _onCompleteCombatRoom(
    CompleteCombatRoom event,
    Emitter<DungeonBlocState> emit,
  ) {
    final currentState = state;
    if (currentState is DungeonFloorReady) {
      final updatedVisited = {...currentState.visitedNodeIds, event.nodeId};
      emit(DungeonFloorReady(
        floorMap: currentState.floorMap,
        currentNodeId: event.nodeId,
        visitedNodeIds: updatedVisited,
        minimapVisible: false,
      ));
    }
  }
}
