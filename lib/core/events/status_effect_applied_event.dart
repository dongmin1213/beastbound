import 'package:soul_dungeon/core/events/game_event.dart';

/// Status effect applied event -- emitted by CombatBloc.
/// AudioBloc subscribes to play effect-specific SFX.
class StatusEffectAppliedEvent extends GameEvent {
  /// Status effect type (poison/burn/weak/vulnerable/strength/dexterity/thorn/regenerate).
  final String effectType;

  /// Target (player/enemy).
  final String target;

  StatusEffectAppliedEvent({
    required this.effectType,
    required this.target,
  });

  @override
  String toString() => 'StatusEffectAppliedEvent(effectType: $effectType, target: $target)';
}
