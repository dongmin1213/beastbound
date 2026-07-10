import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/blessing_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('BlessingData', () {
    final validJson = {
      'id': 'fire_shield',
      'name': '화염 방패',
      'description': '공격을 받을 때 화염으로 반격한다',
      'rarity': 'rare',
      'effect_type': 'counterAttack',
      'effect_value': 5,
      'job_affinity': 'warrior',
    };

    test('fromJson/toJson roundtrip', () {
      final blessing = BlessingData.fromJson(validJson);
      expect(blessing.id, 'fire_shield');
      expect(blessing.name, '화염 방패');
      expect(blessing.description, '공격을 받을 때 화염으로 반격한다');
      expect(blessing.rarity, Rarity.rare);
      expect(blessing.effectType, 'counterAttack');
      expect(blessing.effectValue, 5);
      expect(blessing.jobAffinity, 'warrior');

      final output = blessing.toJson();
      final restored = BlessingData.fromJson(output);
      expect(restored.id, blessing.id);
      expect(restored.name, blessing.name);
      expect(restored.rarity, blessing.rarity);
      expect(restored.effectValue, blessing.effectValue);
      expect(restored.jobAffinity, blessing.jobAffinity);
    });

    test('fromJson with optional fields missing', () {
      final json = {
        'id': 'minor_heal',
        'name': '소치유',
        'description': 'HP를 소량 회복',
        'rarity': 'common',
        'effect_type': 'heal',
      };

      final blessing = BlessingData.fromJson(json);
      expect(blessing.effectValue, 0);
      expect(blessing.jobAffinity, isNull);
    });

    test('toJson omits null jobAffinity', () {
      const blessing = BlessingData(
        id: 'test',
        name: 'test',
        description: 'test',
        rarity: Rarity.common,
        effectType: 'test',
      );

      final json = blessing.toJson();
      expect(json.containsKey('job_affinity'), isFalse);
    });

    test('negative JSON: missing required field throws TypeError', () {
      final badJson = {
        'name': '화염 방패',
        'description': 'desc',
        'rarity': 'rare',
        'effect_type': 'counter',
      };

      expect(() => BlessingData.fromJson(badJson), throwsA(isA<TypeError>()));
    });

    test('negative JSON: invalid rarity falls back to common', () {
      final badJson = {
        'id': 'test',
        'name': 'test',
        'description': 'test',
        'rarity': 'invalid_rarity',
        'effect_type': 'test',
      };

      final data = BlessingData.fromJson(badJson);
      expect(data.rarity, Rarity.common);
    });
  });
}
