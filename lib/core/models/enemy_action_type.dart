/// 적 행동 유형 — domain 레이어.
/// presentation의 EnemyAction, CombatBloc 등이 공통으로 참조.
enum EnemyActionType {
  attack,
  defend,
  observe,
  heavy,
  charge,
  heal,
  buff;

  /// 공격 배율.
  double get attackMultiplier => switch (this) {
        EnemyActionType.attack => 1.0,
        EnemyActionType.heavy => 1.8,
        _ => 0.0,
      };

  /// 공격 행동 여부.
  bool get isAttack => this == attack || this == heavy;

  String get displayName => switch (this) {
        EnemyActionType.attack => '공격',
        EnemyActionType.defend => '방어',
        EnemyActionType.observe => '관찰',
        EnemyActionType.heavy => '강공격',
        EnemyActionType.charge => '충전',
        EnemyActionType.heal => '회복',
        EnemyActionType.buff => '강화',
      };
}
