import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/map_node.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  late FloorMap map;

  setUp(() {
    map = FloorMap(
      floorNumber: 1,
      seed: 42,
      nodes: const [
        MapNode(id: 'start', depth: 0, roomType: RoomType.combat, nextNodeIds: ['a', 'b']),
        MapNode(id: 'a', depth: 1, roomType: RoomType.shop, nextNodeIds: ['c'], prevNodeIds: ['start']),
        MapNode(id: 'b', depth: 1, roomType: RoomType.event, nextNodeIds: ['c'], prevNodeIds: ['start']),
        MapNode(id: 'c', depth: 2, roomType: RoomType.rest, nextNodeIds: ['boss'], prevNodeIds: ['a', 'b']),
        MapNode(id: 'boss', depth: 3, roomType: RoomType.boss, prevNodeIds: ['c']),
      ],
      startNodeId: 'start',
      bossNodeId: 'boss',
    );
  });

  group('FloorMap', () {
    test('nodeById returns correct node in O(1)', () {
      expect(map.nodeById('start')?.roomType, RoomType.combat);
      expect(map.nodeById('a')?.roomType, RoomType.shop);
      expect(map.nodeById('boss')?.roomType, RoomType.boss);
      expect(map.nodeById('nonexistent'), isNull);
    });

    test('nodesAtDepth returns all nodes at given depth', () {
      final depth0 = map.nodesAtDepth(0);
      expect(depth0.length, 1);
      expect(depth0.first.id, 'start');

      final depth1 = map.nodesAtDepth(1);
      expect(depth1.length, 2);
      expect(depth1.map((n) => n.id).toSet(), {'a', 'b'});

      final depth99 = map.nodesAtDepth(99);
      expect(depth99, isEmpty);
    });

    test('maxDepth returns boss node depth and boss node is accessible', () {
      expect(map.maxDepth, 3);
      expect(map.nodeById(map.bossNodeId)?.depth, 3);
      expect(map.nodeById(map.startNodeId)?.depth, 0);
    });
  });
}
