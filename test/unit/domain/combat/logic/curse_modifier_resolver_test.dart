import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/curse_modifier_pool.dart';
import 'package:soul_dungeon/domain/combat/logic/curse_modifier_resolver.dart';

void main() {
  group('CurseModifierResolver', () {
    group('curseLevel', () {
      test('0 클리어 → 레벨 0', () {
        expect(CurseModifierResolver.curseLevel(0), 0);
      });

      test('1 클리어 → 레벨 1', () {
        expect(CurseModifierResolver.curseLevel(1), 1);
      });

      test('2 클리어 → 레벨 1', () {
        expect(CurseModifierResolver.curseLevel(2), 1);
      });

      test('3 클리어 → 레벨 2', () {
        expect(CurseModifierResolver.curseLevel(3), 2);
      });

      test('5 클리어 → 레벨 3', () {
        expect(CurseModifierResolver.curseLevel(5), 3);
      });

      test('8 클리어 → 레벨 4', () {
        expect(CurseModifierResolver.curseLevel(8), 4);
      });

      test('12 클리어 → 레벨 5', () {
        expect(CurseModifierResolver.curseLevel(12), 5);
      });

      test('100 클리어 → 레벨 5 (최대)', () {
        expect(CurseModifierResolver.curseLevel(100), 5);
      });
    });

    group('generateCurseIds', () {
      test('0 클리어 → 빈 목록', () {
        expect(CurseModifierResolver.generateCurseIds(0), isEmpty);
      });

      test('3 클리어 → 4종 레벨 2', () {
        final ids = CurseModifierResolver.generateCurseIds(3);
        expect(ids, hasLength(4));
        expect(ids, contains('curse_mod_combat:2'));
        expect(ids, contains('curse_mod_deck:2'));
        expect(ids, contains('curse_mod_card:2'));
        expect(ids, contains('curse_mod_narrator:2'));
      });
    });

    group('resolveCombatStart', () {
      test('빈 저주 → 보너스 없음', () {
        final result = CurseModifierResolver.resolveCombatStart([]);
        expect(result.enemyStrengthBonus, 0);
      });

      test('전투 저주 레벨 1 → 적 힘 +2', () {
        final curses = [CurseModifierPool.combatCurse.withLevel(1)];
        final result = CurseModifierResolver.resolveCombatStart(curses);
        expect(result.enemyStrengthBonus, 2);
      });

      test('전투 저주 레벨 3 → 적 힘 +5', () {
        final curses = [CurseModifierPool.combatCurse.withLevel(3)];
        final result = CurseModifierResolver.resolveCombatStart(curses);
        expect(result.enemyStrengthBonus, 5);
      });

      test('전투 저주 레벨 5 → 적 힘 +10', () {
        final curses = [CurseModifierPool.combatCurse.withLevel(5)];
        final result = CurseModifierResolver.resolveCombatStart(curses);
        expect(result.enemyStrengthBonus, 10);
      });

      test('비전투 저주 무시', () {
        final curses = [CurseModifierPool.deckCurse.withLevel(3)];
        final result = CurseModifierResolver.resolveCombatStart(curses);
        expect(result.enemyStrengthBonus, 0);
      });
    });

    group('resolveRewardReduction', () {
      test('빈 저주 → 감소 없음', () {
        expect(CurseModifierResolver.resolveRewardReduction([]), 0);
      });

      test('덱 저주 레벨 1 → 감소 0', () {
        final curses = [CurseModifierPool.deckCurse.withLevel(1)];
        expect(CurseModifierResolver.resolveRewardReduction(curses), 0);
      });

      test('덱 저주 레벨 2 → 감소 1', () {
        final curses = [CurseModifierPool.deckCurse.withLevel(2)];
        expect(CurseModifierResolver.resolveRewardReduction(curses), 1);
      });

      test('덱 저주 레벨 5 → 감소 2', () {
        final curses = [CurseModifierPool.deckCurse.withLevel(5)];
        expect(CurseModifierResolver.resolveRewardReduction(curses), 2);
      });
    });

    group('resolveShopPriceMultiplier', () {
      test('빈 저주 → 배율 1.0', () {
        expect(CurseModifierResolver.resolveShopPriceMultiplier([]), 1.0);
      });

      test('덱 저주 레벨 3 → 배율 1.5', () {
        final curses = [CurseModifierPool.deckCurse.withLevel(3)];
        expect(
          CurseModifierResolver.resolveShopPriceMultiplier(curses),
          1.5,
        );
      });

      test('덱 저주 레벨 5 → 배율 2.0', () {
        final curses = [CurseModifierPool.deckCurse.withLevel(5)];
        expect(
          CurseModifierResolver.resolveShopPriceMultiplier(curses),
          2.0,
        );
      });
    });

    group('resolveNarratorFloorOffset', () {
      test('빈 저주 → 오프셋 0', () {
        expect(CurseModifierResolver.resolveNarratorFloorOffset([]), 0);
      });

      test('서술자 저주 레벨 2 → 오프셋 1', () {
        final curses = [CurseModifierPool.narratorCurse.withLevel(2)];
        expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 1);
      });

      test('서술자 저주 레벨 5 → 오프셋 2', () {
        final curses = [CurseModifierPool.narratorCurse.withLevel(5)];
        expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 2);
      });
    });

    group('resolveCurseCardCount', () {
      test('빈 저주 → 0장', () {
        expect(CurseModifierResolver.resolveCurseCardCount([]), 0);
      });

      test('카드 저주 레벨 1 → 1장', () {
        final curses = [CurseModifierPool.cardCurse.withLevel(1)];
        expect(CurseModifierResolver.resolveCurseCardCount(curses), 1);
      });

      test('카드 저주 레벨 3 → 2장', () {
        final curses = [CurseModifierPool.cardCurse.withLevel(3)];
        expect(CurseModifierResolver.resolveCurseCardCount(curses), 2);
      });

      test('카드 저주 레벨 5 → 3장', () {
        final curses = [CurseModifierPool.cardCurse.withLevel(5)];
        expect(CurseModifierResolver.resolveCurseCardCount(curses), 3);
      });
    });

    group('통합 — resolveIds + 효과', () {
      test('generateCurseIds → resolveIds → 효과 해결', () {
        final ids = CurseModifierResolver.generateCurseIds(5); // level 3
        final curses = CurseModifierPool.resolveIds(ids);
        expect(curses, hasLength(4));

        final combat = CurseModifierResolver.resolveCombatStart(curses);
        expect(combat.enemyStrengthBonus, 5);

        expect(CurseModifierResolver.resolveRewardReduction(curses), 1);
        expect(CurseModifierResolver.resolveShopPriceMultiplier(curses), 1.5);
        expect(CurseModifierResolver.resolveNarratorFloorOffset(curses), 1);
        expect(CurseModifierResolver.resolveCurseCardCount(curses), 2);
      });
    });
  });
}
