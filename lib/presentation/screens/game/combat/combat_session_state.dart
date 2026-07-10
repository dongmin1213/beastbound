import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

/// 전투 세션의 immutable 상태 컨테이너.
/// currentEncounter, bossEncounter, bossPhaseIndex를 중앙 관리.
class CombatSessionState {
  final CombatEncounter? currentEncounter;
  final CombatEncounter? bossEncounter;
  final int currentBossPhaseIndex;

  const CombatSessionState({
    this.currentEncounter,
    this.bossEncounter,
    this.currentBossPhaseIndex = 0,
  });

  CombatSessionState copyWith({
    CombatEncounter? currentEncounter,
    CombatEncounter? bossEncounter,
    int? currentBossPhaseIndex,
    bool clearCurrentEncounter = false,
    bool clearBossEncounter = false,
  }) {
    return CombatSessionState(
      currentEncounter: clearCurrentEncounter
          ? null
          : (currentEncounter ?? this.currentEncounter),
      bossEncounter: clearBossEncounter
          ? null
          : (bossEncounter ?? this.bossEncounter),
      currentBossPhaseIndex:
          currentBossPhaseIndex ?? this.currentBossPhaseIndex,
    );
  }

  CombatSessionState resetBoss() {
    return copyWith(
      clearBossEncounter: true,
      currentBossPhaseIndex: 0,
    );
  }
}
