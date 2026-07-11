import 'package:soul_dungeon/core/events/game_event.dart';

/// 이벤트 방 선택지 선택 이벤트 — EventRoomBloc이 SelectEventChoice 처리 시 발행.
/// primitive 타입만 사용 — core → domain 역방향 의존 방지.
class EventChoiceEvent extends GameEvent {
  final String choiceLabel;
  final int goldChange;
  final int hpChange;

  EventChoiceEvent({
    required this.choiceLabel,
    required this.goldChange,
    required this.hpChange,
  });

  @override
  String toString() =>
      'EventChoiceEvent(choiceLabel: $choiceLabel, goldChange: $goldChange, hpChange: $hpChange)';
}
