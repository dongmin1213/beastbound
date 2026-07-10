import 'package:soul_dungeon/core/config/config_utils.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';

/// 층별 난이도 오버라이드 설정.
///
/// null 필드는 기본 DungeonBalanceConfig 값을 사용한다.
class FloorConfig {
  final int? roomsPerFloor;
  final int? eliteMin;
  final int? eliteMax;
  final int? eliteMinDepth;
  final int? minEventsPerPath;
  final int? combatWeight;
  final int? mysteryWeight;
  final int? eventWeight;
  final double enemyHpMultiplier;
  final double goldMultiplier;

  const FloorConfig({
    this.roomsPerFloor,
    this.eliteMin,
    this.eliteMax,
    this.eliteMinDepth,
    this.minEventsPerPath,
    this.combatWeight,
    this.mysteryWeight,
    this.eventWeight,
    this.enemyHpMultiplier = 1.0,
    this.goldMultiplier = 1.0,
  });

  factory FloorConfig.fromJson(Map<String, dynamic> json) {
    final rawRooms = (json['rooms_per_floor'] as num?)?.toInt();
    final rawEliteMin = (json['elite_min'] as num?)?.toInt();
    final rawEliteMax = (json['elite_max'] as num?)?.toInt();
    final rawEliteMinDepth = (json['elite_min_depth'] as num?)?.toInt();
    final rawMinEvents = (json['min_events_per_path'] as num?)?.toInt();
    final rawCombatWeight = (json['combat_weight'] as num?)?.toInt();
    final rawMysteryWeight = (json['mystery_weight'] as num?)?.toInt();
    final rawEventWeight = (json['event_weight'] as num?)?.toInt();
    final rawHpMult = (json['enemy_hp_multiplier'] as num?)?.toDouble() ?? 1.0;
    final rawGoldMult = (json['gold_multiplier'] as num?)?.toDouble() ?? 1.0;

    return FloorConfig(
      roomsPerFloor: rawRooms != null
          ? clampInt(rawRooms, 5, 30, 16, 'floor_rooms_per_floor')
          : null,
      eliteMin: rawEliteMin != null
          ? clampInt(rawEliteMin, 0, 5, 1, 'floor_elite_min')
          : null,
      eliteMax: rawEliteMax != null
          ? clampInt(rawEliteMax, 0, 5, 2, 'floor_elite_max')
          : null,
      eliteMinDepth: rawEliteMinDepth != null
          ? clampInt(rawEliteMinDepth, 0, 10, 3, 'floor_elite_min_depth')
          : null,
      minEventsPerPath: rawMinEvents != null
          ? clampInt(rawMinEvents, 1, 5, 1, 'floor_min_events_per_path')
          : null,
      combatWeight: rawCombatWeight != null
          ? clampInt(rawCombatWeight, 0, 100, 60, 'floor_combat_weight')
          : null,
      mysteryWeight: rawMysteryWeight != null
          ? clampInt(rawMysteryWeight, 0, 100, 25, 'floor_mystery_weight')
          : null,
      eventWeight: rawEventWeight != null
          ? clampInt(rawEventWeight, 0, 100, 15, 'floor_event_weight')
          : null,
      enemyHpMultiplier: rawHpMult.clamp(0.1, 10.0),
      goldMultiplier: rawGoldMult.clamp(0.1, 10.0),
    );
  }
}

/// 5층 전체 설정 — balance.json "floors" 배열에서 파싱.
class FloorsConfig {
  final List<FloorConfig> _floors;

  const FloorsConfig(this._floors);

  /// 층 번호(1-based)에 해당하는 FloorConfig를 반환.
  /// 범위 밖이면 기본 FloorConfig.
  FloorConfig forFloor(int floor) {
    final index = floor - 1;
    if (index < 0 || index >= _floors.length) {
      return const FloorConfig();
    }
    return _floors[index];
  }

  int get length => _floors.length;

  factory FloorsConfig.fromJson(List<dynamic>? json) {
    if (json == null || json.isEmpty) {
      GameLogger.warning(
        LogSystem.core,
        'No floors config found, using defaults for all floors',
      );
      return const FloorsConfig([]);
    }

    final floors = <FloorConfig>[];
    for (var i = 0; i < json.length; i++) {
      try {
        floors.add(FloorConfig.fromJson(json[i] as Map<String, dynamic>));
      } catch (e) {
        GameLogger.warning(
          LogSystem.core,
          'Invalid floor config at index $i, using defaults: $e',
        );
        floors.add(const FloorConfig());
      }
    }
    return FloorsConfig(floors);
  }
}

/// DungeonBalanceConfig에 floor-aware 머지 기능 확장.
extension FloorAwareDungeonConfig on DungeonBalanceConfig {
  /// 기본 설정에 층별 오버라이드를 적용한 새 config를 반환.
  DungeonBalanceConfig withFloorOverride(FloorConfig override) {
    var effectiveEliteMin = override.eliteMin ?? eliteMin;
    var effectiveEliteMax = override.eliteMax ?? eliteMax;
    if (effectiveEliteMin > effectiveEliteMax) {
      final temp = effectiveEliteMin;
      effectiveEliteMin = effectiveEliteMax;
      effectiveEliteMax = temp;
    }

    return DungeonBalanceConfig(
      roomsPerFloor: clampInt(
        override.roomsPerFloor ?? roomsPerFloor,
        8, 30, roomsPerFloor, 'floor_rooms_per_floor',
      ),
      branchFactorMin: branchFactorMin,
      branchFactorMax: branchFactorMax,
      eliteMin: clampInt(effectiveEliteMin, 0, 3, eliteMin, 'floor_elite_min'),
      eliteMax: clampInt(effectiveEliteMax, 1, 4, eliteMax, 'floor_elite_max'),
      eliteMinDepth: clampInt(
        override.eliteMinDepth ?? eliteMinDepth,
        1, 5, eliteMinDepth, 'floor_elite_min_depth',
      ),
      combatWeight: clampInt(
        override.combatWeight ?? combatWeight,
        0, 100, combatWeight, 'floor_combat_weight',
      ),
      mysteryWeight: clampInt(
        override.mysteryWeight ?? mysteryWeight,
        0, 100, mysteryWeight, 'floor_mystery_weight',
      ),
      eventWeight: clampInt(
        override.eventWeight ?? eventWeight,
        0, 100, eventWeight, 'floor_event_weight',
      ),
      minEventsPerPath: clampInt(
        override.minEventsPerPath ?? minEventsPerPath,
        1, 5, minEventsPerPath, 'floor_min_events_per_path',
      ),
    );
  }
}
