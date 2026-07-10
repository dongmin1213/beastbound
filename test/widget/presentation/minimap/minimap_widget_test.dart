import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/map_node.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/minimap/minimap_widget.dart';
import 'package:soul_dungeon/presentation/widgets/minimap/room_symbol.dart';

FloorMap _createTestMap() {
  return FloorMap(
    floorNumber: 1,
    seed: 42,
    nodes: [
      const MapNode(
        id: 'start',
        depth: 0,
        roomType: RoomType.combat,
        nextNodeIds: ['shop_1', 'combat_1'],
      ),
      const MapNode(
        id: 'shop_1',
        depth: 1,
        roomType: RoomType.shop,
        prevNodeIds: ['start'],
        nextNodeIds: ['boss'],
      ),
      const MapNode(
        id: 'combat_1',
        depth: 1,
        roomType: RoomType.combat,
        prevNodeIds: ['start'],
        nextNodeIds: ['boss'],
      ),
      const MapNode(
        id: 'boss',
        depth: 2,
        roomType: RoomType.boss,
        prevNodeIds: ['shop_1', 'combat_1'],
      ),
    ],
    startNodeId: 'start',
    bossNodeId: 'boss',
  );
}

void main() {
  group('MinimapWidget', () {
    testWidgets('DAG 렌더링 — 모험가의 메모 타이틀 표시', (tester) async {
      final map = _createTestMap();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimapWidget(
              floorMap: map,
              currentNodeId: 'start',
              visitedNodeIds: const {'start'},
            ),
          ),
        ),
      );

      expect(find.text('~ 모험가의 메모 ~'), findsOneWidget);
    });

    testWidgets('심볼 표시 — current/available/typeRevealed locked는 실제 심볼',
        (tester) async {
      final map = _createTestMap();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimapWidget(
              floorMap: map,
              currentNodeId: 'start',
              visitedNodeIds: const {'start'},
            ),
          ),
        ),
      );

      // start(combat) = [X] (current)
      // shop_1 = [$] (available — 실제 심볼 공개)
      // combat_1 = [X] (available — 실제 심볼 공개)
      // boss = [B] (locked but typeRevealed — depth 2 <= 0 + 2)
      expect(find.text('[X]'), findsNWidgets(2)); // current + available combat
      expect(find.text('[\$]'), findsOneWidget); // available shop
      expect(find.text('[B]'), findsOneWidget); // locked but type-revealed boss
    });

    testWidgets('현재 노드 강조 — current 상태 구분', (tester) async {
      final map = _createTestMap();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimapWidget(
              floorMap: map,
              currentNodeId: 'start',
              visitedNodeIds: const {'start'},
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers, isNotEmpty);
    });

    testWidgets('미니맵은 읽기 전용 — 노드 탭해도 콜백 없음', (tester) async {
      final map = _createTestMap();
      String? tappedNodeId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimapWidget(
              floorMap: map,
              currentNodeId: 'start',
              visitedNodeIds: const {'start'},
              onNodeTap: (nodeId) => tappedNodeId = nodeId,
            ),
          ),
        ),
      );

      // available 노드 탭 — 미니맵은 읽기 전용이므로 콜백 없음
      await tester.tap(find.text('[\$]').first);
      expect(tappedNodeId, isNull);
    });

    testWidgets('타입 공개 범위 — 먼 locked 노드는 [·] 표시', (tester) async {
      // 7-depth 맵: 0→1→2→3→4→5→6
      final map = FloorMap(
        floorNumber: 1,
        seed: 42,
        nodes: const [
          MapNode(id: 'd0', depth: 0, roomType: RoomType.combat, nextNodeIds: ['d1']),
          MapNode(id: 'd1', depth: 1, roomType: RoomType.shop, prevNodeIds: ['d0'], nextNodeIds: ['d2']),
          MapNode(id: 'd2', depth: 2, roomType: RoomType.rest, prevNodeIds: ['d1'], nextNodeIds: ['d3']),
          MapNode(id: 'd3', depth: 3, roomType: RoomType.elite, prevNodeIds: ['d2'], nextNodeIds: ['d4']),
          MapNode(id: 'd4', depth: 4, roomType: RoomType.event, prevNodeIds: ['d3'], nextNodeIds: ['d5']),
          MapNode(id: 'd5', depth: 5, roomType: RoomType.npc, prevNodeIds: ['d4'], nextNodeIds: ['d6']),
          MapNode(id: 'd6', depth: 6, roomType: RoomType.boss, prevNodeIds: ['d5']),
        ],
        startNodeId: 'd0',
        bossNodeId: 'd6',
      );

      // typeRevealAhead=2 → depth 0~2 타입 공개, depth 3+ 미공개
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimapWidget(
              floorMap: map,
              currentNodeId: 'd0',
              visitedNodeIds: const {'d0'},
            ),
          ),
        ),
      );

      // depth 0 (current): [X], depth 1 (available): [$]
      // depth 2 (locked, typeRevealed): [R]
      // depth 3~6 (locked, NOT typeRevealed): [\u00B7] x4
      expect(find.text('[X]'), findsOneWidget);
      expect(find.text('[\$]'), findsOneWidget);
      expect(find.text('[R]'), findsOneWidget);
      expect(find.text('[\u00B7]'), findsNWidgets(4));
    });

    testWidgets('엘리트 available 노드 — 타입별 악센트 색상 렌더링',
        (tester) async {
      final map = FloorMap(
        floorNumber: 1,
        seed: 42,
        nodes: const [
          MapNode(
            id: 'start',
            depth: 0,
            roomType: RoomType.combat,
            nextNodeIds: ['elite_1'],
          ),
          MapNode(
            id: 'elite_1',
            depth: 1,
            roomType: RoomType.elite,
            prevNodeIds: ['start'],
            nextNodeIds: ['boss'],
          ),
          MapNode(
            id: 'boss',
            depth: 2,
            roomType: RoomType.boss,
            prevNodeIds: ['elite_1'],
          ),
        ],
        startNodeId: 'start',
        bossNodeId: 'boss',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimapWidget(
              floorMap: map,
              currentNodeId: 'start',
              visitedNodeIds: const {'start'},
            ),
          ),
        ),
      );

      // 엘리트 available 노드는 실제 심볼 [E]로 표시
      expect(find.text('[E]'), findsOneWidget);

      // available 노드의 텍스트 색상이 타입별 악센트 색상인지 검증
      final eliteText = tester.widget<Text>(find.text('[E]'));
      expect(
        eliteText.style?.color,
        RoomSymbolData.typeAccentColor(RoomType.elite),
      );
    });
  });
}
