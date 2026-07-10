import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/config/floor_config.dart';

void main() {
  group('FloorConfig', () {
    test('기본값 생성', () {
      const config = FloorConfig();
      expect(config.roomsPerFloor, isNull);
      expect(config.eliteMin, isNull);
      expect(config.enemyHpMultiplier, 1.0);
      expect(config.goldMultiplier, 1.0);
    });

    test('fromJson 파싱', () {
      final config = FloorConfig.fromJson({
        'rooms_per_floor': 12,
        'elite_min': 2,
        'elite_max': 3,
        'enemy_hp_multiplier': 1.5,
        'gold_multiplier': 1.3,
      });
      expect(config.roomsPerFloor, 12);
      expect(config.eliteMin, 2);
      expect(config.eliteMax, 3);
      expect(config.enemyHpMultiplier, 1.5);
      expect(config.goldMultiplier, 1.3);
    });

    test('fromJson null 필드 → 기본값', () {
      final config = FloorConfig.fromJson({});
      expect(config.roomsPerFloor, isNull);
      expect(config.enemyHpMultiplier, 1.0);
    });
  });

  group('FloorsConfig', () {
    test('5층 파싱', () {
      final config = FloorsConfig.fromJson([
        {'enemy_hp_multiplier': 1.0},
        {'enemy_hp_multiplier': 1.3},
        {'enemy_hp_multiplier': 1.1},
        {'enemy_hp_multiplier': 1.6},
        {'enemy_hp_multiplier': 1.8},
      ]);
      expect(config.length, 5);
      expect(config.forFloor(1).enemyHpMultiplier, 1.0);
      expect(config.forFloor(5).enemyHpMultiplier, 1.8);
    });

    test('범위 밖 층 → 기본 FloorConfig', () {
      final config = FloorsConfig.fromJson([
        {'enemy_hp_multiplier': 1.0},
      ]);
      final outOfRange = config.forFloor(99);
      expect(outOfRange.enemyHpMultiplier, 1.0);
      expect(outOfRange.roomsPerFloor, isNull);
    });

    test('floor 0 → 기본 FloorConfig', () {
      final config = FloorsConfig.fromJson([
        {'enemy_hp_multiplier': 1.5},
      ]);
      expect(config.forFloor(0).enemyHpMultiplier, 1.0);
    });

    test('null JSON → 빈 config', () {
      final config = FloorsConfig.fromJson(null);
      expect(config.length, 0);
    });

    test('빈 배열 → 빈 config', () {
      final config = FloorsConfig.fromJson([]);
      expect(config.length, 0);
    });

    test('잘못된 엔트리 → 기본값 폴백', () {
      final config = FloorsConfig.fromJson([
        'invalid',
        {'enemy_hp_multiplier': 1.5},
      ]);
      expect(config.length, 2);
      expect(config.forFloor(1).enemyHpMultiplier, 1.0); // 기본값
      expect(config.forFloor(2).enemyHpMultiplier, 1.5);
    });
  });

  group('FloorAwareDungeonConfig (withFloorOverride)', () {
    const base = DungeonBalanceConfig(
      roomsPerFloor: 10,
      eliteMin: 1,
      eliteMax: 2,
      eliteMinDepth: 3,
    );

    test('빈 오버라이드 → 기본값 유지', () {
      final result = base.withFloorOverride(const FloorConfig());
      expect(result.roomsPerFloor, 10);
      expect(result.eliteMin, 1);
      expect(result.eliteMax, 2);
      expect(result.eliteMinDepth, 3);
    });

    test('roomsPerFloor 오버라이드', () {
      final result = base.withFloorOverride(
        const FloorConfig(roomsPerFloor: 12),
      );
      expect(result.roomsPerFloor, 12);
      expect(result.eliteMin, 1); // 변경 없음
    });

    test('eliteMin/Max 오버라이드', () {
      final result = base.withFloorOverride(
        const FloorConfig(eliteMin: 2, eliteMax: 3),
      );
      expect(result.eliteMin, 2);
      expect(result.eliteMax, 3);
    });

    test('eliteMin > eliteMax 역전 → 스왑', () {
      final result = base.withFloorOverride(
        const FloorConfig(eliteMin: 3, eliteMax: 1),
      );
      expect(result.eliteMin, 1);
      expect(result.eliteMax, 3);
    });

    test('eliteMinDepth 오버라이드', () {
      final result = base.withFloorOverride(
        const FloorConfig(eliteMinDepth: 2),
      );
      expect(result.eliteMinDepth, 2);
    });

    test('branchFactor는 오버라이드 불가 (기본 유지)', () {
      final result = base.withFloorOverride(const FloorConfig());
      expect(result.branchFactorMin, base.branchFactorMin);
      expect(result.branchFactorMax, base.branchFactorMax);
    });

    test('층 5 오버라이드 적용', () {
      final floorsConfig = FloorsConfig.fromJson([
        {},
        {},
        {},
        {},
        {'rooms_per_floor': 12, 'elite_min': 2, 'elite_max': 3, 'elite_min_depth': 2},
      ]);
      final floor5 = floorsConfig.forFloor(5);
      final result = base.withFloorOverride(floor5);
      expect(result.roomsPerFloor, 12);
      expect(result.eliteMin, 2);
      expect(result.eliteMax, 3);
      expect(result.eliteMinDepth, 2);
    });
  });

  group('balance.json floors 통합', () {
    test('톱니형 난이도 패턴 확인', () {
      final floors = FloorsConfig.fromJson([
        {'enemy_hp_multiplier': 1.0},
        {'enemy_hp_multiplier': 1.3},
        {'enemy_hp_multiplier': 1.1},
        {'enemy_hp_multiplier': 1.6},
        {'enemy_hp_multiplier': 1.8},
      ]);

      final hp1 = floors.forFloor(1).enemyHpMultiplier;
      final hp2 = floors.forFloor(2).enemyHpMultiplier;
      final hp3 = floors.forFloor(3).enemyHpMultiplier;
      final hp4 = floors.forFloor(4).enemyHpMultiplier;
      final hp5 = floors.forFloor(5).enemyHpMultiplier;

      // 톱니: 1↑ 2↑ 3↓ 4↑↑ 5최고
      expect(hp2, greaterThan(hp1));
      expect(hp3, lessThan(hp2));
      expect(hp4, greaterThan(hp3));
      expect(hp5, greaterThan(hp4));
    });
  });
}
