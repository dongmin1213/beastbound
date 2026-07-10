import 'package:soul_dungeon/core/config/config_utils.dart';

/// 던전 맵 생성 밸런스 설정.
/// balance.json의 "dungeon" 섹션에서 파싱.
/// 모든 필드는 범위 검증 + 기본값 폴백.
class DungeonBalanceConfig {
  final int roomsPerFloor;
  final int branchFactorMin;
  final int branchFactorMax;
  final int eliteMin;
  final int eliteMax;
  final int eliteMinDepth;

  /// 잔여 노드 방 유형 가중치 (Phase 5).
  /// combatWeight + mysteryWeight + eventWeight = 100 권장.
  final int combatWeight;
  final int mysteryWeight;
  final int eventWeight;

  /// 경로당 최소 이벤트 방 수 (전직 기회 보장).
  final int minEventsPerPath;

  const DungeonBalanceConfig({
    this.roomsPerFloor = 20,
    this.branchFactorMin = 2,
    this.branchFactorMax = 4,
    this.eliteMin = 1,
    this.eliteMax = 2,
    this.eliteMinDepth = 3,
    this.combatWeight = 60,
    this.mysteryWeight = 25,
    this.eventWeight = 15,
    this.minEventsPerPath = 1,
  });

  factory DungeonBalanceConfig.fromJson(Map<String, dynamic> json) {
    var eliteMin = clampInt(json['elite_min'], 0, 3, 1, 'elite_min');
    var eliteMax = clampInt(json['elite_max'], 1, 4, 2, 'elite_max');
    // eliteMin <= eliteMax 보장 — 역전 시 스왑
    if (eliteMin > eliteMax) {
      final temp = eliteMin;
      eliteMin = eliteMax;
      eliteMax = temp;
    }
    return DungeonBalanceConfig(
      roomsPerFloor: clampInt(json['rooms_per_floor'], 8, 30, 20, 'rooms_per_floor'),
      branchFactorMin: clampInt(json['branch_factor_min'], 1, 4, 2, 'branch_factor_min'),
      branchFactorMax: clampInt(json['branch_factor_max'], 2, 5, 4, 'branch_factor_max'),
      eliteMin: eliteMin,
      eliteMax: eliteMax,
      eliteMinDepth: clampInt(json['elite_min_depth'], 1, 5, 3, 'elite_min_depth'),
      combatWeight: clampInt(json['combat_weight'], 0, 100, 60, 'combat_weight'),
      mysteryWeight: clampInt(json['mystery_weight'], 0, 100, 25, 'mystery_weight'),
      eventWeight: clampInt(json['event_weight'], 0, 100, 15, 'event_weight'),
      minEventsPerPath: clampInt(json['min_events_per_path'], 1, 5, 1, 'min_events_per_path'),
    );
  }
}
