import 'package:soul_dungeon/core/models/floor_map.dart';

/// HSM FloorState — 현재 층 번호 + FloorMap 참조 (불변).
class FloorState {
  final int floorNumber;
  final FloorMap floorMap;

  const FloorState({
    required this.floorNumber,
    required this.floorMap,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FloorState &&
          runtimeType == other.runtimeType &&
          floorNumber == other.floorNumber &&
          floorMap == other.floorMap;

  @override
  int get hashCode => Object.hash(floorNumber, floorMap);

  @override
  String toString() => 'FloorState(floor: $floorNumber)';
}
