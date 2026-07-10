import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

/// BuildBloc 이벤트 — sealed class (Dart 3 switch exhaustiveness).
sealed class BuildEvent extends Equatable {
  const BuildEvent();
}

/// 빌드 초기화 — 신규 런(null) 또는 세이브 로드(non-null).
final class InitializeBuild extends BuildEvent {
  final String? currentJobId;

  /// 세이브 로드 시 2차 전직 직업 ID.
  final String? secondaryJobId;

  const InitializeBuild({this.currentJobId, this.secondaryJobId});

  @override
  List<Object?> get props => [currentJobId, secondaryJobId];
}

/// 1차 직업 분화 평가 — 성향 변경 후 호출.
final class EvaluateClassChange extends BuildEvent {
  final Map<DispositionAxis, int> disposition;
  const EvaluateClassChange(this.disposition);

  @override
  List<Object?> get props => [disposition];
}

/// 2차 전직 평가 — 1차 전직 완료 후 성향 변경 시 호출.
final class EvaluateSecondClassChange extends BuildEvent {
  final Map<DispositionAxis, int> disposition;
  const EvaluateSecondClassChange(this.disposition);

  @override
  List<Object?> get props => [disposition];
}

/// 전직 후보 선택 — 2개 이상 후보 중 하나를 선택.
final class SelectClassCandidate extends BuildEvent {
  final JobPath selectedJob;
  const SelectClassCandidate(this.selectedJob);

  @override
  List<Object?> get props => [selectedJob];
}

/// 분화 텍스트 표시 후 확인 — ClassChanging → Specialized 전환.
final class AcknowledgeClassChange extends BuildEvent {
  const AcknowledgeClassChange();

  @override
  List<Object?> get props => [];
}

/// 빌드 리셋 — 런 리셋 시 호출.
final class ResetBuild extends BuildEvent {
  const ResetBuild();

  @override
  List<Object?> get props => [];
}

/// 디버그: 지정 직업으로 강제 전직 (kDebugMode only).
final class DebugForceClassChange extends BuildEvent {
  final JobPath targetJob;
  const DebugForceClassChange(this.targetJob);

  @override
  List<Object?> get props => [targetJob];
}

/// 디버그: 전직 선택지 UI 강제 표시 (kDebugMode only).
final class DebugShowClassChoices extends BuildEvent {
  final List<JobPath> candidates;
  final bool isSecondClassChange;
  const DebugShowClassChoices(this.candidates, {this.isSecondClassChange = false});

  @override
  List<Object?> get props => [candidates, isSecondClassChange];
}
