import 'package:soul_dungeon/core/models/floor_map.dart';

/// 시작→보스 경로 열거 유틸.
/// RoomPlacer가 경로 커버리지 확인에 사용.
/// 내부 전용 (barrel export 미노출).
///
/// rooms ≤ 15: DFS 전체 열거 (기존).
/// rooms > 15: 보스→시작 역추적 — 경로 수 폭발 방지.
class PathFinder {
  PathFinder._();

  /// 시작 노드에서 보스 노드까지 모든 경로를 열거.
  /// DAG 구조(depth 증가만)이므로 순환 불가.
  static List<List<String>> allPaths(FloorMap map) {
    if (map.nodes.length > 15) {
      return _backtrackPaths(map);
    }
    final results = <List<String>>[];
    _dfs(map, map.startNodeId, map.bossNodeId, [], results);
    return results;
  }

  // ── DFS (rooms ≤ 15) ──

  static void _dfs(
    FloorMap map,
    String current,
    String target,
    List<String> path,
    List<List<String>> results,
  ) {
    path.add(current);

    if (current == target) {
      results.add(List<String>.from(path));
    } else {
      final node = map.nodeById(current);
      if (node != null) {
        for (final next in node.nextNodeIds) {
          _dfs(map, next, target, path, results);
        }
      }
    }

    path.removeLast();
  }

  // ── 역추적 (rooms > 15) ──
  // 보스에서 시작으로 prevNodeIds를 따라 역순 DFS.
  // DAG이므로 순환 없음. 경로를 뒤집어 시작→보스 순서로 반환.

  static List<List<String>> _backtrackPaths(FloorMap map) {
    final results = <List<String>>[];
    _reverseDfs(map, map.bossNodeId, map.startNodeId, [], results);
    return results.map((p) => p.reversed.toList()).toList();
  }

  static void _reverseDfs(
    FloorMap map,
    String current,
    String target,
    List<String> path,
    List<List<String>> results,
  ) {
    path.add(current);

    if (current == target) {
      results.add(List<String>.from(path));
    } else {
      final node = map.nodeById(current);
      if (node != null) {
        for (final prev in node.prevNodeIds) {
          _reverseDfs(map, prev, target, path, results);
        }
      }
    }

    path.removeLast();
  }
}
