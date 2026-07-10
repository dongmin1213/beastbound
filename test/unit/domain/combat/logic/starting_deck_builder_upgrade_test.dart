import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/starting_deck_builder.dart';

void main() {
  group('StartingDeckBuilder — purchasedUpgradeIds', () {
    test('purchasedUpgradeIds 비어있으면 기존 동작 (12장, 업그레이드 없음)', () {
      final deck = StartingDeckBuilder.build('warrior');
      expect(deck.length, 12);
      expect(deck.every((c) => !c.upgraded), true);
    });

    test('soul_starting_deck_upgrade 포함 시 타격 카드가 업그레이드됨', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        purchasedUpgradeIds: {'soul_starting_deck_upgrade'},
      );
      expect(deck.length, 12);

      // 타격 카드 3장이 모두 업그레이드되어야 함
      final strikeCards = deck.where(
        (c) => c.name == '타격+' || c.id == StarterCards.strikeUpgraded.id,
      );
      expect(strikeCards.length, 3,
          reason: '타격 3장이 모두 타격+로 업그레이드되어야 함');

      // 업그레이드된 타격 카드 확인
      for (final card in strikeCards) {
        expect(card.upgraded, true);
        expect(card.damage, 8, reason: '타격+ 데미지는 8');
      }
    });

    test('타격 카드만 업그레이드, 다른 카드 불변', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        purchasedUpgradeIds: {'soul_starting_deck_upgrade'},
      );

      // 방어 카드는 업그레이드되지 않아야 함
      final defendCards = deck.where(
        (c) => c.id == 'starter_defend_1' || c.id == 'starter_defend_2',
      );
      expect(defendCards.length, 2, reason: '방어 카드 2장은 그대로');
      for (final card in defendCards) {
        expect(card.upgraded, false);
        expect(card.block, 5, reason: '방어 블록은 5 유지');
      }
    });

    test('관련 없는 upgradeId는 영향 없음', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        purchasedUpgradeIds: {'soul_starting_gold', 'some_other_upgrade'},
      );
      expect(deck.length, 12);
      expect(deck.every((c) => !c.upgraded), true);
    });

    test('빈 Set과 기본값 동일', () {
      final deck1 = StartingDeckBuilder.build('warrior');
      final deck2 = StartingDeckBuilder.build(
        'warrior',
        purchasedUpgradeIds: const {},
      );
      expect(
        deck1.map((c) => c.id).toList(),
        deck2.map((c) => c.id).toList(),
      );
    });
  });
}
