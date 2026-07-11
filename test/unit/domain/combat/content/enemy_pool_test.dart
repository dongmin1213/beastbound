import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/floor_region.dart';
import 'package:soul_dungeon/domain/combat/content/enemy_pool.dart';
import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';

void main() {
  group('EnemyPool', () {
    test('전체 적 수 = 40', () {
      expect(EnemyPool.count, 40);
    });

    test('층별 일반 적 5종씩 (10층, 지역 풀 공유)', () {
      for (int floor = 1; floor <= FloorRegion.totalFloors; floor++) {
        expect(
          EnemyPool.normalEnemies(floor).length, 5,
          reason: 'Floor $floor should have 5 normal enemies',
        );
      }
    });

    test('층별 엘리트 3종씩 (10층)', () {
      for (int floor = 1; floor <= FloorRegion.totalFloors; floor++) {
        expect(
          EnemyPool.eliteEnemies(floor).length, 3,
          reason: 'Floor $floor should have 3 elite enemies',
        );
      }
    });

    test('같은 지역의 두 층은 같은 적 풀 공유', () {
      // 폐허 1·2 / 동굴 3·4 / 감옥 5·6 / 사원 7·8 / 심연 9·10
      for (final pair in const [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]) {
        expect(EnemyPool.normalEnemies(pair[0]),
            EnemyPool.normalEnemies(pair[1]));
        expect(EnemyPool.eliteEnemies(pair[0]),
            EnemyPool.eliteEnemies(pair[1]));
      }
    });

    test('randomNormal — 유효한 적 반환', () {
      final enemy = EnemyPool.randomNormal(1, random: Random(42));
      expect(enemy, isNotNull);
      expect(enemy!.floor, 1);
      expect(enemy.isElite, false);
    });

    test('randomElite — 유효한 적 반환 (층→지역)', () {
      final enemy = EnemyPool.randomElite(3, random: Random(42));
      expect(enemy, isNotNull);
      expect(enemy!.floor, FloorRegion.of(3)); // 동굴 = 지역 2
      expect(enemy.isElite, true);
    });

    test('깊은 층(7-10)도 유효한 적 반환', () {
      expect(EnemyPool.randomNormal(9, random: Random(42)), isNotNull);
      expect(EnemyPool.randomElite(10, random: Random(42)), isNotNull);
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
