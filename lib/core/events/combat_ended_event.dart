import 'package:soul_dungeon/core/events/game_event.dart';

/// 전투 종료 이벤트 — 전투 완료 후 발행.
/// AudioBloc이 구독하여 탐색 BGM 복귀.
class CombatEndedEvent extends GameEvent {
  final int currentFloor;

  CombatEndedEvent({required this.currentFloor});

  @override
  String toString() => 'CombatEndedEvent(currentFloor: $currentFloor)';
}
