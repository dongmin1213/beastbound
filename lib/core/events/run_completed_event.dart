import 'package:soul_dungeon/core/events/game_event.dart';

/// 런 완료 이벤트 — 5층 보스 클리어 후 발행.
class RunCompletedEvent extends GameEvent {
  final int totalFloors;

  /// 런 완료 시점의 직업 ID (null = 미분화).
  final String? jobId;

  RunCompletedEvent({required this.totalFloors, this.jobId});

  @override
  String toString() =>
      'RunCompletedEvent(totalFloors: $totalFloors, jobId: $jobId)';
}
