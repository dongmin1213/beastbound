import 'package:soul_dungeon/core/config/floor_region.dart';

/// BGM ID -> asset path mapping.
/// 8종 BGM: 탐색 5지역 + 전투 3종 (일반/엘리트/보스).
class BgmRegistry {
  BgmRegistry._();

  static const Map<String, String> _registry = {
    // Exploration BGM (floor-specific)
    'exploration_floor1': 'assets/audio/music/exploration_floor1.ogg',
    'exploration_floor2': 'assets/audio/music/exploration_floor2.ogg',
    'exploration_floor3': 'assets/audio/music/exploration_floor3.ogg',
    'exploration_floor4': 'assets/audio/music/exploration_floor4.ogg',
    'exploration_floor5': 'assets/audio/music/exploration_floor5.ogg',
    // Combat BGM
    'combat_normal': 'assets/audio/music/combat_normal.ogg',
    'combat_elite': 'assets/audio/music/combat_elite.ogg',
    'combat_boss': 'assets/audio/music/combat_boss.ogg',
  };

  /// BGM ID -> asset path. Returns null if not registered.
  static String? pathFor(String bgmId) => _registry[bgmId];

  /// All registered BGM IDs.
  static List<String> get allIds => _registry.keys.toList();

  /// Total registered count.
  static int get count => _registry.length;

  /// 층 번호 -> 탐색 BGM ID. 5지역이 각 2층에 걸치므로 지역 기준 트랙 사용.
  static String explorationBgmForFloor(int floor) {
    final region = FloorRegion.of(floor);
    return 'exploration_floor$region';
  }

  /// 전투 유형 -> 전투 BGM ID.
  static String combatBgm({bool isBoss = false, bool isElite = false}) {
    if (isBoss) return 'combat_boss';
    if (isElite) return 'combat_elite';
    return 'combat_normal';
  }
}
