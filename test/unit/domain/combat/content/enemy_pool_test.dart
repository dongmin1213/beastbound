import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/enemy_pool.dart';
import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';

void main() {
  group('EnemyPool', () {
    test('전체 적 수 = 40', () {
      expect(EnemyPool.count, 40);
    });

    test('층별 일반 적 5종씩', () {
      for (int floor = 1; floor <= 5; floor++) {
        expect(
          EnemyPool.normalEnemies(floor).length, 5,
          reason: 'Floor $floor should have 5 normal enemies',
        );
      }
    });

    test('층별 엘리트 3종씩', () {
      for (int floor = 1; floor <= 5; floor++) {
        expect(
          EnemyPool.eliteEnemies(floor).length, 3,
          reason: 'Floor $floor should have 3 elite enemies',
        );
      }
    });

    test('유효하지 않은 층은 빈 리스트', () {
      expect(EnemyPool.normalEnemies(0), isEmpty);
      expect(EnemyPool.normalEnemies(6), isEmpty);
      expect(EnemyPool.eliteEnemies(0), isEmpty);
      expect(EnemyPool.eliteEnemies(6), isEmpty);
    });

    test('randomNormal — 유효한 적 반환', () {
      final enemy = EnemyPool.randomNormal(1, random: Random(42));
      expect(enemy, isNotNull);
      expect(enemy!.floor, 1);
      expect(enemy.isElite, false);
    });

    test('randomElite — 유효한 적 반환', () {
      final enemy = EnemyPool.randomElite(3, random: Random(42));
      expect(enemy, isNotNull);
      expect(enemy!.floor, 3);
      expect(enemy.isElite, true);
    });

    test('randomNormal — 유효하지 않은 층은 null', () {
      expect(EnemyPool.randomNormal(0, random: Random(42)), isNull);
    });

    test('randomElite — 유효하지 않은 층은 null', () {
      expect(EnemyPool.randomElite(6, random: Random(42)), isNull);
    });

    test('findById — 존재하는 적', () {
      final enemy = EnemyPool.findById('enemy_rat');
      expect(enemy, isNotNull);
      expect(enemy!.name, '쥐');
    });

    test('findById — 존재하지 않는 ID는 null', () {
      expect(EnemyPool.findById('nonexistent'), isNull);
    });

    test('findById — 모든 적 조회 가능', () {
      for (final enemy in FloorEnemies.all) {
        expect(EnemyPool.findById(enemy.id), isNotNull,
            reason: '${enemy.id} should be findable');
      }
    });
  });
}
