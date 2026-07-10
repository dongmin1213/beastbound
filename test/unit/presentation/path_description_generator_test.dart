import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/path_description_generator.dart';

void main() {
  group('PathDescriptionGenerator', () {
    test('모든 RoomType에 대해 non-empty 텍스트 반환', () {
      for (final type in RoomType.values) {
        final desc = PathDescriptionGenerator.describe(type, 'test_node');
        expect(desc.isNotEmpty, isTrue, reason: '$type should have a description');
      }
    });

    test('동일 nodeId → 동일 설명 (결정적)', () {
      const nodeId = 'room_42';
      final first = PathDescriptionGenerator.describe(RoomType.combat, nodeId);
      final second = PathDescriptionGenerator.describe(RoomType.combat, nodeId);
      expect(first, equals(second));
    });

    test('다른 nodeId → 최소 하나는 다른 설명', () {
      final descriptions = <String>{};
      for (int i = 0; i < 10; i++) {
        descriptions.add(
          PathDescriptionGenerator.describe(RoomType.combat, 'node_$i'),
        );
      }
      // 3개 풀에서 10개 노드 → 최소 2개 이상 다른 설명
      expect(descriptions.length, greaterThan(1));
    });

    test('엘리트 → ⚠ 마커 포함', () {
      // 3개 풀 모두 ⚠ 포함 확인
      for (int i = 0; i < 3; i++) {
        final desc = PathDescriptionGenerator.describe(RoomType.elite, 'e_$i');
        expect(desc, contains('⚠'), reason: 'elite node_$i should contain ⚠');
      }
    });

    test('보스 → ⚠ 마커 포함', () {
      for (int i = 0; i < 3; i++) {
        final desc = PathDescriptionGenerator.describe(RoomType.boss, 'b_$i');
        expect(desc, contains('⚠'), reason: 'boss node_$i should contain ⚠');
      }
    });

    test('비전투 방(shop/rest/npc) → ⚠ 미포함', () {
      for (final type in [RoomType.shop, RoomType.rest, RoomType.npc]) {
        for (int i = 0; i < 3; i++) {
          final desc = PathDescriptionGenerator.describe(type, 'safe_$i');
          expect(desc, isNot(contains('⚠')),
              reason: '$type should not contain ⚠');
        }
      }
    });
  });
}
