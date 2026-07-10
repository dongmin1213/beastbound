import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/tier_effect.dart';

/// 전투 턴 결과 — CombatBloc이 계산하여 상태에 포함.
class CombatTurnResult extends Equatable {
  final int turnNumber;
  final ActionType playerAction;
  final EnemyActionType enemyAction;
  final ActionResult actionResult;
  final TierModifiedResult? tierEffect;
  final String? specialActionType;

  const CombatTurnResult({
    required this.turnNumber,
    required this.playerAction,
    required this.enemyAction,
    required this.actionResult,
    this.tierEffect,
    this.specialActionType,
  });

  @override
  List<Object?> get props => [
        turnNumber,
        playerAction,
        enemyAction,
        actionResult,
        tierEffect,
        specialActionType,
      ];
}
