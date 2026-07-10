import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';

/// MysteryBloc 상태 — sealed class (Dart 3 switch exhaustiveness).
sealed class MysteryState extends Equatable {
  const MysteryState();
}

/// 초기 상태 — 미스터리 방 미진입.
final class MysteryInitial extends MysteryState {
  const MysteryInitial();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'MysteryInitial()';
}

/// 결과 공개 — 플레이어에게 결과 표시 중.
final class MysteryRevealed extends MysteryState {
  final MysteryOutcome outcome;

  const MysteryRevealed(this.outcome);

  @override
  List<Object?> get props => [outcome];

  @override
  String toString() => 'MysteryRevealed($outcome)';
}

/// 결과 수락 완료 — 보상/페널티 적용 대기.
final class MysteryCompleted extends MysteryState {
  final MysteryOutcome outcome;

  const MysteryCompleted(this.outcome);

  @override
  List<Object?> get props => [outcome];

  @override
  String toString() => 'MysteryCompleted($outcome)';
}
