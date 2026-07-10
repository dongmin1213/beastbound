import 'package:soul_dungeon/core/models/enemy_action_type.dart';
export 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 하위 호환 — 기존 코드에서 PlayerActionType으로 참조하던 곳 호환 유지.
typedef PlayerActionType = ActionType;

/// ActionType의 표시용 접두사 (presentation 레이어 전용)
extension ActionTypePrefix on ActionType {
  String get prefix => switch (this) {
        ActionType.attack => '⚔ ',
        ActionType.defend => '🛡 ',
        ActionType.observe => '👁 ',
        ActionType.environment => '🌿 ',
        ActionType.special => '★ ',
      };
}

/// EnemyActionType의 표시용 접두사 (presentation 레이어 전용)
extension EnemyActionTypePrefix on EnemyActionType {
  /// 행동 유형별 접두사 (⚔ / 🛡 / 👁)
  String get prefix => switch (this) {
        EnemyActionType.attack || EnemyActionType.heavy => '⚔ ',
        EnemyActionType.defend ||
        EnemyActionType.charge ||
        EnemyActionType.heal ||
        EnemyActionType.buff =>
          '🛡 ',
        EnemyActionType.observe => '👁 ',
      };
}

/// 적 행동 1개
class EnemyAction {
  final EnemyActionType type;
  final String previewText;
  final int threatLevel;

  const EnemyAction({
    required this.type,
    required this.previewText,
    this.threatLevel = 1,
  });
}

/// 전투 1턴 데이터
class CombatTurnData {
  final int turnNumber;
  final EnemyAction enemyAction;
  final List<ChoiceData> playerChoices;

  const CombatTurnData({
    required this.turnNumber,
    required this.enemyAction,
    required this.playerChoices,
  });
}

/// 전투 조우 전체
/// 보스 페이즈 데이터 (presentation).
class BossPhasePresentation {
  final String introText;
  final List<CombatTurnData> turns;
  final String? transitionText;

  const BossPhasePresentation({
    required this.introText,
    required this.turns,
    this.transitionText,
  });
}

/// 시너지 판정 결과 — 폭발 연출 트리거.
class SynergyInfo {
  /// 큰 데미지 (20+).
  final bool isBigDamage;

  /// 힘 스태킹 폭발 (strengthBonus 5+).
  final bool isStrengthBurst;

  /// 연속 공격 콤보 (3+).
  final bool isCombo;

  /// 하나라도 시너지가 있는지.
  final bool hasSynergy;

  const SynergyInfo({
    this.isBigDamage = false,
    this.isStrengthBurst = false,
    this.isCombo = false,
    this.hasSynergy = false,
  });
}

class CombatEncounter {
  final RoomType roomType;
  final String enemyName;
  final String? environmentText;
  final List<EnvironmentClue> environmentClues;
  final String introText;
  final List<CombatTurnData> turns;
  final String victoryText;
  final String defeatText;
  final List<BossPhasePresentation>? bossPhases;

  const CombatEncounter({
    this.roomType = RoomType.combat,
    required this.enemyName,
    this.environmentText,
    this.environmentClues = const [],
    required this.introText,
    required this.turns,
    required this.victoryText,
    required this.defeatText,
    this.bossPhases,
  });
}
