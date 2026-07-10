import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/job_path.dart';

/// BuildBloc 상태 — sealed class (Dart 3 switch exhaustiveness).
sealed class BuildState extends Equatable {
  const BuildState();
}

/// 초기 상태 — 아직 InitializeBuild 전.
final class BuildInitial extends BuildState {
  const BuildInitial();

  @override
  List<Object?> get props => [];
}

/// 미분화 상태 — 아직 임계치 미도달.
final class BuildUnspecialized extends BuildState {
  const BuildUnspecialized();

  @override
  List<Object?> get props => [];
}

/// 전직 후보 선택 대기 — 2개 이상 후보 시 UI 표시.
final class BuildClassChoosing extends BuildState {
  final List<JobPath> candidates;

  /// 2차 전직 선택인지 여부.
  final bool isSecondClassChange;

  const BuildClassChoosing(this.candidates, {this.isSecondClassChange = false});

  @override
  List<Object?> get props => [candidates, isSecondClassChange];
}

/// 분화 진행 중 — 분화 텍스트 표시 대기.
final class BuildClassChanging extends BuildState {
  final JobPath newJob;

  /// 2차 전직인지 여부.
  final bool isSecondClassChange;

  const BuildClassChanging(this.newJob, {this.isSecondClassChange = false});

  @override
  List<Object?> get props => [newJob, isSecondClassChange];
}

/// 분화 완료 — 직업 확정 (1차 전직).
final class BuildSpecialized extends BuildState {
  final JobPath currentJob;
  const BuildSpecialized(this.currentJob);

  @override
  List<Object?> get props => [currentJob];
}

/// 2차 전직 완료 — 상위직 또는 조합직 확정.
final class BuildAdvancedSpecialized extends BuildState {
  /// 1차 전직 직업.
  final JobPath primaryJob;

  /// 2차 전직 직업.
  final JobPath secondaryJob;

  const BuildAdvancedSpecialized({
    required this.primaryJob,
    required this.secondaryJob,
  });

  @override
  List<Object?> get props => [primaryJob, secondaryJob];
}
