import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// MomentumBloc 상태 (sealed class — switch exhaustiveness 보장)
sealed class MomentumState extends Equatable {
  const MomentumState();
}

/// 초기 상태 (전투 미진행 또는 리셋 직후)
final class MomentumInitial extends MomentumState {
  const MomentumInitial();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'MomentumInitial()';
}

/// 야성 업데이트됨
final class MomentumUpdated extends MomentumState {
  final int value;
  final MomentumTier tier;
  final MomentumDelta lastDelta;
  final ActionType? lastActionType;
  final CardType? lastCardType;
  final int consecutiveSameAction;

  const MomentumUpdated({
    required this.value,
    required this.tier,
    required this.lastDelta,
    this.lastActionType,
    this.lastCardType,
    this.consecutiveSameAction = 0,
  });

  @override
  List<Object?> get props => [value, tier, lastDelta, lastActionType, lastCardType, consecutiveSameAction];

  @override
  String toString() =>
      'MomentumUpdated(value: $value, tier: $tier, '
      'lastDelta: $lastDelta, lastActionType: $lastActionType, '
      'lastCardType: $lastCardType, '
      'consecutiveSameAction: $consecutiveSameAction)';
}
