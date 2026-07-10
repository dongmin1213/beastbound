import 'package:soul_dungeon/core/models/map_node.dart';

/// 한 층의 전체 맵 (불변).
/// DAG 구조: 시작 노드에서 보스 노드까지 전진만 가능.
class FloorMap {
  final int floorNumber;
  final int seed;
  final List<MapNode> nodes;
  final String startNodeId;
  final String bossNodeId;

  /// O(1) 노드 조회용 인덱스.
  final Map<String, MapNode> _nodeIndex;

  FloorMap({
    required this.floorNumber,
    required this.seed,
    required this.nodes,
    required this.startNodeId,
    required this.bossNodeId,
  }) : _nodeIndex = Map.unmodifiable({for (final node in nodes) node.id: node});

  /// O(1) 노드 조회.
  MapNode? nodeById(String id) => _nodeIndex[id];

  /// 특정 depth의 모든 노드 반환.
  List<MapNode> nodesAtDepth(int depth) =>
      nodes.where((n) => n.depth == depth).toList();

  /// 맵의 최대 depth (보스 노드 depth).
  int get maxDepth =>
      nodes.isEmpty ? 0 : nodes.map((n) => n.depth).reduce((a, b) => a > b ? a : b);
}
