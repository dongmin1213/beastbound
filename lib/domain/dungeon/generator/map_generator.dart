import 'dart:math';

import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/map_node.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 분기 노드맵 생성기 — 층마다 여러 갈래 경로가 보스로 수렴.
/// 순수 함수 클래스 (static 메서드). 방 유형은 미할당 상태로 생성.
class MapGenerator {
  MapGenerator._();

  /// 시드 기반 결정론적 맵 생성.
  /// 비트 믹싱 해시로 floor별 시드 파생 → 동일 seed + floor → 동일 맵.
  static FloorMap generate(int floor, int seed, DungeonBalanceConfig config) {
    final floorSeed = (seed.hashCode ^ (floor * 0x9E3779B9)) & 0x7FFFFFFF;
    final random = Random(floorSeed);

    final targetNodes = config.roomsPerFloor;
    final branchMin = config.branchFactorMin;
    final branchMax = config.branchFactorMax;

    // depth 레이어별 노드 수 결정
    final layers = _buildLayers(targetNodes, branchMin, branchMax, random);

    // 노드 생성 + 연결
    final nodes = _buildNodes(layers, random);

    return FloorMap(
      floorNumber: floor,
      seed: seed,
      nodes: List.unmodifiable(nodes),
      startNodeId: nodes.first.id,
      bossNodeId: nodes.last.id,
    );
  }

  /// depth 레이어별 노드 수 배분.
  /// depth 0: 1 (시작), depth N: 1 (보스), 중간: branchMin~branchMax.
  static List<int> _buildLayers(
    int targetNodes,
    int branchMin,
    int branchMax,
    Random random,
  ) {
    final layers = <int>[1]; // depth 0: 시작 1개
    var remaining = targetNodes - 2; // 시작 + 보스 제외

    while (remaining > 0) {
      final maxForLayer = min(branchMax, remaining);
      final minForLayer = min(branchMin, maxForLayer);
      final count = minForLayer + random.nextInt(maxForLayer - minForLayer + 1);
      layers.add(count);
      remaining -= count;
    }

    layers.add(1); // 마지막: 보스 1개
    return layers;
  }

  /// 레이어 구조에서 노드 + 연결 생성.
  static List<MapNode> _buildNodes(List<int> layers, Random random) {
    final allNodes = <MapNode>[];
    var nodeCounter = 0;

    // 레이어별 노드 ID 맵핑
    final layerNodeIds = <List<String>>[];
    for (var depth = 0; depth < layers.length; depth++) {
      final ids = <String>[];
      for (var i = 0; i < layers[depth]; i++) {
        ids.add('node_$nodeCounter');
        nodeCounter++;
      }
      layerNodeIds.add(ids);
    }

    // 연결 구조 빌드
    // nextMap[id] = 다음 노드 ID 리스트
    // prevMap[id] = 이전 노드 ID 리스트
    final nextMap = <String, List<String>>{};
    final prevMap = <String, List<String>>{};

    for (final ids in layerNodeIds) {
      for (final id in ids) {
        nextMap[id] = [];
        prevMap[id] = [];
      }
    }

    // 레이어 간 연결 생성
    for (var depth = 0; depth < layers.length - 1; depth++) {
      final currentIds = layerNodeIds[depth];
      final nextIds = layerNodeIds[depth + 1];

      // 1단계: 모든 current 노드에 최소 1개 next 보장
      for (final currentId in currentIds) {
        final nextId = nextIds[random.nextInt(nextIds.length)];
        if (!nextMap[currentId]!.contains(nextId)) {
          nextMap[currentId]!.add(nextId);
          prevMap[nextId]!.add(currentId);
        }
      }

      // 2단계: 모든 next 노드에 최소 1개 prev 보장
      for (final nextId in nextIds) {
        if (prevMap[nextId]!.isEmpty) {
          final currentId = currentIds[random.nextInt(currentIds.length)];
          nextMap[currentId]!.add(nextId);
          prevMap[nextId]!.add(currentId);
        }
      }

      // 3단계: 추가 연결 (합류 패턴 생성)
      if (currentIds.length > 1 && nextIds.length > 1) {
        final extraConnections = random.nextInt(2); // 0~1개 추가
        for (var i = 0; i < extraConnections; i++) {
          final currentId = currentIds[random.nextInt(currentIds.length)];
          final nextId = nextIds[random.nextInt(nextIds.length)];
          if (!nextMap[currentId]!.contains(nextId)) {
            nextMap[currentId]!.add(nextId);
            prevMap[nextId]!.add(currentId);
          }
        }
      }
    }

    // MapNode 인스턴스 생성 (방 유형 미할당 = combat 기본값)
    for (var depth = 0; depth < layerNodeIds.length; depth++) {
      for (final id in layerNodeIds[depth]) {
        allNodes.add(MapNode(
          id: id,
          depth: depth,
          roomType: RoomType.combat, // RoomPlacer가 별도 할당
          nextNodeIds: List.unmodifiable(nextMap[id]!),
          prevNodeIds: List.unmodifiable(prevMap[id]!),
        ));
      }
    }

    return allNodes;
  }
}
