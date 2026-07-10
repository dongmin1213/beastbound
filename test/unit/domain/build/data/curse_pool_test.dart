
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/build/data/curse_pool.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CursePool', () {
    test('모든 저주는 cursed rarity', () {
      for (final curse in CursePool.curses) {
        expect(curse.rarity, Rarity.cursed,
            reason: '${curse.id} should be cursed rarity');
      }
    });

    test('저주 ID 중복 없음', () {
      final ids = CursePool.curses.map((c) => c.id).toSet();
      expect(ids.length, CursePool.curses.length);
    });

    test('악마 축복 ID 중복 없음', () {
      final ids = CursePool.devilBlessings.map((b) => b.id).toSet();
      expect(ids.length, CursePool.devilBlessings.length);
    });

    test('모든 악마 축복은 cursed rarity', () {
      for (final b in CursePool.devilBlessings) {
        expect(b.rarity, Rarity.cursed,
            reason: '${b.id} should be cursed rarity');
      }
    });

    test('모든 거래의 blessingId가 악마 축복 풀에 존재', () {
      for (final deal in CursePool.deals) {
        final blessing = CursePool.findDevilBlessingById(deal.blessingId);
        expect(blessing, isNotNull,
            reason: '${deal.id} references missing blessing ${deal.blessingId}');
      }
    });

    test('모든 거래의 curseId가 저주 풀에 존재', () {
      for (final deal in CursePool.deals) {
        final curse = CursePool.findCurseById(deal.curseId);
        expect(curse, isNotNull,
            reason: '${deal.id} references missing curse ${deal.curseId}');
      }
    });

    test('findCurseById — 존재하면 반환', () {
      final curse = CursePool.findCurseById('curse_001');
      expect(curse, isNotNull);
      expect(curse!.name, '약화');
    });

    test('findCurseById — 존재하지 않으면 null', () {
      expect(CursePool.findCurseById('nonexistent'), isNull);
    });

    test('findDevilBlessingById — 존재하면 반환', () {
      final blessing = CursePool.findDevilBlessingById('devil_blessing_001');
      expect(blessing, isNotNull);
      expect(blessing!.name, '피의 계약');
    });

    test('findDealById — 존재하면 반환', () {
      final deal = CursePool.findDealById('deal_001');
      expect(deal, isNotNull);
      expect(deal!.blessingId, 'devil_blessing_001');
    });

    test('resolveCurseIds — 존재하는 ID만 반환', () {
      final result =
          CursePool.resolveCurseIds(['curse_001', 'nonexistent', 'curse_003']);
      expect(result.length, 2);
      expect(result[0].id, 'curse_001');
      expect(result[1].id, 'curse_003');
    });

    test('거래 ID 중복 없음', () {
      final ids = CursePool.deals.map((d) => d.id).toSet();
      expect(ids.length, CursePool.deals.length);
    });

    group('load()', () {
      test('load — valid JSON replaces defaults', () async {
        await CursePool.load(bundle: _TestAssetBundle());

        expect(CursePool.curses.length, 1);
        expect(CursePool.curses.first.id, 'test_curse_001');
        expect(CursePool.curses.first.name, 'Test Curse');
        expect(CursePool.curses.first.effectValue, 77);

        expect(CursePool.devilBlessings.length, 1);
        expect(CursePool.devilBlessings.first.id, 'test_devil_001');
        expect(CursePool.devilBlessings.first.name, 'Test Devil Blessing');

        expect(CursePool.deals.length, 1);
        expect(CursePool.deals.first.id, 'test_deal_001');
        expect(CursePool.deals.first.blessingId, 'test_devil_001');
        expect(CursePool.deals.first.curseId, 'test_curse_001');

        // Reset to defaults for other tests.
        await CursePool.load(bundle: _InvalidAssetBundle());
      });

      test('load — invalid JSON keeps defaults', () async {
        final defaultCurseCount = CursePool.curses.length;
        final defaultDealCount = CursePool.deals.length;

        await CursePool.load(bundle: _InvalidAssetBundle());

        expect(CursePool.curses.length, defaultCurseCount);
        expect(CursePool.curses.first.id, 'curse_001');
        expect(CursePool.deals.length, defaultDealCount);
        expect(CursePool.devilBlessings.first.id, 'devil_blessing_001');
      });
    });
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"curses": ['
        '{"id": "test_curse_001", "name": "Test Curse", '
        '"description": "A test curse", "rarity": "cursed", '
        '"effect_type": "testPenalty", "effect_value": 77}'
        '], "devil_blessings": ['
        '{"id": "test_devil_001", "name": "Test Devil Blessing", '
        '"description": "A test devil blessing", "rarity": "cursed", '
        '"effect_type": "testBonus", "effect_value": 50}'
        '], "devil_deals": ['
        '{"id": "test_deal_001", "blessing_id": "test_devil_001", '
        '"curse_id": "test_curse_001", "cost": 0, '
        '"flavor_text": "A test deal."}'
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
