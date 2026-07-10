/// 히든 직업 해금 조건 정의.
///
/// 각 히든 직업의 해금 요구사항을 sealed class로 정의.
/// 실제 판정은 [JobUnlockChecker]가 수행.
sealed class JobUnlockCondition {
  /// 대상 직업 ID.
  String get jobId;

  /// 해금 조건 힌트 텍스트 (잠긴 상태에서 표시).
  String get hintText;

  const JobUnlockCondition();
}

/// 아무 직업으로 N회 클리어.
final class WinAnyJobCondition extends JobUnlockCondition {
  @override
  final String jobId;
  final int requiredWins;

  @override
  String get hintText => '던전을 $requiredWins회 클리어하세요';

  const WinAnyJobCondition({required this.jobId, required this.requiredWins});
}

/// 특정 직업으로 N회 클리어.
final class WinWithJobCondition extends JobUnlockCondition {
  @override
  final String jobId;
  final String requiredJobId;
  final String requiredJobDisplayName;
  final int requiredWins;

  @override
  String get hintText =>
      '$requiredJobDisplayName(으)로 $requiredWins회 클리어하세요';

  const WinWithJobCondition({
    required this.jobId,
    required this.requiredJobId,
    required this.requiredJobDisplayName,
    required this.requiredWins,
  });
}

/// 총 클리어 N회.
final class TotalWinsCondition extends JobUnlockCondition {
  @override
  final String jobId;
  final int requiredTotalWins;

  @override
  String get hintText => '총 $requiredTotalWins회 클리어하세요';

  const TotalWinsCondition({
    required this.jobId,
    required this.requiredTotalWins,
  });
}
