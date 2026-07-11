import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_manager.dart';
import 'package:soul_dungeon/core/save/save_storage.dart';
import 'package:soul_dungeon/core/save/save_validator.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  late InMemorySaveStorage storage;
  late SaveManager manager;

  RunSaveData makeRunData({int hp = 50, int maxHp = 100, int floor = 1}) {
    return RunSaveData(
      playerRunState: PlayerRunState(
        currentHp: hp,
        maxHp: maxHp,
        currentFloor: floor,
      ),
      savedAt: DateTime(2026, 2, 17),
    );
  }

  setUp(() {
    storage = InMemorySaveStorage();
    manager = SaveManager(storage);
  });

  group('SaveManager — Run', () {
    test('save + load round-trip', () async {
      final data = makeRunData(hp: 80, floor: 3);
      final saveResult = await manager.saveRun(data);
      expect(saveResult, isA<Success>());

      final loadResult = await manager.loadRun();
      expect(loadResult, isA<Success<RunSaveData>>());
      final loaded = (loadResult as Success<RunSaveData>).data;
      expect(loaded.playerRunState.currentHp, 80);
      expect(loaded.playerRunState.currentFloor, 3);
    });

    test('더블 버퍼 — 첫 저장은 슬롯 b에', () async {
      // 초기 active = 'a' → 비활성 = 'b'에 저장 → active 'b'로 스왑
      await manager.saveRun(makeRunData(hp: 60));

      final runB = await storage.read('save_run_b');
      expect(runB, isNotNull);
      final active = await storage.read('save_active_slot');
      expect(active, 'b');
    });

    test('더블 버퍼 — 두 번째 저장은 슬롯 a에', () async {
      await manager.saveRun(makeRunData(hp: 60));
      await manager.saveRun(makeRunData(hp: 40));

      final runA = await storage.read('save_run_a');
      expect(runA, isNotNull);
      final active = await storage.read('save_active_slot');
      expect(active, 'a');
    });

    test('더블 버퍼 스왑 — 교대 저장', () async {
      await manager.saveRun(makeRunData(hp: 100)); // → b
      await manager.saveRun(makeRunData(hp: 90)); // → a
      await manager.saveRun(makeRunData(hp: 80)); // → b

      final active = await storage.read('save_active_slot');
      expect(active, 'b');

      final result = await manager.loadRun();
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState.currentHp, 80);
    });

    test('체크섬 검증 성공', () async {
      await manager.saveRun(makeRunData(hp: 50));

      final active = await storage.read('save_active_slot');
      final key = active == 'a' ? 'save_run_a' : 'save_run_b';
      final data = await storage.read(key);
      final checksum = await storage.read('${key}_checksum');

      expect(data, isNotNull);
      expect(checksum, isNotNull);
      expect(SaveValidator.validate(data!, checksum!), isTrue);
    });

    test('체크섬 불일치 → 폴백 슬롯', () async {
      // 정상 저장 (슬롯 b)
      await manager.saveRun(makeRunData(hp: 70));
      // 두 번째 저장 (슬롯 a) — 이후 active = 'a'
      await manager.saveRun(makeRunData(hp: 50));

      // 슬롯 a 체크섬 손상
      await storage.write('save_run_a_checksum', 'corrupted');

      // 로드 → a 실패 → b 폴백 (hp=70)
      final result = await manager.loadRun();
      expect(result, isA<Success<RunSaveData>>());
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState.currentHp, 70);
    });

    test('양쪽 슬롯 손상 → Failure', () async {
      await manager.saveRun(makeRunData(hp: 50));
      await manager.saveRun(makeRunData(hp: 40));

      // 양쪽 체크섬 손상
      await storage.write('save_run_a_checksum', 'bad');
      await storage.write('save_run_b_checksum', 'bad');

      final result = await manager.loadRun();
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('저장 없는 상태에서 load → Failure', () async {
      final result = await manager.loadRun();
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('hasRunSave — 저장 전 false', () async {
      expect(await manager.hasRunSave(), isFalse);
    });

    test('hasRunSave — 저장 후 true', () async {
      await manager.saveRun(makeRunData());
      expect(await manager.hasRunSave(), isTrue);
    });

    test('deleteRun — 삭제 후 hasRunSave false', () async {
      await manager.saveRun(makeRunData());
      await manager.deleteRun();
      expect(await manager.hasRunSave(), isFalse);
    });

    test('deleteRun — 삭제 후 load Failure', () async {
      await manager.saveRun(makeRunData());
      await manager.deleteRun();
      final result = await manager.loadRun();
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('복잡한 상태 round-trip — bossChoices + blessings', () async {
      final state = PlayerRunState(
        currentHp: 45,
        maxHp: 100,
        gold: 300,
        currentFloor: 4,
        ownedBlessingIds: ['b1', 'b2', 'b3'],
        ownedRelicIds: ['r1'],
        activeCurseIds: ['c1', 'c2'],
        bossChoices: [
          const BossChoice(
            floor: 1,
            bossId: 'boss_1',
            choiceType: BossChoiceType.slay,
          ),
          const BossChoice(
            floor: 2,
            bossId: 'boss_2',
            choiceType: BossChoiceType.coexist,
          ),
          const BossChoice(
            floor: 3,
            bossId: 'boss_3',
            choiceType: BossChoiceType.liberate,
          ),
        ],
        completedFloors: {1, 2, 3},
      );
      final data = RunSaveData(
        playerRunState: state,
        savedAt: DateTime(2026, 2, 17),
      );

      await manager.saveRun(data);
      final result = await manager.loadRun();
      expect(result, isA<Success<RunSaveData>>());
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState, state);
    });

    test('데이터 변조 → 체크섬 실패', () async {
      await manager.saveRun(makeRunData(hp: 50));
      final active = await storage.read('save_active_slot');
      final key = active == 'a' ? 'save_run_a' : 'save_run_b';

      // 데이터 변조
      await storage.write(key, '{"tampered":true}');

      // active 실패 → inactive도 없음 → Failure
      final result = await manager.loadRun();
      expect(result, isA<Failure<RunSaveData>>());
    });
  });

  group('SaveManager — Meta', () {
    test('save + load round-trip', () async {
      const meta = MetaSaveData(
        totalRuns: 10,
        deathCount: 7,
        endingsReached: {'slay', 'hidden'},
        soulCount: 500,
      );
      await manager.saveMeta(meta);
      final result = await manager.loadMeta();
      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 10);
      expect(loaded.deathCount, 7);
      expect(loaded.endingsReached, {'slay', 'hidden'});
      expect(loaded.soulCount, 500);
    });

    test('메타 없으면 기본 MetaSaveData 반환', () async {
      final result = await manager.loadMeta();
      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 0);
      expect(loaded.soulCount, 0);
    });

    test('양쪽 슬롯에 동시 저장', () async {
      const meta = MetaSaveData(totalRuns: 5);
      await manager.saveMeta(meta);

      // 양쪽 슬롯 모두에 데이터 존재
      final dataA = await storage.read('save_meta_a');
      final dataB = await storage.read('save_meta_b');
      expect(dataA, isNotNull);
      expect(dataB, isNotNull);
      expect(dataA, dataB); // 동일한 데이터

      // 양쪽 체크섬도 존재
      final checksumA = await storage.read('save_meta_a_checksum');
      final checksumB = await storage.read('save_meta_b_checksum');
      expect(checksumA, isNotNull);
      expect(checksumB, isNotNull);
      expect(checksumA, checksumB);
    });

    test('메타 체크섬 손상 → 다른 슬롯 폴백', () async {
      const meta = MetaSaveData(totalRuns: 5);
      await manager.saveMeta(meta);

      // 슬롯 a 체크섬 손상 → 슬롯 b 폴백
      await storage.write('save_meta_a_checksum', 'bad');

      final result = await manager.loadMeta();
      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 5);
    });

    test('메타 양쪽 체크섬 손상 → 기본 MetaSaveData', () async {
      const meta = MetaSaveData(totalRuns: 5);
      await manager.saveMeta(meta);

      // 양쪽 체크섬 손상
      await storage.write('save_meta_a_checksum', 'bad');
      await storage.write('save_meta_b_checksum', 'bad');

      final result = await manager.loadMeta();
      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 0); // 기본값
    });

    test('메타 저장은 active_slot과 독립', () async {
      // run 저장으로 active_slot 변경
      await manager.saveRun(makeRunData(hp: 50)); // active → b
      await manager.saveRun(makeRunData(hp: 40)); // active → a

      // 메타 저장 — active_slot 무관하게 양쪽에 저장
      const meta = MetaSaveData(totalRuns: 10);
      await manager.saveMeta(meta);

      // active_slot은 run 저장에 의해 'a'로 유지
      final activeSlot = await storage.read('save_active_slot');
      expect(activeSlot, 'a');

      // 메타는 양쪽 모두 존재
      final dataA = await storage.read('save_meta_a');
      final dataB = await storage.read('save_meta_b');
      expect(dataA, isNotNull);
      expect(dataB, isNotNull);
    });
  });

  group('SaveManager — Emergency', () {
    test('긴급 세이브 + 로드', () async {
      await manager.emergencySave(makeRunData(hp: 10));
      final result = await manager.loadEmergency();
      expect(result, isA<Success<RunSaveData>>());
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState.currentHp, 10);
    });

    test('긴급 세이브 없으면 Failure', () async {
      final result = await manager.loadEmergency();
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('긴급 세이브 삭제', () async {
      await manager.emergencySave(makeRunData(hp: 10));
      await manager.deleteEmergency();
      final result = await manager.loadEmergency();
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('긴급 세이브 체크섬 저장', () async {
      await manager.emergencySave(makeRunData(hp: 10));

      final data = await storage.read('save_emergency');
      final checksum = await storage.read('save_emergency_checksum');
      expect(data, isNotNull);
      expect(checksum, isNotNull);
      expect(checksum!.length, 64); // SHA-256
      expect(SaveValidator.validate(data!, checksum), isTrue);
    });

    test('긴급 세이브 체크섬 손상 → Failure', () async {
      await manager.emergencySave(makeRunData(hp: 10));
      await storage.write('save_emergency_checksum', 'corrupted');

      final result = await manager.loadEmergency();
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('긴급 세이브 데이터 변조 → 체크섬 불일치 Failure', () async {
      await manager.emergencySave(makeRunData(hp: 10));
      await storage.write('save_emergency', '{"tampered":true}');

      final result = await manager.loadEmergency();
      expect(result, isA<Failure<RunSaveData>>());
    });

    test('긴급 세이브 삭제 — 체크섬도 함께 삭제', () async {
      await manager.emergencySave(makeRunData(hp: 10));
      await manager.deleteEmergency();

      final data = await storage.read('save_emergency');
      final checksum = await storage.read('save_emergency_checksum');
      expect(data, isNull);
      expect(checksum, isNull);
    });
  });

  group('SaveManager — 슬롯 데이터 분리', () {
    test('active 슬롯 기본값 a', () async {
      final slot = await storage.read('save_active_slot');
      expect(slot, isNull); // 명시적으로 설정 안 됨 → 매니저가 'a'로 처리
    });

    test('save 후 active 슬롯 변경', () async {
      await manager.saveRun(makeRunData());
      final slot = await storage.read('save_active_slot');
      expect(slot, 'b');
    });

    test('연속 save — 슬롯 교대', () async {
      await manager.saveRun(makeRunData(hp: 100));
      expect(await storage.read('save_active_slot'), 'b');

      await manager.saveRun(makeRunData(hp: 90));
      expect(await storage.read('save_active_slot'), 'a');

      await manager.saveRun(makeRunData(hp: 80));
      expect(await storage.read('save_active_slot'), 'b');
    });

    test('체크섬 키 형식', () async {
      await manager.saveRun(makeRunData());
      // 첫 save → slot b
      final checksum = await storage.read('save_run_b_checksum');
      expect(checksum, isNotNull);
      expect(checksum!.length, 64); // SHA-256
    });
  });

  group('SaveManager — deleteAllData', () {
    test('모든 데이터 삭제 — run + meta + emergency + active_slot', () async {
      // 런, 메타, 긴급 세이브 모두 저장
      await manager.saveRun(makeRunData(hp: 80));
      await manager.saveMeta(const MetaSaveData(soulCount: 500, totalRuns: 10));
      await manager.emergencySave(makeRunData(hp: 10));

      // 삭제 전 확인
      expect(await manager.hasRunSave(), isTrue);

      // 완전 삭제
      await manager.deleteAllData();

      // 런 삭제 확인
      expect(await manager.hasRunSave(), isFalse);
      final runResult = await manager.loadRun();
      expect(runResult, isA<Failure<RunSaveData>>());

      // 메타 삭제 확인 — 기본 MetaSaveData로 폴백
      final metaResult = await manager.loadMeta();
      expect(metaResult, isA<Success<MetaSaveData>>());
      final meta = (metaResult as Success<MetaSaveData>).data;
      expect(meta.soulCount, 0);
      expect(meta.totalRuns, 0);

      // 긴급 세이브 삭제 확인
      final emergencyResult = await manager.loadEmergency();
      expect(emergencyResult, isA<Failure<RunSaveData>>());

      // active_slot 삭제 확인
      final slot = await storage.read('save_active_slot');
      expect(slot, isNull);
    });

    test('빈 상태에서 deleteAllData 호출 — 에러 없음', () async {
      // 아무 데이터 없이 호출해도 에러 발생하지 않아야 함
      await manager.deleteAllData();
      expect(await manager.hasRunSave(), isFalse);
    });
  });

  group('SaveManager — 저장 후 데이터 변경', () {
    test('저장 후 state 변경 → 이전 데이터 로드', () async {
      await manager.saveRun(makeRunData(hp: 80));

      // 새 state로 저장하지 않음
      final result = await manager.loadRun();
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState.currentHp, 80);
    });

    test('연속 save 후 최신 데이터 로드', () async {
      await manager.saveRun(makeRunData(hp: 100));
      await manager.saveRun(makeRunData(hp: 80));
      await manager.saveRun(makeRunData(hp: 60));

      final result = await manager.loadRun();
      final loaded = (result as Success<RunSaveData>).data;
      expect(loaded.playerRunState.currentHp, 60);
    });
  });
}
