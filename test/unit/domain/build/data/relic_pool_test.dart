
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/build/data/relic_pool.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('RelicPool', () {
    test('유물 ID 중복 없음', () {
      final ids = RelicPool.relics.map((r) => r.id).toSet();
      expect(ids.length, RelicPool.relics.length);
    });

    test('모든 유물의 effectValue > 0', () {
      for (final relic in RelicPool.relics) {
        expect(relic.effectValue, greaterThan(0),
            reason: '${relic.id} effectValue must be positive');
      }
    });

    test('findById — 존재하면 반환', () {
      final relic = RelicPool.findById('relic_001');
      expect(relic, isNotNull);
      expect(relic!.name, '녹슨 부적');
    });

    test('findById — 존재하지 않으면 null', () {
      expect(RelicPool.findById('nonexistent'), isNull);
    });

    test('resolveIds — 존재하는 ID만 반환', () {
      final result = RelicPool.resolveIds(['relic_001', 'nonexistent', 'relic_005']);
      expect(result.length, 2);
      expect(result[0].id, 'relic_001');
      expect(result[1].id, 'relic_005');
    });

    test('byRarity — common 유물만 필터', () {
      final commons = RelicPool.byRarity(Rarity.common);
      expect(commons.isNotEmpty, isTrue);
      for (final r in commons) {
        expect(r.rarity, Rarity.common);
      }
    });

    test('byRarity — legendary 유물 존재', () {
      final legendaries = RelicPool.byRarity(Rarity.legendary);
      expect(legendaries.isNotEmpty, isTrue);
    });

    test('조건 유형(conditionType)이 빈 문자열이 아님', () {
      for (final relic in RelicPool.relics) {
        expect(relic.conditionType.isNotEmpty, isTrue,
            reason: '${relic.id} conditionType must not be empty');
      }
    });

    test('패시브 효과(passiveEffect)가 빈 문자열이 아님', () {
      for (final relic in RelicPool.relics) {
        expect(relic.passiveEffect.isNotEmpty, isTrue,
            reason: '${relic.id} passiveEffect must not be empty');
      }
    });

    group('load()', () {
      test('load — valid JSON replaces defaults', () async {
        await RelicPool.load(bundle: _TestAssetBundle());

        expect(RelicPool.relics.length, 1);
        expect(RelicPool.relics.first.id, 'test_relic_001');
        expect(RelicPool.relics.first.name, 'Test Relic');
        expect(RelicPool.relics.first.rarity, Rarity.legendary);
        expect(RelicPool.relics.first.conditionType, 'testCondition');
        expect(RelicPool.relics.first.passiveEffect, 'testPassive');
        expect(RelicPool.relics.first.effectValue, 42);

        // Reset to defaults for other tests.
        await RelicPool.load(bundle: _InvalidAssetBundle());
      });

      test('load — invalid JSON keeps defaults', () async {
        final defaultCount = RelicPool.relics.length;

        await RelicPool.load(bundle: _InvalidAssetBundle());

        expect(RelicPool.relics.length, defaultCount);
        expect(RelicPool.relics.first.id, 'relic_001');
      });
    });
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"relics": ['
        '{"id": "test_relic_001", "name": "Test Relic", '
        '"description": "A test relic", "rarity": "legendary", '
        '"condition_type": "testCondition", "passive_effect": "testPassive", '
        '"effect_value": 42}'
        ']}';
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}

class _InvalidAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return 'not valid json';
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}
