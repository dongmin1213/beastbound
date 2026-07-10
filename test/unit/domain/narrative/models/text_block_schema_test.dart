import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/narrative/models/text_block_schema.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('TextBlockSchema', () {
    final validJson = {
      'text_id': 'floor1_combat_intro_001',
      'text': '어둠 속에서 무언가가 다가온다.',
      'run_type': 'first',
      'boss_disposition': 'none',
      'reliable': true,
      'layer': 'l1',
      'floor': 1,
      'room_type': 'combat',
      'memory_category': 'none',
      'skip_flag': 'seen_floor1_intro_a',
      'priority': 10,
      'weight': 1.5,
      'tags': ['floor1', 'combat', 'intro'],
      'special_triggers': ['memory_fragment_001'],
    };

    test('fromJson/toJson roundtrip with all fields', () {
      final block = TextBlockSchema.fromJson(validJson);
      expect(block.textId, 'floor1_combat_intro_001');
      expect(block.text, '어둠 속에서 무언가가 다가온다.');
      expect(block.runType, RunType.first);
      expect(block.bossDisposition, BossDisposition.none);
      expect(block.reliable, isTrue);
      expect(block.layer, NarrativeLayer.l1);
      expect(block.floor, 1);
      expect(block.roomType, RoomType.combat);
      expect(block.memoryCategory, MemoryCategory.none);
      expect(block.skipFlag, 'seen_floor1_intro_a');
      expect(block.priority, 10);
      expect(block.weight, 1.5);
      expect(block.tags, {'floor1', 'combat', 'intro'});
      expect(block.specialTriggers, ['memory_fragment_001']);

      final output = block.toJson();
      final restored = TextBlockSchema.fromJson(output);
      expect(restored.textId, block.textId);
      expect(restored.text, block.text);
      expect(restored.runType, block.runType);
      expect(restored.bossDisposition, block.bossDisposition);
      expect(restored.reliable, block.reliable);
      expect(restored.layer, block.layer);
      expect(restored.floor, block.floor);
      expect(restored.roomType, block.roomType);
      expect(restored.memoryCategory, block.memoryCategory);
      expect(restored.skipFlag, block.skipFlag);
      expect(restored.priority, block.priority);
      expect(restored.weight, block.weight);
      expect(restored.tags, block.tags);
      expect(restored.specialTriggers, block.specialTriggers);
    });

    test('fromJson with optional fields missing uses defaults', () {
      final minimalJson = {
        'text_id': 'minimal_001',
        'text': '텍스트',
        'run_type': 'repeat',
        'boss_disposition': 'slayer',
        'reliable': false,
        'layer': 'l2',
        'floor': 3,
        'room_type': 'boss',
      };

      final block = TextBlockSchema.fromJson(minimalJson);
      expect(block.memoryCategory, MemoryCategory.none);
      expect(block.skipFlag, isNull);
      expect(block.priority, 0);
      expect(block.weight, 1.0);
      expect(block.tags, isEmpty);
      expect(block.specialTriggers, isEmpty);
    });

    test('toJson omits null skipFlag', () {
      const block = TextBlockSchema(
        textId: 'test',
        text: 'test',
        runType: RunType.first,
        bossDisposition: BossDisposition.none,
        reliable: true,
        layer: NarrativeLayer.l1,
        floor: 1,
        roomType: RoomType.combat,
      );

      final json = block.toJson();
      expect(json.containsKey('skip_flag'), isFalse);
    });

    test('empty tags produce empty set', () {
      final json = {
        'text_id': 'no_tags',
        'text': 'text',
        'run_type': 'first',
        'boss_disposition': 'none',
        'reliable': true,
        'layer': 'l1',
        'floor': 1,
        'room_type': 'event',
        'tags': <String>[],
      };

      final block = TextBlockSchema.fromJson(json);
      expect(block.tags, isEmpty);
    });

    test('unreliable narrator block', () {
      final json = {
        'text_id': 'unreliable_001',
        'text': '적의 HP는 분명 1이다. ...아마도.',
        'run_type': 'first',
        'boss_disposition': 'none',
        'reliable': false,
        'layer': 'l2',
        'floor': 2,
        'room_type': 'combat',
        'tags': ['unreliable', 'combat'],
      };

      final block = TextBlockSchema.fromJson(json);
      expect(block.reliable, isFalse);
      expect(block.tags.contains('unreliable'), isTrue);
    });

    test('negative JSON: missing required text_id throws TypeError', () {
      final badJson = {
        'text': 'text',
        'run_type': 'first',
        'boss_disposition': 'none',
        'reliable': true,
        'layer': 'l1',
        'floor': 1,
        'room_type': 'combat',
      };

      expect(
          () => TextBlockSchema.fromJson(badJson), throwsA(isA<TypeError>()));
    });

    test('negative JSON: invalid run_type falls back to RunType.first', () {
      final badJson = {
        'text_id': 'test',
        'text': 'text',
        'run_type': 'invalid',
        'boss_disposition': 'none',
        'reliable': true,
        'layer': 'l1',
        'floor': 1,
        'room_type': 'combat',
      };

      final block = TextBlockSchema.fromJson(badJson);
      expect(block.runType, RunType.first);
    });

    test('negative JSON: invalid room_type falls back to RoomType.combat', () {
      final badJson = {
        'text_id': 'test',
        'text': 'text',
        'run_type': 'first',
        'boss_disposition': 'none',
        'reliable': true,
        'layer': 'l1',
        'floor': 1,
        'room_type': 'invalid_room',
      };

      final block = TextBlockSchema.fromJson(badJson);
      expect(block.roomType, RoomType.combat);
    });
  });
}
