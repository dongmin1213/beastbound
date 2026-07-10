/// 적 변형 수식어 — 기존 적에 접두사 + 스탯 변형.
enum EnemyModifierType {
  /// 강화된: HP×1.3, ATK×1.2
  enhanced,

  /// 맹독: 공격 시 독 3 부여
  venomous,

  /// 분노한: ATK×1.2, DEF×0.7
  enraged,

  /// 단단한: DEF×2.0, HP×1.1
  hardened,

  /// 신속한: 패턴에 attack 1개 추가
  swift,
}

extension EnemyModifierTypeX on EnemyModifierType {
  String get prefix => switch (this) {
        EnemyModifierType.enhanced => '강화된',
        EnemyModifierType.venomous => '맹독',
        EnemyModifierType.enraged => '분노한',
        EnemyModifierType.hardened => '단단한',
        EnemyModifierType.swift => '신속한',
      };
}
