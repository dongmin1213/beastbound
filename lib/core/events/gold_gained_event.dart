import 'package:soul_dungeon/core/events/game_event.dart';

/// 금화 획득 이벤트 — GameScreen이 CombatRewardEvent 수신 후 gold 누적 시 발행.
/// 향후 UI HUD/오디오 연동용.
class GoldGainedEvent extends GameEvent {
  final int amount;
  final int totalGold;

  GoldGainedEvent({required this.amount, required this.totalGold});

  @override
  String toString() => 'GoldGainedEvent(amount: $amount, totalGold: $totalGold)';
}
