import 'package:soul_dungeon/core/events/game_event.dart';

/// 전투 시작 이벤트 — 전투 진입 시 발행.
/// AudioBloc이 구독하여 전투 BGM 재생.
class CombatStartedEvent extends GameEvent {
  final bool isBoss;
  final bool isElite;

  CombatStartedEvent({this.isBoss = false, this.isElite = false});

  @override
  String toString() =>
      'CombatStartedEvent(isBoss: $isBoss, isElite: $isElite)';
}
