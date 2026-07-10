import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_generator.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';

/// 항상 특정 값을 반환하는 테스트용 Random.
class _FixedRandom implements Random {
  final double _doubleValue;
  final int _intValue;

  _FixedRandom({double doubleValue = 0.0, int intValue = 0})
      : _doubleValue = doubleValue,
        _intValue = intValue;

  @override
  double nextDouble() => _doubleValue;

  @override
  int nextInt(int max) => _intValue.clamp(0, max - 1);

  @override
  bool nextBool() => false;
}

void main() {
  // ── 테스트용 유령 데이터 ──

  const ghostRun1Floor3 = GhostNpcData(
    deathFloor: 3,
    jobId: 'warrior',
    dispositionSnapshot: {'courage': 5, 'wisdom': 2, 'mercy': 1},
    runNumber: 1,
  );

  const ghostRun1Floor2 = GhostNpcData(
    deathFloor: 2,
    jobId: 'sage',
    dispositionSnapshot: {'courage': 1, 'wisdom': 5, 'mercy': 3},
    runNumber: 1,
  );

  const ghostRun2Floor4 = GhostNpcData(
    deathFloor: 4,
    jobId: 'assassin',
    dispositionSnapshot: {'courage': 3, 'wisdom': 1, 'mercy': 0},
    runNumber: 2,
  );

  group('GhostNpcGenerator — trySpawn', () {
    test('빈 풀 → null', () {
      final result = GhostNpcGenerator.trySpawn(
        currentRun: 2,
        ghostPool: const [],
        currentFloor: 2,
      );

      expect(result, isNull);
    });

    test('1런차 → null (아직 확정 런 아님)', () {
      final result = GhostNpcGenerator.trySpawn(
        currentRun: 1,
        ghostPool: [ghostRun1Floor3],
        currentFloor: 2,
      );

      expect(result, isNull);
    });

    test('2런차 2층 확정 등장 → 가장 최근 유령', () {
      final result = GhostNpcGenerator.trySpawn(
        currentRun: 2,
        ghostPool: [ghostRun1Floor3, ghostRun1Floor2],
        currentFloor: 2,
      );

      expect(result, equals(ghostRun1Floor2)); // 마지막 요소 = 가장 최근
    });

    test('2런차 다른 층 → null', () {
      final result = GhostNpcGenerator.trySpawn(
        currentRun: 2,
        ghostPool: [ghostRun1Floor3],
        currentFloor: 3, // 2층이 아님
      );

      expect(result, isNull);
    });

    test('3런차+ 확률 등장 — 낮은 난수 → 등장', () {
      final result = GhostNpcGenerator.trySpawn(
        currentRun: 3,
        ghostPool: [ghostRun1Floor3],
        currentFloor: 1,
        spawnProbability: 0.3,
        random: _FixedRandom(doubleValue: 0.1), // 0.1 < 0.3 → 등장
      );

      expect(result, isNotNull);
      expect(result, equals(ghostRun1Floor3));
    });

    test('3런차+ 확률 미등장 — 높은 난수 → null', () {
      final result = GhostNpcGenerator.trySpawn(
        currentRun: 3,
        ghostPool: [ghostRun1Floor3],
        currentFloor: 1,
        spawnProbability: 0.3,
        random: _FixedRandom(doubleValue: 0.5), // 0.5 >= 0.3 → 미등장
      );

      expect(result, isNull);
    });

    test('같은 층 유령 우선 선택', () {
      final result = GhostNpcGenerator.trySpawn(
        currentRun: 3,
        ghostPool: [ghostRun1Floor3, ghostRun1Floor2, ghostRun2Floor4],
        currentFloor: 3, // ghostRun1Floor3과 같은 층
        spawnProbability: 0.3,
        random: _FixedRandom(doubleValue: 0.1, intValue: 0),
      );

      expect(result, equals(ghostRun1Floor3));
    });

    test('같은 층 유령 없으면 풀에서 랜덤 선택', () {
      final result = GhostNpcGenerator.trySpawn(
        currentRun: 3,
        ghostPool: [ghostRun1Floor3, ghostRun1Floor2],
        currentFloor: 5, // 5층에서 사망한 유령 없음
        spawnProbability: 0.3,
        random: _FixedRandom(doubleValue: 0.1, intValue: 1),
      );

      expect(result, equals(ghostRun1Floor2)); // intValue=1 → index 1
    });
  });

  group('GhostNpcGenerator — cosineSimilarity', () {
    test('동일 벡터 → 1.0', () {
      final a = {'courage': 3, 'wisdom': 4};
      final b = {'courage': 3, 'wisdom': 4};

      final result = GhostNpcGenerator.cosineSimilarity(a, b);

      expect(result, closeTo(1.0, 1e-9));
    });

    test('직교 벡터 → 0.0', () {
      // (1, 0) · (0, 1) = 0
      final a = {'x': 1, 'y': 0};
      final b = {'x': 0, 'y': 1};

      final result = GhostNpcGenerator.cosineSimilarity(a, b);

      expect(result, closeTo(0.0, 1e-9));
    });

    test('반대 벡터 → -1.0', () {
      final a = {'courage': 3, 'wisdom': 4};
      final b = {'courage': -3, 'wisdom': -4};

      final result = GhostNpcGenerator.cosineSimilarity(a, b);

      expect(result, closeTo(-1.0, 1e-9));
    });

    test('빈 맵 → 0.0', () {
      final result = GhostNpcGenerator.cosineSimilarity({}, {});

      expect(result, 0.0);
    });

    test('한쪽 영벡터 → 0.0', () {
      final a = {'courage': 0, 'wisdom': 0};
      final b = {'courage': 3, 'wisdom': 4};

      final result = GhostNpcGenerator.cosineSimilarity(a, b);

      expect(result, 0.0);
    });

    test('부분 키 겹침 — 없는 키는 0 처리', () {
      final a = {'courage': 3}; // wisdom 없음 → 0
      final b = {'courage': 3, 'wisdom': 4};

      // dot = 3*3 + 0*4 = 9
      // normA = sqrt(9) = 3
      // normB = sqrt(9+16) = 5
      // similarity = 9 / (3 * 5) = 0.6
      final result = GhostNpcGenerator.cosineSimilarity(a, b);

      expect(result, closeTo(0.6, 1e-9));
    });
  });

  group('GhostNpcGenerator — reactionLevel', () {
    test('유사도 0.8 → familiar', () {
      // 동일 벡터 → 1.0 → familiar
      final result = GhostNpcGenerator.reactionLevel(
        ghostDisposition: {'courage': 3, 'wisdom': 4},
        currentDisposition: {'courage': 3, 'wisdom': 4},
        familiarThreshold: 0.7,
        curiousThreshold: 0.3,
      );

      expect(result, GhostReactionLevel.familiar);
    });

    test('유사도 0.5 → curious', () {
      // 부분 유사 벡터: (3, 0) vs (3, 4) → 0.6
      final result = GhostNpcGenerator.reactionLevel(
        ghostDisposition: {'courage': 3},
        currentDisposition: {'courage': 3, 'wisdom': 4},
        familiarThreshold: 0.7,
        curiousThreshold: 0.3,
      );

      // 0.6 >= 0.3 → curious
      expect(result, GhostReactionLevel.curious);
    });

    test('유사도 0.1 → distant', () {
      // 거의 직교: (1, 0) vs (0, 1) → 0.0
      final result = GhostNpcGenerator.reactionLevel(
        ghostDisposition: {'x': 1, 'y': 0},
        currentDisposition: {'x': 0, 'y': 1},
        familiarThreshold: 0.7,
        curiousThreshold: 0.3,
      );

      expect(result, GhostReactionLevel.distant);
    });

    test('정확히 familiarThreshold → familiar', () {
      final result = GhostNpcGenerator.reactionLevel(
        ghostDisposition: {'courage': 3, 'wisdom': 4},
        currentDisposition: {'courage': 3, 'wisdom': 4},
        familiarThreshold: 1.0, // 정확히 1.0
        curiousThreshold: 0.3,
      );

      expect(result, GhostReactionLevel.familiar);
    });

    test('정확히 curiousThreshold → curious', () {
      final result = GhostNpcGenerator.reactionLevel(
        ghostDisposition: {'courage': 3},
        currentDisposition: {'courage': 3, 'wisdom': 4},
        familiarThreshold: 0.7,
        curiousThreshold: 0.6, // 0.6 == 0.6 → curious
      );

      expect(result, GhostReactionLevel.curious);
    });
  });

  group('GhostReactionLevel — displayName', () {
    test('familiar → 익숙함', () {
      expect(GhostReactionLevel.familiar.displayName, '익숙함');
    });

    test('curious → 호기심', () {
      expect(GhostReactionLevel.curious.displayName, '호기심');
    });

    test('distant → 무관심', () {
      expect(GhostReactionLevel.distant.displayName, '무관심');
    });
  });

  group('GhostNpcData — Equatable', () {
    test('동일 값 → 같은 객체', () {
      const a = GhostNpcData(
        deathFloor: 3,
        jobId: 'warrior',
        dispositionSnapshot: {'courage': 5},
        runNumber: 1,
      );
      const b = GhostNpcData(
        deathFloor: 3,
        jobId: 'warrior',
        dispositionSnapshot: {'courage': 5},
        runNumber: 1,
      );

      expect(a, equals(b));
    });

    test('다른 값 → 다른 객체', () {
      const a = GhostNpcData(
        deathFloor: 3,
        jobId: 'warrior',
        dispositionSnapshot: {'courage': 5},
        runNumber: 1,
      );
      const b = GhostNpcData(
        deathFloor: 4,
        jobId: 'sage',
        dispositionSnapshot: {'courage': 1},
        runNumber: 2,
      );

      expect(a, isNot(equals(b)));
    });
  });
}
