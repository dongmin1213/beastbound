import 'package:soul_dungeon/core/events/game_event.dart';

/// 휴식 방 선택 이벤트 — RestBloc이 ChooseHeal/ChooseUpgrade 처리 시 발행.
/// primitive/String 타입만 사용 — core → domain 역방향 의존 방지.
/// 향후 통계/세이브/기세리셋(Story 3-7) 시스템 연동용.
class RestChoiceEvent extends GameEvent {
  final String choiceType;
  final int hpChange;
  final int maxHpChange;

  RestChoiceEvent({
    required this.choiceType,
    this.hpChange = 0,
    this.maxHpChange = 0,
  });

  @override
  String toString() =>
      'RestChoiceEvent(choiceType: $choiceType, hpChange: $hpChange, maxHpChange: $maxHpChange)';
}
