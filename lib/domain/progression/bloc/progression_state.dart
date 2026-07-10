import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/save/save_data.dart';

/// ProgressionBloc 상태 — 메타 진행 데이터.
sealed class ProgressionState extends Equatable {
  const ProgressionState();
}

/// 초기 상태 (로드 전).
final class ProgressionInitial extends ProgressionState {
  const ProgressionInitial();

  @override
  List<Object?> get props => [];
}

/// 메타 데이터 로드 완료.
final class ProgressionLoaded extends ProgressionState {
  final MetaSaveData meta;

  const ProgressionLoaded(this.meta);

  int get soulCount => meta.soulCount;
  int get totalRuns => meta.totalRuns;
  int get deathCount => meta.deathCount;
  int get clearCount => meta.clearCount;
  Set<String> get endingsReached => meta.endingsReached;
  Map<String, int> get upgradeLevels => meta.upgradeLevels;
  Set<String> get purchasedUpgradeIds => meta.purchasedUpgradeIds;
  Set<String> get unlockedCardIds => meta.unlockedCardIds;
  Set<String> get unlockedMemoryIds => meta.unlockedMemoryIds;
  Set<String> get unlockedHiddenJobIds => meta.unlockedHiddenJobIds;
  Map<String, int> get winsByJob => meta.winsByJob;

  @override
  List<Object?> get props => [
        meta.soulCount,
        meta.totalRuns,
        meta.deathCount,
        meta.clearCount,
        meta.endingsReached,
        meta.upgradeLevels,
        meta.purchasedUpgradeIds,
        meta.unlockedCardIds,
        meta.unlockedMemoryIds,
        meta.unlockedHiddenJobIds,
        meta.winsByJob,
      ];
}
