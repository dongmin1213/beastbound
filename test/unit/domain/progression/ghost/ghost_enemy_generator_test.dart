import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_enemy_generator.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';

void main() {
  group('GhostEnemyGenerator', () {
    test('warrior 1층 유령 → 공격형 스탯', () {
      const ghost = GhostNpcData(
        deathFloor: 1,
        jobId: 'warrior',
        dispositionSnapshot: {'courage': 5},
        runNumber: 1,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.id, 'ghost_warrior_f1');
      expect(enemy.name, '전사의 유령');
      expect(enemy.hp, 50);
      expect(enemy.atk, 13);
      expect(enemy.def, 4);
      expect(enemy.floor, 1);
      expect(enemy.isElite, true);
      expect(enemy.pattern, contains(EnemyActionType.attack));
    });

    test('guardian 3층 유령 → 탱커 스탯 + 층 스케일링', () {
      const ghost = GhostNpcData(
        deathFloor: 3,
        jobId: 'guardian',
        dispositionSnapshot: {},
        runNumber: 2,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.id, 'ghost_guardian_f3');
      expect(enemy.name, '수호자의 유령');
      // floor 3 multiplier = 1.6
      expect(enemy.hp, (60 * 1.6).toInt()); // 96
      expect(enemy.atk, (9 * 1.6).toInt()); // 14
      expect(enemy.def, (7 * 1.6).toInt()); // 11
      expect(enemy.floor, 3);
      expect(enemy.isElite, true);
      // tank 패턴은 defend로 시작
      expect(enemy.pattern.first, EnemyActionType.defend);
    });

    test('assassin 5층 유령 → 암살자 스탯 + 최고 스케일링', () {
      const ghost = GhostNpcData(
        deathFloor: 5,
        jobId: 'assassin',
        dispositionSnapshot: {},
        runNumber: 3,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.id, 'ghost_assassin_f5');
      expect(enemy.name, '암살자의 유령');
      // floor 5 multiplier = 2.1
      expect(enemy.hp, (35 * 2.1).toInt()); // 73
      expect(enemy.atk, (15 * 2.1).toInt()); // 31
      expect(enemy.def, (2 * 2.1).toInt()); // 4
      // assassin 패턴: 5액션 (attack x3 + charge + heavy)
      expect(enemy.pattern.length, 5);
      expect(enemy.pattern, contains(EnemyActionType.heavy));
    });

    test('sage 유령 → caster 원형', () {
      const ghost = GhostNpcData(
        deathFloor: 2,
        jobId: 'sage',
        dispositionSnapshot: {},
        runNumber: 1,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.name, '현자의 유령');
      // caster 패턴: buff로 시작
      expect(enemy.pattern.first, EnemyActionType.buff);
      // floor 2 multiplier = 1.3
      expect(enemy.hp, (40 * 1.3).toInt()); // 52
      expect(enemy.atk, (14 * 1.3).toInt()); // 18
    });

    test('saint 유령 → healer 원형', () {
      const ghost = GhostNpcData(
        deathFloor: 1,
        jobId: 'saint',
        dispositionSnapshot: {},
        runNumber: 1,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.name, '성자의 유령');
      expect(enemy.hp, 55);
      expect(enemy.atk, 10);
      expect(enemy.def, 5);
      // healer 패턴: heal로 시작
      expect(enemy.pattern.first, EnemyActionType.heal);
    });

    test('wanderer 유령 → balanced 원형', () {
      const ghost = GhostNpcData(
        deathFloor: 4,
        jobId: 'wanderer',
        dispositionSnapshot: {},
        runNumber: 2,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.name, '방랑자의 유령');
      // floor 4 multiplier = 1.85
      expect(enemy.hp, (45 * 1.85).toInt()); // 83
      // balanced 패턴: attack, defend, buff, attack
      expect(enemy.pattern.length, 4);
      expect(enemy.pattern[1], EnemyActionType.defend);
      expect(enemy.pattern[2], EnemyActionType.buff);
    });

    test('2차 상위직 swordSaint → attacker 원형', () {
      const ghost = GhostNpcData(
        deathFloor: 4,
        jobId: 'swordSaint',
        dispositionSnapshot: {},
        runNumber: 3,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.name, '검성의 유령');
      // attacker 기본 스탯 사용
      expect(enemy.hp, (50 * 1.85).toInt()); // 92
      expect(enemy.atk, (13 * 1.85).toInt()); // 24
    });

    test('2차 조합직 darkKnight → tank 원형', () {
      const ghost = GhostNpcData(
        deathFloor: 3,
        jobId: 'darkKnight',
        dispositionSnapshot: {},
        runNumber: 2,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.name, '암흑기사의 유령');
      // tank 패턴: defend로 시작
      expect(enemy.pattern.first, EnemyActionType.defend);
    });

    test('알 수 없는 직업 → balanced 폴백', () {
      const ghost = GhostNpcData(
        deathFloor: 1,
        jobId: 'unknown_job',
        dispositionSnapshot: {},
        runNumber: 1,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.id, 'ghost_unknown_job_f1');
      expect(enemy.name, 'unknown_job의 유령');
      // balanced 스탯
      expect(enemy.hp, 45);
      expect(enemy.atk, 11);
      expect(enemy.def, 5);
    });

    test('대체 패턴이 존재', () {
      const ghost = GhostNpcData(
        deathFloor: 1,
        jobId: 'warrior',
        dispositionSnapshot: {},
        runNumber: 1,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      expect(enemy.alternatePatterns, isNotEmpty);
      expect(enemy.alternatePatterns.length, 2);
    });

    test('층 0 이하 → 배율 1.0 적용', () {
      const ghost = GhostNpcData(
        deathFloor: 0,
        jobId: 'warrior',
        dispositionSnapshot: {},
        runNumber: 1,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      // floor 0 → multiplier 1.0
      expect(enemy.hp, 50);
      expect(enemy.atk, 13);
    });

    test('층 6 이상 → 배율 2.1 적용', () {
      const ghost = GhostNpcData(
        deathFloor: 6,
        jobId: 'warrior',
        dispositionSnapshot: {},
        runNumber: 1,
      );

      final enemy = GhostEnemyGenerator.generate(ghost);

      // floor 6+ → multiplier 2.1
      expect(enemy.hp, (50 * 2.1).toInt());
      expect(enemy.atk, (13 * 2.1).toInt());
    });
  });
}
