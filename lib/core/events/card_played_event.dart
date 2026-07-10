import 'package:soul_dungeon/core/events/game_event.dart';

/// Card played event -- emitted by CombatBloc when a card is played.
/// AudioBloc subscribes to play card-type-specific SFX.
class CardPlayedEvent extends GameEvent {
  /// Card type (attack/skill/power).
  final String cardType;

  /// Card ID.
  final String cardId;

  CardPlayedEvent({
    required this.cardType,
    required this.cardId,
  });

  @override
  String toString() => 'CardPlayedEvent(cardType: $cardType, cardId: $cardId)';
}
