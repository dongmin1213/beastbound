import 'package:soul_dungeon/core/events/game_event.dart';

/// HsmController가 Phase 전환 시 발행.
/// core → domain 의존 방지를 위해 String 표현 사용.
class PhaseChangedEvent extends GameEvent {
  final String fromPhase;
  final String toPhase;

  PhaseChangedEvent({
    required this.fromPhase,
    required this.toPhase,
  });

  @override
  String toString() => 'PhaseChangedEvent(fromPhase: $fromPhase, toPhase: $toPhase)';
}
