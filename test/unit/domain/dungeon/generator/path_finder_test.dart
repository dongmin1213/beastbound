import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/generator/path_finder.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/map_node.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('PathFinder', () {
    test('single linear path: S → A → B', () {
      final map = FloorMap(
        floorNumber: 1,
        seed: 1,
        nodes: const [
          MapNode(id: 'S', depth: 0, roomType: RoomType.combat, nextNodeIds: ['A']),
          MapNode(id: 'A', depth: 1, roomType: RoomType.shop, nextNodeIds: ['B'], prevNodeIds: ['S']),
          MapNode(id: 'B', depth: 2, roomType: RoomType.boss, prevNodeIds: ['A']),
        ],
        startNodeId: 'S',
        bossNodeId: 'B',
      );

      final paths = PathFinder.allPaths(map);
      expect(paths.length, 1);
      expect(paths[0], ['S', 'A', 'B']);
    });

    test('branching paths: S → A/B → Boss', () {
      final map = FloorMap(
        floorNumber: 1,
        seed: 1,
        nodes: const [
          MapNode(id: 'S', depth: 0, roomType: RoomType.combat, nextNodeIds: ['A', 'B']),
          MapNode(id: 'A', depth: 1, roomType: RoomType.shop, nextNodeIds: ['Boss'], prevNodeIds: ['S']),
          MapNode(id: 'B', depth: 1, roomType: RoomType.event, nextNodeIds: ['Boss'], prevNodeIds: ['S']),
          MapNode(id: 'Boss', depth: 2, roomType: RoomType.boss, prevNodeIds: ['A', 'B']),
        ],
        startNodeId: 'S',
        bossNodeId: 'Boss',
      );

      final paths = PathFinder.allPaths(map);
      expect(paths.length, 2);
      expect(paths, containsAll([
        ['S', 'A', 'Boss'],
        ['S', 'B', 'Boss'],
      ]));
    });

    test('merge paths: S → A/B → C → Boss', () {
      final map = FloorMap(
        floorNumber: 1,
        seed: 1,
        nodes: const [
          MapNode(id: 'S', depth: 0, roomType: RoomType.combat, nextNodeIds: ['A', 'B']),
          MapNode(id: 'A', depth: 1, roomType: RoomType.shop, nextNodeIds: ['C'], prevNodeIds: ['S']),
          MapNode(id: 'B', depth: 1, roomType: RoomType.event, nextNodeIds: ['C'], prevNodeIds: ['S']),
          MapNode(id: 'C', depth: 2, roomType: RoomType.rest, nextNodeIds: ['Boss'], prevNodeIds: ['A', 'B']),
          MapNode(id: 'Boss', depth: 3, roomType: RoomType.boss, prevNodeIds: ['C']),
        ],
        startNodeId: 'S',
        bossNodeId: 'Boss',
      );

      final paths = PathFinder.allPaths(map);
      expect(paths.length, 2);
      // 두 경로 모두 C를 거침 (합류)
      for (final path in paths) {
        expect(path.contains('C'), isTrue);
        expect(path.first, 'S');
        expect(path.last, 'Boss');
      }
    });

    test('complex graph: branch + merge + re-branch', () {
      //  S → A, B
      //  A → C, D
      //  B → D
      //  C → E
      //  D → E
      //  E → Boss
      final map = FloorMap(
        floorNumber: 1,
        seed: 1,
        nodes: const [
          MapNode(id: 'S', depth: 0, roomType: RoomType.combat, nextNodeIds: ['A', 'B']),
          MapNode(id: 'A', depth: 1, roomType: RoomType.shop, nextNodeIds: ['C', 'D'], prevNodeIds: ['S']),
          MapNode(id: 'B', depth: 1, roomType: RoomType.event, nextNodeIds: ['D'], prevNodeIds: ['S']),
          MapNode(id: 'C', depth: 2, roomType: RoomType.mystery, nextNodeIds: ['E'], prevNodeIds: ['A']),
          MapNode(id: 'D', depth: 2, roomType: RoomType.rest, nextNodeIds: ['E'], prevNodeIds: ['A', 'B']),
          MapNode(id: 'E', depth: 3, roomType: RoomType.npc, nextNodeIds: ['Boss'], prevNodeIds: ['C', 'D']),
          MapNode(id: 'Boss', depth: 4, roomType: RoomType.boss, prevNodeIds: ['E']),
        ],
        startNodeId: 'S',
        bossNodeId: 'Boss',
      );

      final paths = PathFinder.allPaths(map);
      // S→A→C→E→Boss, S→A→D→E→Boss, S→B→D→E→Boss = 3 paths
      expect(paths.length, 3);
      for (final path in paths) {
        expect(path.first, 'S');
        expect(path.last, 'Boss');
      }
    });

    test('backtrack optimization: >15 nodes uses reverse DFS', () {
      // 16노드 그래프: 역추적 경로 검증
      // S → A1,A2 → B1,B2,B3 → C1,C2,C3 → D1,D2,D3 → E1,E2,E3 → Boss
      final nodes = const <MapNode>[
        MapNode(id: 'S', depth: 0, roomType: RoomType.combat, nextNodeIds: ['A1', 'A2']),
        MapNode(id: 'A1', depth: 1, roomType: RoomType.combat, nextNodeIds: ['B1', 'B2'], prevNodeIds: ['S']),
        MapNode(id: 'A2', depth: 1, roomType: RoomType.combat, nextNodeIds: ['B2', 'B3'], prevNodeIds: ['S']),
        MapNode(id: 'B1', depth: 2, roomType: RoomType.shop, nextNodeIds: ['C1'], prevNodeIds: ['A1']),
        MapNode(id: 'B2', depth: 2, roomType: RoomType.shop, nextNodeIds: ['C1', 'C2'], prevNodeIds: ['A1', 'A2']),
        MapNode(id: 'B3', depth: 2, roomType: RoomType.shop, nextNodeIds: ['C2', 'C3'], prevNodeIds: ['A2']),
        MapNode(id: 'C1', depth: 3, roomType: RoomType.event, nextNodeIds: ['D1'], prevNodeIds: ['B1', 'B2']),
        MapNode(id: 'C2', depth: 3, roomType: RoomType.event, nextNodeIds: ['D1', 'D2'], prevNodeIds: ['B2', 'B3']),
        MapNode(id: 'C3', depth: 3, roomType: RoomType.event, nextNodeIds: ['D2', 'D3'], prevNodeIds: ['B3']),
        MapNode(id: 'D1', depth: 4, roomType: RoomType.mystery, nextNodeIds: ['E1'], prevNodeIds: ['C1', 'C2']),
        MapNode(id: 'D2', depth: 4, roomType: RoomType.mystery, nextNodeIds: ['E1', 'E2'], prevNodeIds: ['C2', 'C3']),
        MapNode(id: 'D3', depth: 4, roomType: RoomType.mystery, nextNodeIds: ['E2', 'E3'], prevNodeIds: ['C3']),
        MapNode(id: 'E1', depth: 5, roomType: RoomType.rest, nextNodeIds: ['Boss'], prevNodeIds: ['D1', 'D2']),
        MapNode(id: 'E2', depth: 5, roomType: RoomType.rest, nextNodeIds: ['Boss'], prevNodeIds: ['D2', 'D3']),
        MapNode(id: 'E3', depth: 5, roomType: RoomType.rest, nextNodeIds: ['Boss'], prevNodeIds: ['D3']),
        MapNode(id: 'Boss', depth: 6, roomType: RoomType.boss, prevNodeIds: ['E1', 'E2', 'E3']),
      ];

      final map = FloorMap(
        floorNumber: 1,
        seed: 1,
        nodes: nodes,
        startNodeId: 'S',
        bossNodeId: 'Boss',
      );

      // 16노드 → 역추적 DFS 사용
      expect(map.nodes.length, greaterThan(15));

      final paths = PathFinder.allPaths(map);
      expect(paths.isNotEmpty, isTrue);

      // 모든 경로가 S→...→Boss, 길이 7 (깊이 0~6)
      for (final path in paths) {
        expect(path.first, 'S');
        expect(path.last, 'Boss');
        expect(path.length, 7);
      }
    });
  });
}
