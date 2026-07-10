import 'package:soul_dungeon/core/events/game_event.dart';

/// 맵 생성 완료 시 발행되는 이벤트.
/// 향후 UI(미니맵 표시) / 오디오(BGM 전환) 구독용.
class MapGeneratedEvent extends GameEvent {
  final int floorNumber;
  final int nodeCount;
  final int seed;

  MapGeneratedEvent({
    required this.floorNumber,
    required this.nodeCount,
    required this.seed,
  });

  @override
  String toString() =>
      'MapGeneratedEvent(floorNumber: $floorNumber, nodeCount: $nodeCount, seed: $seed)';
}
