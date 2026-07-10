import 'package:soul_dungeon/core/events/game_event.dart';

/// 덱 셔플 이벤트 — 버림 더미가 드로우 파일로 셔플될 때 emit.
/// AudioBloc이 구독하여 deck_shuffle SFX 재생.
class DeckShuffledEvent extends GameEvent {
  @override
  String toString() => 'DeckShuffledEvent()';
}
