import 'package:soul_dungeon/core/events/game_event.dart';

/// 히든 직업 해금 이벤트 — GameEventBus 경유.
///
/// core → domain 역방향 의존 방지: String 필드만 사용 (JobPath import 금지).
class JobUnlockEvent extends GameEvent {
  /// 해금된 직업 ID (예: 'saint', 'reaper').
  final String jobId;

  /// 표시용 직업명 (예: '성자', '사신').
  final String displayName;

  JobUnlockEvent({required this.jobId, required this.displayName});

  @override
  String toString() =>
      'JobUnlockEvent(jobId: $jobId, displayName: $displayName)';
}
