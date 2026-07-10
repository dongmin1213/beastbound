import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  const strike = CardData(
    id: 'strike_1',
    name: '타격',
    type: CardType.attack,
    apCost: 1,
    damage: 6,
    description: '6 데미지',
  );

  const defend = CardData(
    id: 'defend_1',
    name: '방어',
    type: CardType.skill,
    apCost: 1,
    block: 5,
    description: '블록 5',
  );

  const warCry = CardData(
    id: 'war_cry',
    name: '전쟁함성',
    type: CardType.power,
    apCost: 1,
    description: '힘 +2',
  );

  group('DeckState', () {
    test('기본 생성 — 모든 파일 빈 리스트', () {
      const deck = DeckState();
      expect(deck.drawPileCount, 0);
      expect(deck.handCount, 0);
      expect(deck.discardPileCount, 0);
      expect(deck.exhaustPileCount, 0);
    });

    test('초기화 — 드로우 파일에 카드 설정', () {
      final deck = DeckState(
        drawPile: [strike, defend, warCry],
      );
      expect(deck.drawPileCount, 3);
      expect(deck.handCount, 0);
    });

    test('hasCardInHand — 손패에 카드 존재 확인', () {
      final deck = DeckState(
        hand: [strike, defend],
      );
      expect(deck.hasCardInHand('strike_1'), true);
      expect(deck.hasCardInHand('war_cry'), false);
    });

    test('copyWith — 손패 변경', () {
      final deck = DeckState(
        drawPile: [warCry],
        hand: [strike],
      );
      final updated = deck.copyWith(
        hand: [strike, defend],
      );
      expect(updated.handCount, 2);
      expect(updated.drawPileCount, 1); // 변경 안 됨
    });

    test('copyWith — 버림 더미 추가', () {
      final deck = DeckState(
        hand: [strike, defend],
        discardPile: [warCry],
      );
      final updated = deck.copyWith(
        hand: [defend],
        discardPile: [warCry, strike],
      );
      expect(updated.handCount, 1);
      expect(updated.discardPileCount, 2);
    });

    test('copyWith — 소진 파일 추가', () {
      final deck = DeckState(
        hand: [strike],
      );
      final updated = deck.copyWith(
        hand: [],
        exhaustPile: [strike],
      );
      expect(updated.handCount, 0);
      expect(updated.exhaustPileCount, 1);
    });

    test('Equatable 동등성', () {
      final d1 = DeckState(hand: [strike, defend]);
      final d2 = DeckState(hand: [strike, defend]);
      expect(d1, equals(d2));
    });

    test('Equatable 비동등성', () {
      final d1 = DeckState(hand: [strike]);
      final d2 = DeckState(hand: [defend]);
      expect(d1, isNot(equals(d2)));
    });
  });
}
