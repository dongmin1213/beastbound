import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/events/event_choice_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_event.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_state.dart';

/// 이벤트 방 Bloc — 생성자 주입, 3파일 분리.
/// 선택지 표시 → 선택 처리 흐름 관리. presentation 의존 없음.
class EventRoomBloc extends Bloc<EventRoomEvent, EventRoomState> {
  final GameEventBus gameEventBus;

  EventRoomBloc({required this.gameEventBus})
      : super(const EventRoomInitial()) {
    on<OpenEventRoom>(_onOpenEventRoom);
    on<SelectEventChoice>(_onSelectEventChoice);
  }

  void _onOpenEventRoom(
      OpenEventRoom event, Emitter<EventRoomState> emit) {
    emit(EventRoomReady(event.data));
  }

  void _onSelectEventChoice(
      SelectEventChoice event, Emitter<EventRoomState> emit) {
    final currentState = state;
    if (currentState is! EventRoomReady) return;

    final choices = currentState.data.choices;
    if (event.choiceIndex < 0 || event.choiceIndex >= choices.length) return;

    final selectedChoice = choices[event.choiceIndex];

    gameEventBus.emit(EventChoiceEvent(
      choiceLabel: selectedChoice.label,
      goldChange: selectedChoice.goldChange,
      hpChange: selectedChoice.hpChange,
    ));

    emit(EventRoomCompleted(selectedChoice));
  }
}
