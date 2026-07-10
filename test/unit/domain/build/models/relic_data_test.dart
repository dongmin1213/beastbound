import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/relic_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('RelicData', () {
    final validJson = {
      'id': 'ancient_ring',
      'name': '고대의 반지',
      'description': '전투 시작 시 기세가 10 증가한다',
      'rarity': 'legendary',
      'condition_type': 'combatStart',
      'passive_effect': 'momentumGain',
      'effect_value': 10,
    };

    test('fromJson/toJson roundtrip', () {
      final relic = RelicData.fromJson(validJson);
      expect(relic.id, 'ancient_ring');
      expect(relic.name, '고대의 반지');
      expect(relic.description, '전투 시작 시 기세가 10 증가한다');
      expect(relic.rarity, Rarity.legendary);
      expect(relic.conditionType, 'combatStart');
      expect(relic.passiveEffect, 'momentumGain');
      expect(relic.effectValue, 10);

      final output = relic.toJson();
      final restored = RelicData.fromJson(output);
      expect(restored.id, relic.id);
      expect(restored.name, relic.name);
      expect(restored.rarity, relic.rarity);
      expect(restored.conditionType, relic.conditionType);
      expect(restored.passiveEffect, relic.passiveEffect);
      expect(restored.effectValue, relic.effectValue);
    });

    test('effectValue 미지정 시 기본값 0', () {
      final json = {
        'id': 'test',
        'name': 'test',
        'description': 'test',
        'rarity': 'common',
        'condition_type': 'test',
        'passive_effect': 'test',
      };
      final relic = RelicData.fromJson(json);
      expect(relic.effectValue, 0);
    });

    test('negative JSON: missing required field throws TypeError', () {
      final badJson = {
        'name': '고대의 반지',
        'description': 'desc',
        'rarity': 'legendary',
        'condition_type': 'combatStart',
      };

      expect(() => RelicData.fromJson(badJson), throwsA(isA<TypeError>()));
    });

    test('negative JSON: invalid rarity falls back to common', () {
      final badJson = {
        'id': 'test',
        'name': 'test',
        'description': 'test',
        'rarity': 'mythical',
        'condition_type': 'test',
        'passive_effect': 'test',
      };

      final data = RelicData.fromJson(badJson);
      expect(data.rarity, Rarity.common);
    });

    test('const constructor works', () {
      const relic = RelicData(
        id: 'test',
        name: 'test',
        description: 'test',
        rarity: Rarity.cursed,
        conditionType: 'test',
        passiveEffect: 'test',
      );
      expect(relic.rarity, Rarity.cursed);
    });
  });
}
