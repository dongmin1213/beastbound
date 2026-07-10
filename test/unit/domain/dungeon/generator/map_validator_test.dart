import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/domain/dungeon/error/dungeon_error.dart';
import 'package:soul_dungeon/domain/dungeon/generator/map_validator.dart';

import '../../../../helpers/floor_map_test_builder.dart';

void main() {
  const config = DungeonBalanceConfig();

  group('MapValidator', () {
    test('valid map passes validation', () {
      final map = FloorMapTestBuilder().withValidDefaults().build();
      final result = MapValidator.validate(map, config);
      expect(result, isA<Success<void>>());
    });

    test('map without shop on path fails with NoShopOnPath', () {
      final map = FloorMapTestBuilder()
          .withValidDefaults()
          .withoutShopOnPath()
          .build();
      final result = MapValidator.validate(map, config);
      expect(result, isA<Failure<void>>());
      expect((result as Failure).error, isA<NoShopOnPath>());
    });

    test('map without event/npc on path fails with NoEventOnPath', () {
      final map = FloorMapTestBuilder()
          .withValidDefaults()
          .withoutEventOrNpc()
          .build();
      final result = MapValidator.validate(map, config);
      expect(result, isA<Failure<void>>());
      expect((result as Failure).error, isA<NoEventOnPath>());
    });

    test('disconnected map fails with IsolatedNode or UnreachableBoss', () {
      final map = FloorMapTestBuilder()
          .withValidDefaults()
          .withUnreachableBoss()
          .build();
      final result = MapValidator.validate(map, config);
      expect(result, isA<Failure<void>>());
      final error = (result as Failure).error;
      expect(
        error is IsolatedNode || error is UnreachableBoss,
        isTrue,
        reason: 'Expected IsolatedNode or UnreachableBoss, got ${error.runtimeType}',
      );
    });

    test('excess elites fails with EliteCountOutOfRange', () {
      final map = FloorMapTestBuilder()
          .withValidDefaults()
          .withExcessElites()
          .build();
      final result = MapValidator.validate(map, config);
      expect(result, isA<Failure<void>>());
      final error = (result as Failure).error as EliteCountOutOfRange;
      expect(error.actual, greaterThan(config.eliteMax));
    });
  });
}
