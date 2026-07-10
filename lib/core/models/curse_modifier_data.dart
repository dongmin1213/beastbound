/// 저주 모디파이어 유형 — E9 4종 저주 분류.
///
/// 기존 [CurseData](악마의 거래)와 별개. 클리어 횟수 기반 난이도 증가.
enum CurseModifierType {
  /// 전투 저주: 매 전투 시작 시 적 힘 +N.
  combat,

  /// 덱 저주: 카드 보상 수 감소, 상점 가격 증가.
  deck,

  /// 카드 저주: 시작 덱에 저주 카드 추가 (Exhaust 불가, 손패 낭비).
  card,

  /// 서술자 저주: 왜곡 시작 층 앞당김.
  narrator,
}

/// 저주 모디파이어 데이터 — 클리어 횟수 기반 난이도 증가.
///
/// 기존 [CurseData](악마의 거래 부정 효과)와 구분.
/// E9 저주 시스템: 클리어 후 재도전 시 자동 적용.
class CurseModifierData {
  final String id;
  final String name;
  final String description;
  final CurseModifierType curseType;

  /// 저주 레벨 (0 = 비활성, 1~5 = 점진 강화).
  final int level;

  const CurseModifierData({
    required this.id,
    required this.name,
    required this.description,
    required this.curseType,
    this.level = 0,
  }) : assert(level >= 0 && level <= 5, 'Curse level must be 0~5');

  /// 활성 여부.
  bool get isActive => level > 0;

  /// 레벨 변경 복사.
  CurseModifierData withLevel(int newLevel) => CurseModifierData(
        id: id,
        name: name,
        description: description,
        curseType: curseType,
        level: newLevel.clamp(0, 5),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurseModifierData && id == other.id && level == other.level;

  @override
  int get hashCode => Object.hash(id, level);

  @override
  String toString() => 'CurseModifierData($id, level: $level)';
}
