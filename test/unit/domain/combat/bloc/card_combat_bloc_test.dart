import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/combat_reward_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/permadeath_event.dart';
import 'package:soul_dungeon/core/events/player_damaged_event.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';
import 'package:soul_dungeon/domain/combat/content/monster_cards.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/build/data/blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_relic_pool.dart';
import 'package:soul_dungeon/domain/build/data/curse_pool.dart';
import 'package:soul_dungeon/domain/build/data/relic_pool.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';
import 'package:soul_dungeon/domain/combat/content/warrior_cards.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/domain/combat/models/enemy_battle_state.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/core/models/tier_effect_calculator.dart';

void main() {
  late GameEventBus gameEventBus;
  late CombatBloc bloc;

  const combatConfig = CombatBalanceConfig();
  const economyConfig = EconomyConfig();
  const cardCombatConfig = CardCombatBalanceConfig();
  const momentumConfig = MomentumConfig();
  final tierEffectCalculator = TierEffectCalculator(config: momentumConfig);

  final initialPlayerState = PlayerRunState.initial(maxHp: 100);

  /// 테스트용 마스터 덱: 타격×3 + 방어×2 (결정적 셔플).
  final testDeck = [
    StarterCards.strike1,
    StarterCards.strike2,
    StarterCards.strike3,
    StarterCards.defend1,
    StarterCards.defend2,
  ];

  /// 결정적 초기 상태 생성 (셔플 제거).
  CardCombatActive makeActive({
    EnemyCombatData? enemy,
    List<EnemyCombatData>? enemies,
    int playerHp = 100,
    int playerMaxHp = 100,
    int playerBlock = 0,
    int? enemyHp,
    int? enemyMaxHp,
    int enemyBlock = 0,
    DeckState? deckState,
    int actionPoints = 3,
    int maxActionPoints = 3,
    List<StatusEffect> playerStatuses = const [],
    List<StatusEffect> enemyStatuses = const [],
    int currentTurn = 0,
    int enemyStrength = 0,
    RoomType roomType = RoomType.combat,
  }) {
    final enemyList = enemies ?? [enemy ?? FloorEnemies.rat];
    final enemyStates = enemyList.asMap().entries.map((entry) {
      final idx = entry.key;
      final data = entry.value;
      // 첫 번째 적에만 커스텀 HP/블록/상태 적용
      if (idx == 0) {
        return EnemyBattleState(
          data: data,
          currentHp: enemyHp ?? data.hp,
          maxHp: enemyMaxHp ?? data.hp,
          block: enemyBlock,
          strength: enemyStrength,
          statuses: enemyStatuses,
        );
      }
      return EnemyBattleState.fromData(data);
    }).toList();

    return CardCombatActive(
      enemies: enemyStates,
      playerHp: playerHp,
      playerMaxHp: playerMaxHp,
      playerBlock: playerBlock,
      deckState: deckState ??
          DeckState(hand: [
            StarterCards.strike1,
            StarterCards.strike2,
            StarterCards.defend1,
          ]),
      actionPoints: actionPoints,
      maxActionPoints: maxActionPoints,
      playerStatuses: playerStatuses,
      currentTurn: currentTurn,
      playerRunState: PlayerRunState(
        currentHp: playerHp,
        maxHp: playerMaxHp,
      ),
      roomType: roomType,
    );
  }

  setUp(() {
    gameEventBus = GameEventBus();
    bloc = CombatBloc(
      gameEventBus: gameEventBus,
      combatConfig: combatConfig,
      economyConfig: economyConfig,
      tierEffectCalculator: tierEffectCalculator,
      cardCombatConfig: cardCombatConfig,
      resolveCurseIds: CursePool.resolveCurseIds,
      resolveCardRelicIds: CardRelicPool.resolveIds,
      resolveBlessingIds: BlessingPool.resolveIds,
      resolveCardBlessingIds: CardBlessingPool.resolveIds,
      resolveRelicIds: RelicPool.resolveIds,
    );
  });

  tearDown(() {
    bloc.close();
    gameEventBus.dispose();
  });

  group('StartCardCombat', () {
    blocTest<CombatBloc, CombatState>(
      '초기 상태 → CardCombatActive',
      build: () => bloc,
      act: (b) => b.add(StartCardCombat(
        enemies: [FloorEnemies.rat],
        masterDeck: testDeck,
        playerRunState: initialPlayerState,
        momentumTier: 2,
      )),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.playerHp, 100);
        expect(state.playerMaxHp, 100);
        expect(state.enemyHp, FloorEnemies.rat.hp);
        expect(state.enemyMaxHp, FloorEnemies.rat.hp);
        expect(state.handCount, 5);
        expect(state.actionPoints, 3); // Mid tier
        expect(state.maxActionPoints, 3);
        expect(state.playerBlock, 0);
        expect(state.enemyBlock, 0);
        expect(state.currentTurn, 0);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'Low tier → AP 2',
      build: () => CombatBloc(
        gameEventBus: gameEventBus,
        combatConfig: combatConfig,
        economyConfig: economyConfig,
        tierEffectCalculator: tierEffectCalculator,
        cardCombatConfig: cardCombatConfig,
        resolveCurseIds: CursePool.resolveCurseIds,
        resolveCardRelicIds: CardRelicPool.resolveIds,
        resolveBlessingIds: BlessingPool.resolveIds,
        resolveCardBlessingIds: CardBlessingPool.resolveIds,
        resolveRelicIds: RelicPool.resolveIds,
        momentumConfig: const MomentumConfig(initialValue: 0),
      ),
      act: (b) => b.add(StartCardCombat(
        enemies: [FloorEnemies.rat],
        masterDeck: testDeck,
        playerRunState: initialPlayerState,
        momentumTier: 1,
      )),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.actionPoints, 2);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'High tier → AP 4',
      build: () => CombatBloc(
        gameEventBus: gameEventBus,
        combatConfig: combatConfig,
        economyConfig: economyConfig,
        tierEffectCalculator: tierEffectCalculator,
        cardCombatConfig: cardCombatConfig,
        resolveCurseIds: CursePool.resolveCurseIds,
        resolveCardRelicIds: CardRelicPool.resolveIds,
        resolveBlessingIds: BlessingPool.resolveIds,
        resolveCardBlessingIds: CardBlessingPool.resolveIds,
        resolveRelicIds: RelicPool.resolveIds,
        momentumConfig: const MomentumConfig(initialValue: 80),
      ),
      act: (b) => b.add(StartCardCombat(
        enemies: [FloorEnemies.rat],
        masterDeck: testDeck,
        playerRunState: initialPlayerState,
        momentumTier: 3,
      )),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.actionPoints, 4);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'RoomType 전달',
      build: () => bloc,
      act: (b) => b.add(StartCardCombat(
        enemies: [FloorEnemies.goblinChief],
        masterDeck: testDeck,
        playerRunState: initialPlayerState,
        roomType: RoomType.elite,
      )),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.roomType, RoomType.elite);
        expect(state.enemy, FloorEnemies.goblinChief);
      },
    );
  });

  group('PlayCard', () {
    blocTest<CombatBloc, CombatState>(
      '타격 카드 — 6 데미지, AP 감소',
      build: () => bloc,
      seed: () => makeActive(),
      act: (b) => b.add(PlayCard(StarterCards.strike1.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.enemyHp, FloorEnemies.rat.hp - 6);
        expect(state.actionPoints, 2); // 3 - 1
        expect(state.handCount, 2); // 3 - 1 (played)
      },
    );

    blocTest<CombatBloc, CombatState>(
      '방어 카드 — 블록 5',
      build: () => bloc,
      seed: () => makeActive(),
      act: (b) => b.add(PlayCard(StarterCards.defend1.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.playerBlock, 5);
        expect(state.enemyHp, FloorEnemies.rat.hp); // 데미지 없음
        expect(state.actionPoints, 2);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'AP 부족 — 무시',
      build: () => bloc,
      seed: () => makeActive(actionPoints: 0),
      act: (b) => b.add(PlayCard(StarterCards.strike1.id)),
      expect: () => [],
    );

    blocTest<CombatBloc, CombatState>(
      '손패에 없는 카드 — 무시',
      build: () => bloc,
      seed: () => makeActive(),
      act: (b) => b.add(const PlayCard('nonexistent_card')),
      expect: () => [],
    );

    blocTest<CombatBloc, CombatState>(
      '적 블록 흡수',
      build: () => bloc,
      seed: () => makeActive(enemyBlock: 4),
      act: (b) => b.add(PlayCard(StarterCards.strike1.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        // 6 데미지 → 4 블록 흡수 → 2 HP 손실
        expect(state.enemyHp, FloorEnemies.rat.hp - 2);
        expect(state.enemyBlock, 0);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '적 사망 → CardCombatResolved(victory)',
      build: () => bloc,
      seed: () => makeActive(enemyHp: 5),
      act: (b) => b.add(PlayCard(StarterCards.strike1.id)),
      verify: (b) {
        final state = b.state as CardCombatResolved;
        expect(state.outcome, CombatOutcome.victory);
        final rewards = gameEventBus.history
            .whereType<CombatRewardEvent>()
            .toList();
        expect(rewards, hasLength(1));
      },
    );

    blocTest<CombatBloc, CombatState>(
      '전쟁함성 — gainStrength 효과',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(hand: [WarriorCards.warCry]),
      ),
      act: (b) => b.add(PlayCard(WarriorCards.warCry.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(
          state.playerStatuses.any((s) => s.type == StatusEffectType.strength),
          isTrue,
        );
      },
    );

    blocTest<CombatBloc, CombatState>(
      '약점 간파 — applyVulnerable',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(hand: [ColorlessCards.exposeWeakness]),
      ),
      act: (b) => b.add(PlayCard(ColorlessCards.exposeWeakness.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(
          state.enemyStatuses
              .any((s) => s.type == StatusEffectType.vulnerable),
          isTrue,
        );
      },
    );

    blocTest<CombatBloc, CombatState>(
      '독 항아리 — Exhaust + poison',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(hand: [ColorlessCards.poisonJar]),
      ),
      act: (b) => b.add(PlayCard(ColorlessCards.poisonJar.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(
          state.enemyStatuses.any((s) => s.type == StatusEffectType.poison),
          isTrue,
        );
        expect(state.deckState.exhaustPileCount, 1);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '돌진 — 8d + 힘+1 + draw 1',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(
          hand: [WarriorCards.charge],
          drawPile: [StarterCards.strike1],
        ),
      ),
      act: (b) => b.add(PlayCard(WarriorCards.charge.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.enemyHp, FloorEnemies.rat.hp - 8);
        expect(
          state.playerStatuses.any((s) => s.type == StatusEffectType.strength),
          isTrue,
        );
        // charge는 discard, strike1은 draw → 손패에 strike1
        expect(state.handCount, 1);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '피의 맹세 — selfDamage + strength + draw + exhaust',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(
          hand: [WarriorCards.bloodOath],
          drawPile: [StarterCards.defend1],
        ),
        actionPoints: 3, // bloodOath = 0AP
      ),
      act: (b) => b.add(PlayCard(WarriorCards.bloodOath.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.playerHp, 100 - 4); // selfDamage 4
        expect(
          state.playerStatuses.any((s) => s.type == StatusEffectType.strength),
          isTrue,
        );
        expect(state.deckState.exhaustPileCount, 1); // bloodOath exhausted
        expect(state.handCount, 1); // defend1 drawn
        expect(state.actionPoints, 3); // 0AP cost
      },
    );

    blocTest<CombatBloc, CombatState>(
      '맹공 — momentumTier × 5',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(hand: [WarriorCards.onslaught]),
        actionPoints: 2,
      ),
      act: (b) => b.add(PlayCard(WarriorCards.onslaught.id, momentumTier: 3)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        // 3 * 5 = 15 데미지
        expect(state.enemyHp, FloorEnemies.rat.hp - 15);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '강타 — 2AP 18d',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(hand: [WarriorCards.heavyStrike]),
        actionPoints: 3,
      ),
      act: (b) => b.add(PlayCard(WarriorCards.heavyStrike.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.enemyHp, FloorEnemies.rat.hp - 18);
        expect(state.actionPoints, 1); // 3 - 2
      },
    );

    blocTest<CombatBloc, CombatState>(
      '연막 — 블록 10 + weak + exhaust',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(hand: [ColorlessCards.smokeScreen]),
      ),
      act: (b) => b.add(PlayCard(ColorlessCards.smokeScreen.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.playerBlock, 10);
        expect(
          state.enemyStatuses.any((s) => s.type == StatusEffectType.weak),
          isTrue,
        );
        expect(state.deckState.exhaustPileCount, 1);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '힘 보너스로 타격 데미지 증가',
      build: () => bloc,
      seed: () => makeActive(
        playerStatuses: [
          const StatusEffect(type: StatusEffectType.strength, stacks: 3),
        ],
      ),
      act: (b) => b.add(PlayCard(StarterCards.strike1.id)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.enemyHp, FloorEnemies.rat.hp - 9); // 6 + 3
      },
    );

    blocTest<CombatBloc, CombatState>(
      'CombatIdle에서 PlayCard → re-emit (UI stream 해제)',
      build: () => bloc,
      act: (b) => b.add(PlayCard(StarterCards.strike1.id)),
      expect: () => [isA<CombatIdle>()],
    );
  });

  group('EndPlayerTurn', () {
    blocTest<CombatBloc, CombatState>(
      '기본 턴 종료 — 적 공격 + 드로우 + AP 리셋',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.rat], // 항상 attack, atk=10
        deckState: DeckState(
          hand: [StarterCards.strike1], // 1장 남음
          drawPile: [
            StarterCards.strike2,
            StarterCards.defend1,
            StarterCards.defend2,
            StarterCards.strike3,
            ColorlessCards.freshStart,
          ],
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        // 적 공격 (10 데미지, 블록 0) → HP 90
        expect(state.playerHp, 90);
        // 블록 리셋
        expect(state.playerBlock, 0);
        // 적 블록 리셋
        expect(state.enemyBlock, 0);
        // 새 손패 4장 (discard 1 + draw 4)
        expect(state.handCount, 4);
        // AP 리셋 (Mid tier)
        expect(state.actionPoints, 3);
        expect(state.maxActionPoints, 3);
        // 턴 증가
        expect(state.currentTurn, 1);
        // 적 행동 기록
        expect(state.lastEnemyAction, isNotNull);
        expect(state.lastEnemyAction!.type, EnemyActionType.attack);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '블록으로 적 공격 흡수',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.rat], // atk=10
        playerBlock: 5,
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        // 10 - 5 = 5 데미지
        expect(state.playerHp, 95);
        // 블록은 다음 턴 시작에 리셋
        expect(state.playerBlock, 0);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '적 방어 행동 — 적 블록 획득',
      build: () => bloc,
      seed: () => makeActive(
        enemy: FloorEnemies.slime, // 패턴: [defend, attack, attack, defend]
        currentTurn: 0, // defend 턴
        playerBlock: 1, // Phase 3-C: 블록>0이면 defend→attack 오버라이드 방지
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.playerHp, 100); // 데미지 없음
        expect(state.enemyBlock, 4); // slime def=4
      },
    );

    blocTest<CombatBloc, CombatState>(
      '적 회복 행동',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.goblinChief], // 패턴 [buff, attack, attack, heavy, heal]
        currentTurn: 4, // heal
        enemyHp: 50,
        enemyMaxHp: 65,
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        // 65 * 0.2 = 13 회복
        expect(state.enemyHp, 63); // 50 + 13 = 63 (maxHp=65 이하)
      },
    );

    blocTest<CombatBloc, CombatState>(
      '적 강화 행동 — enemyStrength 증가',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.goblinChief], // 패턴 [buff, ...]
        currentTurn: 0, // buff
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.enemyStrength, 4); // elite buff gives +4
        expect(state.playerHp, 100); // 데미지 없음
      },
    );

    blocTest<CombatBloc, CombatState>(
      '적 독 상태 — 틱 시 적 데미지',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.rat],
        enemyStatuses: [
          const StatusEffect(type: StatusEffectType.poison, stacks: 5),
        ],
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        // 적 독: 5 데미지 + rat attack 10
        expect(state.enemyHp, FloorEnemies.rat.hp - 5);
        expect(state.playerHp, 90); // rat attack 10
      },
    );

    blocTest<CombatBloc, CombatState>(
      '플레이어 사망 → CardCombatResolved(defeat)',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.rat], // atk=10
        playerHp: 5,
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatResolved;
        expect(state.outcome, CombatOutcome.defeat);
        // 실제 전투 사망 — hpLost = 초기 런 HP (5)
        expect(state.hpLost, 5);
        expect(state.isPermadeath, isTrue);
        expect(state.playerHp, 0);
        final damaged = gameEventBus.history
            .whereType<PlayerDamagedEvent>()
            .toList();
        // 적 공격 피격(1) + 패배 HP 차감(1) = 2
        expect(damaged, hasLength(2));
      },
    );

    blocTest<CombatBloc, CombatState>(
      '적 독 사망 → CardCombatResolved(victory)',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.rat],
        enemyHp: 3,
        enemyStatuses: [
          const StatusEffect(type: StatusEffectType.poison, stacks: 5),
        ],
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatResolved;
        expect(state.outcome, CombatOutcome.victory);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '가시 반사 데미지',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.rat], // attack
        playerStatuses: [
          const StatusEffect(type: StatusEffectType.thorn, stacks: 3),
        ],
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        // thorn 3 → 적에게 3 반사
        expect(state.enemyHp, FloorEnemies.rat.hp - 3);
      },
    );

    // (턴 제한 제거됨 — 엘리트/보스 턴 제한 테스트 삭제)

    blocTest<CombatBloc, CombatState>(
      '일반 전투 턴 제한 없음 — 턴 50 OK',
      build: () => bloc,
      seed: () => makeActive(
        enemy: const EnemyCombatData(
          id: 'test_normal',
          name: '테스트 적',
          hp: 999,
          atk: 0,
          def: 0,
          floor: 1,
          pattern: [EnemyActionType.charge],
        ),
        currentTurn: 49,
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.currentTurn, 50);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'CombatIdle에서 EndPlayerTurn → 무시',
      build: () => bloc,
      act: (b) => b.add(const EndPlayerTurn()),
      expect: () => [],
    );
  });

  group('AttemptFlee', () {
    // seed=2 → Random(2).nextDouble() ≈ 0.0008 < 0.5 → 도주 성공
    blocTest<CombatBloc, CombatState>(
      '도주 성공 (RNG < 50%) → CombatOutcome.fled + HP/골드 패널티',
      build: () => CombatBloc(
        gameEventBus: gameEventBus,
        combatConfig: combatConfig,
        economyConfig: economyConfig,
        tierEffectCalculator: tierEffectCalculator,
        resolveCurseIds: CursePool.resolveCurseIds,
        resolveCardRelicIds: CardRelicPool.resolveIds,
        resolveBlessingIds: BlessingPool.resolveIds,
        resolveCardBlessingIds: CardBlessingPool.resolveIds,
        resolveRelicIds: RelicPool.resolveIds,
        random: Random(2),
      ),
      seed: () => makeActive(playerHp: 100, playerMaxHp: 100),
      act: (b) => b.add(const AttemptFlee()),
      verify: (b) {
        final state = b.state as CardCombatResolved;
        expect(state.outcome, CombatOutcome.fled);
        // HP 패널티: 100 * 20% = 20 → 80
        expect(state.playerHp, 80);
        // 골드 패널티: 0 - 30 → 0 (clamp)
        expect(state.playerRunState.gold, 0);
      },
    );

    // seed=0 → Random(0).nextDouble() ≈ 0.826 >= 0.5 → 도주 실패
    blocTest<CombatBloc, CombatState>(
      '도주 실패 (RNG >= 50%) → CardCombatActive + AP 소모 + fleeFailed',
      build: () => CombatBloc(
        gameEventBus: gameEventBus,
        combatConfig: combatConfig,
        economyConfig: economyConfig,
        tierEffectCalculator: tierEffectCalculator,
        resolveCurseIds: CursePool.resolveCurseIds,
        resolveCardRelicIds: CardRelicPool.resolveIds,
        resolveBlessingIds: BlessingPool.resolveIds,
        resolveCardBlessingIds: CardBlessingPool.resolveIds,
        resolveRelicIds: RelicPool.resolveIds,
        random: Random(0),
      ),
      seed: () => makeActive(
        playerHp: 100,
        playerMaxHp: 100,
        actionPoints: 3,
      ),
      act: (b) => b.add(const AttemptFlee()),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.fleeFailed, true);
        // 도주 실패 → 전체 턴 종료 처리 (적 행동 + 턴 전진)
        // AP: apForTier(1) = apLow = 2 (턴 종료 후 리셋)
        expect(state.actionPoints, 2);
        // 적 공격: 쥐 ATK=10 → HP 100-10=90
        expect(state.playerHp, 90);
        // 턴 전진: 0 → 1
        expect(state.currentTurn, 1);
        // 적 행동 기록
        expect(state.lastEnemyAction, isNotNull);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'AP 부족 시 도주 불가 — 무시',
      build: () => CombatBloc(
        gameEventBus: gameEventBus,
        combatConfig: combatConfig,
        economyConfig: economyConfig,
        tierEffectCalculator: tierEffectCalculator,
        resolveCurseIds: CursePool.resolveCurseIds,
        resolveCardRelicIds: CardRelicPool.resolveIds,
        resolveBlessingIds: BlessingPool.resolveIds,
        resolveCardBlessingIds: CardBlessingPool.resolveIds,
        resolveRelicIds: RelicPool.resolveIds,
        random: Random(2),
      ),
      seed: () => makeActive(actionPoints: 0),
      act: (b) => b.add(const AttemptFlee()),
      expect: () => [],
    );

    // fleeGuaranteed → 100% 성공 (seed=0 → 실패 시드이지만 보장됨)
    blocTest<CombatBloc, CombatState>(
      'fleeGuaranteed → 무조건 성공',
      build: () => CombatBloc(
        gameEventBus: gameEventBus,
        combatConfig: combatConfig,
        economyConfig: economyConfig,
        tierEffectCalculator: tierEffectCalculator,
        resolveCurseIds: CursePool.resolveCurseIds,
        resolveCardRelicIds: CardRelicPool.resolveIds,
        resolveBlessingIds: BlessingPool.resolveIds,
        resolveCardBlessingIds: CardBlessingPool.resolveIds,
        resolveRelicIds: RelicPool.resolveIds,
        random: Random(0), // 실패 시드
      ),
      seed: () => CardCombatActive(
        enemies: [EnemyBattleState.fromData(FloorEnemies.rat)],
        playerHp: 100,
        playerMaxHp: 100,
        deckState: DeckState(hand: [StarterCards.strike1]),
        actionPoints: 3,
        maxActionPoints: 3,
        playerRunState: const PlayerRunState(currentHp: 100, maxHp: 100),
        fleeGuaranteed: true,
      ),
      act: (b) => b.add(const AttemptFlee()),
      verify: (b) {
        final state = b.state as CardCombatResolved;
        expect(state.outcome, CombatOutcome.fled);
      },
    );

    // Wind Amulet → 성공률 +30% (50+30=80%)
    // seed=1 → 0.579 (< 0.8 → 성공, but >= 0.5 without amulet → 실패 without)
    blocTest<CombatBloc, CombatState>(
      'Wind Amulet → 성공률 +30%',
      build: () => CombatBloc(
        gameEventBus: gameEventBus,
        combatConfig: combatConfig,
        economyConfig: economyConfig,
        tierEffectCalculator: tierEffectCalculator,
        resolveCurseIds: CursePool.resolveCurseIds,
        resolveCardRelicIds: CardRelicPool.resolveIds,
        resolveBlessingIds: BlessingPool.resolveIds,
        resolveCardBlessingIds: CardBlessingPool.resolveIds,
        resolveRelicIds: RelicPool.resolveIds,
        random: Random(1), // 0.579 → without amulet fail, with amulet success
      ),
      seed: () => CardCombatActive(
        enemies: [EnemyBattleState.fromData(FloorEnemies.rat)],
        playerHp: 100,
        playerMaxHp: 100,
        deckState: DeckState(hand: [StarterCards.strike1]),
        actionPoints: 3,
        maxActionPoints: 3,
        playerRunState: PlayerRunState(
          currentHp: 100,
          maxHp: 100,
          ownedRelicIds: [CardRelicPool.windAmulet.id],
        ),
      ),
      act: (b) => b.add(const AttemptFlee()),
      verify: (b) {
        final state = b.state as CardCombatResolved;
        expect(state.outcome, CombatOutcome.fled);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '보스 전투 도주 불가 — 무시',
      build: () => bloc,
      seed: () => makeActive(roomType: RoomType.boss),
      act: (b) => b.add(const AttemptFlee()),
      expect: () => [],
    );

    blocTest<CombatBloc, CombatState>(
      'CombatIdle에서 AttemptFlee → 무시',
      build: () => bloc,
      act: (b) => b.add(const AttemptFlee()),
      expect: () => [],
    );
  });

  group('SelectCardReward', () {
    blocTest<CombatBloc, CombatState>(
      '보상 선택 → CombatIdle',
      build: () => bloc,
      seed: () => CardCombatResolved(
        outcome: CombatOutcome.victory,
        enemies: [FloorEnemies.rat],
        playerHp: 80,
        playerMaxHp: 100,
        playerRunState: const PlayerRunState(currentHp: 80, maxHp: 100),
      ),
      act: (b) => b.add(const SelectCardReward(selectedCardId: 'card_1')),
      expect: () => [const CombatIdle()],
    );

    blocTest<CombatBloc, CombatState>(
      '보상 건너뛰기 (null) → CombatIdle',
      build: () => bloc,
      seed: () => CardCombatResolved(
        outcome: CombatOutcome.victory,
        enemies: [FloorEnemies.rat],
        playerHp: 80,
        playerMaxHp: 100,
        playerRunState: const PlayerRunState(currentHp: 80, maxHp: 100),
      ),
      act: (b) => b.add(const SelectCardReward()),
      expect: () => [const CombatIdle()],
    );
  });

  group('퍼마데스', () {
    blocTest<CombatBloc, CombatState>(
      '카드 전투 패배 + 퍼마데스 → PermadeathEvent',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.rat],
        playerHp: 5,
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ).copyWith(
        playerRunState: const PlayerRunState(currentHp: 5, maxHp: 100),
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 1)),
      verify: (b) {
        final state = b.state as CardCombatResolved;
        expect(state.outcome, CombatOutcome.defeat);
        // HP 5 - defeat loss 30 → 0 이하 → permadeath
        expect(state.isPermadeath, isTrue);
        final permadeath = gameEventBus.history
            .whereType<PermadeathEvent>()
            .toList();
        expect(permadeath, hasLength(1));
      },
    );
  });

  group('다중 턴 플로우', () {
    blocTest<CombatBloc, CombatState>(
      '2턴 전투 → 카드 플레이 + 턴 종료 반복',
      build: () => bloc,
      seed: () => makeActive(
        enemies: [FloorEnemies.rat], // atk 10
        enemyHp: 50, // Phase 3-C: HP>50% 유지 → 반응형 오버라이드 방지
        enemyMaxHp: 50,
        deckState: DeckState(
          hand: [
            StarterCards.strike1,
            StarterCards.strike2,
            StarterCards.defend1,
          ],
          drawPile: [
            StarterCards.strike3,
            StarterCards.defend2,
            ColorlessCards.freshStart,
            ColorlessCards.absorb,
            ColorlessCards.insight,
          ],
        ),
        actionPoints: 3,
      ),
      act: (b) {
        // 턴 1: 타격 2회 (12d) → AP 1 남음
        b.add(PlayCard(StarterCards.strike1.id));
        b.add(PlayCard(StarterCards.strike2.id));
        b.add(const EndPlayerTurn(momentumTier: 2));
        // 턴 2: 새 손패에서 플레이
      },
      verify: (b) {
        final state = b.state as CardCombatActive;
        // 적 HP: 50 - 6(strike1) - 6(strike2) - 1(2연쇄 20% of 6) = 37
        expect(state.enemyHp, 37);
        // 플레이어 HP: 100 - 10 (rat attack) = 90
        expect(state.playerHp, 90);
        // 턴 1
        expect(state.currentTurn, 1);
        // 새 손패 4장
        expect(state.handCount, 4);
        // AP 리셋 (Mid=3)
        expect(state.actionPoints, 3);
      },
    );
  });

  group('EndCombat (카드 전투 후)', () {
    blocTest<CombatBloc, CombatState>(
      'CardCombatResolved 상태에서 EndCombat → CombatIdle',
      build: () => bloc,
      seed: () => CardCombatResolved(
        outcome: CombatOutcome.victory,
        enemies: [FloorEnemies.rat],
        playerHp: 80,
        playerMaxHp: 100,
        playerRunState: const PlayerRunState(currentHp: 80, maxHp: 100),
      ),
      act: (b) => b.add(const EndCombat()),
      expect: () => [const CombatIdle()],
    );
  });

  group('CardCombatBalanceConfig', () {
    test('apForTier — Low/Mid/High', () {
      const config = CardCombatBalanceConfig();
      expect(config.apForTier(1), 2);
      expect(config.apForTier(2), 3);
      expect(config.apForTier(3), 4);
    });

    test('fromJson — 기본값 폴백', () {
      final config = CardCombatBalanceConfig.fromJson(const {});
      expect(config.initialHandSize, 5);
      expect(config.drawPerTurn, 4);
      expect(config.apLow, 2);
      expect(config.apMid, 3);
      expect(config.apHigh, 4);
    });

    test('fromJson — 커스텀 값', () {
      final config = CardCombatBalanceConfig.fromJson(const {
        'initial_hand_size': 4,
        'draw_per_turn': 3,
        'ap_low': 1,
        'ap_mid': 2,
        'ap_high': 3,
        'elite_turn_limit': 15,
        'boss_turn_limit': 25,
      });
      expect(config.initialHandSize, 4);
      expect(config.drawPerTurn, 3);
      expect(config.apLow, 1);
      expect(config.apMid, 2);
      expect(config.apHigh, 3);
    });
  });

  group('CardCombatActive 헬퍼', () {
    test('isPlayerDead / isEnemyDead', () {
      final alive = makeActive(playerHp: 10, enemyHp: 10);
      expect(alive.isPlayerDead, isFalse);
      expect(alive.isEnemyDead, isFalse);

      final playerDead = makeActive(playerHp: 0, enemyHp: 10);
      expect(playerDead.isPlayerDead, isTrue);

      final enemyDead = makeActive(playerHp: 10, enemyHp: 0);
      expect(enemyDead.isEnemyDead, isTrue);
    });

    test('hand getter', () {
      final state = makeActive(
        deckState: DeckState(hand: [StarterCards.strike1, StarterCards.defend1]),
      );
      expect(state.hand, hasLength(2));
      expect(state.handCount, 2);
    });

    test('copyWith', () {
      final original = makeActive(playerHp: 100, enemyHp: 50);
      final updated = original.copyWith(playerHp: 80, enemyBlock: 5);
      expect(updated.playerHp, 80);
      expect(updated.enemyBlock, 5);
      expect(updated.enemyHp, 50); // 유지
    });

    test('copyWith clearLastPlayResult', () {
      final state = makeActive();
      final withResult = state.copyWith(clearLastPlayResult: true);
      expect(withResult.lastPlayResult, isNull);
    });
  });

  group('적 의도 표시 + 관찰 연동', () {
    /// 관찰 카드 — revealIntent 효과.
    const observeCard = CardData(
      id: 'test_observe',
      name: '관찰',
      type: CardType.skill,
      apCost: 1,
      description: '적 의도 공개',
      effects: [CardEffect(type: CardEffectType.revealIntent, value: 2)],
    );

    blocTest<CombatBloc, CombatState>(
      '관찰 카드 사용 → intentRevealed=true, intentRevealTurns=2',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(
          hand: [observeCard, StarterCards.strike1],
          drawPile: List.generate(
            5,
            (i) => StarterCards.defend1.copyWith(id: 'draw_$i'),
          ),
        ),
      ),
      act: (b) => b.add(const PlayCard('test_observe')),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.intentRevealed, isTrue);
        expect(state.intentRevealTurns, 2);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '의도 공개 카운트다운 — 1턴 경과 후 remainingTurns=1',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ).copyWith(
        intentRevealed: true,
        intentRevealTurns: 2,
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.intentRevealed, isTrue);
        expect(state.intentRevealTurns, 1);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '의도 공개 카운트다운 — 2턴 경과 후 해제',
      build: () => bloc,
      seed: () => makeActive(
        deckState: DeckState(
          hand: [],
          drawPile: List.generate(
            5,
            (i) => StarterCards.strike1.copyWith(id: 'draw_$i'),
          ),
        ),
      ).copyWith(
        intentRevealed: true,
        intentRevealTurns: 1,
      ),
      act: (b) => b.add(const EndPlayerTurn(momentumTier: 2)),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.intentRevealed, isFalse);
        expect(state.intentRevealTurns, 0);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '초기 상태 — intentRevealed=false',
      build: () => bloc,
      act: (b) => b.add(StartCardCombat(
        enemies: [FloorEnemies.rat],
        masterDeck: testDeck,
        playerRunState: initialPlayerState,
        momentumTier: 2,
      )),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.intentRevealed, isFalse);
        expect(state.intentRevealTurns, 0);
      },
    );

    test('CardCombatActive copyWith intentRevealed', () {
      final original = makeActive();
      expect(original.intentRevealed, isFalse);
      expect(original.intentRevealTurns, 0);

      final revealed = original.copyWith(
        intentRevealed: true,
        intentRevealTurns: 3,
      );
      expect(revealed.intentRevealed, isTrue);
      expect(revealed.intentRevealTurns, 3);
    });
  });

  group('축복/유물 플로우 통합', () {
    blocTest<CombatBloc, CombatState>(
      'StartCardCombat — 축복/유물 ID → 해결',
      build: () => bloc,
      act: (b) => b.add(StartCardCombat(
        enemies: [FloorEnemies.rat],
        masterDeck: testDeck,
        playerRunState: const PlayerRunState(
          currentHp: 100,
          maxHp: 100,
          ownedBlessingIds: ['cb_thorn', 'cb_sharp'],
          ownedRelicIds: ['cr_blood_ring'],
        ),
        momentumTier: 2,
      )),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.activeBlessings, hasLength(2));
        expect(state.activeBlessings[0].id, 'cb_thorn');
        expect(state.activeBlessings[1].id, 'cb_sharp');
        expect(state.activeRelics, hasLength(1));
        expect(state.activeRelics[0].id, 'cr_blood_ring');
      },
    );

    blocTest<CombatBloc, CombatState>(
      'StartCardCombat — 존재하지 않는 ID 무시',
      build: () => bloc,
      act: (b) => b.add(StartCardCombat(
        enemies: [FloorEnemies.rat],
        masterDeck: testDeck,
        playerRunState: const PlayerRunState(
          currentHp: 100,
          maxHp: 100,
          ownedBlessingIds: ['cb_thorn', 'old_blessing_001'],
          ownedRelicIds: ['unknown_relic'],
        ),
        momentumTier: 2,
      )),
      verify: (b) {
        final state = b.state as CardCombatActive;
        // old_blessing_001은 CardBlessingPool에 없으므로 무시
        expect(state.activeBlessings, hasLength(1));
        expect(state.activeBlessings[0].id, 'cb_thorn');
        // unknown_relic은 CardRelicPool에 없으므로 무시
        expect(state.activeRelics, isEmpty);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'StartCardCombat — 축복/유물 없는 경우',
      build: () => bloc,
      act: (b) => b.add(StartCardCombat(
        enemies: [FloorEnemies.rat],
        masterDeck: testDeck,
        playerRunState: initialPlayerState,
        momentumTier: 2,
      )),
      verify: (b) {
        final state = b.state as CardCombatActive;
        expect(state.activeBlessings, isEmpty);
        expect(state.activeRelics, isEmpty);
      },
    );

    test('CardBlessingPool.resolveIds', () {
      final resolved = CardBlessingPool.resolveIds(
        ['cb_thorn', 'invalid', 'cb_echo'],
      );
      expect(resolved, hasLength(2));
      expect(resolved[0].id, 'cb_thorn');
      expect(resolved[1].id, 'cb_echo');
    });

    test('CardRelicPool.resolveIds', () {
      final resolved = CardRelicPool.resolveIds(
        ['cr_blood_ring', 'invalid', 'cr_soul_stone'],
      );
      expect(resolved, hasLength(2));
      expect(resolved[0].id, 'cr_blood_ring');
      expect(resolved[1].id, 'cr_soul_stone');
    });
  });

  group('몬스터 테이밍 — 제압/길들이기', () {
    test('제압 감지: HP ≤ 25%면 canTame=true', () {
      final suppressed = makeActive(enemyHp: 5, enemyMaxHp: 100);
      expect(suppressed.canTame, isTrue);
      expect(suppressed.suppressedTargetIndex, 0);

      final healthy = makeActive(enemyHp: 100, enemyMaxHp: 100);
      expect(healthy.canTame, isFalse);
      expect(healthy.suppressedTargetIndex, isNull);

      // 경계값: 정확히 25%는 제압 가능(≤).
      final boundary = makeActive(enemyHp: 25, enemyMaxHp: 100);
      expect(boundary.canTame, isTrue);
      final above = makeActive(enemyHp: 26, enemyMaxHp: 100);
      expect(above.canTame, isFalse);
    });

    blocTest<CombatBloc, CombatState>(
      '제압된 적 길들이기 → CardCombatResolved(tamedEnemyId + 무브풀 드래프트)',
      build: () => bloc,
      seed: () => makeActive(enemyHp: 5, enemyMaxHp: 100),
      act: (b) => b.add(const TameEnemy(0)),
      expect: () => [
        isA<CardCombatResolved>()
            .having((s) => s.isTamed, 'isTamed', isTrue)
            .having((s) => s.tamedEnemyId, 'tamedEnemyId', FloorEnemies.rat.id)
            .having((s) => s.outcome, 'outcome', CombatOutcome.victory)
            .having((s) => s.cardRewardOptions.isNotEmpty, '보상 있음', isTrue)
            .having(
              (s) => s.cardRewardOptions.every((c) =>
                  MonsterCards.movepoolIds(FloorEnemies.rat.id).contains(c.id)),
              '보상이 길들인 몬스터 무브풀에서 나옴',
              isTrue,
            ),
      ],
    );

    blocTest<CombatBloc, CombatState>(
      '제압되지 않은 적 길들이기 시도 → 무시(상태 변화 없음)',
      build: () => bloc,
      seed: () => makeActive(enemyHp: 100, enemyMaxHp: 100),
      act: (b) => b.add(const TameEnemy(0)),
      expect: () => [],
    );

    blocTest<CombatBloc, CombatState>(
      '잘못된 인덱스 길들이기 → 무시',
      build: () => bloc,
      seed: () => makeActive(enemyHp: 5, enemyMaxHp: 100),
      act: (b) => b.add(const TameEnemy(9)),
      expect: () => [],
    );

    test('MonsterCards: 무브풀이 실제 카드로 해석됨', () {
      final rat = MonsterCards.movepool('enemy_rat');
      expect(rat, isNotEmpty);
      expect(rat.length, MonsterCards.movepoolIds('enemy_rat').length);
      // 알 수 없는 몬스터 → 빈 목록
      expect(MonsterCards.movepool('enemy_unknown_xyz'), isEmpty);
      expect(MonsterCards.hasMovepool('enemy_goblin'), isTrue);
    });
  });
}
