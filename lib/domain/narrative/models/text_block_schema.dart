import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// enum name→value 안전 변환. 실패 시 fallback 반환 + 경고 로그.
T _safeByName<T extends Enum>(List<T> values, dynamic name, T fallback) {
  if (name is! String) return fallback;
  for (final v in values) {
    if (v.name == name) return v;
  }
  GameLogger.warning(
    LogSystem.narrative,
    'Unknown enum value "$name" for ${fallback.runtimeType}, using ${fallback.name}',
  );
  return fallback;
}

/// 콘텐츠 엔진용 텍스트 블록 스키마.
///
/// JSON 에셋(floor_*.json, boss_text.json 등)에서 로드되며,
/// 역인덱스 기반 태그 매칭으로 조건부 텍스트를 조회한다.
class TextBlockSchema {
  final String textId;
  final String text;
  final RunType runType;
  final BossDisposition bossDisposition;
  final bool reliable;
  final NarrativeLayer layer;
  final int floor;
  final RoomType roomType;
  final MemoryCategory memoryCategory;
  final String? skipFlag;
  final int priority;
  final double weight;
  final Set<String> tags;
  final List<String> specialTriggers;

  const TextBlockSchema({
    required this.textId,
    required this.text,
    required this.runType,
    required this.bossDisposition,
    required this.reliable,
    required this.layer,
    required this.floor,
    required this.roomType,
    this.memoryCategory = MemoryCategory.none,
    this.skipFlag,
    this.priority = 0,
    this.weight = 1.0,
    this.tags = const {},
    this.specialTriggers = const [],
  });

  factory TextBlockSchema.fromJson(Map<String, dynamic> json) {
    return TextBlockSchema(
      textId: json['text_id'] as String,
      text: json['text'] as String,
      runType: _safeByName(RunType.values, json['run_type'], RunType.first),
      bossDisposition: _safeByName(
          BossDisposition.values, json['boss_disposition'], BossDisposition.none),
      reliable: json['reliable'] as bool,
      layer: _safeByName(NarrativeLayer.values, json['layer'], NarrativeLayer.l1),
      floor: json['floor'] as int,
      roomType: _safeByName(RoomType.values, json['room_type'], RoomType.combat),
      memoryCategory: json['memory_category'] != null
          ? _safeByName(MemoryCategory.values, json['memory_category'], MemoryCategory.none)
          : MemoryCategory.none,
      skipFlag: json['skip_flag'] as String?,
      priority: json['priority'] as int? ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toSet() ??
          const {},
      specialTriggers: (json['special_triggers'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'text_id': textId,
        'text': text,
        'run_type': runType.name,
        'boss_disposition': bossDisposition.name,
        'reliable': reliable,
        'layer': layer.name,
        'floor': floor,
        'room_type': roomType.name,
        'memory_category': memoryCategory.name,
        if (skipFlag != null) 'skip_flag': skipFlag,
        'priority': priority,
        'weight': weight,
        'tags': tags.toList(),
        'special_triggers': specialTriggers,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextBlockSchema && textId == other.textId;

  @override
  int get hashCode => textId.hashCode;
}
