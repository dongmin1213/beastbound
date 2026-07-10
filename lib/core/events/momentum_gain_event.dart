import 'package:soul_dungeon/core/events/game_event.dart';

/// 기세 직접 증가 이벤트 — 카드 효과(momentumGain)에서 emit.
/// MomentumBloc이 구독하여 기세 값 직접 증가.
class MomentumGainEvent extends GameEvent {
  final int amount;

  MomentumGainEvent({required this.amount});

  @override
  String toString() => 'MomentumGainEvent(amount: $amount)';
}
