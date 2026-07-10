import 'dart:collection';

import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/domain/dungeon/error/dungeon_error.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 생성된 맵의 경로 보장 규칙을 독립 검증하는 클래스.
/// BFS 기반 경로 열거 — RoomPlacer의 DFS(PathFinder)와 교차 검증.
class MapValidator {
  MapValidator._();

  static Result<void> validate(FloorMap map, DungeonBalanceConfig config) {
    // (f) 고립 노드 없음
    for (final node in map.nodes) {
      if (node.id != map.startNodeId && node.prevNodeIds.isEmpty) {
        return Failure(IsolatedNode(nodeId: node.id));
      }
      if (node.id != map.bossNodeId && node.nextNodeIds.isEmpty) {
        return Failure(IsolatedNode(nodeId: node.id));
      }
    }

    // (d) 도달 가능 경로 최소 1개
    final allPaths = _bfsAllPaths(map);
    if (allPaths.isEmpty) {
      return const Failure(UnreachableBoss());
    }

    // (e) 엘리트 수 범위
    final eliteCount =
        map.nodes.where((n) => n.roomType == RoomType.elite).length;
    if (eliteCount < config.eliteMin || eliteCount > config.eliteMax) {
      return Failure(EliteCountOutOfRange(
        actual: eliteCount,
        min: config.eliteMin,
        max: config.eliteMax,
      ));
    }

    // (a) 모든 경로에 상점 최소 1개
    for (final path in allPaths) {
      final hasShop = path.any((id) {
        final node = map.nodeById(id);
        return node != null && node.roomType == RoomType.shop;
      });
      if (!hasShop) {
        return const Failure(NoShopOnPath());
      }
    }

    // (b) 모든 경로에 이벤트/NPC 최소 1개
    for (final path in allPaths) {
      final hasEventOrNpc = path.any((id) {
        final node = map.nodeById(id);
        return node != null &&
            (node.roomType == RoomType.event || node.roomType == RoomType.npc);
      });
      if (!hasEventOrNpc) {
        return const Failure(NoEventOnPath());
      }
    }

    // (h) 모든 경로에 휴식 방 최소 1개
    for (final path in allPaths) {
      final hasRest = path.any((id) {
        final node = map.nodeById(id);
        return node != null && node.roomType == RoomType.rest;
      });
      if (!hasRest) {
        return const Failure(NoRestOnPath());
      }
    }

    // (g) 경로별 최소 이벤트+NPC 수 (minEventsPerPath > 1일 때만)
    // NPC도 성향 변화에 기여하므로 합산 카운트.
    if (config.minEventsPerPath > 1) {
      for (final path in allPaths) {
        final eventNpcCount = path.where((id) {
          final node = map.nodeById(id);
          return node != null &&
              (node.roomType == RoomType.event ||
                  node.roomType == RoomType.npc);
        }).length;
        if (eventNpcCount < config.minEventsPerPath) {
          return Failure(InsufficientEventsOnPath(
            actual: eventNpcCount,
            required: config.minEventsPerPath,
          ));
        }
      }
    }

    return const Success(null);
  }

  /// BFS 기반 시작→보스 모든 경로 열거.
  /// PathFinder(DFS)와 독립된 알고리즘으로 교차 검증.
  static List<List<String>> _bfsAllPaths(FloorMap map) {
    const maxPaths = 5000; // 메모리 폭발 방지 안전 제한
    final results = <List<String>>[];
    final queue = Queue<List<String>>();
    queue.add([map.startNodeId]);

    while (queue.isNotEmpty) {
      final path = queue.removeFirst();
      final currentId = path.last;

      if (currentId == map.bossNodeId) {
        results.add(path);
        if (results.length >= maxPaths) break;
        continue;
      }

      final node = map.nodeById(currentId);
      if (node == null) continue;

      for (final nextId in node.nextNodeIds) {
        if (path.contains(nextId)) continue; // 순환 방지
        queue.add([...path, nextId]);
      }
    }

    return results;
  }
}
