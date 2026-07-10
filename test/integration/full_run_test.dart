import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_manager.dart';
import 'package:soul_dungeon/core/save/save_storage.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/domain/ending/ending.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_bloc.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_state.dart';
import 'package:soul_dungeon/domain/run/run_bloc.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/domain/run/run_state.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  group('Full Run Integration', () {
    late GameEventBus eventBus;
    late SaveManager saveManager;
    late InMemorySaveStorage storage;

    setUp(() {
      eventBus = GameEventBus();
      storage = InMemorySaveStorage();
      saveManager = SaveManager(storage);
    });

    tearDown(() {
      eventBus.dispose();
    });

    test('5층 완주 → 메타 기록 + 엔딩 저장', () async {
      // 1. 런 상태 생성 — 5보스 처치 선택
      final choices = List.generate(
        5,
        (i) => BossChoice(
          floor: i + 1,
          bossId: 'boss_${i + 1}',
          choiceType: BossChoiceType.slay,
        ),
      );

      // 2. EndingResolver 검증
      final ending = EndingResolver.resolve(choices);
      expect(ending, EndingType.slay);

      // 3. 메타 데이터 업데이트 (GameScreen._recordRunCompleted 시뮬레이션)
      final meta = MetaSaveData(
        totalRuns: 1,
        endingsReached: {ending.name},
      );
      await saveManager.saveMeta(meta);

      // 4. 메타 로드 → 기록 확인
      final loaded = await saveManager.loadMeta();
      expect(loaded, isA<Success<MetaSaveData>>());
      final loadedMeta = (loaded as Success<MetaSaveData>).data;
      expect(loadedMeta.totalRuns, 1);
      expect(loadedMeta.endingsReached, contains('slay'));
    });

    test('퍼마데스 → 사망 기록 + 런 세이브 삭제', () async {
      // 1. 런 세이브 생성
      final runData = RunSaveData(
        playerRunState: PlayerRunState(
          currentHp: 0,
          maxHp: 100,
          gold: 50,
          disposition: {for (final a in DispositionAxis.values) a: 0},
        ),
        savedAt: DateTime.now(),
      );
      await saveManager.saveRun(runData);
      expect(await saveManager.hasRunSave(), isTrue);

      // 2. 퍼마데스 기록 (GameScreen._recordPermadeath 시뮬레이션)
      final meta = const MetaSaveData(totalRuns: 1, deathCount: 1);
      await saveManager.saveMeta(meta);

      // 3. 런 삭제 (GameScreen._handleRestartRun 시뮬레이션)
      await saveManager.deleteRun();

      // 4. 검증
      expect(await saveManager.hasRunSave(), isFalse);
      final loadedMeta = await saveManager.loadMeta();
      expect(loadedMeta, isA<Success<MetaSaveData>>());
      final m = (loadedMeta as Success<MetaSaveData>).data;
      expect(m.deathCount, 1);
      expect(m.totalRuns, 1);
    });

    test('세이브/로드 왕복 — PlayerRunState 보존', () async {
      final state = PlayerRunState(
        currentHp: 75,
        maxHp: 100,
        gold: 150,
        currentFloor: 3,
        bossChoices: [
          const BossChoice(
            floor: 1,
            bossId: 'boss_1',
            choiceType: BossChoiceType.slay,
          ),
          const BossChoice(
            floor: 2,
            bossId: 'boss_2',
            choiceType: BossChoiceType.liberate,
          ),
        ],
        disposition: {
          DispositionAxis.struggle: 3,
          DispositionAxis.mercy: 3,
          DispositionAxis.harmony: 0,
        },
      );

      await saveManager.saveRun(RunSaveData(
        playerRunState: state,
        savedAt: DateTime.now(),
      ));

      final loaded = await saveManager.loadRun();
      expect(loaded, isA<Success<RunSaveData>>());
      final loadedState = (loaded as Success<RunSaveData>).data.playerRunState;
      expect(loadedState.currentHp, 75);
      expect(loadedState.maxHp, 100);
      expect(loadedState.gold, 150);
      expect(loadedState.currentFloor, 3);
      expect(loadedState.bossChoices.length, 2);
      expect(loadedState.bossChoices[0].choiceType, BossChoiceType.slay);
      expect(loadedState.bossChoices[1].choiceType, BossChoiceType.liberate);
      expect(loadedState.disposition[DispositionAxis.struggle], 3);
    });

    test('DungeonGenerator — 5층 생성 가능', () {
      final generator = DungeonGenerator(
        config: const DungeonBalanceConfig(),
        floorsConfig: const BalanceConfig().floors,
        gameEventBus: eventBus,
      );

      for (var floor = 1; floor <= 5; floor++) {
        final result = generator.generateFloor(floor, 42 + floor);
        expect(result, isA<Success>(),
            reason: 'Floor $floor generation should succeed');
      }
    });

    test('RunBloc — 5층 진행 후 완료', () async {
      final runBloc = RunBloc(
        gameEventBus: eventBus,
        initialPlayerState: PlayerRunState.initial(maxHp: 100),
      );

      // floor 1 → 4 진행
      for (var i = 0; i < 4; i++) {
        runBloc.add(const AdvanceFloor());
        await runBloc.stream.first;
      }

      final activeState = runBloc.state as RunActive;
      expect(activeState.playerRunState.currentFloor, 5);

      // floor 5 진행 → 런 완료 (currentFloor 유지, RunCompletedEvent 발행)
      runBloc.add(const AdvanceFloor());
      await runBloc.stream.first;
      final finalState = runBloc.state as RunActive;
      expect(finalState.playerRunState.completedFloors, contains(5));

      await runBloc.close();
    });

    test('NarratorBloc — 층별 신뢰도 변화', () async {
      final narrator = NarratorBloc(gameEventBus: eventBus);

      // floor 2-4: RunBloc이 nextFloor를 emit하므로 2,3,4
      for (var f = 2; f <= 4; f++) {
        eventBus.emit(FloorCompletedEvent(floorNumber: f));
        await narrator.stream.first;
      }
      // floor 4 도달 → narrator floor 4
      expect(narrator.state.currentFloor, 4);
      expect(narrator.state, isA<NarratorDistorted>());

      // floor 5 도달 → narrator floor 5
      eventBus.emit(FloorCompletedEvent(floorNumber: 5));
      await narrator.stream.first;
      expect(narrator.state.currentFloor, 5);
      expect((narrator.state as NarratorDistorted).silent, isTrue);

      await narrator.close();
    });

    test('4가지 엔딩 도달 가능', () {
      // slay: 전원 처치
      final slayChoices = List.generate(
        5,
        (i) => BossChoice(
          floor: i + 1,
          bossId: 'boss_${i + 1}',
          choiceType: BossChoiceType.slay,
        ),
      );
      expect(EndingResolver.resolve(slayChoices), EndingType.slay);

      // liberate: 전원 해방
      final liberateChoices = List.generate(
        5,
        (i) => BossChoice(
          floor: i + 1,
          bossId: 'boss_${i + 1}',
          choiceType: BossChoiceType.liberate,
        ),
      );
      expect(EndingResolver.resolve(liberateChoices), EndingType.liberate);

      // coexist: 전원 공존
      final coexistChoices = List.generate(
        5,
        (i) => BossChoice(
          floor: i + 1,
          bossId: 'boss_${i + 1}',
          choiceType: BossChoiceType.coexist,
        ),
      );
      expect(EndingResolver.resolve(coexistChoices), EndingType.coexist);

      // hidden: 2+2+1 (maxCount ≤ 2)
      final hiddenChoices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.coexist),
      ];
      expect(EndingResolver.resolve(hiddenChoices), EndingType.hidden);
    });

    test('메타 데이터 누적 — 여러 런', () async {
      // 첫 런: slay 엔딩
      var meta = const MetaSaveData(
        totalRuns: 1,
        endingsReached: {'slay'},
      );
      await saveManager.saveMeta(meta);

      // 둘째 런: 퍼마데스
      meta = MetaSaveData(
        totalRuns: meta.totalRuns + 1,
        deathCount: 1,
        endingsReached: meta.endingsReached,
      );
      await saveManager.saveMeta(meta);

      // 셋째 런: liberate 엔딩
      meta = MetaSaveData(
        totalRuns: meta.totalRuns + 1,
        deathCount: meta.deathCount,
        endingsReached: {...meta.endingsReached, 'liberate'},
      );
      await saveManager.saveMeta(meta);

      // 검증
      final loaded = await saveManager.loadMeta();
      final m = (loaded as Success<MetaSaveData>).data;
      expect(m.totalRuns, 3);
      expect(m.deathCount, 1);
      expect(m.endingsReached, containsAll(['slay', 'liberate']));
    });

    test('DungeonGenerator — 첫 런 후 isFirstRun false', () {
      final generator = DungeonGenerator(
        config: const DungeonBalanceConfig(),
        gameEventBus: eventBus,
      );

      expect(generator.isFirstRun, isTrue);

      // 첫 런 → markFirstRunDone (GameScreen._handleRestartRun 시뮬레이션)
      generator.markFirstRunDone();
      expect(generator.isFirstRun, isFalse);
    });
  });
}
