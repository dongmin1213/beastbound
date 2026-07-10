import 'package:soul_dungeon/core/events/game_event.dart';

/// 직업 분화 이벤트 — GameEventBus 경유.
///
/// core → domain 역방향 의존 방지: String 필드만 사용 (JobPath import 금지).
class ClassChangeEvent extends GameEvent {
  final String jobId;
  final String displayName;

  /// 2차 전직 여부. false = 1차 전직, true = 2차 전직 (상위직/조합직).
  final bool isSecondClassChange;

  ClassChangeEvent({
    required this.jobId,
    required this.displayName,
    this.isSecondClassChange = false,
  });

  @override
  String toString() =>
      'ClassChangeEvent(jobId: $jobId, displayName: $displayName, isSecondClassChange: $isSecondClassChange)';
}
