import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/curse_cards.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CurseCards', () {
    test('weakness — 아무 효과 없는 카드', () {
      expect(CurseCards.weakness.id, 'curse_weakness');
      expect(CurseCards.weakness.type, CardType.skill);
      expect(CurseCards.weakness.apCost, 0);
      expect(CurseCards.weakness.keywords, isEmpty);
      expect(CurseCards.weakness.effects.first.type, CardEffectType.nothing);
    });

    test('decay — HP -1 카드', () {
      expect(CurseCards.decay.id, 'curse_decay');
      expect(CurseCards.decay.type, CardType.skill);
      expect(CurseCards.decay.apCost, 0);
      expect(CurseCards.decay.effects.first.type, CardEffectType.selfDamage);
      expect(CurseCards.decay.effects.first.value, 1);
    });

    test('all — 2종 등록', () {
      expect(CurseCards.all, hasLength(2));
    });

    test('forCount 0 → 빈 목록', () {
      expect(CurseCards.forCount(0), isEmpty);
    });

    test('forCount 1 → 나약함 1장', () {
      final cards = CurseCards.forCount(1);
      expect(cards, hasLength(1));
      expect(cards[0].id, 'curse_weakness');
    });

    test('forCount 2 → 나약함 + 쇠퇴', () {
      final cards = CurseCards.forCount(2);
      expect(cards, hasLength(2));
      expect(cards[0].id, 'curse_weakness');
      expect(cards[1].id, 'curse_decay');
    });

    test('forCount 3 → 나약함 + 쇠퇴 + 나약함', () {
      final cards = CurseCards.forCount(3);
      expect(cards, hasLength(3));
      expect(cards[0].id, 'curse_weakness');
      expect(cards[1].id, 'curse_decay');
      expect(cards[2].id, 'curse_weakness');
    });

    test('Exhaust 불가 — keywords에 exhaust 없음', () {
      for (final card in CurseCards.all) {
        expect(card.keywords, isNot(contains(CardKeyword.exhaust)));
      }
    });
  });
}
