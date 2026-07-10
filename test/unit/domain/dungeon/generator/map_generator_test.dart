import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/generator/map_generator.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';

void main() {
  const config = DungeonBalanceConfig();

  group('MapGenerator', () {
    test('generates correct node count within range', () {
      final map = MapGenerator.generate(1, 42, config);
      // rooms_per_floor=10, +1 for boss layer insertion
      expect(map.nodes.length, greaterThanOrEqualTo(config.roomsPerFloor));
      expect(map.nodes.length, lessThanOrEqualTo(config.roomsPerFloor + 2));
    });

    test('start node at depth 0 and boss node at max depth', () {
      final map = MapGenerator.generate(1, 42, config);
      final startNode = map.nodeById(map.startNodeId)!;
      final bossNode = map.nodeById(map.bossNodeId)!;

      expect(startNode.depth, 0);
      expect(bossNode.depth, map.maxDepth);
    });

    test('all node depths are monotonically increasing in connections', () {
      final map = MapGenerator.generate(1, 42, config);
      for (final node in map.nodes) {
        for (final nextId in node.nextNodeIds) {
          final nextNode = map.nodeById(nextId)!;
          expect(nextNode.depth, greaterThan(node.depth),
              reason: '${node.id}(depth=${node.depth}) → ${nextNode.id}(depth=${nextNode.depth})');
        }
      }
    });

    test('every non-start node has at least one prev connection, every non-boss node has at least one next', () {
      final map = MapGenerator.generate(1, 42, config);
      for (final node in map.nodes) {
        if (node.id != map.startNodeId) {
          expect(node.prevNodeIds, isNotEmpty,
              reason: '${node.id} has no prev connections (isolated)');
        }
        if (node.id != map.bossNodeId) {
          expect(node.nextNodeIds, isNotEmpty,
              reason: '${node.id} has no next connections (dead end)');
        }
      }
    });

    test('same seed + same floor produces identical map (deterministic)', () {
      final map1 = MapGenerator.generate(1, 42, config);
      final map2 = MapGenerator.generate(1, 42, config);

      expect(map1.nodes.length, map2.nodes.length);
      expect(map1.seed, map2.seed);
      for (var i = 0; i < map1.nodes.length; i++) {
        expect(map1.nodes[i].id, map2.nodes[i].id);
        expect(map1.nodes[i].depth, map2.nodes[i].depth);
        expect(map1.nodes[i].nextNodeIds, map2.nodes[i].nextNodeIds);
        expect(map1.nodes[i].prevNodeIds, map2.nodes[i].prevNodeIds);
      }
    });

    test('different seed produces different map', () {
      final map1 = MapGenerator.generate(1, 42, config);
      final map2 = MapGenerator.generate(1, 43, config);

      // 노드 수가 같을 수 있지만 연결 구조가 달라야 함
      final ids1 = map1.nodes.map((n) => n.nextNodeIds.join(',')).join('|');
      final ids2 = map2.nodes.map((n) => n.nextNodeIds.join(',')).join('|');
      expect(ids1, isNot(equals(ids2)));
    });

    test('branch factor respects config bounds per depth layer', () {
      final map = MapGenerator.generate(1, 42, config);
      // 중간 레이어 (depth 0과 maxDepth 제외)
      for (var depth = 1; depth < map.maxDepth; depth++) {
        final count = map.nodesAtDepth(depth).length;
        expect(count, greaterThanOrEqualTo(1));
        expect(count, lessThanOrEqualTo(config.branchFactorMax));
      }
    });

    test('floor-independent: different floors from same seed produce different maps', () {
      final map1 = MapGenerator.generate(1, 42, config);
      final map2 = MapGenerator.generate(2, 42, config);

      // 다른 floor → 내부 floorSeed 파생 → 다른 맵 구조
      final ids1 = map1.nodes.map((n) => n.nextNodeIds.join(',')).join('|');
      final ids2 = map2.nodes.map((n) => n.nextNodeIds.join(',')).join('|');
      expect(ids1, isNot(equals(ids2)));
    });
  });

  group('MapGenerator boundary configs', () {
    FloorMap generateAndValidateStructure(int floor, int seed, DungeonBalanceConfig cfg) {
      final map = MapGenerator.generate(floor, seed, cfg);
      // 기본 구조 검증
      expect(map.nodeById(map.startNodeId), isNotNull);
      expect(map.nodeById(map.bossNodeId), isNotNull);
      expect(map.nodeById(map.startNodeId)!.depth, 0);
      expect(map.nodeById(map.bossNodeId)!.depth, map.maxDepth);
      return map;
    }

    test('minimum config (rooms=8, branch=1)', () {
      const minConfig = DungeonBalanceConfig(
        roomsPerFloor: 8,
        branchFactorMin: 1,
        branchFactorMax: 1,
      );
      generateAndValidateStructure(1, 42, minConfig);
    });

    test('maximum config (rooms=15, branch=4)', () {
      const maxConfig = DungeonBalanceConfig(
        roomsPerFloor: 15,
        branchFactorMin: 3,
        branchFactorMax: 4,
      );
      generateAndValidateStructure(1, 42, maxConfig);
    });
  });
}
