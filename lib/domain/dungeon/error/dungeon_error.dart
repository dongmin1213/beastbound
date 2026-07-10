import 'package:soul_dungeon/core/error/game_error.dart';

/// 던전 생성 관련 에러 기반 클래스.
/// sealed class — switch exhaustiveness 보장 (MapValidationError / MapGenerationExhausted).
sealed class DungeonError extends GameError {
  const DungeonError({
    required super.message,
    super.severity = ErrorSeverity.recoverable,
    super.cause,
  }) : super(system: 'dungeon');
}

/// 맵 검증 실패 에러 (sealed class — switch exhaustiveness).
sealed class MapValidationError extends DungeonError {
  const MapValidationError({required super.message});
}

/// 모든 경로에 상점이 없음.
final class NoShopOnPath extends MapValidationError {
  const NoShopOnPath() : super(message: 'Not all paths have a shop');
}

/// 모든 경로에 이벤트/NPC가 없음.
final class NoEventOnPath extends MapValidationError {
  const NoEventOnPath() : super(message: 'Not all paths have an event or NPC');
}

/// 보스 직전 레이어에 휴식/상점/NPC가 없음.
final class NoPreBossRest extends MapValidationError {
  const NoPreBossRest() : super(message: 'No rest/shop/NPC before boss');
}

/// 시작에서 보스까지 도달 불가.
final class UnreachableBoss extends MapValidationError {
  const UnreachableBoss() : super(message: 'Boss node is unreachable from start');
}

/// 엘리트 수가 설정 범위 밖.
final class EliteCountOutOfRange extends MapValidationError {
  final int actual;
  final int min;
  final int max;

  const EliteCountOutOfRange({
    required this.actual,
    required this.min,
    required this.max,
  }) : super(message: 'Elite count $actual not in range $min~$max');
}

/// 경로별 최소 이벤트 수 미충족.
final class InsufficientEventsOnPath extends MapValidationError {
  final int actual;
  final int required;

  const InsufficientEventsOnPath({
    required this.actual,
    required this.required,
  }) : super(
            message:
                'Path has $actual events, need at least $required');
}

/// 모든 경로에 휴식 방이 없음.
final class NoRestOnPath extends MapValidationError {
  const NoRestOnPath() : super(message: 'Not all paths have a rest room');
}

/// 고립 노드 존재.
final class IsolatedNode extends MapValidationError {
  final String nodeId;

  const IsolatedNode({required this.nodeId})
      : super(message: 'Node $nodeId is isolated (no connections)');
}

/// 맵 생성 최대 재시도 초과.
final class MapGenerationExhausted extends DungeonError {
  final int attempts;

  const MapGenerationExhausted({required this.attempts})
      : super(
          message: 'Map generation failed after $attempts attempts',
          severity: ErrorSeverity.critical,
        );
}
