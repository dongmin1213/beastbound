import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/deck_manager.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  final fixedRandom = Random(42);

  const innateCard = CardData(
    id: 'innate_1',
    name: 'Innate',
    type: CardType.attack,
    apCost: 0,
    damage: 3,
    description: 'Innate',
    keywords: {CardKeyword.innate},
  );

  const retainCard = CardData(
    id: 'retain_1',
    name: 'Retain',
    type: CardType.skill,
    apCost: 1,
    block: 5,
    description: 'Retain',
    keywords: {CardKeyword.retain},
  );

  const etherealCard = CardData(
    id: 'ethereal_1',
    name: 'Ethereal',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: 'Ethereal',
    keywords: {CardKeyword.ethereal},
  );

  group('DeckManager.initialize', () {
    test('마스터 덱 → 셔플된 드로우 파일', () {
      final state = DeckManager.initialize(
        StarterCards.all,
        random: Random(42),
      );
      expect(state.drawPileCount, 7);
      expect(state.handCount, 0);
      expect(state.discardPileCount, 0);
    });

    test('Innate 카드가 드로우 파일 맨 위에 배치', () {
      final deck = [
        StarterCards.strike1,
        StarterCards.defend1,
        innateCard,
        StarterCards.strike2,
      ];
      final state = DeckManager.initialize(deck, random: Random(42));
      expect(state.drawPile.first.id, 'innate_1');
    });
  });

  group('DeckManager.draw', () {
    test('드로우 파일에서 카드 드로우', () {
      final state = DeckState(
        drawPile: StarterCards.all,
      );
      final drawn = DeckManager.draw(state, 3, random: fixedRandom);
      expect(drawn.handCount, 3);
      expect(drawn.drawPileCount, 4);
    });

    test('5장 드로우', () {
      final state = DeckState(
        drawPile: StarterCards.all,
      );
      final drawn = DeckManager.draw(state, 5, random: fixedRandom);
      expect(drawn.handCount, 5);
      expect(drawn.drawPileCount, 2);
    });

    test('드로우 파일 부족 — 버림 더미 셔플', () {
      final state = DeckState(
        drawPile: [StarterCards.strike1],
        discardPile: [StarterCards.defend1, StarterCards.strike2],
      );
      final drawn = DeckManager.draw(state, 3, random: Random(42));
      expect(drawn.handCount, 3);
      expect(drawn.drawPileCount, 0);
      expect(drawn.discardPileCount, 0);
    });

    test('드로우 파일 + 버림 더미 모두 부족 — 가능한 만큼만', () {
      final state = DeckState(
        drawPile: [StarterCards.strike1],
        discardPile: [],
      );
      final drawn = DeckManager.draw(state, 5, random: fixedRandom);
      expect(drawn.handCount, 1);
    });

    test('빈 드로우 파일 + 빈 버림 더미 — 0장 드로우', () {
      const state = DeckState();
      final drawn = DeckManager.draw(state, 5, random: fixedRandom);
      expect(drawn.handCount, 0);
    });
  });

  group('DeckManager.discardFromHand', () {
    test('손패에서 카드 버리기', () {
      final state = DeckState(
        hand: [StarterCards.strike1, StarterCards.defend1],
      );
      final result = DeckManager.discardFromHand(state, 'starter_strike_1');
      expect(result.handCount, 1);
      expect(result.discardPileCount, 1);
      expect(result.discardPile.first.id, 'starter_strike_1');
    });

    test('없는 카드 id — 변화 없음', () {
      final state = DeckState(
        hand: [StarterCards.strike1],
      );
      final result = DeckManager.discardFromHand(state, 'nonexistent');
      expect(result.handCount, 1);
    });
  });

  group('DeckManager.exhaustFromHand', () {
    test('손패에서 카드 소진', () {
      final state = DeckState(
        hand: [StarterCards.strike1, StarterCards.defend1],
      );
      final result = DeckManager.exhaustFromHand(state, 'starter_strike_1');
      expect(result.handCount, 1);
      expect(result.exhaustPileCount, 1);
      expect(result.exhaustPile.first.id, 'starter_strike_1');
    });
  });

  group('DeckManager.endTurnDiscard', () {
    test('남은 손패 전부 버림 더미로', () {
      final state = DeckState(
        hand: [StarterCards.strike1, StarterCards.defend1],
      );
      final result = DeckManager.endTurnDiscard(state);
      expect(result.handCount, 0);
      expect(result.discardPileCount, 2);
    });

    test('Retain 카드는 손패에 유지', () {
      final state = DeckState(
        hand: [StarterCards.strike1, retainCard],
      );
      final result = DeckManager.endTurnDiscard(state);
      expect(result.handCount, 1);
      expect(result.hand.first.id, 'retain_1');
      expect(result.discardPileCount, 1);
    });

    test('Ethereal 카드는 소진 파일로', () {
      final state = DeckState(
        hand: [StarterCards.strike1, etherealCard],
      );
      final result = DeckManager.endTurnDiscard(state);
      expect(result.handCount, 0);
      expect(result.discardPileCount, 1);
      expect(result.exhaustPileCount, 1);
      expect(result.exhaustPile.first.id, 'ethereal_1');
    });
  });

  group('DeckManager.addToHand', () {
    test('손패에 카드 추가', () {
      final state = DeckState(hand: [StarterCards.strike1]);
      final result = DeckManager.addToHand(state, StarterCards.defend1);
      expect(result.handCount, 2);
    });

    test('손패 15장 초과 시 버림 더미로', () {
      final fullHand = List.generate(
        DeckManager.maxHandSize,
        (i) => CardData(
          id: 'card_$i',
          name: 'Card $i',
          type: CardType.attack,
          apCost: 1,
          damage: 5,
          description: 'Test',
        ),
      );
      final state = DeckState(hand: fullHand);
      expect(state.handCount, DeckManager.maxHandSize);

      final result = DeckManager.addToHand(state, StarterCards.strike1);
      expect(result.handCount, DeckManager.maxHandSize);
      expect(result.discardPileCount, 1);
      expect(result.discardPile.first.id, 'starter_strike_1');
    });
  });

  group('DeckManager.draw — 손패 제한', () {
    test('손패 15장 도달 시 추가 드로우 중단', () {
      final existingHand = List.generate(
        13,
        (i) => CardData(
          id: 'hand_$i',
          name: 'Hand $i',
          type: CardType.attack,
          apCost: 1,
          damage: 5,
          description: 'Test',
        ),
      );
      final state = DeckState(
        hand: existingHand,
        drawPile: StarterCards.all,
      );
      // 13장 + 5장 요청 → 최대 15장까지만
      final drawn = DeckManager.draw(state, 5, random: Random(42));
      expect(drawn.handCount, DeckManager.maxHandSize);
      expect(drawn.drawPileCount, 5); // 7 - 2 = 5장 남음
    });
  });

  group('DeckManager.discardEntireHand', () {
    test('손패 전부 버리기', () {
      final state = DeckState(
        hand: [StarterCards.strike1, StarterCards.defend1],
        discardPile: [StarterCards.strike2],
      );
      final result = DeckManager.discardEntireHand(state);
      expect(result.handCount, 0);
      expect(result.discardPileCount, 3);
    });
  });
}
