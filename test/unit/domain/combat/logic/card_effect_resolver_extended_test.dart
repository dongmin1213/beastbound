import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/guardian_cards.dart';
import 'package:soul_dungeon/domain/combat/content/wanderer_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_effect_resolver.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CardEffectResolver — 수호자 카드 효과', () {
    test('blockRetain — blockRetainPercent=60', () {
      final deck = DeckState(hand: [GuardianCards.counterStance]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.counterStance,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockRetainPercent, 60);
      expect(result.blockGained, 12);
    });

    test('thornMultiplierDamage — 가시 5 × 3 = 15 데미지', () {
      final deck = DeckState(hand: [GuardianCards.thornBurst]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.thornBurst,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [
          const StatusEffect(type: StatusEffectType.thorn, stacks: 5),
        ],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult, isNotNull);
      expect(result.damageResult!.finalDamage, 15);
    });

    test('thornMultiplierDamage — 가시 0이면 데미지 없음', () {
      final deck = DeckState(hand: [GuardianCards.thornBurst]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.thornBurst,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult, isNull);
    });

    test('thornMultiplierDamage+ — 가시 5 × 5 = 25 데미지', () {
      final deck = DeckState(hand: [GuardianCards.thornBurstPlus]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.thornBurstPlus,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [
          const StatusEffect(type: StatusEffectType.thorn, stacks: 5),
        ],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult, isNotNull);
      expect(result.damageResult!.finalDamage, 25);
    });

    test('blockPerTurnStartConditional — HP 30% 미만일 때', () {
      final deck = DeckState(hand: [GuardianCards.unyielding]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.unyielding,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerHp: 20,
        playerMaxHp: 100,
      );
      // blockPerTurnStartConditional은 별도 필드로 분리
      // (실제 조건 체크는 CombatBloc _processEndOfTurn에서 HP <30% 검사)
      expect(result.conditionalBlockPerTurnStart, 15);
      expect(result.blockPerTurnStart, 0);
    });

    test('방패 타격 — 5d + 5b', () {
      final deck = DeckState(hand: [GuardianCards.shieldBash]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.shieldBash,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.finalDamage, 5);
      expect(result.blockGained, 5);
    });

    test('철벽 방어 — 10 블록', () {
      final deck = DeckState(hand: [GuardianCards.ironGuard]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.ironGuard,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockGained, 10);
    });

    test('가시 갑옷 — gainThorn 2', () {
      final deck = DeckState(hand: [GuardianCards.thornArmor]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.thornArmor,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.newPlayerStatuses, hasLength(1));
      expect(result.newPlayerStatuses.first.type, StatusEffectType.thorn);
      expect(result.newPlayerStatuses.first.stacks, 2);
    });

    test('도발 — 6 블록 + applyWeak', () {
      final deck = DeckState(hand: [GuardianCards.taunt]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.taunt,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockGained, 6);
      expect(result.newEnemyStatuses, hasLength(1));
      expect(result.newEnemyStatuses.first.type, StatusEffectType.weak);
    });

    test('철벽 진영 — blockPerTurnStart 4', () {
      final deck = DeckState(hand: [GuardianCards.fortress]);
      final result = CardEffectResolver.resolve(
        card: GuardianCards.fortress,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockPerTurnStart, 4);
    });
  });

  group('CardEffectResolver — 방랑자 카드 효과', () {
    test('randomDamage — min~max 범위 내 (seeded Random)', () {
      final deck = DeckState(hand: [WandererCards.improviseStrike]);
      final seededRandom = Random(42);
      final result = CardEffectResolver.resolve(
        card: WandererCards.improviseStrike,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        random: seededRandom,
      );
      expect(result.damageResult, isNotNull);
      // 4~12 범위
      expect(result.damageResult!.finalDamage, inInclusiveRange(4, 12));
    });

    test('randomDamage+ — 6~16 범위', () {
      final deck = DeckState(hand: [WandererCards.improviseStrikePlus]);
      final seededRandom = Random(42);
      final result = CardEffectResolver.resolve(
        card: WandererCards.improviseStrikePlus,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        random: seededRandom,
      );
      expect(result.damageResult, isNotNull);
      expect(result.damageResult!.finalDamage, inInclusiveRange(6, 16));
    });

    test('coinFlip — 성공 시 draw (seeded Random, roll < 50)', () {
      // Find a seed that produces roll < 50
      Random? successRandom;
      for (var seed = 0; seed < 100; seed++) {
        final rng = Random(seed);
        if (rng.nextInt(100) < 50) {
          successRandom = Random(seed);
          break;
        }
      }
      expect(successRandom, isNotNull, reason: 'success seed found');

      final deck = DeckState(hand: [WandererCards.luckyCoin]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.luckyCoin,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        random: successRandom,
      );
      expect(result.drawCount, 2);
      expect(result.selfDamage, 0);
    });

    test('coinFlip — 실패 시 selfDamage (seeded Random, roll >= 50)', () {
      // Find a seed that produces roll >= 50
      Random? failRandom;
      for (var seed = 0; seed < 100; seed++) {
        final rng = Random(seed);
        if (rng.nextInt(100) >= 50) {
          failRandom = Random(seed);
          break;
        }
      }
      expect(failRandom, isNotNull, reason: 'fail seed found');

      final deck = DeckState(hand: [WandererCards.luckyCoin]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.luckyCoin,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        random: failRandom,
      );
      expect(result.drawCount, 0);
      expect(result.selfDamage, 5);
    });

    test('retrieveRandomPerTurn — retrievePerTurn 반환', () {
      final deck = DeckState(hand: [WandererCards.wisdom]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.wisdom,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.retrievePerTurn, 1);
    });

    test('mimicEnemyDamage — mimicEnemyMultiplier 반환', () {
      final deck = DeckState(hand: [WandererCards.mimic]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.mimic,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.mimicEnemyMultiplier, 100);
    });

    test('mimicEnemyDamage+ — mimicEnemyMultiplier 150 반환', () {
      final deck = DeckState(hand: [WandererCards.mimicPlus]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.mimicPlus,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.mimicEnemyMultiplier, 150);
    });

    test('generateRandomCard — generateCardCount 반환', () {
      final deck = DeckState(hand: [WandererCards.conjure]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.conjure,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.generateCardCount, 1);
    });

    test('generateRandomCard+ — generateCardCount 2', () {
      final deck = DeckState(hand: [WandererCards.conjurePlus]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.conjurePlus,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.generateCardCount, 2);
    });

    test('blockPerCardPlayed — blockPerCardPlayedValue 반환', () {
      final deck = DeckState(hand: [WandererCards.chainAdapt]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.chainAdapt,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockPerCardPlayedValue, 2);
    });

    test('randomDebuffs — randomDebuffCount 반환', () {
      final deck = DeckState(hand: [WandererCards.chaos]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.chaos,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.randomDebuffCount, 2);
      // 대혼란은 기본 5 데미지도 있음
      expect(result.damageResult, isNotNull);
      expect(result.damageResult!.finalDamage, 5);
    });

    test('randomDebuffs+ — randomDebuffCount 3 + 8 데미지', () {
      final deck = DeckState(hand: [WandererCards.chaosPlus]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.chaosPlus,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.randomDebuffCount, 3);
      expect(result.damageResult!.finalDamage, 8);
    });

    test('적응 — 6 블록 + 1 드로우', () {
      final deck = DeckState(
        hand: [WandererCards.adapt],
        drawPile: [
          const CardData(
            id: 'dummy',
            name: 'Dummy',
            type: CardType.attack,
            apCost: 0,
            description: '',
          ),
        ],
      );
      final result = CardEffectResolver.resolve(
        card: WandererCards.adapt,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockGained, 6);
      expect(result.drawCount, 1);
    });

    test('운의 동전 Exhaust', () {
      final deck = DeckState(hand: [WandererCards.luckyCoin]);
      final result = CardEffectResolver.resolve(
        card: WandererCards.luckyCoin,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        random: Random(0),
      );
      expect(result.updatedDeck.exhaustPileCount, 1);
    });
  });
}
