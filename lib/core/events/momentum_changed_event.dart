import 'package:soul_dungeon/core/events/game_event.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';

/// 기세 변경 알림 — 크로스도메인 구독용 (AudioBloc, TextEngineBloc 등).
/// GameEvent 서브클래스: GameEventBus를 통해 발행/구독.
class MomentumChangedEvent extends GameEvent {
  final int value;
  final MomentumTier tier;

  MomentumChangedEvent({required this.value, required this.tier});

  @override
  String toString() => 'MomentumChangedEvent(value: $value, tier: ${tier.name})';
}
