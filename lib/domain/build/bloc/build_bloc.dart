import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/class_change_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/build/bloc/build_event.dart';
import 'package:soul_dungeon/domain/build/bloc/build_state.dart';
import 'package:soul_dungeon/domain/build/logic/class_change_detector.dart';
import 'package:soul_dungeon/core/models/job_path.dart';

export 'build_event.dart';
export 'build_state.dart';

/// BuildBloc — 직업 분화 로직 관리 (1차 + 2차 전직).
///
/// 생성자 주입: [BuildConfig] + [GameEventBus].
/// domain/build/ 소유 — presentation에서 이벤트 전달.
class BuildBloc extends Bloc<BuildEvent, BuildState> {
  final BuildConfig config;
  final GameEventBus gameEventBus;

  /// 해금된 히든 직업 ID — ClassChangeDetector에 전달.
  Set<String> _unlockedHiddenJobIds;

  /// 1차 전직 직업 (2차 전직 시 참조용).
  JobPath? _primaryJob;

  BuildBloc({
    required this.config,
    required this.gameEventBus,
    Set<String> unlockedHiddenJobIds = const {},
  })  : _unlockedHiddenJobIds = unlockedHiddenJobIds,
        super(const BuildInitial()) {
    on<InitializeBuild>(_onInitializeBuild);
    on<EvaluateClassChange>(_onEvaluateClassChange);
    on<EvaluateSecondClassChange>(_onEvaluateSecondClassChange);
    on<SelectClassCandidate>(_onSelectClassCandidate);
    on<AcknowledgeClassChange>(_onAcknowledgeClassChange);
    on<ResetBuild>(_onResetBuild);
    on<DebugForceClassChange>(_onDebugForceClassChange);
    on<DebugShowClassChoices>(_onDebugShowClassChoices);
  }

  void _onInitializeBuild(
    InitializeBuild event,
    Emitter<BuildState> emit,
  ) {
    if (event.currentJobId == null) {
      emit(const BuildUnspecialized());
      return;
    }

    final job = JobPath.values.firstWhere(
      (j) => j.id == event.currentJobId,
      orElse: () => const Wanderer(),
    );

    // 세이브 로드 시 2차 전직 복원
    if (event.secondaryJobId != null) {
      final secondaryJob = JobPath.values.firstWhere(
        (j) => j.id == event.secondaryJobId,
        orElse: () => const Wanderer(),
      );
      _primaryJob = job;
      emit(BuildAdvancedSpecialized(
        primaryJob: job,
        secondaryJob: secondaryJob,
      ));
    } else if (job.isAdvanced || job.isCombination) {
      // 2차 전직 직업이 currentJobId에 저장된 경우 자동 감지
      // requiredPrimaryJobId로 1차 전직 직업 복원
      final primaryJobId = job.requiredPrimaryJobId;
      final primaryJob = primaryJobId != null
          ? JobPath.values.firstWhere(
              (j) => j.id == primaryJobId,
              orElse: () => const Wanderer(),
            )
          : const Wanderer();
      _primaryJob = primaryJob;
      emit(BuildAdvancedSpecialized(
        primaryJob: primaryJob,
        secondaryJob: job,
      ));
    } else {
      _primaryJob = job;
      emit(BuildSpecialized(job));
    }
  }

  void _onEvaluateClassChange(
    EvaluateClassChange event,
    Emitter<BuildState> emit,
  ) {
    // 이미 분화 완료/진행 중/선택 대기 중이면 무시
    if (state is BuildSpecialized ||
        state is BuildAdvancedSpecialized ||
        state is BuildClassChanging ||
        state is BuildClassChoosing) {
      return;
    }

    final candidates = ClassChangeDetector.evaluateCandidates(
      event.disposition,
      config,
      unlockedHiddenJobIds: _unlockedHiddenJobIds,
    );

    if (candidates.isEmpty) return;

    if (candidates.length == 1) {
      // 후보 1개 → 기존 동작: 자동 전직
      final job = candidates.first;
      emit(BuildClassChanging(job));
      gameEventBus.emit(ClassChangeEvent(
        jobId: job.id,
        displayName: job.displayName,
      ));
    } else {
      // 후보 2개+ → 선택 UI 표시
      emit(BuildClassChoosing(candidates));
    }
  }

