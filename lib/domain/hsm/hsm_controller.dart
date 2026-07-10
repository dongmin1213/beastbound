import 'dart:async';

import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/phase_changed_event.dart';
import 'package:soul_dungeon/core/events/room_completed_event.dart';
import 'package:soul_dungeon/core/events/room_entered_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/hsm/room_phase_mapper.dart';
import 'package:soul_dungeon/domain/hsm/states/floor_state.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/domain/hsm/states/game_phase.dart';
import 'package:soul_dungeon/domain/hsm/states/room_state.dart';

/// HSM 3레벨 계층 컨트롤러.
///
/// FloorState + RoomState + GamePhase 관리.
/// 전환은 [tryTransition] 경유만 허용 — 직접 할당 금지.
/// GameEventBus의 [RoomEnteredEvent] 구독 → 자동 Phase 전환.
class HsmController {
  final GameEventBus gameEventBus;

  GamePhase _currentPhase;
  FloorState? _floorState;
  RoomState? _roomState;
  StreamSubscription<RoomEnteredEvent>? _roomEnteredSubscription;
  StreamSubscription<RoomCompletedEvent>? _roomCompletedSubscription;

  HsmController({required this.gameEventBus})
      : _currentPhase = const ExplorationPhase() {
    _roomEnteredSubscription =
        gameEventBus.on<RoomEnteredEvent>().listen(_onRoomEntered);
    _roomCompletedSubscription =
        gameEventBus.on<RoomCompletedEvent>().listen(_onRoomCompleted);
  }

  GamePhase get currentPhase => _currentPhase;
  FloorState? get floorState => _floorState;
  RoomState? get roomState => _roomState;

  /// Phase 전환 시도. 유효하면 true + PhaseChangedEvent 발행.
  /// 무효하면 false + 경고 로그.
  bool tryTransition(GamePhase to) {
    final from = _currentPhase;

    if (!_isValidTransition(from, to)) {
      GameLogger.warning(
        LogSystem.hsm,
        'Invalid transition: $from → $to',
      );
      return false;
    }

    _currentPhase = to;
    gameEventBus.emit(PhaseChangedEvent(
      fromPhase: from.toString(),
      toPhase: to.toString(),
    ));

    GameLogger.info(
      LogSystem.hsm,
      'Phase transition: $from → $to',
    );
    return true;
  }

  /// 유효 전환 규칙:
  /// - Exploration → {Combat,Event,Shop,Rest,Boss,Npc,Mystery}
  /// - {Combat,Event,Shop,Rest,Boss,Npc,Mystery} → Exploration
  bool _isValidTransition(GamePhase from, GamePhase to) {
    if (from is ExplorationPhase && to is! ExplorationPhase) return true;
    if (from is! ExplorationPhase && to is ExplorationPhase) return true;
    return false;
  }

  void _onRoomEntered(RoomEnteredEvent event) {
    final roomType = RoomType.values.byName(event.roomTypeName);
    final targetPhase = RoomPhaseMapper.toPhase(roomType);
    if (tryTransition(targetPhase)) {
      _roomState = RoomState(nodeId: event.nodeId, roomType: roomType);
    }
  }

  void _onRoomCompleted(RoomCompletedEvent event) {
    if (tryTransition(const ExplorationPhase())) {
      _roomState = null;
    }
  }

  void dispose() {
    _roomEnteredSubscription?.cancel();
    _roomEnteredSubscription = null;
    _roomCompletedSubscription?.cancel();
    _roomCompletedSubscription = null;
  }
}
