import 'package:soul_dungeon/core/events/game_event.dart';

/// DungeonBloc이 층 생성/복원 완료 시 발행.
/// AudioBloc이 구독하여 탐색 BGM을 즉시 시작.
class DungeonFloorReadyEvent extends GameEvent {
  final int floorNumber;

  DungeonFloorReadyEvent({required this.floorNumber});

  @override
  String toString() => 'DungeonFloorReadyEvent(floorNumber: $floorNumber)';
}
