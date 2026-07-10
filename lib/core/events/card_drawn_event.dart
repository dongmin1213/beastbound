import 'package:soul_dungeon/core/events/game_event.dart';

/// 카드 드로우 이벤트 — 카드를 드로우할 때 emit.
/// AudioBloc이 구독하여 card_draw SFX 재생.
class CardDrawnEvent extends GameEvent {
  /// 드로우한 카드 수.
  final int count;

  CardDrawnEvent({required this.count});

  @override
  String toString() => 'CardDrawnEvent(count: $count)';
}
