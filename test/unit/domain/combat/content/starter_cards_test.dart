import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('StarterCards', () {
    test('all — 정확히 7장', () {
      expect(StarterCards.all, hasLength(7));
    });

    test('타격 3장 — Attack, 1AP, 6d', () {
      for (final card in [
        StarterCards.strike1,
        StarterCards.strike2,
        StarterCards.strike3,
      ]) {
        expect(card.type, CardType.attack);
        expect(card.apCost, 1);
        expect(card.damage, 6);
        expect(card.isColorless, true);
      }
    });

    test('방어 2장 — Skill, 1AP, 5b', () {
      for (final card in [
        StarterCards.defend1,
        StarterCards.defend2,
      ]) {
        expect(card.type, CardType.skill);
        expect(card.apCost, 1);
        expect(card.block, 5);
        expect(card.isColorless, true);
      }
    });

    test('경계 — Skill, 1AP, 3d + 3b', () {
      final card = StarterCards.vigilance;
      expect(card.id, 'starter_vigilance');
      expect(card.type, CardType.skill);
      expect(card.apCost, 1);
      expect(card.damage, 3);
      expect(card.block, 3);
      expect(card.isColorless, true);
    });

    test('기합 — Skill, 0AP, Exhaust, 드로우1 + 기세5', () {
      final card = StarterCards.brace;
      expect(card.id, 'starter_brace');
      expect(card.type, CardType.skill);
      expect(card.apCost, 0);
      expect(card.isExhaust, true);
      expect(card.effects, hasLength(2));
      expect(card.effects[0].type, CardEffectType.draw);
      expect(card.effects[0].value, 1);
      expect(card.effects[1].type, CardEffectType.momentumGain);
      expect(card.effects[1].value, 5);
      expect(card.isColorless, true);
    });

    test('모든 시작 카드는 업그레이드 아님', () {
      for (final card in StarterCards.all) {
        expect(card.upgraded, false);
      }
    });

    test('모든 id가 고유', () {
      final ids = StarterCards.all.map((c) => c.id).toSet();
      expect(ids, hasLength(7));
    });

    test('업그레이드 타격 — 8d', () {
      expect(StarterCards.strikeUpgraded.damage, 8);
      expect(StarterCards.strikeUpgraded.upgraded, true);
    });

    test('업그레이드 방어 — 7b', () {
      expect(StarterCards.defendUpgraded.block, 7);
      expect(StarterCards.defendUpgraded.upgraded, true);
    });

    test('업그레이드 경계 — 4d + 5b', () {
      expect(StarterCards.vigilanceUpgraded.damage, 4);
      expect(StarterCards.vigilanceUpgraded.block, 5);
      expect(StarterCards.vigilanceUpgraded.upgraded, true);
    });

    test('업그레이드 기합 — 드로우2 + 기세8', () {
      final card = StarterCards.braceUpgraded;
      expect(card.upgraded, true);
      expect(card.isExhaust, true);
      expect(card.effects[0].type, CardEffectType.draw);
      expect(card.effects[0].value, 2);
      expect(card.effects[1].type, CardEffectType.momentumGain);
      expect(card.effects[1].value, 8);
    });
  });
}
