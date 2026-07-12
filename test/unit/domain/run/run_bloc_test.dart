import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/run_completed_event.dart';
import 'package:soul_dungeon/domain/run/run_bloc.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/domain/run/run_state.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  late RunBloc runBloc;
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
    runBloc = RunBloc(gameEventBus: eventBus);
  });

  tearDown(() {
    runBloc.close();
    eventBus.dispose();
  });

  group('RunBloc', () {
    test('initial state is RunInitial when no initialPlayerState', () {
      expect(runBloc.state, isA<RunInitial>());
    });

    test('initial state is RunActive when initialPlayerState provided', () {
      final bloc = RunBloc(
        initialPlayerState: PlayerRunState.initial(maxHp: 80),
        gameEventBus: eventBus,
      );
      addTearDown(bloc.close);
      expect(bloc.state, isA<RunActive>());
      expect(
        (bloc.state as RunActive).playerRunState,
        PlayerRunState.initial(maxHp: 80),
      );
    });

    group('InitializeRun', () {
      blocTest<RunBloc, RunState>(
        'emits RunActive with initial PlayerRunState',
        build: () => RunBloc(gameEventBus: eventBus),
        act: (bloc) => bloc.add(const InitializeRun(maxHp: 100)),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100),
          ),
        ],
      );
    });

    group('GainGold', () {
      blocTest<RunBloc, RunState>(
        'adds gold to current amount',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(const GainGold(25)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(gold: 25),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'accumulates gold across multiple events',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState:
              PlayerRunState.initial(maxHp: 100).copyWith(gold: 10),
        ),
        act: (bloc) => bloc.add(const GainGold(15)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(gold: 25),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'ignores when state is RunInitial',
        build: () => RunBloc(gameEventBus: eventBus),
        act: (bloc) => bloc.add(const GainGold(10)),
        expect: () => <RunState>[],
      );
    });

    group('SetGold', () {
      blocTest<RunBloc, RunState>(
        'sets gold to exact amount',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState:
              PlayerRunState.initial(maxHp: 100).copyWith(gold: 50),
        ),
        act: (bloc) => bloc.add(const SetGold(30)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(gold: 30),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'can set gold to zero',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState:
              PlayerRunState.initial(maxHp: 100).copyWith(gold: 50),
        ),
        act: (bloc) => bloc.add(const SetGold(0)),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100),
          ),
        ],
      );
    });

    group('ChangeHp', () {
      blocTest<RunBloc, RunState>(
        'reduces HP by damage amount',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(const ChangeHp(-30)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 70),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'increases HP by heal amount',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState:
              PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 60),
        ),
        act: (bloc) => bloc.add(const ChangeHp(20)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 80),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'clamps HP to 0 minimum',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState:
              PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 10),
        ),
        act: (bloc) => bloc.add(const ChangeHp(-50)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 0),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'clamps HP to maxHp maximum',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState:
              PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 90),
        ),
        act: (bloc) => bloc.add(const ChangeHp(50)),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100),
          ),
        ],
      );
    });

    group('ChangeMaxHp', () {
      blocTest<RunBloc, RunState>(
        'increases maxHp',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(const ChangeMaxHp(10)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(maxHp: 110),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'decreases maxHp and clamps currentHp',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(const ChangeMaxHp(-20)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 80, maxHp: 80),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'decreases maxHp without clamping when currentHp already below',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState:
              PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 50),
        ),
        act: (bloc) => bloc.add(const ChangeMaxHp(-20)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 100).copyWith(currentHp: 50, maxHp: 80),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'clamps maxHp to minimum 1 and currentHp accordingly',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 5),
        ),
        act: (bloc) => bloc.add(const ChangeMaxHp(-10)),
        expect: () => [
          RunActive(
            playerRunState:
                PlayerRunState.initial(maxHp: 5).copyWith(currentHp: 1, maxHp: 1),
          ),
        ],
      );
    });

    group('SyncFromCombat', () {
      blocTest<RunBloc, RunState>(
        'syncs HP from combat but preserves current gold',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(currentHp: 80, gold: 50),
        ),
        act: (bloc) => bloc.add(
          SyncFromCombat(
            PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 60, gold: 10),
          ),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 60, gold: 50),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'preserves gold from current state',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(currentHp: 80, gold: 50),
        ),
        act: (bloc) => bloc.add(
          SyncFromCombat(
            PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 60, gold: 10),
          ),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 60, gold: 50),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'preserves gold even when combat gold is zero',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(currentHp: 100, gold: 75),
        ),
        act: (bloc) => bloc.add(
          SyncFromCombat(
            PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 40, gold: 0),
          ),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 40, gold: 75),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'preserves currentJobId from RunBloc state',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(currentHp: 80, currentJobId: 'sage'),
        ),
        act: (bloc) => bloc.add(
          SyncFromCombat(
            PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 60),
          ),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 60, currentJobId: 'sage'),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'syncs masterDeck from combat (card reward)',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(
            maxHp: 100,
            masterDeck: const [
              CardData(
                id: 'strike', name: 'Strike',
                type: CardType.attack, apCost: 1,
                damage: 6, description: 'Deal 6 damage.',
              ),
            ],
          ).copyWith(currentHp: 80, gold: 50),
        ),
        act: (bloc) => bloc.add(
          SyncFromCombat(
            PlayerRunState.initial(
              maxHp: 100,
              masterDeck: const [
                CardData(
                  id: 'strike', name: 'Strike',
                  type: CardType.attack, apCost: 1,
                  damage: 6, description: 'Deal 6 damage.',
                ),
                CardData(
                  id: 'fireball', name: 'Fireball',
                  type: CardType.attack, apCost: 2,
                  damage: 12, description: 'Deal 12 damage.',
                ),
              ],
            ).copyWith(currentHp: 60, gold: 0),
          ),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(
              maxHp: 100,
              masterDeck: const [
                CardData(
                  id: 'strike', name: 'Strike',
                  type: CardType.attack, apCost: 1,
                  damage: 6, description: 'Deal 6 damage.',
                ),
                CardData(
                  id: 'fireball', name: 'Fireball',
                  type: CardType.attack, apCost: 2,
                  damage: 12, description: 'Deal 12 damage.',
                ),
              ],
            ).copyWith(currentHp: 60, gold: 50),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'syncs removedCardIds from combat',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(currentHp: 80, gold: 30),
        ),
        act: (bloc) => bloc.add(
          SyncFromCombat(
            PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 60, removedCardIds: {'strike'}),
          ),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100)
                .copyWith(currentHp: 60, gold: 30, removedCardIds: {'strike'}),
          ),
        ],
      );
    });

    group('SetPlayerRunState', () {
      blocTest<RunBloc, RunState>(
        'directly sets full PlayerRunState',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(
          SetPlayerRunState(
            PlayerRunState.initial(maxHp: 80)
                .copyWith(currentHp: 50, gold: 30),
          ),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 80)
                .copyWith(currentHp: 50, gold: 30),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'works from RunInitial state',
        build: () => RunBloc(gameEventBus: eventBus),
        act: (bloc) => bloc.add(
          SetPlayerRunState(PlayerRunState.initial(maxHp: 100)),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100),
          ),
        ],
      );
    });

    group('ResetRun', () {
      blocTest<RunBloc, RunState>(
        'resets to initial PlayerRunState with given maxHp',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(currentHp: 30, gold: 200),
        ),
        act: (bloc) => bloc.add(const ResetRun(maxHp: 100)),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'can reset with different maxHp',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(const ResetRun(maxHp: 120)),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 120),
          ),
        ],
      );
    });


    group('ApplyCurse', () {
      blocTest<RunBloc, RunState>(
        'ApplyCurse adds curseId to activeCurseIds',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(const ApplyCurse('curse_001')),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100)
                .copyWith(activeCurseIds: ['curse_001']),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'ApplyCurse 중복 저주 허용 (같은 저주 여러 번)',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(activeCurseIds: ['curse_001']),
        ),
        act: (bloc) => bloc.add(const ApplyCurse('curse_002')),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100)
                .copyWith(activeCurseIds: ['curse_001', 'curse_002']),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'SyncFromCombat preserves activeCurseIds',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(
                gold: 50,
                activeCurseIds: ['curse_001'],
                ownedBlessingIds: ['blessing_001'],
              ),
        ),
        act: (bloc) => bloc.add(SyncFromCombat(
          PlayerRunState(currentHp: 80, maxHp: 100, gold: 30),
        )),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState(
              currentHp: 80,
              maxHp: 100,
              gold: 50,
              ownedBlessingIds: const ['blessing_001'],
              activeCurseIds: const ['curse_001'],
            ),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'ResetRun clears activeCurseIds',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100)
              .copyWith(activeCurseIds: ['curse_001', 'curse_002']),
        ),
        act: (bloc) => bloc.add(const ResetRun(maxHp: 100)),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100),
          ),
        ],
      );
    });

    // === E5-3: AdvanceFloor ===

    group('AdvanceFloor', () {

      blocTest<RunBloc, RunState>(
        '1→2층 진행 — currentFloor++, completedFloors 기록',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(const AdvanceFloor()),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
              currentFloor: 2,
              completedFloors: {1},
            ),
          ),
        ],
        verify: (_) {
          final floorEvents = eventBus.history
              .whereType<FloorCompletedEvent>()
              .toList();
          expect(floorEvents.length, 1);
          expect(floorEvents.first.floorNumber, 1);
        },
      );

      blocTest<RunBloc, RunState>(
        '연속 진행 1→2→3',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) {
          bloc.add(const AdvanceFloor());
          bloc.add(const AdvanceFloor());
        },
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
              currentFloor: 2,
              completedFloors: {1},
            ),
          ),
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
              currentFloor: 3,
              completedFloors: {1, 2},
            ),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        '10층(최종) AdvanceFloor → RunCompletedEvent 발행, floor 유지',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
            currentFloor: 10,
            completedFloors: {1, 2, 3, 4, 5, 6, 7, 8, 9},
          ),
        ),
        act: (bloc) => bloc.add(const AdvanceFloor()),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
              currentFloor: 10,
              completedFloors: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
            ),
          ),
        ],
        verify: (_) {
          final runEvents = eventBus.history
              .whereType<RunCompletedEvent>()
              .toList();
          expect(runEvents.length, 1);
          expect(runEvents.first.totalFloors, 10);

          final floorEvents = eventBus.history
              .whereType<FloorCompletedEvent>()
              .toList();
          expect(floorEvents.length, 1);
          expect(floorEvents.first.floorNumber, 10);
        },
      );

      blocTest<RunBloc, RunState>(
        'maxFloor=3일 때 3층에서 완료',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
            currentFloor: 3,
            completedFloors: {1, 2},
          ),
        ),
        act: (bloc) => bloc.add(const AdvanceFloor(maxFloor: 3)),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
              currentFloor: 3,
              completedFloors: {1, 2, 3},
            ),
          ),
        ],
        verify: (_) {
          final runEvents = eventBus.history
              .whereType<RunCompletedEvent>()
              .toList();
          expect(runEvents.length, 1);
          expect(runEvents.first.totalFloors, 3);
        },
      );

      blocTest<RunBloc, RunState>(
        'RunInitial → AdvanceFloor 무시',
        build: () => RunBloc(gameEventBus: eventBus),
        act: (bloc) => bloc.add(const AdvanceFloor()),
        expect: () => <RunState>[],
      );

      blocTest<RunBloc, RunState>(
        'gameEventBus 미전달 시에도 상태 변경 정상 동작',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(const AdvanceFloor()),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
              currentFloor: 2,
              completedFloors: {1},
            ),
          ),
        ],
      );

      test('HP/gold 보존 확인', () async {
        final bloc = RunBloc(
          initialPlayerState: PlayerRunState.initial(maxHp: 100).copyWith(
            currentHp: 60,
            gold: 200,
          ),
          gameEventBus: eventBus,
        );
        addTearDown(bloc.close);

        bloc.add(const AdvanceFloor());
        await bloc.stream.first;

        final prs = (bloc.state as RunActive).playerRunState;
        expect(prs.currentFloor, 2);
        expect(prs.currentHp, 60);
        expect(prs.gold, 200);
      });
    });

    // === E5-3: RecordBossChoice ===

    group('RecordBossChoice', () {
      blocTest<RunBloc, RunState>(
        '보스 선택 기록',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100),
        ),
        act: (bloc) => bloc.add(
          const RecordBossChoice(BossChoice(
            floor: 1,
            bossId: 'boss_fire',
            choiceType: BossChoiceType.slay,
          )),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
              bossChoices: [
                const BossChoice(
                  floor: 1,
                  bossId: 'boss_fire',
                  choiceType: BossChoiceType.slay,
                ),
              ],
            ),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        '연속 보스 선택 누적',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
            bossChoices: [
              const BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay),
            ],
          ),
        ),
        act: (bloc) => bloc.add(
          const RecordBossChoice(BossChoice(
            floor: 2,
            bossId: 'boss_water',
            choiceType: BossChoiceType.liberate,
          )),
        ),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
              bossChoices: [
                const BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay),
                const BossChoice(floor: 2, bossId: 'boss_water', choiceType: BossChoiceType.liberate),
              ],
            ),
          ),
        ],
      );

      blocTest<RunBloc, RunState>(
        'RunInitial → RecordBossChoice 무시',
        build: () => RunBloc(gameEventBus: eventBus),
        act: (bloc) => bloc.add(
          const RecordBossChoice(BossChoice(
            floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay,
          )),
        ),
        expect: () => <RunState>[],
      );

      blocTest<RunBloc, RunState>(
        'ResetRun → bossChoices 초기화',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
            bossChoices: [
              const BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay),
            ],
            currentFloor: 2,
            completedFloors: {1},
          ),
        ),
        act: (bloc) => bloc.add(const ResetRun(maxHp: 100)),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState.initial(maxHp: 100),
          ),
        ],
      );
    });

    // === E5-3: SyncFromCombat — floor 필드 보존 ===

    group('SyncFromCombat (floor fields preservation)', () {
      blocTest<RunBloc, RunState>(
        'SyncFromCombat preserves currentFloor/bossChoices/completedFloors',
        build: () => RunBloc(gameEventBus: eventBus),
        seed: () => RunActive(
          playerRunState: PlayerRunState.initial(maxHp: 100).copyWith(
            currentHp: 80,
            gold: 50,
            currentFloor: 3,
            bossChoices: [
              const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
              const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
            ],
            completedFloors: {1, 2},
          ),
        ),
        act: (bloc) => bloc.add(SyncFromCombat(
          PlayerRunState(currentHp: 60, maxHp: 100, gold: 30),
        )),
        expect: () => [
          RunActive(
            playerRunState: PlayerRunState(
              currentHp: 60,
              maxHp: 100,
              gold: 50,
              currentFloor: 3,
              bossChoices: const [
                BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
                BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
              ],
              completedFloors: const {1, 2},
            ),
          ),
        ],
      );
    });
  });
}
