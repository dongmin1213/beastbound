import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/domain/combat/models/boss_phase_data.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 도메인 레벨 전투 조우 데이터. CombatBloc이 필요한 기계적 데이터만 보유.
/// 표시 텍스트(introText, victoryText 등)는 presentation의 CombatEncounter에 유지.
class CombatEncounterData extends Equatable {
  final RoomType roomType;
  final String enemyName;
  final List<EnvironmentClue> environmentClues;
  final List<CombatTurnInfo> turns;
  final List<BossPhaseData>? bossPhases;

  const CombatEncounterData({
    required this.roomType,
    required this.enemyName,
    this.environmentClues = const [],
    required this.turns,
    this.bossPhases,
  });

  int get totalTurns => turns.length;

  /// 보스 인카운터 여부 — bossPhases가 비어있지 않으면 true.
  bool get isBoss => bossPhases != null && bossPhases!.isNotEmpty;

  /// 보스 총 페이즈 수 — 비보스는 1.
  int get totalBossPhases => isBoss ? bossPhases!.length : 1;

  @override
  List<Object?> get props =>
      [roomType, enemyName, environmentClues, turns, bossPhases];
}

/// 도메인 레벨 전투 턴 정보. 적 행동 유형만 보유.
class CombatTurnInfo extends Equatable {
  final int turnNumber;
  final EnemyActionType enemyAction;

  const CombatTurnInfo({
    required this.turnNumber,
    required this.enemyAction,
  });

  @override
  List<Object?> get props => [turnNumber, enemyAction];
}
