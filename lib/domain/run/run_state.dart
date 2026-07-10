import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

/// RunBloc 상태 — sealed class (Dart 3 switch exhaustiveness).
sealed class RunState extends Equatable {
  const RunState();
}

/// 초기 상태 — 런 시작 전.
final class RunInitial extends RunState {
  const RunInitial();

  @override
  List<Object?> get props => [];
}

/// 런 진행 중 — PlayerRunState 보유.
final class RunActive extends RunState {
  final PlayerRunState playerRunState;

  const RunActive({required this.playerRunState});

  @override
  List<Object?> get props => [playerRunState];
}
