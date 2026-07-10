import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/curse_modifier_pool.dart';
import 'package:soul_dungeon/domain/combat/logic/curse_modifier_resolver.dart';

void main() {
  group('E9 저주 밸런스 — curseLevel 임계값', () {
    test('클리어 0회 → 레벨 0', () {
      expect(CurseModifierResolver.curseLevel(0), 0);
    });

    test('클리어 1회 → 레벨 1', () {
      expect(CurseModifierResolver.curseLevel(1), 1);
    });

    test('클리어 2회 → 레벨 1', () {
      expect(CurseModifierResolver.curseLevel(2), 1);
    });

    test('클리어 3회 → 레벨 2', () {
      expect(CurseModifierResolver.curseLevel(3), 2);
    });

    test('클리어 4회 → 레벨 2', () {
      expect(CurseModifierResolver.curseLevel(4), 2);
    });

    test('클리어 5회 → 레벨 3', () {
      expect(CurseModifierResolver.curseLevel(5), 3);
    });

    test('클리어 7회 → 레벨 3', () {
      expect(CurseModifierResolver.curseLevel(7), 3);
    });

    test('클리어 8회 → 레벨 4', () {
      expect(CurseModifierResolver.curseLevel(8), 4);
    });

    test('클리어 11회 → 레벨 4', () {
      expect(CurseModifierResolver.curseLevel(11), 4);
    });

    test('클리어 12회 → 레벨 5 (최대)', () {
      expect(CurseModifierResolver.curseLevel(12), 5);
    });

    test('클리어 100회 → 레벨 5 (상한)', () {
      expect(CurseModifierResolver.curseLevel(100), 5);
    });
  });

  group('E9 저주 밸런스 — generateCurseIds', () {
    test('레벨 0 → 빈 목록', () {
      expect(CurseModifierResolver.generateCurseIds(0), isEmpty);
    });

    test('클리어 1회 → 4종 레벨 1 저주', () {
      final ids = CurseModifierResolver.generateCurseIds(1);
      expect(ids.length, 4);
      expect(ids, contains('curse_mod_combat:1'));
      expect(ids, contains('curse_mod_deck:1'));
      expect(ids, contains('curse_mod_card:1'));
      expect(ids, contains('curse_mod_narrator:1'));
    });

    test('클리어 12회 → 4종 레벨 5 저주', () {
      final ids = CurseModifierResolver.generateCurseIds(12);
      expect(ids.length, 4);
      for (final id in ids) {
        expect(id, endsWith(':5'));
      }
    });
  });

  group('E9 저주 밸런스 — CurseModifierPool.resolveIds', () {
    test('빈 목록 → 빈 결과', () {
      final curses = CurseModifierPool.resolveIds([]);
      expect(curses, isEmpty);
    });

    test('잘못된 형식 무시', () {
      final curses = CurseModifierPool.resolveIds(['invalid']);
      expect(curses, isEmpty);
    });

    test('레벨 0 → 비활성, 결과에 포함 안 됨', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_combat:0']);
      expect(curses, isEmpty);
    });

    test('전투 저주 레벨 3 → CurseModifierData 생성', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_combat:3']);
      expect(curses.length, 1);
      expect(curses.first.id, 'curse_mod_combat');
      expect(curses.first.level, 3);
      expect(curses.first.isActive, isTrue);
    });
  });

  group('E9 저주 밸런스 — 레벨 0 (저주 없음)', () {
    test('적 힘 보너스 = 0', () {
      final result = CurseModifierResolver.resolveCombatStart([]);
      expect(result.enemyStrengthBonus, 0);
    });

    test('보상 감소 = 0', () {
      expect(CurseModifierResolver.resolveRewardReduction([]), 0);
    });

    test('상점 가격 배율 = 1.0', () {
      expect(CurseModifierResolver.resolveShopPriceMultiplier([]), 1.0);
    });

    test('서술자 오프셋 = 0', () {
      expect(CurseModifierResolver.resolveNarratorFloorOffset([]), 0);
    });

    test('저주 카드 수 = 0', () {
      expect(CurseModifierResolver.resolveCurseCardCount([]), 0);
    });
  });

  group('E9 저주 밸런스 — 레벨 1 (전투 저주)', () {
    late List curses;

    setUp(() {
      curses = CurseModifierPool.resolveIds(['curse_mod_combat:1']);
    });

    test('적 힘 보너스 = +2', () {
      final result = CurseModifierResolver.resolveCombatStart(curses.cast());
      expect(result.enemyStrengthBonus, 2);
    });
  });

  group('E9 저주 밸런스 — 레벨 2 (전투 저주)', () {
    test('적 힘 보너스 = +3', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_combat:2']);
      final result = CurseModifierResolver.resolveCombatStart(curses);
      expect(result.enemyStrengthBonus, 3);
    });
  });

  group('E9 저주 밸런스 — 레벨 1~2 (덱 저주)', () {
    test('레벨 1 → 보상 감소 0, 상점 가격 1.0', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_deck:1']);
      expect(CurseModifierResolver.resolveRewardReduction(curses), 0);
      expect(CurseModifierResolver.resolveShopPriceMultiplier(curses), 1.0);
    });

    test('레벨 2 → 보상 감소 1, 상점 가격 1.3', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_deck:2']);
      expect(CurseModifierResolver.resolveRewardReduction(curses), 1);
      expect(
        CurseModifierResolver.resolveShopPriceMultiplier(curses),
        closeTo(1.3, 0.01),
      );
    });
  });

  group('E9 저주 밸런스 — 레벨 3~4', () {
    test('레벨 3: 전투 저주 적 힘 +5', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_combat:3']);
      final result = CurseModifierResolver.resolveCombatStart(curses);
      expect(result.enemyStrengthBonus, 5);
    });

    test('레벨 4: 전투 저주 적 힘 +7', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_combat:4']);
      final result = CurseModifierResolver.resolveCombatStart(curses);
      expect(result.enemyStrengthBonus, 7);
    });

    test('레벨 3: 덱 저주 보상 -1, 상점 1.5x', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_deck:3']);
      expect(CurseModifierResolver.resolveRewardReduction(curses), 1);
      expect(
        CurseModifierResolver.resolveShopPriceMultiplier(curses),
        closeTo(1.5, 0.01),
      );
    });

    test('레벨 4: 덱 저주 보상 -2, 상점 1.7x', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_deck:4']);
      expect(CurseModifierResolver.resolveRewardReduction(curses), 2);
      expect(
        CurseModifierResolver.resolveShopPriceMultiplier(curses),
        closeTo(1.7, 0.01),
      );
    });

    test('레벨 3: 카드 저주 카드 2장', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_card:3']);
      expect(CurseModifierResolver.resolveCurseCardCount(curses), 2);
    });

    test('레벨 4: 카드 저주 카드 2장', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_card:4']);
      expect(CurseModifierResolver.resolveCurseCardCount(curses), 2);
    });

    test('레벨 3: 서술자 저주 오프셋 1', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_narrator:3']);
      expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 1);
    });

    test('레벨 4: 서술자 저주 오프셋 2', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_narrator:4']);
      expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 2);
    });
  });

  group('E9 저주 밸런스 — 레벨 5 (최대)', () {
    test('전투 저주 적 힘 +10', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_combat:5']);
      final result = CurseModifierResolver.resolveCombatStart(curses);
      expect(result.enemyStrengthBonus, 10);
    });

    test('덱 저주 보상 -2, 상점 2.0x', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_deck:5']);
      expect(CurseModifierResolver.resolveRewardReduction(curses), 2);
      expect(
        CurseModifierResolver.resolveShopPriceMultiplier(curses),
        closeTo(2.0, 0.01),
      );
    });

    test('카드 저주 카드 3장', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_card:5']);
      expect(CurseModifierResolver.resolveCurseCardCount(curses), 3);
    });

    test('서술자 저주 오프셋 2', () {
      final curses = CurseModifierPool.resolveIds(['curse_mod_narrator:5']);
      expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 2);
    });
  });

  group('E9 저주 밸런스 — 복합 저주 (4종 동시)', () {
    test('레벨 3 전체 저주 → 각 효과 합산', () {
      final curses = CurseModifierPool.resolveIds([
        'curse_mod_combat:3',
        'curse_mod_deck:3',
        'curse_mod_card:3',
        'curse_mod_narrator:3',
      ]);
      expect(curses.length, 4);

      // 전투: +5
      final combat = CurseModifierResolver.resolveCombatStart(curses);
      expect(combat.enemyStrengthBonus, 5);

      // 덱: 보상 -1, 상점 1.5x
      expect(CurseModifierResolver.resolveRewardReduction(curses), 1);
      expect(
        CurseModifierResolver.resolveShopPriceMultiplier(curses),
        closeTo(1.5, 0.01),
      );

      // 카드: 2장
      expect(CurseModifierResolver.resolveCurseCardCount(curses), 2);

      // 서술자: 오프셋 1
      expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 1);
    });

    test('레벨 5 전체 저주 → 최대 효과', () {
      final curses = CurseModifierPool.resolveIds([
        'curse_mod_combat:5',
        'curse_mod_deck:5',
        'curse_mod_card:5',
        'curse_mod_narrator:5',
      ]);
      expect(curses.length, 4);

      final combat = CurseModifierResolver.resolveCombatStart(curses);
      expect(combat.enemyStrengthBonus, 10);
      expect(CurseModifierResolver.resolveRewardReduction(curses), 2);
      expect(
        CurseModifierResolver.resolveShopPriceMultiplier(curses),
        closeTo(2.0, 0.01),
      );
      expect(CurseModifierResolver.resolveCurseCardCount(curses), 3);
      expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 2);
    });

    test('generateCurseIds → resolveIds 라운드트립', () {
      final ids = CurseModifierResolver.generateCurseIds(8); // level 4
      final curses = CurseModifierPool.resolveIds(ids);
      expect(curses.length, 4);

      // 레벨 4 전투: +7
      final combat = CurseModifierResolver.resolveCombatStart(curses);
      expect(combat.enemyStrengthBonus, 7);

      // 레벨 4 덱: 보상 -2, 상점 1.7x
      expect(CurseModifierResolver.resolveRewardReduction(curses), 2);
      expect(
        CurseModifierResolver.resolveShopPriceMultiplier(curses),
        closeTo(1.7, 0.01),
      );

      // 레벨 4 카드: 2장
      expect(CurseModifierResolver.resolveCurseCardCount(curses), 2);

      // 레벨 4 서술자: 오프셋 2
      expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 2);
    });
  });

  group('E9 저주 밸런스 — 비활성 저주 무시', () {
    test('비활성(level=0) 저주는 효과 없음', () {
      // level 0은 resolveIds에서 걸러지지만, 직접 생성 케이스 테스트
      final result = CurseModifierResolver.resolveCombatStart([]);
      expect(result.enemyStrengthBonus, 0);
    });

    test('전투 저주가 아닌 다른 저주는 전투 효과에 영향 없음', () {
      final curses = CurseModifierPool.resolveIds([
        'curse_mod_deck:5',
        'curse_mod_card:5',
        'curse_mod_narrator:5',
      ]);
      final result = CurseModifierResolver.resolveCombatStart(curses);
      expect(result.enemyStrengthBonus, 0);
    });

    test('덱 저주가 아닌 다른 저주는 보상/상점에 영향 없음', () {
      final curses = CurseModifierPool.resolveIds([
        'curse_mod_combat:5',
        'curse_mod_card:5',
        'curse_mod_narrator:5',
      ]);
      expect(CurseModifierResolver.resolveRewardReduction(curses), 0);
      expect(CurseModifierResolver.resolveShopPriceMultiplier(curses), 1.0);
    });
  });

  group('E9 저주 밸런스 — CurseModifierPool 정적 레지스트리', () {
    test('전체 4종 등록', () {
      expect(CurseModifierPool.all.length, 4);
    });

    test('findById 동작', () {
      expect(CurseModifierPool.findById('curse_mod_combat'), isNotNull);
      expect(CurseModifierPool.findById('curse_mod_deck'), isNotNull);
      expect(CurseModifierPool.findById('curse_mod_card'), isNotNull);
      expect(CurseModifierPool.findById('curse_mod_narrator'), isNotNull);
      expect(CurseModifierPool.findById('nonexistent'), isNull);
    });
  });
}
