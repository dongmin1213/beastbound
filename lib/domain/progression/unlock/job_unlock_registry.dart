import 'package:soul_dungeon/domain/progression/unlock/job_unlock_condition.dart';

/// 히든 직업 해금 조건 레지스트리.
///
/// 히든 직업 3종의 해금 조건을 정의.
/// - reaper: 총 3회 클리어
/// - illusionist: 암살자로 1회 클리어
/// - harmonist: 총 5회 클리어
///
/// 기본 직업 6종(전사/현자/암살자/성자/수호자/방랑자)은 해금 없이
/// 인게임 성향 수치로 자유 전직 가능.
class JobUnlockRegistry {
  JobUnlockRegistry._();

  static const List<JobUnlockCondition> conditions = [
    TotalWinsCondition(
      jobId: 'reaper',
      requiredTotalWins: 3,
    ),
    WinWithJobCondition(
      jobId: 'illusionist',
      requiredJobId: 'assassin',
      requiredJobDisplayName: '암살자',
      requiredWins: 1,
    ),
    TotalWinsCondition(
      jobId: 'harmonist',
      requiredTotalWins: 5,
    ),
  ];

  /// 직업 ID로 해금 조건 조회.
  static JobUnlockCondition? conditionFor(String jobId) {
    for (final c in conditions) {
      if (c.jobId == jobId) return c;
    }
    return null;
  }
}
