import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/curse_modifier_data.dart';

void main() {
  group('CurseModifierData', () {
    test('기본 생성 — level 0 비활성', () {
      const curse = CurseModifierData(
        id: 'curse_mod_combat',
        name: '전투의 저주',
        description: '적이 더 강해집니다.',
        curseType: CurseModifierType.combat,
      );
      expect(curse.level, 0);
      expect(curse.isActive, false);
    });

    test('레벨 지정 — 활성 확인', () {
      const curse = CurseModifierData(
        id: 'curse_mod_deck',
        name: '덱의 저주',
        description: '카드 보상이 줄어듭니다.',
        curseType: CurseModifierType.deck,
        level: 3,
      );
      expect(curse.isActive, true);
      expect(curse.level, 3);
    });

    test('withLevel — 레벨 변경 복사', () {
      const base = CurseModifierData(
        id: 'curse_mod_card',
        name: '카드의 저주',
        description: '저주 카드가 추가됩니다.',
        curseType: CurseModifierType.card,
      );
      final upgraded = base.withLevel(4);
      expect(upgraded.level, 4);
      expect(upgraded.id, 'curse_mod_card');
      expect(upgraded.isActive, true);
    });

    test('withLevel — 범위 클램프', () {
      const base = CurseModifierData(
        id: 'curse_mod_narrator',
        name: '서술자의 저주',
        description: '서술자가 더 일찍 거짓말합니다.',
        curseType: CurseModifierType.narrator,
      );
      expect(base.withLevel(10).level, 5);
      expect(base.withLevel(-1).level, 0);
    });

    test('equality — 동일 id + level', () {
      const a = CurseModifierData(
        id: 'curse_mod_combat',
        name: '전투의 저주',
        description: 'desc',
        curseType: CurseModifierType.combat,
        level: 2,
      );
      const b = CurseModifierData(
        id: 'curse_mod_combat',
        name: '전투의 저주',
        description: 'desc',
        curseType: CurseModifierType.combat,
        level: 2,
      );
      expect(a, equals(b));
    });

    test('inequality — 다른 level', () {
      const a = CurseModifierData(
        id: 'curse_mod_combat',
        name: '전투의 저주',
        description: 'desc',
        curseType: CurseModifierType.combat,
        level: 2,
      );
      const b = CurseModifierData(
        id: 'curse_mod_combat',
        name: '전투의 저주',
        description: 'desc',
        curseType: CurseModifierType.combat,
        level: 3,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
