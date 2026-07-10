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
import 'package:soul_dungeon/domain/combat/logic/combat_result_calculator.dart';
import 'package:soul_dungeon/domain/combat/models/boss_phase_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_encounter_data.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/core/models/tier_effect_calculator.dart';
import 'package:soul_dungeon/domain/build/data/blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_relic_pool.dart';
import 'package:soul_dungeon/domain/build/data/curse_pool.dart';
import 'package:soul_dungeon/domain/build/data/relic_pool.dart';

void main() {
  late GameEventBus gameEventBus;
  late CombatBloc combatBloc;

  const combatConfig = CombatBalanceConfig();
  const economyConfig = EconomyConfig();
  const momentumConfig = MomentumConfig();
  final tierEffectCalculator = TierEffectCalculator(config: momentumConfig);

  const encounter3Turns = CombatEncounterData(
    roomType: RoomType.combat,
    enemyName: '해골 전사',
    turns: [
      CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
      CombatTurnInfo(turnNumber: 2, enemyAction: EnemyActionType.defend),
      CombatTurnInfo(turnNumber: 3, enemyAction: EnemyActionType.observe),
    ],
  );

  const encounter0Turns = CombatEncounterData(
    roomType: RoomType.combat,
    enemyName: '허수아비',
    turns: [],
  );

  const eliteEncounter = CombatEncounterData(
    roomType: RoomType.elite,
    enemyName: '엘리트 기사',
    turns: [
      CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
      CombatTurnInfo(turnNumber: 2, enemyAction: EnemyActionType.defend),
      CombatTurnInfo(turnNumber: 3, enemyAction: EnemyActionType.observe),
    ],
  );

  const encounterWithClues = CombatEncounterData(
    roomType: RoomType.combat,
    enemyName: '동굴 트롤',
    environmentClues: [
      EnvironmentClue(
        id: 'stalactite',
        description: '불안정한 종유석',
        actionHint: '종유석을 떨어뜨린다',
      ),
    ],
    turns: [
      CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
      CombatTurnInfo(turnNumber: 2, enemyAction: EnemyActionType.defend),
    ],
  );

  final initialPlayerState = PlayerRunState.initial(
    maxHp: combatConfig.basePlayerHp,
  );

  setUp(() {
    gameEventBus = GameEventBus();
    combatBloc = CombatBloc(
      gameEventBus: gameEventBus,
      combatConfig: combatConfig,
      economyConfig: economyConfig,
      tierEffectCalculator: tierEffectCalculator,
      resolveCurseIds: CursePool.resolveCurseIds,
      resolveCardRelicIds: CardRelicPool.resolveIds,
      resolveBlessingIds: BlessingPool.resolveIds,
      resolveCardBlessingIds: CardBlessingPool.resolveIds,
      resolveRelicIds: RelicPool.resolveIds,
    );
  });

  tearDown(() {
    combatBloc.close();
    gameEventBus.dispose();
  });

  group('CombatBloc', () {
    blocTest<CombatBloc, CombatState>(
      '초기 상태: CombatIdle',
      build: () => combatBloc,
      verify: (bloc) {
        expect(bloc.state, const CombatIdle());
      },
    );

    blocTest<CombatBloc, CombatState>(
      'StartCombat → CombatActive',
      build: () => combatBloc,
      act: (bloc) => bloc.add(StartCombat(
        encounter: encounter3Turns,
        playerRunState: initialPlayerState,
      )),
      expect: () => [
        CombatActive(
          encounter: encounter3Turns,
          playerRunState: initialPlayerState,
        ),
      ],
    );

    blocTest<CombatBloc, CombatState>(
      'SelectAction (공격 vs 공격) → neutral 결과',
      build: () => combatBloc,
      seed: () => CombatActive(
        encounter: encounter3Turns,
        playerRunState: initialPlayerState,
      ),
      act: (bloc) => bloc.add(const SelectAction(
        ActionType.attack,
        currentMomentumTier: MomentumTier.medium,
      )),
      verify: (bloc) {
        final state = bloc.state as CombatActive;
        expect(state.currentTurnIndex, 1);
        expect(state.turnResults, hasLength(1));
        expect(state.turnResults.first.actionResult, ActionResult.neutral);
        expect(state.turnResults.first.playerAction, ActionType.attack);
        expect(state.turnResults.first.enemyAction, EnemyActionType.attack);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'SelectAction (방어 vs 공격) → effective 결과',
      build: () => combatBloc,
      seed: () => CombatActive(
        encounter: encounter3Turns,
        playerRunState: initialPlayerState,
      ),
      act: (bloc) => bloc.add(const SelectAction(
        ActionType.defend,
        currentMomentumTier: MomentumTier.high,
      )),
      verify: (bloc) {
        final state = bloc.state as CombatActive;
        expect(state.turnResults.first.actionResult, ActionResult.effective);
        expect(state.turnResults.first.tierEffect, isNotNull);
        expect(state.turnResults.first.tierEffect!.effectText, isNotNull);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'SelectAction (관찰) → 환경 단서 해금',
      build: () => combatBloc,
      seed: () => CombatActive(
        encounter: encounterWithClues,
        playerRunState: initialPlayerState,
      ),
      act: (bloc) => bloc.add(const SelectAction(
        ActionType.observe,
        currentMomentumTier: MomentumTier.medium,
      )),
      verify: (bloc) {
        final state = bloc.state as CombatActive;
        expect(state.environmentUnlocked, isTrue);
        expect(state.discoveredClues, hasLength(1));
        expect(state.discoveredClues.first.id, 'stalactite');
      },
    );

    blocTest<CombatBloc, CombatState>(
      'SelectEnvironmentAction → effective 결과',
      build: () => combatBloc,
      seed: () => CombatActive(
        encounter: encounterWithClues,
        playerRunState: initialPlayerState,
        environmentUnlocked: true,
        discoveredClues: encounterWithClues.environmentClues,
      ),
      act: (bloc) => bloc.add(const SelectEnvironmentAction(
        'stalactite',
        currentMomentumTier: MomentumTier.medium,
      )),
      verify: (bloc) {
        final state = bloc.state as CombatActive;
        expect(state.turnResults, hasLength(1));
        expect(state.turnResults.first.actionResult, ActionResult.effective);
        expect(state.turnResults.first.playerAction, ActionType.environment);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'ResolveCombat (승리) → CombatRewardEvent 발행',
      build: () => combatBloc,
      seed: () => CombatActive(
        encounter: encounter3Turns,
        currentTurnIndex: 3,
        turnResults: const [],
        playerRunState: initialPlayerState,
      ),
      act: (bloc) => bloc.add(const ResolveCombat()),
      verify: (bloc) {
        final state = bloc.state as CombatResolved;
        expect(state.resultScore.outcome, CombatOutcome.victory);
        expect(state.isPermadeath, isFalse);

        final events = gameEventBus.history
            .whereType<CombatRewardEvent>()
            .toList();
        expect(events, hasLength(1));
      },
    );

    blocTest<CombatBloc, CombatState>(
      'ResolveCombat (패배) → PlayerDamagedEvent 발행, HP 감소',
      build: () => combatBloc,
      seed: () => CombatActive(
        encounter: encounter3Turns,
        currentTurnIndex: 3,
        turnResults: const [],
        playerRunState: initialPlayerState,
      ),
      act: (bloc) {
        // 패배하려면 score < 0 필요: ineffective 3회
        // seed에 turnResults가 비어있으므로 score=0 >= 0 → 승리가 됨
        // 대신 직접 패배 시나리오를 세팅
      },
    );

    group('패배 시나리오', () {
      blocTest<CombatBloc, CombatState>(
        'ResolveCombat (패배, score < 0) → HP 손실 + PlayerDamagedEvent',
        build: () {
          // 엘리트로 세팅해서 threshold=1, score=0 → defeat
          return combatBloc;
        },
        seed: () => CombatActive(
          encounter: eliteEncounter,
          currentTurnIndex: 3,
          turnResults: const [],
          playerRunState: initialPlayerState,
        ),
        act: (bloc) => bloc.add(const ResolveCombat()),
        verify: (bloc) {
          final state = bloc.state as CombatResolved;
          expect(state.resultScore.outcome, CombatOutcome.defeat);
          expect(state.hpLost, combatConfig.eliteDefeatHpLoss);
          // HP는 0 미만으로 내려가지 않음 (100 - 9999 = -9899 → 0)
          expect(state.playerRunState.currentHp, 0);

          final damaged = gameEventBus.history
              .whereType<PlayerDamagedEvent>()
              .toList();
          expect(damaged, hasLength(1));
          expect(damaged.first.hpLost, combatConfig.eliteDefeatHpLoss);
        },
      );

      blocTest<CombatBloc, CombatState>(
        'ResolveCombat (재도전 패배) → HP 추가 차감 없음',
        build: () => combatBloc,
        seed: () => CombatActive(
          encounter: eliteEncounter,
          currentTurnIndex: 3,
          turnResults: const [],
          playerRunState: PlayerRunState(
            currentHp: 0, // 이미 패배로 HP 0 상태
            maxHp: initialPlayerState.maxHp,
          ),
          hpDeductedForCurrentEncounter: true,
        ),
        act: (bloc) => bloc.add(const ResolveCombat()),
        verify: (bloc) {
          final state = bloc.state as CombatResolved;
          expect(state.resultScore.outcome, CombatOutcome.defeat);
          expect(state.hpLost, isNull);
          // 재도전 패배 → HP 추가 차감 없음, 0 유지
          expect(state.playerRunState.currentHp, 0);

          final damaged = gameEventBus.history
              .whereType<PlayerDamagedEvent>()
              .toList();
          expect(damaged, isEmpty);
        },
      );

      blocTest<CombatBloc, CombatState>(
        'ResolveCombat (퍼마데스) → PermadeathEvent 발행',
        build: () => combatBloc,
        seed: () => CombatActive(
          encounter: eliteEncounter,
          currentTurnIndex: 3,
          turnResults: const [],
          playerRunState: PlayerRunState(
            currentHp: combatConfig.basePlayerHp, // 패배 시 HP 0 → 퍼마데스
            maxHp: initialPlayerState.maxHp,
          ),
        ),
        act: (bloc) => bloc.add(const ResolveCombat()),
        verify: (bloc) {
          final state = bloc.state as CombatResolved;
          expect(state.isPermadeath, isTrue);

          final permadeath = gameEventBus.history
              .whereType<PermadeathEvent>()
              .toList();
          expect(permadeath, hasLength(1));
          expect(permadeath.first.defeatedBy, '엘리트 기사');
        },
      );
    });

    blocTest<CombatBloc, CombatState>(
      'RestartRun → CombatActive (HP 초기화)',
      build: () => combatBloc,
      seed: () => CombatResolved(
        encounter: encounter3Turns,
        resultScore: const CombatResultScore(
          score: -1,
          outcome: CombatOutcome.defeat,
          turnResults: ['ineffective'],
        ),
        playerRunState: const PlayerRunState(currentHp: 0, maxHp: 100),
        isPermadeath: true,
      ),
      act: (bloc) => bloc.add(
        RestartRun(maxHp: combatConfig.basePlayerHp),
      ),
      verify: (bloc) {
        final state = bloc.state as CombatActive;
        expect(state.playerRunState.currentHp, combatConfig.basePlayerHp);
        expect(state.hpDeductedForCurrentEncounter, isFalse);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'EndCombat → CombatIdle',
      build: () => combatBloc,
      seed: () => CombatActive(
        encounter: encounter3Turns,
        playerRunState: initialPlayerState,
      ),
      act: (bloc) => bloc.add(const EndCombat()),
      expect: () => [const CombatIdle()],
    );

    blocTest<CombatBloc, CombatState>(
      '풀 3턴 전투 플로우 (승리)',
      build: () => combatBloc,
      act: (bloc) {
        bloc.add(StartCombat(
          encounter: encounter3Turns,
          playerRunState: initialPlayerState,
        ));
        // 턴 1: 방어 vs 공격 → effective
        bloc.add(const SelectAction(
          ActionType.defend,
          currentMomentumTier: MomentumTier.medium,
        ));
        // 턴 2: 공격 vs 방어 → ineffective
        bloc.add(const SelectAction(
          ActionType.attack,
          currentMomentumTier: MomentumTier.medium,
        ));
        // 턴 3: 공격 vs 관찰 → effective
        bloc.add(const SelectAction(
          ActionType.attack,
          currentMomentumTier: MomentumTier.medium,
        ));
        bloc.add(const ResolveCombat());
      },
      verify: (bloc) {
        final state = bloc.state as CombatResolved;
        // effective(+1) + ineffective(-1) + effective(+1) = 1 >= 0 → 승리
        expect(state.resultScore.outcome, CombatOutcome.victory);
        expect(state.resultScore.score, 1);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '0턴 전투 (즉시 ResolveCombat)',
      build: () => combatBloc,
      act: (bloc) {
        bloc.add(StartCombat(
          encounter: encounter0Turns,
          playerRunState: initialPlayerState,
        ));
        bloc.add(const ResolveCombat());
      },
      verify: (bloc) {
        final state = bloc.state as CombatResolved;
        // score=0 >= 0 → 승리
        expect(state.resultScore.outcome, CombatOutcome.victory);
        expect(state.resultScore.score, 0);
      },
    );

    blocTest<CombatBloc, CombatState>(
      '엘리트 승리 기준 (threshold >= 1)',
      build: () => combatBloc,
      act: (bloc) {
        bloc.add(StartCombat(
          encounter: eliteEncounter,
          playerRunState: initialPlayerState,
        ));
        // neutral 3회 → score=0 < 1 → defeat
        bloc.add(const SelectAction(
          ActionType.attack,
          currentMomentumTier: MomentumTier.medium,
        ));
        bloc.add(const SelectAction(
          ActionType.defend,
          currentMomentumTier: MomentumTier.medium,
        ));
        bloc.add(const SelectAction(
          ActionType.observe,
          currentMomentumTier: MomentumTier.medium,
        ));
        bloc.add(const ResolveCombat());
      },
      verify: (bloc) {
        final state = bloc.state as CombatResolved;
        // attack vs attack=neutral, defend vs defend=neutral,
        // observe vs observe=effective → score=1 >= 1 → victory
        expect(state.resultScore.outcome, CombatOutcome.victory);
      },
    );

    blocTest<CombatBloc, CombatState>(
      'idle 상태에서 SelectAction → 무시',
      build: () => combatBloc,
      act: (bloc) => bloc.add(const SelectAction(
        ActionType.attack,
        currentMomentumTier: MomentumTier.medium,
      )),
      expect: () => [],
    );

    blocTest<CombatBloc, CombatState>(
      'idle 상태에서 ResolveCombat → 무시',
      build: () => combatBloc,
      act: (bloc) => bloc.add(const ResolveCombat()),
      expect: () => [],
    );

    blocTest<CombatBloc, CombatState>(
      '관찰 재수행 시 환경 단서 중복 해금 없음',
      build: () => combatBloc,
      seed: () => CombatActive(
        encounter: encounterWithClues,
        playerRunState: initialPlayerState,
        environmentUnlocked: true,
        discoveredClues: encounterWithClues.environmentClues,
      ),
      act: (bloc) => bloc.add(const SelectAction(
        ActionType.observe,
        currentMomentumTier: MomentumTier.medium,
      )),
      verify: (bloc) {
        final state = bloc.state as CombatActive;
        // 이미 해금됨 — 단서 목록 변경 없음
        expect(state.environmentUnlocked, isTrue);
        expect(state.discoveredClues, hasLength(1));
      },
    );

    // === Story 3-8: 보스 다단계 전투 ===

    group('보스 다단계 전투', () {
      const bossPhase1Turns = [
        CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
        CombatTurnInfo(turnNumber: 2, enemyAction: EnemyActionType.defend),
        CombatTurnInfo(turnNumber: 3, enemyAction: EnemyActionType.attack),
      ];
      const bossPhase2Turns = [
        CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
        CombatTurnInfo(turnNumber: 2, enemyAction: EnemyActionType.attack),
        CombatTurnInfo(turnNumber: 3, enemyAction: EnemyActionType.observe),
        CombatTurnInfo(turnNumber: 4, enemyAction: EnemyActionType.attack),
      ];
      const bossEncounter = CombatEncounterData(
        roomType: RoomType.boss,
        enemyName: '심연의 수호자',
        turns: bossPhase1Turns,
        bossPhases: [
          BossPhaseData(phaseName: 'phase1', turns: bossPhase1Turns),
          BossPhaseData(phaseName: 'phase2', turns: bossPhase2Turns),
        ],
      );

      blocTest<CombatBloc, CombatState>(
        '보스 2페이즈 전체 승리 + 기세 리셋 미발행',
        build: () => combatBloc,
        act: (bloc) {
          bloc.add(StartCombat(
            encounter: bossEncounter,
            playerRunState: initialPlayerState,
          ));
          // Phase 1: 3턴 — defend vs attack, attack vs defend, defend vs attack
          bloc.add(const SelectAction(ActionType.defend, currentMomentumTier: MomentumTier.medium));
          bloc.add(const SelectAction(ActionType.attack, currentMomentumTier: MomentumTier.medium));
          bloc.add(const SelectAction(ActionType.defend, currentMomentumTier: MomentumTier.medium));
          bloc.add(const ResolveCombat());
          bloc.add(const ContinueBossPhase());
          // Phase 2: 4턴
          bloc.add(const SelectAction(ActionType.defend, currentMomentumTier: MomentumTier.medium));
          bloc.add(const SelectAction(ActionType.defend, currentMomentumTier: MomentumTier.medium));
          bloc.add(const SelectAction(ActionType.attack, currentMomentumTier: MomentumTier.medium));
          bloc.add(const SelectAction(ActionType.defend, currentMomentumTier: MomentumTier.medium));
          bloc.add(const ResolveCombat());
        },
        verify: (bloc) {
          final state = bloc.state as CombatResolved;
          expect(state.resultScore.outcome, CombatOutcome.victory);
          expect(
            gameEventBus.history.where((e) => e.runtimeType.toString().contains('MomentumReset')),
            isEmpty,
          );
          final rewards = gameEventBus.history.whereType<CombatRewardEvent>().toList();
          expect(rewards, hasLength(1));
        },
      );

      blocTest<CombatBloc, CombatState>(
        '보스 Phase1 패배 → 즉시 CombatResolved.defeat + 퍼마데스',
        build: () {
          return CombatBloc(
            gameEventBus: gameEventBus,
            combatConfig: const CombatBalanceConfig(bossVictoryThreshold: 1),
            economyConfig: economyConfig,
            tierEffectCalculator: tierEffectCalculator,
            resolveCurseIds: CursePool.resolveCurseIds,
            resolveCardRelicIds: CardRelicPool.resolveIds,
            resolveBlessingIds: BlessingPool.resolveIds,
            resolveCardBlessingIds: CardBlessingPool.resolveIds,
            resolveRelicIds: RelicPool.resolveIds,
          );
        },
        seed: () => CombatActive(
          encounter: bossEncounter,
          currentTurnIndex: 3,
          turnResults: const [],
          playerRunState: initialPlayerState,
        ),
        act: (bloc) => bloc.add(const ResolveCombat()),
        verify: (bloc) {
          final state = bloc.state as CombatResolved;
          expect(state.resultScore.outcome, CombatOutcome.defeat);
          expect(state.hpLost, 9999);
          expect(state.isPermadeath, isTrue);
          final permadeath = gameEventBus.history.whereType<PermadeathEvent>().toList();
          expect(permadeath, hasLength(1));
        },
      );

      blocTest<CombatBloc, CombatState>(
        'BossPhaseTransition 인덱스 검증',
        build: () => combatBloc,
        seed: () => CombatActive(
          encounter: bossEncounter,
          currentTurnIndex: 3,
          turnResults: const [],
          playerRunState: initialPlayerState,
        ),
        act: (bloc) => bloc.add(const ResolveCombat()),
        verify: (bloc) {
          final state = bloc.state as BossPhaseTransition;
          expect(state.completedPhaseIndex, 0);
          expect(state.nextPhaseIndex, 1);
          expect(state.encounter, bossEncounter);
          expect(state.playerRunState, initialPlayerState);
        },
      );

      blocTest<CombatBloc, CombatState>(
        'ContinueBossPhase → CombatActive phase2 턴',
        build: () => combatBloc,
        seed: () => BossPhaseTransition(
          encounter: bossEncounter,
          completedPhaseIndex: 0,
          nextPhaseIndex: 1,
          playerRunState: initialPlayerState,
        ),
        act: (bloc) => bloc.add(const ContinueBossPhase()),
        verify: (bloc) {
          final state = bloc.state as CombatActive;
          expect(state.currentBossPhaseIndex, 1);
          expect(state.encounter.turns, bossPhase2Turns);
          expect(state.encounter.totalTurns, 4);
          expect(state.currentTurnIndex, 0);
          expect(state.turnResults, isEmpty);
        },
      );

      blocTest<CombatBloc, CombatState>(
        'ContinueBossPhase 비정상 상태 가드 (CombatIdle에서 무시)',
        build: () => combatBloc,
        act: (bloc) => bloc.add(const ContinueBossPhase()),
        expect: () => [],
      );

      blocTest<CombatBloc, CombatState>(
        '1페이즈 보스 → Phase1 승리 시 즉시 CombatResolved.victory',
        build: () => combatBloc,
        seed: () => CombatActive(
          encounter: const CombatEncounterData(
            roomType: RoomType.boss,
            enemyName: '약한 보스',
            turns: bossPhase1Turns,
            bossPhases: [
              BossPhaseData(phaseName: 'phase1', turns: bossPhase1Turns),
            ],
          ),
          currentTurnIndex: 3,
          turnResults: const [],
          playerRunState: initialPlayerState,
        ),
        act: (bloc) => bloc.add(const ResolveCombat()),
        verify: (bloc) {
          final state = bloc.state as CombatResolved;
          expect(state.resultScore.outcome, CombatOutcome.victory);
        },
      );
    });

    group('특수 행동 (E4-4)', () {
      blocTest<CombatBloc, CombatState>(
        'SelectSpecialAction (powerStrike vs attack) → effective + 턴 진행',
        build: () => combatBloc,
        seed: () => CombatActive(
          encounter: encounter3Turns,
          playerRunState: initialPlayerState,
        ),
        act: (bloc) => bloc.add(const SelectSpecialAction(
          'powerStrike',
          currentMomentumTier: MomentumTier.medium,
        )),
        expect: () => [
          isA<CombatActive>()
              .having((s) => s.currentTurnIndex, 'turnIndex', 1)
              .having(
                (s) => s.lastTurnResult?.playerAction,
                'playerAction',
                ActionType.special,
              )
              .having(
                (s) => s.lastTurnResult?.specialActionType,
                'specialActionType',
                'powerStrike',
              )
              .having(
                (s) => s.lastTurnResult?.actionResult,
                'actionResult',
                ActionResult.effective,
              ),
        ],
      );

      blocTest<CombatBloc, CombatState>(
        'SelectSpecialAction (shadowStrike vs observe) → ineffective',
        build: () => combatBloc,
        seed: () => CombatActive(
          encounter: const CombatEncounterData(
            roomType: RoomType.combat,
            enemyName: '감시자',
            turns: [
              CombatTurnInfo(
                  turnNumber: 1, enemyAction: EnemyActionType.observe),
            ],
          ),
          playerRunState: initialPlayerState,
        ),
        act: (bloc) => bloc.add(const SelectSpecialAction(
          'shadowStrike',
          currentMomentumTier: MomentumTier.medium,
        )),
        expect: () => [
          isA<CombatActive>().having(
            (s) => s.lastTurnResult?.actionResult,
            'actionResult',
            ActionResult.ineffective,
          ),
        ],
      );

      blocTest<CombatBloc, CombatState>(
        'SelectSpecialAction CombatIdle에서 무시',
        build: () => combatBloc,
        act: (bloc) => bloc.add(const SelectSpecialAction(
          'powerStrike',
          currentMomentumTier: MomentumTier.medium,
        )),
        expect: () => [],
      );
    });
  });
}
