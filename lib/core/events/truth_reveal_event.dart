import 'package:soul_dungeon/core/events/game_event.dart';

/// 관찰/분석 카드 사용 → 서술자 진실 공개 요청.
///
/// CombatBloc → GameEventBus → NarratorBloc 경유.
class TruthRevealEvent extends GameEvent {
  /// 진실 공개 지속 턴 수.
  final int turns;

  TruthRevealEvent({required this.turns});

  @override
  String toString() => 'TruthRevealEvent(turns: $turns)';
}
