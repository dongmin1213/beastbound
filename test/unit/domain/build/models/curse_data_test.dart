import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/curse_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CurseData', () {
    test('JSON 직렬화/역직렬화', () {
      const curse = CurseData(
        id: 'curse_test',
        name: '테스트 저주',
        description: 'HP 감소',
        effectType: 'maxHpPenalty',
        effectValue: 10,
      );
      final json = curse.toJson();
      final restored = CurseData.fromJson(json);
      expect(restored.id, 'curse_test');
      expect(restored.name, '테스트 저주');
      expect(restored.description, 'HP 감소');
      expect(restored.rarity, Rarity.cursed);
      expect(restored.effectType, 'maxHpPenalty');
      expect(restored.effectValue, 10);
    });

    test('기본 rarity는 cursed', () {
      const curse = CurseData(
        id: 'c1',
        name: 'test',
        description: 'test',
        effectType: 'test',
        effectValue: 5,
      );
      expect(curse.rarity, Rarity.cursed);
    });

    test('ID 기반 equality', () {
      const a = CurseData(
        id: 'c1',
        name: 'A',
        description: 'A',
        effectType: 'a',
        effectValue: 1,
      );
      const b = CurseData(
        id: 'c1',
        name: 'B',
        description: 'B',
        effectType: 'b',
        effectValue: 2,
      );
      expect(a, equals(b));
    });

    test('다른 ID → 불일치', () {
      const a = CurseData(
        id: 'c1',
        name: 'same',
        description: 'same',
        effectType: 'same',
        effectValue: 1,
      );
      const b = CurseData(
        id: 'c2',
        name: 'same',
        description: 'same',
        effectType: 'same',
        effectValue: 1,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
