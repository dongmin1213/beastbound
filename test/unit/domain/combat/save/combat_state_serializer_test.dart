import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/domain/build/data/card_blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_relic_pool.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/domain/combat/models/enemy_battle_state.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/core/models/enemy_modifier.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/domain/combat/save/combat_state_serializer.dart';

void main() {
  final testPlayerState = PlayerRunState.initial(maxHp: 80);
  final testEnemy = const EnemyCombatData(
    id: 'test_slime',
    name: '슬라임',
    hp: 30,
    atk: 8,
    def: 4,
    floor: 1,
    pattern: [EnemyActionType.attack, EnemyActionType.defend],
  );

  final testDeck = [
    StarterCards.strike1,
    StarterCards.strike2,
    StarterCards.defend1,
  ];

  /// 최소 전투 상태 생성.
  CardCombatActive makeMinimalActive({
    List<EnemyBattleState>? enemies,
    int playerHp = 80,
    DeckState? deckState,
    int currentTurn = 0,
    List<StatusEffect> playerStatuses = const [],
    TurnFlags turnFlags = const TurnFlags(),
    PowerEffects powerEffects = const PowerEffects(),
    BossCombatData? bossData,
    int currentBossPhase = 0,
    String? rewardJobOverride,
    RoomType roomType = RoomType.combat,
    Map<String, int> cooldownCards = const {},
  }) {
    return CardCombatActive(
      enemies: enemies ??
          [EnemyBattleState.fromData(testEnemy)],
      playerHp: playerHp,
      playerMaxHp: 80,
      deckState: deckState ??
          DeckState(
            hand: [testDeck[0], testDeck[1]],
            drawPile: [testDeck[2]],
          ),
      actionPoints: 3,
      maxActionPoints: 3,
      playerStatuses: playerStatuses,
      currentTurn: currentTurn,
      playerRunState: testPlayerState,
      roomType: roomType,
      turnFlags: turnFlags,
      powerEffects: powerEffects,
      bossData: bossData,
      currentBossPhase: currentBossPhase,
      rewardJobOverride: rewardJobOverride,
      cooldownCards: cooldownCards,
    );
  }

  /// 직렬화 → 역직렬화 라운드 트립.
  CardCombatActive? roundTrip(CardCombatActive state) {
    final json = CombatStateSerializer.toJson(state);
    return CombatStateSerializer.fromJson(
      json,
      cardResolver: CardPool.findById,
      blessingResolver: CardBlessingPool.resolveIds,
      relicResolver: CardRelicPool.resolveIds,
      playerRunState: testPlayerState,
    );
  }

  group('CombatStateSerializer', () {
    test('최소 전투 상태 라운드 트립', () {
      final original = makeMinimalActive();
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      expect(restored!.playerHp, original.playerHp);
      expect(restored.playerMaxHp, original.playerMaxHp);
      expect(restored.actionPoints, original.actionPoints);
      expect(restored.maxActionPoints, original.maxActionPoints);
      expect(restored.currentTurn, original.currentTurn);
      expect(restored.roomType, original.roomType);
    });

    test('적 상태 보존', () {
      final enemyState = EnemyBattleState(
        data: testEnemy,
        currentHp: 20,
        maxHp: 30,
        block: 5,
        strength: 3,
        statuses: const [
          StatusEffect(
            type: StatusEffectType.poison,
            stacks: 4,
          ),
        ],
        healBlockedTurns: 2,
        stunnedTurns: 1,
        patternOffset: 1,
        phaseShifted: true,
        enragedTurns: 3,
      );
      final original = makeMinimalActive(enemies: [enemyState]);
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      final restoredEnemy = restored!.enemies.first;
      expect(restoredEnemy.currentHp, 20);
      expect(restoredEnemy.maxHp, 30);
      expect(restoredEnemy.block, 5);
      expect(restoredEnemy.strength, 3);
      expect(restoredEnemy.statuses.length, 1);
      expect(restoredEnemy.statuses.first.type, StatusEffectType.poison);
      expect(restoredEnemy.statuses.first.stacks, 4);
      expect(restoredEnemy.healBlockedTurns, 2);
      expect(restoredEnemy.stunnedTurns, 1);
      expect(restoredEnemy.patternOffset, 1);
      expect(restoredEnemy.phaseShifted, true);
      expect(restoredEnemy.enragedTurns, 3);
    });

    test('멀티몹 적 상태 보존', () {
      final enemy1 = EnemyBattleState.fromData(testEnemy);
      final enemy2 = EnemyBattleState(
        data: const EnemyCombatData(
          id: 'test_bat',
          name: '박쥐',
          hp: 15,
          atk: 5,
          def: 2,
          floor: 1,
          pattern: [EnemyActionType.attack],
        ),
        currentHp: 10,
        maxHp: 15,
      );
      final original = makeMinimalActive(enemies: [enemy1, enemy2]);
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      expect(restored!.enemies.length, 2);
      expect(restored.enemies[0].data.id, 'test_slime');
      expect(restored.enemies[1].data.id, 'test_bat');
      expect(restored.enemies[1].currentHp, 10);
    });

    test('덱 상태(4파일) 보존', () {
      final deck = DeckState(
        drawPile: [testDeck[2]],
        hand: [testDeck[0]],
        discardPile: [testDeck[1]],
        exhaustPile: const [],
      );
      final original = makeMinimalActive(deckState: deck);
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      expect(restored!.deckState.drawPile.length, 1);
      expect(restored.deckState.hand.length, 1);
      expect(restored.deckState.discardPile.length, 1);
      expect(restored.deckState.exhaustPile.length, 0);
      expect(restored.deckState.hand.first.id, testDeck[0].id);
    });

    test('플레이어 상태 효과 보존', () {
      final statuses = [
        const StatusEffect(type: StatusEffectType.strength, stacks: 5),
        const StatusEffect(
          type: StatusEffectType.weak,
          stacks: 1,
          turnsRemaining: 2,
        ),
        const StatusEffect(type: StatusEffectType.poison, stacks: 3),
      ];
      final original = makeMinimalActive(playerStatuses: statuses);
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      expect(restored!.playerStatuses.length, 3);
      expect(restored.playerStatuses[0].type, StatusEffectType.strength);
      expect(restored.playerStatuses[0].stacks, 5);
      expect(restored.playerStatuses[0].turnsRemaining, isNull);
      expect(restored.playerStatuses[1].type, StatusEffectType.weak);
      expect(restored.playerStatuses[1].turnsRemaining, 2);
    });

    test('TurnFlags 보존', () {
      const flags = TurnFlags(
        immuneThisTurn: true,
        doubleNextAttack: true,
        attacksPlayedThisTurn: 2,
        cardsPlayedThisTurn: 3,
        apModifierNextTurn: 1,
        blockRetainPercent: 50,
        typesPlayedThisTurn: {CardType.attack, CardType.skill},
        remainingApBlockValue: 4,
        skillsPlayedThisTurn: 1,
        lastPlayedCardType: CardType.skill,
        chainCount: 2,
      );
      final original = makeMinimalActive(turnFlags: flags);
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      final f = restored!.turnFlags;
      expect(f.immuneThisTurn, true);
      expect(f.doubleNextAttack, true);
      expect(f.attacksPlayedThisTurn, 2);
      expect(f.cardsPlayedThisTurn, 3);
      expect(f.apModifierNextTurn, 1);
      expect(f.blockRetainPercent, 50);
      expect(f.typesPlayedThisTurn, {CardType.attack, CardType.skill});
      expect(f.remainingApBlockValue, 4);
      expect(f.skillsPlayedThisTurn, 1);
      expect(f.lastPlayedCardType, CardType.skill);
      expect(f.chainCount, 2);
    });

    test('PowerEffects 보존', () {
      const pe = PowerEffects(
        poisonPerTurnStart: 3,
        blockPerTurnStart: 5,
        healPerTurn: 2,
        lifestealOnAllAttacksPercent: 20,
        allAttackPiercing: true,
      );
      final original = makeMinimalActive(powerEffects: pe);
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      final r = restored!.powerEffects;
      expect(r.poisonPerTurnStart, 3);
      expect(r.blockPerTurnStart, 5);
      expect(r.healPerTurn, 2);
      expect(r.lifestealOnAllAttacksPercent, 20);
      expect(r.allAttackPiercing, true);
    });

    test('보스 전투 상태 보존', () {
      const bossData = BossCombatData(
        id: 'test_boss',
        name: '테스트 보스',
        floor: 3,
        phases: [
          BossPhaseConfig(
            hp: 100,
            atk: 15,
            def: 8,
            pattern: [EnemyActionType.attack, EnemyActionType.heavy],
            gimmick: BossGimmick.rage,
          ),
          BossPhaseConfig(
            hp: 80,
            atk: 20,
            def: 5,
            pattern: [EnemyActionType.heavy, EnemyActionType.buff],
            gimmick: BossGimmick.drain,
          ),
        ],
      );
      final original = makeMinimalActive(
        bossData: bossData,
        currentBossPhase: 1,
      );
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      expect(restored!.bossData, isNotNull);
      expect(restored.bossData!.id, 'test_boss');
      expect(restored.bossData!.phases.length, 2);
      expect(restored.bossData!.phases[0].gimmick, BossGimmick.rage);
      expect(restored.bossData!.phases[1].gimmick, BossGimmick.drain);
      expect(restored.currentBossPhase, 1);
    });

    test('변형 적(modifier) 보존', () {
      final modifiedEnemy = testEnemy.withModifier(EnemyModifierType.enhanced);
      final original = makeMinimalActive(
        enemies: [EnemyBattleState.fromData(modifiedEnemy)],
      );
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      final e = restored!.enemies.first.data;
      expect(e.modifier, EnemyModifierType.enhanced);
      expect(e.hp, modifiedEnemy.hp);
      expect(e.atk, modifiedEnemy.atk);
    });

    test('유령 PvP rewardJobOverride 보존', () {
      final original = makeMinimalActive(
        rewardJobOverride: 'mage',
        roomType: RoomType.elite,
      );
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      expect(restored!.rewardJobOverride, 'mage');
      expect(restored.roomType, RoomType.elite);
    });

    test('쿨다운 카드 보존', () {
      final original = makeMinimalActive(
        cooldownCards: {'card_a': 2, 'card_b': 1},
      );
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      expect(restored!.cooldownCards, {'card_a': 2, 'card_b': 1});
    });

    test('null JSON → null 반환', () {
      final result = CombatStateSerializer.fromJson(
        null,
        cardResolver: CardPool.findById,
        blessingResolver: CardBlessingPool.resolveIds,
        relicResolver: CardRelicPool.resolveIds,
        playerRunState: testPlayerState,
      );
      expect(result, isNull);
    });

    test('잘못된 JSON → null 반환 (폴백)', () {
      final result = CombatStateSerializer.fromJson(
        {'invalid': true},
        cardResolver: CardPool.findById,
        blessingResolver: CardBlessingPool.resolveIds,
        relicResolver: CardRelicPool.resolveIds,
        playerRunState: testPlayerState,
      );
      expect(result, isNull);
    });

    test('턴 N 중간 상태 보존', () {
      final original = makeMinimalActive(
        currentTurn: 5,
        playerHp: 45,
      );
      final restored = roundTrip(original);

      expect(restored, isNotNull);
      expect(restored!.currentTurn, 5);
      expect(restored.playerHp, 45);
    });
  });

  group('SaveSerializer cardCombatStateRaw 통합', () {
    test('RunSaveData에 cardCombatStateRaw 포함', () {
      final combatState = makeMinimalActive();
      final raw = CombatStateSerializer.toJson(combatState);

      expect(raw, isA<Map<String, dynamic>>());
      expect(raw['playerHp'], 80);
      expect(raw['enemies'], isA<List>());
      expect((raw['enemies'] as List).length, 1);
    });
  });
}
