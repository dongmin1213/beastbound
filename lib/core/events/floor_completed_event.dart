import 'package:soul_dungeon/core/events/game_event.dart';

/// 층 완료 이벤트 — 보스 승리 + 선택 완료 후 발행.
class FloorCompletedEvent extends GameEvent {
  final int floorNumber;

  FloorCompletedEvent({required this.floorNumber});

  @override
  String toString() => 'FloorCompletedEvent(floorNumber: $floorNumber)';
}
