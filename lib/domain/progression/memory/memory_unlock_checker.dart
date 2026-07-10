import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/domain/progression/memory/memory_fragment_pool.dart';

/// 기억 조각 해금 조건 판정.
///
/// MetaSaveData의 런 기록으로 해금 가능 여부를 판정.
class MemoryUnlockChecker {
  MemoryUnlockChecker._();

  /// 현재 메타 데이터로 새로 해금 가능한 기억 조각 ID 목록 반환.
  static List<String> checkNewUnlocks(MetaSaveData meta) {
    final newUnlocks = <String>[];
    for (final fragment in MemoryFragmentPool.all) {
      if (meta.unlockedMemoryIds.contains(fragment.id)) continue;
      if (_meetsCondition(fragment.unlockCondition, meta)) {
        newUnlocks.add(fragment.id);
      }
    }
    return newUnlocks;
  }

  static bool _meetsCondition(String condition, MetaSaveData meta) {
    return switch (condition) {
      'first_run' => meta.totalRuns >= 1,
      'reach_floor_2' => meta.totalRuns >= 1,
      'reach_floor_3' => meta.totalRuns >= 2 || meta.clearCount >= 1,
      'reach_floor_4' => meta.totalRuns >= 3 || meta.clearCount >= 1,
      'reach_floor_5' => meta.clearCount >= 1,
      'complete_2_runs' => meta.totalRuns >= 2,
      'complete_3_runs' => meta.totalRuns >= 3,
      'complete_5_runs' => meta.totalRuns >= 5,
      'first_death' => meta.deathCount >= 1,
      'die_3_times' => meta.deathCount >= 3,
      'die_5_times' => meta.deathCount >= 5,
      'meet_ghost' => meta.totalRuns >= 2,
      'liberate_boss' => meta.endingsReached.contains('liberate'),
      'coexist_boss' => meta.endingsReached.contains('coexist'),
      'reach_3_endings' => meta.endingsReached.length >= 3,
      _ => false,
    };
  }
}
