import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';

/// EventRoomBloc 상태 — sealed class (Dart 3 switch exhaustiveness).
sealed class EventRoomState extends Equatable {
  const EventRoomState();
}

/// 초기 상태 — 이벤트 방 미진입.
final class EventRoomInitial extends EventRoomState {
  const EventRoomInitial();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'EventRoomInitial()';
}

/// 이벤트 방 데이터 로드 완료 — 선택지 표시 중.
final class EventRoomReady extends EventRoomState {
  final EventRoomData data;

  const EventRoomReady(this.data);

  @override
  List<Object?> get props => [data];

  @override
  String toString() => 'EventRoomReady(${data.title})';
}

/// 선택 완료 — 보상/페널티 적용 대기.
final class EventRoomCompleted extends EventRoomState {
  final EventChoice selectedChoice;

  const EventRoomCompleted(this.selectedChoice);

  @override
  List<Object?> get props => [selectedChoice];

  @override
  String toString() =>
      'EventRoomCompleted(${selectedChoice.label})';
}
