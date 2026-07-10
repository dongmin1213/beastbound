import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/saint_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_effect_resolver.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CardEffectResolver — 성자 카드 효과', () {
    test('cleanse — requestCleanse=true', () {
      final deck = DeckState(hand: [SaintCards.purify]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.purify,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [
          const StatusEffect(
            type: StatusEffectType.poison,
            stacks: 3,
          ),
          const StatusEffect(
            type: StatusEffectType.weak,
            stacks: 1,
            turnsRemaining: 2,
          ),
        ],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.requestCleanse, isTrue);
      expect(result.healAmount, 8);
      expect(result.updatedDeck.exhaustPileCount, 1);
    });

    test('retribution — 블록=20이면 20 데미지 (value=100)', () {
      final deck = DeckState(hand: [SaintCards.retribution]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.retribution,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerBlock: 20,
      );
      expect(result.damageResult, isNotNull);
      expect(result.damageResult!.finalDamage, 20);
    });

    test('retribution — 블록=0이면 데미지 없음', () {
      final deck = DeckState(hand: [SaintCards.retribution]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.retribution,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerBlock: 0,
      );
      expect(result.damageResult, isNull);
    });

    test('retribution+ — 블록=20이면 30 데미지 (value=150)', () {
      final deck = DeckState(hand: [SaintCards.retributionPlus]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.retributionPlus,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerBlock: 20,
      );
      expect(result.damageResult, isNotNull);
      expect(result.damageResult!.finalDamage, 30); // 20 * 150 / 100
    });

    test('retribution — 힘 보너스 적용', () {
      final deck = DeckState(hand: [SaintCards.retribution]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.retribution,
        playerStrength: 5,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerBlock: 10,
      );
      // base=10, str=5 → final=15
      expect(result.damageResult!.finalDamage, 15);
    });

    test('retribution — 적 취약 시 데미지 증가', () {
      final deck = DeckState(hand: [SaintCards.retribution]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.retribution,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [
          const StatusEffect(
            type: StatusEffectType.vulnerable,
            stacks: 1,
            turnsRemaining: 2,
          ),
        ],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerBlock: 20,
      );
      // 20 * 1.5 = 30
      expect(result.damageResult!.finalDamage, 30);
    });

    test('blockPerTurnStart — blockPerTurnStart=3', () {
      final deck = DeckState(hand: [SaintCards.divineShield]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.divineShield,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockPerTurnStart, 3);
    });

    test('blockPerTurnStart+ — blockPerTurnStart=5', () {
      final deck = DeckState(hand: [SaintCards.divineShieldPlus]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.divineShieldPlus,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockPerTurnStart, 5);
    });

    test('신성 일격 — 8d + 4b', () {
      final deck = DeckState(hand: [SaintCards.divineStrike]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.divineStrike,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.finalDamage, 8);
      expect(result.blockGained, 4);
    });

    test('치유 — heal 12 + Exhaust', () {
      final deck = DeckState(hand: [SaintCards.heal]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.heal,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.healAmount, 12);
      expect(result.updatedDeck.exhaustPileCount, 1);
    });

    test('기도 — 8 블록 + draw 1', () {
      final deck = DeckState(hand: [SaintCards.prayer]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.prayer,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockGained, 8);
      expect(result.drawCount, 1);
    });

    test('성벽 — 15 블록', () {
      final deck = DeckState(hand: [SaintCards.holyWall]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.holyWall,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockGained, 15);
    });

    test('재생의 빛 — gainRegenerate 3', () {
      final deck = DeckState(hand: [SaintCards.lightOfRegeneration]);
      final result = CardEffectResolver.resolve(
        card: SaintCards.lightOfRegeneration,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.newPlayerStatuses, hasLength(1));
      expect(
        result.newPlayerStatuses.first.type,
        StatusEffectType.regenerate,
      );
      expect(result.newPlayerStatuses.first.stacks, 3);
    });
  });
}
