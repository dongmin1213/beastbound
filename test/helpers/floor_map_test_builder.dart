import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/map_node.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 테스트 전용 FloorMap 빌더.
/// 특정 규칙만 위반하는 맵을 쉽게 생성.
/// MapValidator, RoomPlacer 테스트에서 공유.
class FloorMapTestBuilder {
  int _floorNumber = 1;
  int _seed = 42;
  List<MapNode> _nodes = [];

  FloorMapTestBuilder withFloor(int n) {
    _floorNumber = n;
    return this;
  }

  FloorMapTestBuilder withSeed(int s) {
    _seed = s;
    return this;
  }

  FloorMapTestBuilder addNode(MapNode n) {
    _nodes.add(n);
    return this;
  }

  /// 유효한 기본 10노드 DAG 생성 (모든 규칙 충족).
  /// 구조:
  ///   d0: start(combat)
  ///   d1: A(shop), B(shop)
  ///   d2: C(elite), D(npc)
  ///   d3: E(event), F(mystery)
  ///   d4: G(rest), H(npc)
  ///   d5: boss(boss)
  ///
  /// 경로별 검증:
  ///   start→A(shop)→C→E(event)→G(rest)→boss ✓ shop, event, rest
  ///   start→A(shop)→D(npc)→E(event)→G(rest)→boss ✓ shop, npc, rest
  ///   start→A(shop)→D(npc)→F→H(rest)→boss ✓ shop, npc, rest
  ///   start→B(shop)→D(npc)→E(event)→G(rest)→boss ✓ shop, npc, rest
  ///   start→B(shop)→D(npc)→F→H(rest)→boss ✓ shop, npc, rest
  FloorMapTestBuilder withValidDefaults() {
    _nodes = [
      const MapNode(id: 'start', depth: 0, roomType: RoomType.combat, nextNodeIds: ['A', 'B']),
      const MapNode(id: 'A', depth: 1, roomType: RoomType.shop, nextNodeIds: ['C', 'D'], prevNodeIds: ['start']),
      const MapNode(id: 'B', depth: 1, roomType: RoomType.shop, nextNodeIds: ['D'], prevNodeIds: ['start']),
      const MapNode(id: 'C', depth: 2, roomType: RoomType.elite, nextNodeIds: ['E'], prevNodeIds: ['A']),
      const MapNode(id: 'D', depth: 2, roomType: RoomType.npc, nextNodeIds: ['E', 'F'], prevNodeIds: ['A', 'B']),
      const MapNode(id: 'E', depth: 3, roomType: RoomType.event, nextNodeIds: ['G'], prevNodeIds: ['C', 'D']),
      const MapNode(id: 'F', depth: 3, roomType: RoomType.mystery, nextNodeIds: ['H'], prevNodeIds: ['D']),
      const MapNode(id: 'G', depth: 4, roomType: RoomType.rest, nextNodeIds: ['boss'], prevNodeIds: ['E']),
      const MapNode(id: 'H', depth: 4, roomType: RoomType.rest, nextNodeIds: ['boss'], prevNodeIds: ['F']),
      const MapNode(id: 'boss', depth: 5, roomType: RoomType.boss, prevNodeIds: ['G', 'H']),
    ];
    return this;
  }

  /// 특정 노드의 방 유형 변경.
  FloorMapTestBuilder changeNodeType(String nodeId, RoomType newType) {
    _nodes = _nodes.map((n) => n.id == nodeId ? n.copyWith(roomType: newType) : n).toList();
    return this;
  }

  /// 특정 경로에서 상점 제거 (NoShopOnPath 위반 유도).
  /// 기본 valid 맵에서 A(shop), B(shop)을 모두 combat으로 변경.
  FloorMapTestBuilder withoutShopOnPath() {
    return changeNodeType('A', RoomType.combat)
        .changeNodeType('B', RoomType.combat);
  }

  /// 보스 직전 노드를 전부 combat으로 변경 (NoPreBossRest 위반 유도).
  FloorMapTestBuilder withCombatBeforeBoss() {
    return changeNodeType('G', RoomType.combat)
        .changeNodeType('H', RoomType.combat);
  }

  /// 이벤트/NPC 전부 제거 (NoEventOnPath 위반 유도).
  /// D(npc), E(event), H(npc)를 모두 combat으로 변경.
  FloorMapTestBuilder withoutEventOrNpc() {
    return changeNodeType('D', RoomType.combat)
        .changeNodeType('E', RoomType.combat)
        .changeNodeType('H', RoomType.combat);
  }

  /// 엘리트 수만 초과 유도 (config.eliteMax=2 기준, 3개 배치).
  /// C는 이미 elite + E(event→elite), F(mystery→elite) = 총 3개.
  /// shop/event/npc/rest 경로 보장은 유지.
  FloorMapTestBuilder withExcessElites() {
    return changeNodeType('E', RoomType.elite)
        .changeNodeType('F', RoomType.elite);
  }

  /// 보스 도달 불가 맵 — A가 dead end (next 없음), boss도 prev 없음.
  /// IsolatedNode 또는 UnreachableBoss 중 하나가 발생.
  FloorMapTestBuilder withUnreachableBoss() {
    _nodes = [
      const MapNode(id: 'start', depth: 0, roomType: RoomType.combat, nextNodeIds: ['A']),
      const MapNode(id: 'A', depth: 1, roomType: RoomType.shop, prevNodeIds: ['start']),
      const MapNode(id: 'boss', depth: 2, roomType: RoomType.boss),
    ];
    return this;
  }

  FloorMap build() {
    assert(_nodes.isNotEmpty, 'No nodes provided');
    return FloorMap(
      floorNumber: _floorNumber,
      seed: _seed,
      nodes: List.unmodifiable(_nodes),
      startNodeId: _nodes.first.id,
      bossNodeId: _nodes.last.id,
    );
  }
}
