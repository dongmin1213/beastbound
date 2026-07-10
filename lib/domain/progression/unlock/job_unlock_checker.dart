import 'package:soul_dungeon/domain/progression/unlock/job_unlock_condition.dart';
import 'package:soul_dungeon/domain/progression/unlock/job_unlock_registry.dart';

/// 히든 직업 해금 판정기.
///
/// MetaSaveData의 클리어 기록을 기반으로 해금 가능한 직업을 판정.
/// 순수 함수 — 부수 효과 없음.
class JobUnlockChecker {
  JobUnlockChecker._();

  /// 현재 기록으로 새로 해금 가능한 직업 ID 목록 반환.
  ///
  /// [alreadyUnlocked]: 이미 해금된 히든 직업 ID Set.
  /// [totalWins]: 총 클리어 횟수 (이번 클리어 포함).
  /// [winsByJob]: 직업별 클리어 횟수 (이번 클리어 포함).
  static List<String> checkNewUnlocks({
    required Set<String> alreadyUnlocked,
    required int totalWins,
    required Map<String, int> winsByJob,
  }) {
    final newUnlocks = <String>[];

    for (final condition in JobUnlockRegistry.conditions) {
      // 이미 해금된 직업은 스킵
      if (alreadyUnlocked.contains(condition.jobId)) continue;

      if (_isSatisfied(condition, totalWins, winsByJob)) {
        newUnlocks.add(condition.jobId);
      }
    }

    return newUnlocks;
  }

  static bool _isSatisfied(
    JobUnlockCondition condition,
    int totalWins,
    Map<String, int> winsByJob,
  ) {
    return switch (condition) {
      WinAnyJobCondition(:final requiredWins) =>
        totalWins >= requiredWins,
      WinWithJobCondition(:final requiredJobId, :final requiredWins) =>
        (winsByJob[requiredJobId] ?? 0) >= requiredWins,
      TotalWinsCondition(:final requiredTotalWins) =>
        totalWins >= requiredTotalWins,
    };
  }
}
