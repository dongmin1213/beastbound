import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/models/boss_phase_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_encounter_data.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CombatEncounterData', () {
    test('기본 생성 및 필드 확인', () {
      const encounter = CombatEncounterData(
        roomType: RoomType.combat,
        enemyName: '해골 전사',
        turns: [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
          CombatTurnInfo(turnNumber: 2, enemyAction: EnemyActionType.defend),
        ],
      );

      expect(encounter.roomType, RoomType.combat);
      expect(encounter.enemyName, '해골 전사');
      expect(encounter.environmentClues, isEmpty);
      expect(encounter.totalTurns, 2);
    });

    test('환경 단서 포함 생성', () {
      final encounter = CombatEncounterData(
        roomType: RoomType.elite,
        enemyName: '엘리트 기사',
        environmentClues: const [
          EnvironmentClue(
            id: 'pillar',
            description: '무너진 기둥',
            actionHint: '기둥을 무너뜨린다',
          ),
        ],
        turns: const [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.observe),
        ],
      );

      expect(encounter.environmentClues, hasLength(1));
      expect(encounter.environmentClues.first.id, 'pillar');
    });

    test('Equatable 동등성', () {
      const a = CombatEncounterData(
        roomType: RoomType.combat,
        enemyName: '슬라임',
        turns: [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
        ],
      );
      const b = CombatEncounterData(
        roomType: RoomType.combat,
        enemyName: '슬라임',
        turns: [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
        ],
      );

      expect(a, equals(b));
    });

    // === Story 3-8: isBoss / totalBossPhases ===

    test('isBoss/totalBossPhases getter 검증', () {
      // 일반 전투: bossPhases null → isBoss false
      const normal = CombatEncounterData(
        roomType: RoomType.combat,
        enemyName: '슬라임',
        turns: [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
        ],
      );
      expect(normal.isBoss, isFalse);
      expect(normal.totalBossPhases, 1);

      // bossPhases 빈 리스트 → isBoss false
      const emptyPhases = CombatEncounterData(
        roomType: RoomType.boss,
        enemyName: '보스',
        turns: [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
        ],
        bossPhases: [],
      );
      expect(emptyPhases.isBoss, isFalse);
      expect(emptyPhases.totalBossPhases, 1);

      // 보스 인카운터: 2 페이즈
      const bossEncounter = CombatEncounterData(
        roomType: RoomType.boss,
        enemyName: '심연의 수호자',
        turns: [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
        ],
        bossPhases: [
          BossPhaseData(phaseName: 'phase1', turns: [
            CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
          ]),
          BossPhaseData(phaseName: 'phase2', turns: [
            CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
          ]),
        ],
      );
      expect(bossEncounter.isBoss, isTrue);
      expect(bossEncounter.totalBossPhases, 2);
    });
  });

  group('CombatTurnInfo', () {
    test('기본 생성 및 Equatable', () {
      const a = CombatTurnInfo(
        turnNumber: 1,
        enemyAction: EnemyActionType.defend,
      );
      const b = CombatTurnInfo(
        turnNumber: 1,
        enemyAction: EnemyActionType.defend,
      );

      expect(a, equals(b));
      expect(a.turnNumber, 1);
      expect(a.enemyAction, EnemyActionType.defend);
    });
  });
}
