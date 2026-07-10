/// 게임 Phase sealed class — HSM 최하위 레벨.
/// switch exhaustiveness로 모든 Phase 분기를 컴파일 타임에 강제.
sealed class GamePhase {
  const GamePhase();
}

/// 탐색 Phase — 미니맵 표시, 경로 선택 가능.
class ExplorationPhase extends GamePhase {
  const ExplorationPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExplorationPhase;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ExplorationPhase';
}

/// 전투 Phase — combat/elite 방 진입 시.
class CombatPhase extends GamePhase {
  const CombatPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CombatPhase;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CombatPhase';
}

/// 이벤트 Phase — event 방 진입 시.
class EventPhase extends GamePhase {
  const EventPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EventPhase;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'EventPhase';
}

/// 상점 Phase — shop 방 진입 시.
class ShopPhase extends GamePhase {
  const ShopPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShopPhase;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ShopPhase';
}

/// 휴식 Phase — rest 방 진입 시.
class RestPhase extends GamePhase {
  const RestPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RestPhase;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'RestPhase';
}

/// 보스 Phase — boss 방 진입 시.
class BossPhase extends GamePhase {
  const BossPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BossPhase;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'BossPhase';
}

/// NPC Phase — npc 방 진입 시.
class NpcPhase extends GamePhase {
  const NpcPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NpcPhase;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'NpcPhase';
}

/// 미스터리 Phase — mystery 방 진입 시.
class MysteryPhase extends GamePhase {
  const MysteryPhase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MysteryPhase;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'MysteryPhase';
}
