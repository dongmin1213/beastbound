import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_serializer.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  group('SaveSerializer — Run', () {
    late PlayerRunState fullState;
    late RunSaveData runData;

    setUp(() {
      fullState = PlayerRunState(
        currentHp: 75,
        maxHp: 100,
        gold: 250,
        disposition: {
          DispositionAxis.struggle: 5,
          DispositionAxis.mercy: 3,
          DispositionAxis.wisdom: 0,
          DispositionAxis.shadow: -2,
          DispositionAxis.will: 1,
          DispositionAxis.harmony: 4,
        },
        currentJobId: 'warrior',
        ownedBlessingIds: ['bless_1', 'bless_2'],
        ownedRelicIds: ['relic_alpha'],
        activeCurseIds: ['curse_x'],
        currentFloor: 3,
        bossChoices: [
          const BossChoice(
            floor: 1,
            bossId: 'boss_ash',
            choiceType: BossChoiceType.slay,
          ),
          const BossChoice(
            floor: 2,
            bossId: 'boss_void',
            choiceType: BossChoiceType.liberate,
          ),
        ],
        completedFloors: {1, 2},
      );
      runData = RunSaveData(
        playerRunState: fullState,
        savedAt: DateTime(2026, 2, 17, 12, 0),
      );
    });

    test('round-trip — 전체 필드 보존', () {
      final json = SaveSerializer.serializeRun(runData);
      final result = SaveSerializer.deserializeRun(json);

      expect(result, isA<Success<RunSaveData>>());
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState, fullState);
      expect(loaded.schemaVersion, 1);
      expect(loaded.savedAt, DateTime(2026, 2, 17, 12, 0));
    });

    test('round-trip — 초기 상태 (기본값)', () {
      final initial = PlayerRunState.initial(maxHp: 50);
      final data = RunSaveData(
        playerRunState: initial,
        savedAt: DateTime(2026, 1, 1),
      );

      final json = SaveSerializer.serializeRun(data);
      final result = SaveSerializer.deserializeRun(json);

      expect(result, isA<Success<RunSaveData>>());
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState.currentHp, 50);
      expect(loaded.playerRunState.maxHp, 50);
      expect(loaded.playerRunState.gold, 0);
      expect(loaded.playerRunState.currentFloor, 1);
      expect(loaded.playerRunState.bossChoices, isEmpty);
      expect(loaded.playerRunState.completedFloors, isEmpty);
    });

    test('round-trip — disposition 모든 축', () {
      final json = SaveSerializer.serializeRun(runData);
      final loaded =
          (SaveSerializer.deserializeRun(json) as Success<RunSaveData>).data;
      for (final axis in DispositionAxis.values) {
        expect(
          loaded.playerRunState.disposition[axis],
          fullState.disposition[axis],
        );
      }
    });

    test('round-trip — bossChoices 순서 보존', () {
      final json = SaveSerializer.serializeRun(runData);
      final loaded =
          (SaveSerializer.deserializeRun(json) as Success<RunSaveData>).data;
      expect(loaded.playerRunState.bossChoices.length, 2);
      expect(
        loaded.playerRunState.bossChoices[0].choiceType,
        BossChoiceType.slay,
      );
      expect(
        loaded.playerRunState.bossChoices[1].choiceType,
        BossChoiceType.liberate,
      );
    });

    test('round-trip — completedFloors Set 보존', () {
      final json = SaveSerializer.serializeRun(runData);
      final loaded =
          (SaveSerializer.deserializeRun(json) as Success<RunSaveData>).data;
      expect(loaded.playerRunState.completedFloors, {1, 2});
    });

    test('round-trip — currentJobId null', () {
      final noJob = fullState.copyWith(currentJobId: null);
      final data = RunSaveData(
        playerRunState: noJob,
        savedAt: DateTime(2026, 1, 1),
      );
      final json = SaveSerializer.serializeRun(data);
      final loaded =
          (SaveSerializer.deserializeRun(json) as Success<RunSaveData>).data;
      expect(loaded.playerRunState.currentJobId, isNull);
    });

    test('deserialize — 잘못된 JSON → Failure', () {
      final result = SaveSerializer.deserializeRun('not json');
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('deserialize — 빈 객체 → Failure (maxHp null)', () {
      final result = SaveSerializer.deserializeRun('{}');
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('round-trip — cardCombatStateRaw 포함', () {
      final data = RunSaveData(
        playerRunState: fullState,
        savedAt: DateTime(2026, 3, 1),
        cardCombatStateRaw: {
          'playerHp': 60,
          'enemies': [{'id': 'slime'}],
        },
      );
      final json = SaveSerializer.serializeRun(data);
      final loaded =
          (SaveSerializer.deserializeRun(json) as Success<RunSaveData>).data;
      expect(loaded.cardCombatStateRaw, isNotNull);
      expect(loaded.cardCombatStateRaw!['playerHp'], 60);
    });

    test('round-trip — cardCombatStateRaw null (비전투)', () {
      final data = RunSaveData(
        playerRunState: fullState,
        savedAt: DateTime(2026, 3, 1),
      );
      final json = SaveSerializer.serializeRun(data);
      final loaded =
          (SaveSerializer.deserializeRun(json) as Success<RunSaveData>).data;
      expect(loaded.cardCombatStateRaw, isNull);
    });

    test('하위 호환 — 기존 세이브에 cardCombatStateRaw 없음', () {
      final json =
          '{"schemaVersion":1,"savedAt":"2026-01-01T00:00:00.000",'
          '"playerRunState":{"currentHp":10,"maxHp":20}}';
      final loaded =
          (SaveSerializer.deserializeRun(json) as Success<RunSaveData>).data;
      expect(loaded.cardCombatStateRaw, isNull);
    });

    test('deserialize — 누락 필드 → 기본값 폴백', () {
      // 최소 필수: maxHp, currentHp
      final json =
          '{"schemaVersion":1,"savedAt":"2026-01-01T00:00:00.000",'
          '"playerRunState":{"currentHp":10,"maxHp":20}}';
      final result = SaveSerializer.deserializeRun(json);
      expect(result, isA<Success<RunSaveData>>());
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState.gold, 0);
      expect(loaded.playerRunState.currentFloor, 1);
      expect(loaded.playerRunState.bossChoices, isEmpty);
      expect(loaded.playerRunState.ownedBlessingIds, isEmpty);
    });

    test('round-trip — BossChoiceType 3종 모두', () {
      final state = PlayerRunState(
        currentHp: 10,
        maxHp: 10,
        bossChoices: [
          const BossChoice(
              floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
          const BossChoice(
              floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
          const BossChoice(
              floor: 3, bossId: 'b3', choiceType: BossChoiceType.coexist),
        ],
      );
      final data = RunSaveData(
        playerRunState: state,
        savedAt: DateTime(2026, 1, 1),
      );
      final json = SaveSerializer.serializeRun(data);
      final loaded =
          (SaveSerializer.deserializeRun(json) as Success<RunSaveData>).data;
      expect(loaded.playerRunState.bossChoices[0].choiceType,
          BossChoiceType.slay);
      expect(loaded.playerRunState.bossChoices[1].choiceType,
          BossChoiceType.liberate);
      expect(loaded.playerRunState.bossChoices[2].choiceType,
          BossChoiceType.coexist);
    });
  });

  group('SaveSerializer — Meta', () {
    test('round-trip — 전체 필드', () {
      const meta = MetaSaveData(
        totalRuns: 5,
        deathCount: 3,
        endingsReached: {'slay', 'liberate'},
        soulCount: 100,
      );
      final json = SaveSerializer.serializeMeta(meta);
      final result = SaveSerializer.deserializeMeta(json);

      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 5);
      expect(loaded.deathCount, 3);
      expect(loaded.endingsReached, {'slay', 'liberate'});
      expect(loaded.soulCount, 100);
    });

    test('round-trip — 초기 메타 (기본값)', () {
      const meta = MetaSaveData();
      final json = SaveSerializer.serializeMeta(meta);
      final result = SaveSerializer.deserializeMeta(json);

      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 0);
      expect(loaded.deathCount, 0);
      expect(loaded.endingsReached, isEmpty);
      expect(loaded.soulCount, 0);
    });

    test('deserialize — 잘못된 JSON → Failure', () {
      final result = SaveSerializer.deserializeMeta('bad json');
      expect(result, isA<Failure<MetaSaveData>>());
    });

    test('deserialize — 누락 필드 → 기본값', () {
      final result = SaveSerializer.deserializeMeta('{"schemaVersion":1}');
      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 0);
      expect(loaded.soulCount, 0);
    });
  });
}
