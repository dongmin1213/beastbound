import 'package:soul_dungeon/core/events/game_event.dart';

/// 카드 소진 이벤트 — Exhaust 키워드 카드 사용 후 emit.
/// AudioBloc이 구독하여 card_exhaust SFX 재생.
class CardExhaustedEvent extends GameEvent {
  final String cardId;
  final String cardName;

  CardExhaustedEvent({required this.cardId, required this.cardName});

  @override
  String toString() => 'CardExhaustedEvent(cardId: $cardId, cardName: $cardName)';
}
