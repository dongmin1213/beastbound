
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/progression/memory/memory_fragment_pool.dart';

void main() {
  group('MemoryFragmentPool', () {
    test('총 15장 기억 조각', () {
      expect(MemoryFragmentPool.totalCount, 15);
    });

    test('ID 중복 없음', () {
      final ids = MemoryFragmentPool.all.map((f) => f.id).toSet();
      expect(ids.length, MemoryFragmentPool.all.length);
    });

    test('4범주 모두 존재', () {
      for (final category in MemoryCategory.values) {
        final fragments = MemoryFragmentPool.byCategory(category);
        expect(fragments.isNotEmpty, isTrue,
            reason: '${category.name} 범주에 기억 조각이 없음');
      }
    });

    test('범주별 수량: origin 4, loss 4, bond 4, cycle 3', () {
      expect(MemoryFragmentPool.byCategory(MemoryCategory.origin).length, 4);
      expect(MemoryFragmentPool.byCategory(MemoryCategory.loss).length, 4);
      expect(MemoryFragmentPool.byCategory(MemoryCategory.bond).length, 4);
      expect(MemoryFragmentPool.byCategory(MemoryCategory.cycle).length, 3);
    });

    test('byId — 존재하면 반환', () {
      final fragment = MemoryFragmentPool.byId('origin_01');
      expect(fragment, isNotNull);
      expect(fragment!.title, '첫 번째 발걸음');
    });

    test('byId — 존재하지 않으면 null', () {
      expect(MemoryFragmentPool.byId('nonexistent'), isNull);
    });

    test('unlockedFragments — 해금된 ID만 반환', () {
      final unlocked =
          MemoryFragmentPool.unlockedFragments({'origin_01', 'loss_01', 'fake'});
      expect(unlocked.length, 2);
      expect(unlocked.map((f) => f.id), containsAll(['origin_01', 'loss_01']));
    });

    test('모든 조각의 필드가 비어있지 않음', () {
      for (final fragment in MemoryFragmentPool.all) {
        expect(fragment.id, isNotEmpty, reason: 'id is empty');
        expect(fragment.title, isNotEmpty,
            reason: '${fragment.id} title is empty');
        expect(fragment.description, isNotEmpty,
            reason: '${fragment.id} description is empty');
        expect(fragment.unlockCondition, isNotEmpty,
            reason: '${fragment.id} unlockCondition is empty');
      }
    });

    test('MemoryFragment.fromJson/toJson 라운드트립', () {
      final original = MemoryFragmentPool.all.first;
      final json = original.toJson();
      final restored = MemoryFragment.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.category, original.category);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.unlockCondition, original.unlockCondition);
    });

    group('load()', () {
      test('load — valid JSON replaces defaults', () async {
        await MemoryFragmentPool.load(bundle: _TestAssetBundle());

        expect(MemoryFragmentPool.all.length, 2);
        expect(MemoryFragmentPool.all.first.id, 'test_origin_01');
        expect(MemoryFragmentPool.all.first.category, MemoryCategory.origin);
        expect(MemoryFragmentPool.all.first.title, 'Test Origin');
        expect(MemoryFragmentPool.all[1].id, 'test_loss_01');
        expect(MemoryFragmentPool.all[1].category, MemoryCategory.loss);

        // Reset to defaults for other tests.
        await MemoryFragmentPool.load(bundle: _InvalidAssetBundle());
      });

      test('load — invalid JSON keeps defaults', () async {
        final defaultCount = MemoryFragmentPool.all.length;

        await MemoryFragmentPool.load(bundle: _InvalidAssetBundle());

        expect(MemoryFragmentPool.all.length, defaultCount);
        expect(MemoryFragmentPool.all.first.id, 'origin_01');
      });
    });
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"fragments": ['
        '{"id": "test_origin_01", "category": "origin", '
        '"title": "Test Origin", "description": "A test origin fragment", '
        '"unlock_condition": "test_condition"}, '
        '{"id": "test_loss_01", "category": "loss", '
        '"title": "Test Loss", "description": "A test loss fragment", '
        '"unlock_condition": "test_condition_2"}'
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
