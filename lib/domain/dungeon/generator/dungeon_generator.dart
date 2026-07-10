import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/config/floor_config.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/map_generated_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/dungeon/error/dungeon_error.dart';
import 'package:soul_dungeon/domain/dungeon/generator/map_generator.dart';
import 'package:soul_dungeon/domain/dungeon/generator/map_validator.dart';
import 'package:soul_dungeon/domain/dungeon/generator/room_placer.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/config/tutorial_config.dart';

/// 던전 맵 생성 통합 파이프라인 (facade).
/// generate → place → validate 순서. 검증 실패 시 최대 3회 재생성.
class DungeonGenerator {
  final DungeonBalanceConfig config;
  final FloorsConfig floorsConfig;
  final GameEventBus gameEventBus;
  final TutorialConfig tutorialConfig;
  bool _isFirstRun;

  /// 첫 런 여부 (읽기 전용).
  bool get isFirstRun => _isFirstRun;

  /// 첫 런 완료 처리 — 이후 generateFloor에서 튜토리얼 미적용.
  void markFirstRunDone() => _isFirstRun = false;

  static const int _maxAttempts = 10;

  DungeonGenerator({
    required this.config,
    this.floorsConfig = const FloorsConfig([]),
    required this.gameEventBus,
    this.tutorialConfig = const TutorialConfig(),
    bool isFirstRun = true,
  }) : _isFirstRun = isFirstRun;

  /// 층별 오버라이드가 적용된 config를 반환.
  DungeonBalanceConfig _configForFloor(int floor) {
    final override = floorsConfig.forFloor(floor);
    return config.withFloorOverride(override);
  }

  Result<FloorMap> generateFloor(int floor, int seed) {
    final floorConfig = _configForFloor(floor);

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final attemptSeed =
          (seed ^ (attempt * 0x9E3779B9)) & 0x7FFFFFFF;

      final rawMap = MapGenerator.generate(floor, attemptSeed, floorConfig);
      final placedMap = RoomPlacer.placeRooms(
        rawMap, floor, attemptSeed, floorConfig,
        tutorialConfig: tutorialConfig,
        isFirstRun: isFirstRun,
      );
      final validation = MapValidator.validate(placedMap, floorConfig);

      switch (validation) {
        case Success():
          GameLogger.info(LogSystem.dungeon,
              'Floor $floor generated: ${placedMap.nodes.length} nodes, seed=$attemptSeed');
          gameEventBus.emit(MapGeneratedEvent(
            floorNumber: floor,
            nodeCount: placedMap.nodes.length,
            seed: attemptSeed,
          ));
          return Success(placedMap);
        case Failure(:final error):
          GameLogger.warning(LogSystem.dungeon,
              'Floor $floor attempt ${attempt + 1}/$_maxAttempts failed: ${error.message}');
          continue;
      }
    }

    GameLogger.warning(LogSystem.dungeon,
        'Floor $floor generation exhausted after $_maxAttempts attempts');
    return const Failure(MapGenerationExhausted(attempts: _maxAttempts));
  }
}
