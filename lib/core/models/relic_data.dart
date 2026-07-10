import 'package:soul_dungeon/core/models/game_enums.dart';

/// 유물 데이터 — JSON 에셋에서 로드되는 불변 유물 정의.
class RelicData {
  final String id;
  final String name;
  final String description;
  final Rarity rarity;
  final String conditionType;
  final String passiveEffect;
  final int effectValue;

  const RelicData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.conditionType,
    required this.passiveEffect,
    this.effectValue = 0,
  });

  factory RelicData.fromJson(Map<String, dynamic> json) {
    return RelicData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: _parseRarity(json['rarity'] as String?),
      conditionType: json['condition_type'] as String,
      passiveEffect: json['passive_effect'] as String,
      effectValue: json['effect_value'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'rarity': rarity.name,
        'condition_type': conditionType,
        'passive_effect': passiveEffect,
        'effect_value': effectValue,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RelicData && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static Rarity _parseRarity(String? value) {
    if (value == null) return Rarity.common;
    return Rarity.values.where((r) => r.name == value).firstOrNull ??
        Rarity.common;
  }
}
