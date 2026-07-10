
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/build/data/blessing_pool.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('BlessingPool', () {
    test('축복 ID 중복 없음', () {
      final ids = BlessingPool.blessings.map((b) => b.id).toSet();
      expect(ids.length, BlessingPool.blessings.length);
    });

    test('모든 축복의 effectValue > 0', () {
      for (final blessing in BlessingPool.blessings) {
        expect(blessing.effectValue, greaterThan(0),
            reason: '${blessing.id} effectValue must be positive');
      }
    });

    test('findById — 존재하면 반환', () {
      final blessing = BlessingPool.findById('blessing_001');
      expect(blessing, isNotNull);
      expect(blessing!.name, '힘의 축복');
    });

    test('findById — 존재하지 않으면 null', () {
      expect(BlessingPool.findById('nonexistent'), isNull);
    });

    test('resolveIds — 존재하는 ID만 반환', () {
      final result = BlessingPool.resolveIds(
          ['blessing_001', 'nonexistent', 'blessing_005']);
      expect(result.length, 2);
      expect(result[0].id, 'blessing_001');
      expect(result[1].id, 'blessing_005');
    });

    test('shopBlessings — blessing_ 접두사만 필터', () {
      final shop = BlessingPool.shopBlessings;
      expect(shop.isNotEmpty, isTrue);
      for (final b in shop) {
        expect(b.id.startsWith('blessing_'), isTrue,
            reason: '${b.id} should start with blessing_');
      }
    });

    test('NPC 축복 포함', () {
      final npc = BlessingPool.blessings
          .where((b) => b.id.startsWith('npc_'))
          .toList();
      expect(npc.length, 6);
    });

    test('악마 축복 포함', () {
      final devil = BlessingPool.blessings
          .where((b) => b.id.startsWith('devil_'))
          .toList();
      expect(devil.length, 4);
      for (final b in devil) {
        expect(b.rarity, Rarity.cursed);
      }
    });

    group('load()', () {
      test('load — valid JSON replaces defaults', () async {
        await BlessingPool.load(bundle: _TestAssetBundle());

        expect(BlessingPool.blessings.length, 1);
        expect(BlessingPool.blessings.first.id, 'test_blessing_001');
        expect(BlessingPool.blessings.first.name, 'Test Blessing');
        expect(BlessingPool.blessings.first.rarity, Rarity.rare);
        expect(BlessingPool.blessings.first.effectType, 'testEffect');
        expect(BlessingPool.blessings.first.effectValue, 99);

        // Reset to defaults for other tests.
        await BlessingPool.load(bundle: _InvalidAssetBundle());
      });

      test('load — invalid JSON keeps defaults', () async {
        final defaultCount = BlessingPool.blessings.length;

        await BlessingPool.load(bundle: _InvalidAssetBundle());

        expect(BlessingPool.blessings.length, defaultCount);
        expect(BlessingPool.blessings.first.id, 'blessing_001');
      });
    });
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"blessings": ['
        '{"id": "test_blessing_001", "name": "Test Blessing", '
        '"description": "A test blessing", "rarity": "rare", '
        '"effect_type": "testEffect", "effect_value": 99}'
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
