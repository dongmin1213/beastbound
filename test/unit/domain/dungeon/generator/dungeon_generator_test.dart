import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/config/floor_config.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/map_generated_event.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  const config = DungeonBalanceConfig();

  late GameEventBus eventBus;
  late DungeonGenerator generator;

  setUp(() {
    eventBus = GameEventBus();
    generator = DungeonGenerator(config: config, gameEventBus: eventBus);
  });

  tearDown(() {
    eventBus.dispose();
  });

  group('DungeonGenerator', () {
    test('successful pipeline returns valid FloorMap and emits event', () {
      final result = generator.generateFloor(1, 42);
      expect(result, isA<Success<FloorMap>>());

      final map = (result as Success<FloorMap>).data;
      expect(map.floorNumber, 1);
      expect(map.nodes.isNotEmpty, isTrue);

      // MapGeneratedEvent 발행 확인
      final events = eventBus.history
          .whereType<MapGeneratedEvent>()
          .toList();
      expect(events.length, 1);
      expect(events.first.floorNumber, 1);
      expect(events.first.nodeCount, map.nodes.length);
    });

    test('same seed produces identical map (deterministic)', () {
      final result1 = generator.generateFloor(1, 42);
      final result2 = generator.generateFloor(1, 42);

      expect(result1, isA<Success<FloorMap>>());
      expect(result2, isA<Success<FloorMap>>());

      final map1 = (result1 as Success<FloorMap>).data;
      final map2 = (result2 as Success<FloorMap>).data;

      expect(map1.nodes.length, map2.nodes.length);
      for (var i = 0; i < map1.nodes.length; i++) {
        expect(map1.nodes[i].id, map2.nodes[i].id);
        expect(map1.nodes[i].roomType, map2.nodes[i].roomType);
        expect(map1.nodes[i].depth, map2.nodes[i].depth);
      }
    });

    test('floor-aware 생성 — FloorsConfig 오버라이드 적용', () {
      final floorsConfig = FloorsConfig.fromJson([
        {},
        {},
        {},
        {},
        {'rooms_per_floor': 12, 'elite_min': 2, 'elite_max': 3, 'elite_min_depth': 2},
      ]);
      final floorGenerator = DungeonGenerator(
        config: config,
        floorsConfig: floorsConfig,
        gameEventBus: eventBus,
      );

      final result = floorGenerator.generateFloor(5, 42);
      expect(result, isA<Success<FloorMap>>());
      final map = (result as Success<FloorMap>).data;
      expect(map.floorNumber, 5);
      // 12개 방 설정이 적용됨
      expect(map.nodes.length, greaterThanOrEqualTo(12));
    });

    test('floor-aware 생성 — 엘리트 수 차이', () {
      final floorsConfig = FloorsConfig.fromJson([
        {'elite_min': 1, 'elite_max': 1},  // floor 1: 엘리트 최소
        {'elite_min': 2, 'elite_max': 3},  // floor 2: 엘리트 많음
      ]);
      final floorGenerator = DungeonGenerator(
        config: config,
        floorsConfig: floorsConfig,
        gameEventBus: eventBus,
      );

      final r1 = floorGenerator.generateFloor(1, 42);
      final r2 = floorGenerator.generateFloor(2, 42);

      expect(r1, isA<Success<FloorMap>>());
      expect(r2, isA<Success<FloorMap>>());

      final map1 = (r1 as Success<FloorMap>).data;
      final map2 = (r2 as Success<FloorMap>).data;

      final elites1 = map1.nodes.where((n) => n.roomType == RoomType.elite).length;
      final elites2 = map2.nodes.where((n) => n.roomType == RoomType.elite).length;

      expect(elites1, lessThanOrEqualTo(1));
      expect(elites2, greaterThanOrEqualTo(2));
    });

    test('FloorsConfig 미지정 → 기본 config로 동작', () {
      // floorsConfig 미전달 (기본값)
      final gen = DungeonGenerator(config: config, gameEventBus: eventBus);
      final result = gen.generateFloor(3, 42);
      expect(result, isA<Success<FloorMap>>());
    });

    test('1000 generations all produce valid maps', () {
      var successCount = 0;
      final failures = <int, String>{};
      for (var seed = 0; seed < 1000; seed++) {
        final result = generator.generateFloor(1, seed);
        if (result is Success<FloorMap>) {
          successCount++;
        } else if (result is Failure<FloorMap>) {
          failures[seed] = result.error.toString();
        }
      }
      // 99.9% 신뢰도 — 모든 시드에서 성공
      expect(successCount, 1000,
          reason: '$successCount/1000 succeeded. First 5 failures: ${failures.entries.take(5).map((e) => 'seed=${e.key}: ${e.value}').join(', ')}');
    });
  });
}
