import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_generator.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';

void main() {
  group('유령 NPC 통합', () {
    test('2런차 2층 확정 등장', () {
      final ghost = GhostNpcData(
        deathFloor: 2,
        jobId: 'warrior',
        dispositionSnapshot: {},
        runNumber: 1,
      );
      final result = GhostNpcGenerator.trySpawn(
        ghostPool: [ghost],
        currentRun: 2,
        currentFloor: 2,
      );
      expect(result, isNotNull);
    });

    test('1런차 등장 불가', () {
      final ghost = GhostNpcData(
        deathFloor: 1,
        jobId: 'warrior',
        dispositionSnapshot: {},
        runNumber: 1,
      );
      final result = GhostNpcGenerator.trySpawn(
        ghostPool: [ghost],
        currentRun: 1,
        currentFloor: 1,
      );
      expect(result, isNull);
    });

    test('반응 레벨 3단계', () {
      expect(GhostReactionLevel.values, hasLength(3));
    });
  });

}
