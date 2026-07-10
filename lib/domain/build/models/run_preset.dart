/// 런 프리셋 — 반복 런 시 빠른 선택을 위한 저장 데이터.
///
/// 준비 페이즈 선택을 기록하여 다음 런에서 빠르게 재사용.
class RunPreset {
  final String id;
  final String name;

  /// 준비 페이즈에서 선택한 보너스 ID (prep_gold, prep_hp, prep_blessing).
  final String prepChoiceId;

  /// 프리셋 생성 시각 (정렬/관리용).
  final DateTime createdAt;

  const RunPreset({
    required this.id,
    required this.name,
    required this.prepChoiceId,
    required this.createdAt,
  });

  factory RunPreset.fromJson(Map<String, dynamic> json) {
    return RunPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      prepChoiceId: json['prep_choice_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'prep_choice_id': prepChoiceId,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RunPreset && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
