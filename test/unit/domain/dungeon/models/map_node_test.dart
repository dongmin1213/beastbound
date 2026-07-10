import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/map_node.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('MapNode', () {
    test('creates node and copyWith preserves/overrides fields', () {
      const node = MapNode(
        id: 'n1',
        depth: 0,
        roomType: RoomType.combat,
        nextNodeIds: ['n2', 'n3'],
        prevNodeIds: [],
      );

      expect(node.id, 'n1');
      expect(node.depth, 0);
      expect(node.roomType, RoomType.combat);
      expect(node.nextNodeIds, ['n2', 'n3']);
      expect(node.prevNodeIds, isEmpty);

      final copied = node.copyWith(roomType: RoomType.shop, depth: 2);
      expect(copied.id, 'n1');
      expect(copied.depth, 2);
      expect(copied.roomType, RoomType.shop);
      expect(copied.nextNodeIds, ['n2', 'n3']);
    });

    test('equality and hashCode based on all fields', () {
      const a = MapNode(
        id: 'n1',
        depth: 1,
        roomType: RoomType.event,
        nextNodeIds: ['n2'],
        prevNodeIds: ['n0'],
      );
      const b = MapNode(
        id: 'n1',
        depth: 1,
        roomType: RoomType.event,
        nextNodeIds: ['n2'],
        prevNodeIds: ['n0'],
      );
      const c = MapNode(
        id: 'n1',
        depth: 1,
        roomType: RoomType.shop,
        nextNodeIds: ['n2'],
        prevNodeIds: ['n0'],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
