import 'package:soul_dungeon/core/events/game_event.dart';

/// 전투 패배 시 HP 감소와 함께 발행. 향후 UI/오디오 시스템 구독용.
class PlayerDamagedEvent extends GameEvent {
  final int hpLost;
  final int remainingHp;

  PlayerDamagedEvent({required this.hpLost, required this.remainingHp});

  @override
  String toString() => 'PlayerDamagedEvent(hpLost: $hpLost, remainingHp: $remainingHp)';
}
