import 'package:equatable/equatable.dart';

/// 서술자 신뢰도 이벤트.
sealed class NarratorEvent extends Equatable {
  const NarratorEvent();
}

/// 층 변경 → 신뢰도 재계산.
final class NarratorFloorChanged extends NarratorEvent {
  final int floor;
  const NarratorFloorChanged(this.floor);

  @override
  List<Object?> get props => [floor];
}

/// 서술자 리셋 (새 런 시작).
final class ResetNarrator extends NarratorEvent {
  const ResetNarrator();

  @override
  List<Object?> get props => [];
}

/// 관찰/분석 카드 사용 → N턴간 진실 표시.
final class RevealTruth extends NarratorEvent {
  final int turns;
  const RevealTruth(this.turns);

  @override
  List<Object?> get props => [turns];
}

/// 턴 종료 → 진실 공개 잔여 턴 감소.
final class TickTruthReveal extends NarratorEvent {
  const TickTruthReveal();

  @override
  List<Object?> get props => [];
}