  void _onEvaluateSecondClassChange(
    EvaluateSecondClassChange event,
    Emitter<BuildState> emit,
  ) {
    // 1차 전직 완료 상태에서만 2차 전직 평가 가능
    if (state is! BuildSpecialized) return;
    final currentJob = (state as BuildSpecialized).currentJob;

    // 이미 2차 전직된 직업이면 불가
    if (currentJob.isAdvanced || currentJob.isCombination) return;

    final candidates = ClassChangeDetector.evaluateSecondClassCandidates(
      currentJob,
      event.disposition,
      config,
    );

    if (candidates.isEmpty) return;

    if (candidates.length == 1) {
      final job = candidates.first;
      emit(BuildClassChanging(job, isSecondClassChange: true));
      gameEventBus.emit(ClassChangeEvent(
        jobId: job.id,
        displayName: job.displayName,
        isSecondClassChange: true,
      ));
    } else {
      emit(BuildClassChoosing(candidates, isSecondClassChange: true));
    }
  }

  void _onSelectClassCandidate(
    SelectClassCandidate event,
    Emitter<BuildState> emit,
  ) {
    if (state is! BuildClassChoosing) return;
    final choosing = state as BuildClassChoosing;
    final job = event.selectedJob;
    final isSecond = choosing.isSecondClassChange;
    emit(BuildClassChanging(job, isSecondClassChange: isSecond));
    gameEventBus.emit(ClassChangeEvent(
      jobId: job.id,
      displayName: job.displayName,
      isSecondClassChange: isSecond,
    ));
  }

  void _onAcknowledgeClassChange(
    AcknowledgeClassChange event,
    Emitter<BuildState> emit,
  ) {
    final current = state;
    if (current is BuildClassChanging) {
      if (current.isSecondClassChange && _primaryJob != null) {
        emit(BuildAdvancedSpecialized(
          primaryJob: _primaryJob!,
          secondaryJob: current.newJob,
        ));
      } else {
        _primaryJob = current.newJob;
        emit(BuildSpecialized(current.newJob));
      }
    }
  }

  void _onResetBuild(
    ResetBuild event,
    Emitter<BuildState> emit,
  ) {
    _primaryJob = null;
    emit(const BuildInitial());
  }

  /// 해금된 히든 직업 ID 업데이트 — 런 중 새 해금 시 호출.
  void updateUnlockedHiddenJobIds(Set<String> ids) {
    _unlockedHiddenJobIds = ids;
  }

  void _onDebugForceClassChange(
    DebugForceClassChange event,
    Emitter<BuildState> emit,
  ) {
    final job = event.targetJob;
    final isSecond = job.isAdvanced || job.isCombination;
    if (isSecond && _primaryJob == null) {
      // 1차 전직 없이 2차 직접 전직 시 → 1차를 자동 세팅
      // requiredPrimaryJobId 기반 또는 dominantAxis 기반 기본직 할당
      final baseJob = JobPath.tier1Values.where(
        (j) => !j.isHidden && j.dominantAxis == job.dominantAxis,
      ).firstOrNull;
      if (baseJob != null) {
        _primaryJob = baseJob;
        emit(BuildSpecialized(baseJob));
      }
    }
    emit(BuildClassChanging(job, isSecondClassChange: isSecond));
    gameEventBus.emit(ClassChangeEvent(
      jobId: job.id,
      displayName: job.displayName,
      isSecondClassChange: isSecond,
    ));
  }

  void _onDebugShowClassChoices(
    DebugShowClassChoices event,
    Emitter<BuildState> emit,
  ) {
    emit(BuildClassChoosing(
      event.candidates,
      isSecondClassChange: event.isSecondClassChange,
    ));
  }
}
