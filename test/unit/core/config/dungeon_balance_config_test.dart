import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';

void main() {
  group('DungeonBalanceConfig', () {
    test('fromJson parses valid dungeon config', () {
      final config = DungeonBalanceConfig.fromJson({
        'rooms_per_floor': 20,
        'branch_factor_min': 2,
        'branch_factor_max': 4,
        'elite_min': 1,
        'elite_max': 2,
        'elite_min_depth': 3,
      });

      expect(config.roomsPerFloor, 20);
      expect(config.branchFactorMin, 2);
      expect(config.branchFactorMax, 4);
      expect(config.eliteMin, 1);
      expect(config.eliteMax, 2);
      expect(config.eliteMinDepth, 3);
    });

    test('fromJson clamps out-of-range values to fallback', () {
      final config = DungeonBalanceConfig.fromJson({
        'rooms_per_floor': 100,
        'branch_factor_min': 0,
        'branch_factor_max': 10,
        'elite_min': -1,
        'elite_max': 99,
        'elite_min_depth': 0,
      });

      expect(config.roomsPerFloor, 20);
      expect(config.branchFactorMin, 2);
      expect(config.branchFactorMax, 4);
      expect(config.eliteMin, 1);
      expect(config.eliteMax, 2);
      expect(config.eliteMinDepth, 3);
    });

    test('default constructor provides correct defaults', () {
      const config = DungeonBalanceConfig();

      expect(config.roomsPerFloor, 20);
      expect(config.branchFactorMin, 2);
      expect(config.branchFactorMax, 4);
      expect(config.eliteMin, 1);
      expect(config.eliteMax, 2);
      expect(config.eliteMinDepth, 3);
    });
  });
}
