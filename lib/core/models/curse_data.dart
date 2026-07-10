import 'package:soul_dungeon/core/models/game_enums.dart';

/// 저주 데이터 — 악마의 거래로 부여되는 부정적 효과.
///
/// BlessingData와 병렬 구조. effectType으로 효과 분류,
/// effectValue로 강도 지정.
class CurseData {
  final String id;
  final String name;
  final String description;
  final Rarity rarity;
  final String effectType;
  final int effectValue;

  const CurseData({
    required this.id,
    required this.name,
    required this.description,
    this.rarity = Rarity.cursed,
    required this.effectType,
    required this.effectValue,
  });

  factory CurseData.fromJson(Map<String, dynamic> json) {
    return CurseData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: _parseRarity(json['rarity'] as String?),
      effectType: json['effect_type'] as String,
      effectValue: (json['effect_value'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'rarity': rarity.name,
        'effect_type': effectType,
        'effect_value': effectValue,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CurseData && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static Rarity _parseRarity(String? value) {
    if (value == null) return Rarity.cursed;
    return Rarity.values.where((r) => r.name == value).firstOrNull ??
        Rarity.cursed;
  }
}
