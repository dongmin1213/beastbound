import 'package:soul_dungeon/core/models/game_enums.dart';

/// 튜토리얼 설정 — 첫 런 floor 1의 처음 방을 고정 배치.
class TutorialConfig {
  final bool enabled;
  final Map<int, RoomType> fixedDepthRooms;

  const TutorialConfig({
    this.enabled = true,
    this.fixedDepthRooms = const {
      0: RoomType.combat,
      1: RoomType.event,
    },
  });

  factory TutorialConfig.fromJson(Map<String, dynamic> json) {
    final enabled = json['enabled'] as bool? ?? true;
    final rawValue = json['fixed_depth_rooms'];
    final fixedRoomsRaw = rawValue is Map ? Map<String, dynamic>.from(rawValue) : null;

    final fixedRooms = <int, RoomType>{};
    if (fixedRoomsRaw != null) {
      for (final entry in fixedRoomsRaw.entries) {
        final depth = int.tryParse(entry.key);
        if (depth == null) continue;
        final typeName = entry.value as String?;
        if (typeName == null) continue;
        final roomType = RoomType.values.where((t) => t.name == typeName).firstOrNull;
        if (roomType != null) {
          fixedRooms[depth] = roomType;
        }
      }
    }

    return TutorialConfig(
      enabled: enabled,
      fixedDepthRooms: fixedRooms.isEmpty
          ? const {0: RoomType.combat, 1: RoomType.event}
          : fixedRooms,
    );
  }

  /// 튜토리얼이 해당 층에 적용되는지 확인.
  bool appliesTo({required int floor, required bool isFirstRun}) {
    return enabled && floor == 1 && isFirstRun;
  }
}
