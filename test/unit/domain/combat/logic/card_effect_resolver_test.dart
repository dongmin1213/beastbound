import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';
import 'package:soul_dungeon/domain/combat/content/warrior_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_effect_resolver.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CardEffectResolver.resolve', () {
    test('타격 — 6d, 카드 버림 더미로', () {
      final deck = DeckState(hand: [StarterCards.strike1, StarterCards.defend1]);
      final result = CardEffectResolver.resolve(
        card: StarterCards.strike1,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.finalDamage, 6);
      expect(result.updatedDeck.handCount, 1);
      expect(result.updatedDeck.discardPileCount, 1);
    });

    test('방어 — 블록 5', () {
      final deck = DeckState(hand: [StarterCards.defend1]);
      final result = CardEffectResolver.resolve(
        card: StarterCards.defend1,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockGained, 5);
      expect(result.damageResult, isNull);
    });

    test('방어 + 민첩 보너스', () {
      final deck = DeckState(hand: [StarterCards.defend1]);
      final result = CardEffectResolver.resolve(
        card: StarterCards.defend1,
        playerStrength: 0,
        playerDexterity: 3,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockGained, 8); // 5 + 3
    });

    test('힘 보너스 — 데미지 증가', () {
      final deck = DeckState(hand: [StarterCards.strike1]);
      final result = CardEffectResolver.resolve(
        card: StarterCards.strike1,
        playerStrength: 4,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.finalDamage, 10); // 6 + 4
    });

    test('약화 상태 — 데미지 감소', () {
      final deck = DeckState(hand: [StarterCards.strike1]);
      final result = CardEffectResolver.resolve(
        card: StarterCards.strike1,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [
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
      expect(result.damageResult!.finalDamage, 4); // 6 * 0.75 = 4
    });

    test('적 취약 — 데미지 증가', () {
      final deck = DeckState(hand: [StarterCards.strike1]);
      final result = CardEffectResolver.resolve(
        card: StarterCards.strike1,
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
      );
      expect(result.damageResult!.finalDamage, 9); // 6 * 1.5 = 9
    });

    test('Exhaust 카드 — 소진 파일로', () {
      final deck = DeckState(
        hand: [ColorlessCards.focusedStrike, StarterCards.defend1],
      );
      final result = CardEffectResolver.resolve(
        card: ColorlessCards.focusedStrike,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.updatedDeck.exhaustPileCount, 1);
      expect(result.updatedDeck.discardPileCount, 0);
    });

    test('전쟁함성 — gainStrength 효과', () {
      final deck = DeckState(hand: [WarriorCards.warCry]);
      final result = CardEffectResolver.resolve(
        card: WarriorCards.warCry,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.newPlayerStatuses, hasLength(1));
      expect(result.newPlayerStatuses.first.type, StatusEffectType.strength);
      expect(result.newPlayerStatuses.first.stacks, 2);
    });

    test('돌진 — 8d + 힘+1 + draw 1', () {
      final deck = DeckState(
        hand: [WarriorCards.charge],
        drawPile: [StarterCards.strike1],
      );
      final result = CardEffectResolver.resolve(
        card: WarriorCards.charge,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.finalDamage, 8);
      expect(result.newPlayerStatuses, hasLength(1));
      expect(result.newPlayerStatuses.first.type, StatusEffectType.strength);
      expect(result.newPlayerStatuses.first.stacks, 1);
      expect(result.drawCount, 1);
    });

    test('약점 간파 — applyVulnerable', () {
      final deck = DeckState(hand: [ColorlessCards.exposeWeakness]);
      final result = CardEffectResolver.resolve(
        card: ColorlessCards.exposeWeakness,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.newEnemyStatuses, hasLength(1));
      expect(result.newEnemyStatuses.first.type, StatusEffectType.vulnerable);
      expect(result.newEnemyStatuses.first.turnsRemaining, 2);
    });

    test('독 항아리 — applyPoison + Exhaust', () {
      final deck = DeckState(hand: [ColorlessCards.poisonJar]);
      final result = CardEffectResolver.resolve(
        card: ColorlessCards.poisonJar,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.newEnemyStatuses.first.type, StatusEffectType.poison);
      expect(result.newEnemyStatuses.first.stacks, 5);
      expect(result.updatedDeck.exhaustPileCount, 1);
    });

    test('연막 — 블록 10 + applyWeak + Exhaust', () {
      final deck = DeckState(hand: [ColorlessCards.smokeScreen]);
      final result = CardEffectResolver.resolve(
        card: ColorlessCards.smokeScreen,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.blockGained, 10);
      expect(result.newEnemyStatuses.first.type, StatusEffectType.weak);
      expect(result.updatedDeck.exhaustPileCount, 1);
    });

    test('통찰 — draw 2', () {
      final deck = DeckState(hand: [ColorlessCards.insight]);
      final result = CardEffectResolver.resolve(
        card: ColorlessCards.insight,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.drawCount, 2);
    });

    test('맹공 — momentumTier × 5', () {
      final deck = DeckState(hand: [WarriorCards.onslaught]);
      final result = CardEffectResolver.resolve(
        card: WarriorCards.onslaught,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 3,
      );
      expect(result.damageResult!.finalDamage, 15); // 3 * 5
    });

    test('피의 맹세 — selfDamage + gainStrength + draw', () {
      final deck = DeckState(hand: [WarriorCards.bloodOath]);
      final result = CardEffectResolver.resolve(
        card: WarriorCards.bloodOath,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.selfDamage, 4);
      expect(result.newPlayerStatuses.first.type, StatusEffectType.strength);
      expect(result.newPlayerStatuses.first.stacks, 3);
      expect(result.drawCount, 1);
      expect(result.updatedDeck.exhaustPileCount, 1);
    });

    test('적 블록이 데미지 흡수', () {
      final deck = DeckState(hand: [StarterCards.strike1]);
      final result = CardEffectResolver.resolve(
        card: StarterCards.strike1,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 4,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.blockAbsorbed, 4);
      expect(result.damageResult!.hpLost, 2);
    });
  });

  group('Phase 2 새 효과 타입', () {
    test('immuneThisTurn — 플래그 설정', () {
      final card = CardData(
        id: 'test_immune',
        name: '은신',
        type: CardType.skill,
        apCost: 1,
        description: '이번 턴 피해 무효',
        keywords: const {CardKeyword.exhaust},
        effects: const [CardEffect(type: CardEffectType.immuneThisTurn, value: 1)],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.setImmuneThisTurn, isTrue);
      expect(result.updatedDeck.exhaustPileCount, 1);
    });

    test('doubleNextAttack — 플래그 설정', () {
      final card = CardData(
        id: 'test_double',
        name: '그림자',
        type: CardType.skill,
        apCost: 1,
        description: '다음 공격 2배',
        effects: const [CardEffect(type: CardEffectType.doubleNextAttack, value: 1)],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.setDoubleNextAttack, isTrue);
    });

    test('doubleNextAttack 적용 — 공격 데미지 2배', () {
      final deck = DeckState(hand: [StarterCards.strike1]);
      final result = CardEffectResolver.resolve(
        card: StarterCards.strike1,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        doubleNextAttack: true,
      );
      expect(result.damageResult!.finalDamage, 12); // 6 * 2
    });

    test('copyLastAttack — 플래그 설정', () {
      final card = CardData(
        id: 'test_copy',
        name: '그림자 분신',
        type: CardType.skill,
        apCost: 1,
        description: '마지막 공격 복사',
        keywords: const {CardKeyword.exhaust},
        effects: const [CardEffect(type: CardEffectType.copyLastAttack, value: 1)],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.requestCopyLastAttack, isTrue);
    });

    test('apPenaltyNextTurn — 다음 턴 AP -1', () {
      final card = CardData(
        id: 'test_focus',
        name: '집중',
        type: CardType.skill,
        apCost: 0,
        description: 'AP +1 이번 턴, 다음 턴 -1',
        effects: const [
          CardEffect(type: CardEffectType.apGain, value: 1),
          CardEffect(type: CardEffectType.apPenaltyNextTurn, value: 1),
        ],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.apGain, 1);
      expect(result.apModifierNextTurn, -1);
    });

    test('poisonMultiplierDamage — 독 수치 × value', () {
      final card = CardData(
        id: 'test_assassinate',
        name: '암살',
        type: CardType.attack,
        apCost: 2,
        description: '독 × 2 데미지',
        keywords: const {CardKeyword.exhaust},
        effects: const [
          CardEffect(type: CardEffectType.poisonMultiplierDamage, value: 2),
        ],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [
          const StatusEffect(type: StatusEffectType.poison, stacks: 8),
        ],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.finalDamage, 16); // 8 * 2
    });

    test('poisonMultiplierDamage — 독 없으면 데미지 0', () {
      final card = CardData(
        id: 'test_assassinate',
        name: '암살',
        type: CardType.attack,
        apCost: 2,
        description: '독 × 2 데미지',
        effects: const [
          CardEffect(type: CardEffectType.poisonMultiplierDamage, value: 2),
        ],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
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

    test('damagePerHandCard — 손패 수 × value', () {
      final card = CardData(
        id: 'test_explosion',
        name: '마력 폭발',
        type: CardType.attack,
        apCost: 3,
        description: '손패 수 × 8 데미지',
        keywords: const {CardKeyword.exhaust},
        effects: const [
          CardEffect(type: CardEffectType.damagePerHandCard, value: 8),
        ],
      );
      final deck = DeckState(hand: [
        card,
        StarterCards.strike1,
        StarterCards.strike2,
        StarterCards.defend1,
      ]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      // 손패 4장(자기 포함) — Exhaust 처리 전 계산
      expect(result.damageResult!.finalDamage, 32); // 4 * 8
    });

    test('multiHit — value × duration 회', () {
      final card = CardData(
        id: 'test_multi',
        name: '연쇄 번개',
        type: CardType.attack,
        apCost: 2,
        description: '7 × 3회',
        effects: const [
          CardEffect(type: CardEffectType.multiHit, value: 7, duration: 3),
        ],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.finalDamage, 21); // 7 * 3
    });

    test('multiHit — 블록을 히트별로 차감', () {
      final card = CardData(
        id: 'test_multi_block',
        name: '연타',
        type: CardType.attack,
        apCost: 2,
        description: '5 × 3회',
        effects: const [
          CardEffect(type: CardEffectType.multiHit, value: 5, duration: 3),
        ],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 8,
        deckState: deck,
        momentumTier: 1,
      );
      // 1히트: 5 vs 8블록 → 5 흡수, 0 HP. 남은 블록 3
      // 2히트: 5 vs 3블록 → 3 흡수, 2 HP. 남은 블록 0
      // 3히트: 5 vs 0블록 → 0 흡수, 5 HP.
      // 총: hpLost=7, blockAbsorbed=8
      expect(result.damageResult!.hpLost, 7);
      expect(result.damageResult!.blockAbsorbed, 8);
    });

    test('retrieveFromDiscard — 버림더미 → 손패', () {
      final card = CardData(
        id: 'test_retrieve',
        name: '시간 왜곡',
        type: CardType.skill,
        apCost: 2,
        description: '버림더미 2장 복귀',
        effects: const [
          CardEffect(type: CardEffectType.retrieveFromDiscard, value: 2),
        ],
      );
      final deck = DeckState(
        hand: [card],
        discardPile: [StarterCards.strike1, StarterCards.defend1],
      );
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      // 원래 손패 1(card) → 카드 버림 → 손패 0 + 복귀 2 = 손패 2
      expect(result.updatedDeck.handCount, 2);
      expect(result.updatedDeck.discardPileCount, 1); // card가 discard로
    });

    test('sprintExhaust — AP 증가 + exhaustHandAtTurnEnd 플래그', () {
      final card = CardData(
        id: 'test_sprint',
        name: '전력 질주',
        type: CardType.skill,
        apCost: 0,
        description: 'AP +2, 턴 종료 시 손패 Exhaust',
        effects: const [
          CardEffect(type: CardEffectType.sprintExhaust, value: 2),
        ],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.apGain, 2);
      expect(result.setExhaustHandAtTurnEnd, isTrue);
    });

    test('exhaustAndDraw — 손패 1장 Exhaust + N장 드로우', () {
      final card = CardData(
        id: 'test_trickery',
        name: '속임수',
        type: CardType.skill,
        apCost: 0,
        description: '손패 1장 Exhaust, 2장 드로우',
        effects: const [
          CardEffect(type: CardEffectType.exhaustAndDraw, value: 2),
        ],
      );
      final deck = DeckState(
        hand: [card, StarterCards.strike1],
        drawPile: [StarterCards.defend1, StarterCards.defend2],
      );
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.drawCount, 2);
      // strike1이 exhaust됨
      expect(result.updatedDeck.exhaustPileCount, 1);
    });

    test('hpPercentDamage — HP 10% 데미지', () {
      final card = CardData(
        id: 'test_laststand',
        name: '최후의 발악',
        type: CardType.attack,
        apCost: 0,
        description: 'HP 10% 데미지',
        keywords: const {CardKeyword.exhaust},
        effects: const [
          CardEffect(type: CardEffectType.hpPercentDamage, value: 10),
        ],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerHp: 80,
      );
      expect(result.damageResult!.finalDamage, 8); // 80 * 10% = 8
    });

    test('highMomentumBonus — High 시 데미지 2배', () {
      final card = CardData(
        id: 'test_crit',
        name: '치명타',
        type: CardType.attack,
        apCost: 1,
        damage: 12,
        description: '기세 High 시 24',
        effects: const [
          CardEffect(type: CardEffectType.highMomentumBonus, value: 0),
        ],
      );
      final deck = DeckState(hand: [card]);
      // High (tier 3)
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 3,
      );
      expect(result.damageResult!.finalDamage, 24); // 12 * 2
    });

    test('highMomentumBonus — Low 시 기본 데미지', () {
      final card = CardData(
        id: 'test_crit',
        name: '치명타',
        type: CardType.attack,
        apCost: 1,
        damage: 12,
        description: '기세 High 시 24',
        effects: const [
          CardEffect(type: CardEffectType.highMomentumBonus, value: 0),
        ],
      );
      final deck = DeckState(hand: [card]);
      final result = CardEffectResolver.resolve(
        card: card,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
      );
      expect(result.damageResult!.finalDamage, 12); // 기본
    });

    test('lowHp 조건 — HP <50% 시 발동', () {
      final deck = DeckState(hand: [WarriorCards.berserker]);
      final result = CardEffectResolver.resolve(
        card: WarriorCards.berserker,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerHp: 30,
        playerMaxHp: 80,
      );
      expect(result.newPlayerStatuses, hasLength(1));
      expect(result.newPlayerStatuses.first.stacks, 3);
    });

    test('lowHp 조건 — HP ≥50% 시 미발동', () {
      final deck = DeckState(hand: [WarriorCards.berserker]);
      final result = CardEffectResolver.resolve(
        card: WarriorCards.berserker,
        playerStrength: 0,
        playerDexterity: 0,
        playerStatuses: [],
        enemyStatuses: [],
        enemyBlock: 0,
        deckState: deck,
        momentumTier: 1,
        playerHp: 50,
        playerMaxHp: 80,
      );
      expect(result.newPlayerStatuses, isEmpty);
    });
  });
}
