import 'package:soul_dungeon/core/models/game_enums.dart';

/// 축복 데이터 — JSON 에셋에서 로드되는 불변 축복 정의.
class BlessingData {
  final String id;
  final String name;
  final String description;
  final Rarity rarity;
  final String effectType;
  final int effectValue;
  final String? jobAffinity;

  const BlessingData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.effectType,
    this.effectValue = 0,
    this.jobAffinity,
  });

  factory BlessingData.fromJson(Map<String, dynamic> json) {
    return BlessingData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: _parseRarity(json['rarity'] as String?),
      effectType: json['effect_type'] as String,
      effectValue: json['effect_value'] as int? ?? 0,
      jobAffinity: json['job_affinity'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'rarity': rarity.name,
        'effect_type': effectType,
        'effect_value': effectValue,
        if (jobAffinity != null) 'job_affinity': jobAffinity,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BlessingData && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static Rarity _parseRarity(String? value) {
    if (value == null) return Rarity.common;
    return Rarity.values.where((r) => r.name == value).firstOrNull ??
        Rarity.common;
  }
}
