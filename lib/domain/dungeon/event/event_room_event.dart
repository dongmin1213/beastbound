import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';

/// 이벤트 방 Bloc 이벤트 — sealed class (Dart 3 exhaustiveness).
/// EventRoom prefix 사용: EventEvent 혼동 방지.
sealed class EventRoomEvent {
  const EventRoomEvent();
}

/// 이벤트 방 데이터를 열어 선택지를 표시한다.
final class OpenEventRoom extends EventRoomEvent {
  final EventRoomData data;

  const OpenEventRoom(this.data);
}

/// 선택지를 선택한다.
final class SelectEventChoice extends EventRoomEvent {
  final int choiceIndex;

  const SelectEventChoice(this.choiceIndex);
}
