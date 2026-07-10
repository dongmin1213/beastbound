import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/curse_modifier_data.dart';
import 'package:soul_dungeon/core/models/curse_modifier_pool.dart';

void main() {
  group('CurseModifierPool', () {
    test('all — 4종 저주 등록', () {
      expect(CurseModifierPool.all, hasLength(4));
      final types =
          CurseModifierPool.all.map((c) => c.curseType).toSet();
      expect(types, containsAll(CurseModifierType.values));
    });

    test('findById — 존재하는 ID', () {
      final result = CurseModifierPool.findById('curse_mod_combat');
      expect(result, isNotNull);
      expect(result!.curseType, CurseModifierType.combat);
    });

    test('findById — 존재하지 않는 ID', () {
      expect(CurseModifierPool.findById('nonexistent'), isNull);
    });

    test('resolveIds — 유효한 ID:level 파싱', () {
      final curses = CurseModifierPool.resolveIds([
        'curse_mod_combat:3',
        'curse_mod_deck:2',
      ]);
      expect(curses, hasLength(2));
      expect(curses[0].id, 'curse_mod_combat');
      expect(curses[0].level, 3);
      expect(curses[1].id, 'curse_mod_deck');
      expect(curses[1].level, 2);
    });

    test('resolveIds — level 0 필터링', () {
      final curses = CurseModifierPool.resolveIds([
        'curse_mod_combat:0',
      ]);
      expect(curses, isEmpty);
    });

    test('resolveIds — 잘못된 형식 무시', () {
      final curses = CurseModifierPool.resolveIds([
        'invalid_format',
        'curse_mod_combat:3',
        'no_colon',
      ]);
      expect(curses, hasLength(1));
      expect(curses[0].id, 'curse_mod_combat');
    });

    test('resolveIds — 존재하지 않는 ID 무시', () {
      final curses = CurseModifierPool.resolveIds([
        'nonexistent_curse:3',
      ]);
      expect(curses, isEmpty);
    });

    test('resolveIds — 레벨 클램프', () {
      final curses = CurseModifierPool.resolveIds([
        'curse_mod_card:10',
      ]);
      expect(curses, hasLength(1));
      expect(curses[0].level, 5);
    });
  });
}
