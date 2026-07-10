import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/environment_cards.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('EnvironmentCards', () {
    test('base 11종', () {
      expect(EnvironmentCards.allBase.length, 11);
    });

    test('upgraded 11종', () {
      expect(EnvironmentCards.allUpgraded.length, 11);
    });

    test('모든 base ID 고유', () {
      final ids = EnvironmentCards.allBase.map((c) => c.id).toSet();
      expect(ids.length, 11);
    });

    test('모든 upgraded ID 고유', () {
      final ids = EnvironmentCards.allUpgraded.map((c) => c.id).toSet();
      expect(ids.length, 11);
    });

    test('모든 base 카드는 Exhaust 키워드', () {
      for (final card in EnvironmentCards.allBase) {
        expect(card.keywords.contains(CardKeyword.exhaust), true,
            reason: '${card.name} should have Exhaust');
      }
    });

    test('모든 upgraded 카드는 Exhaust 키워드', () {
      for (final card in EnvironmentCards.allUpgraded) {
        expect(card.keywords.contains(CardKeyword.exhaust), true,
            reason: '${card.name} should have Exhaust');
      }
    });

    test('모든 upgraded는 upgraded=true', () {
      for (final card in EnvironmentCards.allUpgraded) {
        expect(card.upgraded, true, reason: '${card.name} should be upgraded');
      }
    });

    test('모든 base는 upgraded=false', () {
      for (final card in EnvironmentCards.allBase) {
        expect(card.upgraded, false, reason: '${card.name} should not be upgraded');
      }
    });

    test('천장 낙석 — fixedDamage 20', () {
      final card = EnvironmentCards.ceilingCollapse;
      expect(card.effects.first.type, CardEffectType.fixedDamage);
      expect(card.effects.first.value, 20);
    });

    test('천장 낙석+ — fixedDamage 30', () {
      final card = EnvironmentCards.ceilingCollapsePlus;
      expect(card.effects.first.type, CardEffectType.fixedDamage);
      expect(card.effects.first.value, 30);
    });

    test('늪의 독기 — applyPoison 8', () {
      final card = EnvironmentCards.swampMiasma;
      expect(card.effects.first.type, CardEffectType.applyPoison);
      expect(card.effects.first.value, 8);
    });

    test('사슬 속박 — applyWeak + applyVulnerable', () {
      final card = EnvironmentCards.chainBind;
      expect(card.effects.length, 2);
      expect(card.effects[0].type, CardEffectType.applyWeak);
      expect(card.effects[1].type, CardEffectType.applyVulnerable);
    });

    test('보스 환경 카드 5종', () {
      final bossCards = [
        EnvironmentCards.acidPool,
        EnvironmentCards.webReversal,
        EnvironmentCards.trapTrigger,
        EnvironmentCards.holyWater,
        EnvironmentCards.primordialLight,
      ];
      expect(bossCards.length, 5);
      for (final card in bossCards) {
        expect(card.id.startsWith('env_'), true);
      }
    });

    test('염산 웅덩이 — regenNullify', () {
      expect(EnvironmentCards.acidPool.effects.first.type, CardEffectType.regenNullify);
    });

    test('거미줄 역이용 — stunEnemy', () {
      expect(EnvironmentCards.webReversal.effects.first.type, CardEffectType.stunEnemy);
    });
  });
}
