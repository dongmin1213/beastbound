import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  group('PlayerRunState', () {
    test('creates with default HP from basePlayerHp', () {
      final state = PlayerRunState.initial(maxHp: 100);

      expect(state.currentHp, 100);
      expect(state.maxHp, 100);
      expect(state.isAlive, true);
    });

    test('copyWith creates new instance with updated fields', () {
      final state = PlayerRunState.initial(maxHp: 100);
      final damaged = state.copyWith(currentHp: 70);

      expect(damaged.currentHp, 70);
      expect(damaged.maxHp, 100);
      // Original unchanged
      expect(state.currentHp, 100);
    });

    test('isAlive returns false when hp is 0, true when hp is 1', () {
      final dead = PlayerRunState(currentHp: 0, maxHp: 100);
      final alive = PlayerRunState(currentHp: 1, maxHp: 100);

      expect(dead.isAlive, false);
      expect(alive.isAlive, true);
    });

    test('hpPercent calculates correct ratio', () {
      final full = PlayerRunState(currentHp: 100, maxHp: 100);
      final half = PlayerRunState(currentHp: 50, maxHp: 100);
      final quarter = PlayerRunState(currentHp: 25, maxHp: 100);
      final zero = PlayerRunState(currentHp: 0, maxHp: 100);

      expect(full.hpPercent, 1.0);
      expect(half.hpPercent, 0.5);
      expect(quarter.hpPercent, 0.25);
      expect(zero.hpPercent, 0.0);
    });

    test('gold field initializes to 0 and supports copyWith', () {
      final state = PlayerRunState.initial(maxHp: 100);
      expect(state.gold, 0);

      final withGold = state.copyWith(gold: 45);
      expect(withGold.gold, 45);
      expect(withGold.currentHp, 100);
      // Original unchanged
      expect(state.gold, 0);

      // Equality includes gold
      final sameGold = state.copyWith(gold: 45);
      expect(withGold, sameGold);

      final differentGold = state.copyWith(gold: 10);
      expect(withGold, isNot(differentGold));

      // toString includes gold
      expect(withGold.toString(), contains('45'));
    });

    // === Story 4-3: currentJobId 필드 테스트 ===

    test('currentJobId is null in initial state', () {
      final state = PlayerRunState.initial(maxHp: 100);
      expect(state.currentJobId, isNull);
    });

    test('copyWith currentJobId sets and clears job', () {
      final state = PlayerRunState.initial(maxHp: 100);

      // null → non-null
      final withJob = state.copyWith(currentJobId: 'warrior');
      expect(withJob.currentJobId, 'warrior');

      // non-null → null (explicit null)
      final cleared = withJob.copyWith(currentJobId: null);
      expect(cleared.currentJobId, isNull);

      // no argument → preserves current value
      final preserved = withJob.copyWith(gold: 50);
      expect(preserved.currentJobId, 'warrior');
    });

    test('equality includes currentJobId', () {
      final state1 = PlayerRunState.initial(maxHp: 100);
      final state2 = PlayerRunState.initial(maxHp: 100);
      expect(state1, state2); // both null

      final withJob = state1.copyWith(currentJobId: 'sage');
      expect(state1, isNot(withJob));

      final sameJob = state1.copyWith(currentJobId: 'sage');
      expect(withJob, sameJob);
    });

    // === masterDeck + removedCardIds 필드 테스트 ===

    test('initial masterDeck is empty by default', () {
      final state = PlayerRunState.initial(maxHp: 100);
      expect(state.masterDeck, isEmpty);
      expect(state.removedCardIds, isEmpty);
    });

    test('initial with masterDeck parameter', () {
      final deck = StarterCards.all;
      final state = PlayerRunState.initial(maxHp: 100, masterDeck: deck);
      expect(state.masterDeck.length, deck.length);
    });

    test('copyWith masterDeck', () {
      final state = PlayerRunState.initial(maxHp: 100);
      final deck = StarterCards.all;
      final updated = state.copyWith(masterDeck: deck);
      expect(updated.masterDeck.length, deck.length);
      expect(state.masterDeck, isEmpty);
    });

    test('effectiveDeck excludes removedCardIds', () {
      const card1 = CardData(
        id: 'c1', name: 'A', type: CardType.attack,
        apCost: 1, description: '',
      );
      const card2 = CardData(
        id: 'c2', name: 'B', type: CardType.skill,
        apCost: 1, description: '',
      );
      final state = PlayerRunState(
        currentHp: 100, maxHp: 100,
        masterDeck: const [card1, card2],
        removedCardIds: const {'c1'},
      );
      expect(state.effectiveDeck.length, 1);
      expect(state.effectiveDeck.first.id, 'c2');
    });

    test('equality includes masterDeck and removedCardIds', () {
      final deck = StarterCards.all;
      final state1 = PlayerRunState.initial(maxHp: 100, masterDeck: deck);
      final state2 = PlayerRunState.initial(maxHp: 100, masterDeck: deck);
      expect(state1, state2);

      final withRemoved = state1.copyWith(removedCardIds: {'some_card'});
      expect(state1, isNot(withRemoved));
    });
  });
}
