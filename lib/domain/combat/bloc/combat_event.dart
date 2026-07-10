import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_encounter_data.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

/// CombatBloc 이벤트 (sealed class — switch exhaustiveness 보장).
sealed class CombatEvent extends Equatable {
  const CombatEvent();
}

/// 전투 시작.
final class StartCombat extends CombatEvent {
  final CombatEncounterData encounter;
  final PlayerRunState playerRunState;

  const StartCombat({
    required this.encounter,
    required this.playerRunState,
  });

  @override
  List<Object?> get props => [encounter, playerRunState];
}

/// 행동 선택. MomentumTier는 presentation이 MomentumBloc에서 읽어 전달.
final class SelectAction extends CombatEvent {
  final ActionType actionType;
  final MomentumTier currentMomentumTier;

  const SelectAction(
    this.actionType, {
    required this.currentMomentumTier,
  });

  @override
  List<Object?> get props => [actionType, currentMomentumTier];
}

/// 특수 행동 선택 (직업 고유 행동).
final class SelectSpecialAction extends CombatEvent {
  final String specialActionType;
  final MomentumTier currentMomentumTier;

  const SelectSpecialAction(
    this.specialActionType, {
    required this.currentMomentumTier,
  });

  @override
  List<Object?> get props => [specialActionType, currentMomentumTier];
}

/// 환경 행동 선택.
final class SelectEnvironmentAction extends CombatEvent {
  final String clueId;
  final MomentumTier currentMomentumTier;

  const SelectEnvironmentAction(
    this.clueId, {
    required this.currentMomentumTier,
  });

  @override
  List<Object?> get props => [clueId, currentMomentumTier];
}

/// 전투 결과 판정.
final class ResolveCombat extends CombatEvent {
  const ResolveCombat();

  @override
  List<Object?> get props => [];
}

/// 퍼마데스 후 런 재시작.
final class RestartRun extends CombatEvent {
  final int maxHp;

  const RestartRun({required this.maxHp});

  @override
  List<Object?> get props => [maxHp];
}

/// 전투 종료 → idle 복귀.
final class EndCombat extends CombatEvent {
  const EndCombat();

  @override
  List<Object?> get props => [];
}

/// 보스 다음 페이즈 진행.
final class ContinueBossPhase extends CombatEvent {
  const ContinueBossPhase();

  @override
  List<Object?> get props => [];
}

// ── 카드 전투 이벤트 ──────────────────────────────────────

/// 카드 전투 시작 — 멀티몹 지원.
final class StartCardCombat extends CombatEvent {
  final List<EnemyCombatData> enemies;
  final List<CardData> masterDeck;
  final PlayerRunState playerRunState;
  final int momentumTier;
  final RoomType roomType;
  final int currentMomentum;

  /// 보상 카드 직업 오버라이드 (유령 PvP: 유령 직업 카드 보상).
  final String? rewardJobOverride;

  /// 이번 런 로스터 몬스터 id (스타터+길들인). 비어있지 않으면 승리 보상이
  /// 이 몬스터들의 무브풀에서 나온다 (몬스터 테이밍 컨셉).
  final List<String> rewardMonsterIds;

  const StartCardCombat({
    required this.enemies,
    required this.masterDeck,
    required this.playerRunState,
    this.momentumTier = 1,
    this.roomType = RoomType.combat,
    this.currentMomentum = 0,
    this.rewardJobOverride,
    this.rewardMonsterIds = const [],
  });

  @override
  List<Object?> get props => [
        enemies, masterDeck, playerRunState, momentumTier, roomType,
        currentMomentum, rewardJobOverride, rewardMonsterIds,
      ];
}

/// 카드 플레이.
final class PlayCard extends CombatEvent {
  final String cardId;
  final int momentumTier;
  /// 손패 내 카드 인덱스 — 동일 ID 카드 구분용.
  final int handIndex;

  const PlayCard(this.cardId, {this.momentumTier = 1, this.handIndex = -1});

  @override
  List<Object?> get props => [cardId, momentumTier, handIndex];
}

/// 플레이어 턴 종료.
final class EndPlayerTurn extends CombatEvent {
  final int momentumTier;

  const EndPlayerTurn({this.momentumTier = 1});

  @override
  List<Object?> get props => [momentumTier];
}

/// 카드 보상 선택 (null = 건너뛰기).
final class SelectCardReward extends CombatEvent {
  final String? selectedCardId;

  const SelectCardReward({this.selectedCardId});

  @override
  List<Object?> get props => [selectedCardId];
}

/// 카드 보스 전투 시작.
final class StartCardBossCombat extends CombatEvent {
  final BossCombatData bossData;
  final List<CardData> masterDeck;
  final PlayerRunState playerRunState;
  final int momentumTier;
  final int currentMomentum;

  const StartCardBossCombat({
    required this.bossData,
    required this.masterDeck,
    required this.playerRunState,
    this.momentumTier = 1,
    this.currentMomentum = 0,
  });

  @override
  List<Object?> get props =>
      [bossData, masterDeck, playerRunState, momentumTier, currentMomentum];
}

/// 카드 보스 다음 페이즈 진행.
final class ContinueCardBossPhase extends CombatEvent {
  final int momentumTier;

  const ContinueCardBossPhase({this.momentumTier = 1});

  @override
  List<Object?> get props => [momentumTier];
}

/// 저장된 카드 전투 상태 복원 (이어하기).
final class RestoreCardCombat extends CombatEvent {
  final CardCombatActive savedState;

  const RestoreCardCombat({required this.savedState});

  @override
  List<Object?> get props => [savedState];
}

/// 멀티몹 타겟 선택.
final class SelectTarget extends CombatEvent {
  final int targetIndex;

  const SelectTarget(this.targetIndex);

  @override
  List<Object?> get props => [targetIndex];
}

/// 도주 시도.
final class AttemptFlee extends CombatEvent {
  final int momentumTier;

  const AttemptFlee({this.momentumTier = 1});

  @override
  List<Object?> get props => [momentumTier];
}

/// 제압된 적 길들이기 — 처치 대신 포획으로 전투 종료.
/// [index]의 적이 제압 상태(HP ≤ 임계치, 생존)일 때만 유효.
final class TameEnemy extends CombatEvent {
  final int index;

  const TameEnemy(this.index);

  @override
  List<Object?> get props => [index];
}

// ── 디버그 전용 이벤트 (kDebugMode only) ──────────────────

/// 디버그: AP를 99로 설정.
final class DebugSetAp extends CombatEvent {
  const DebugSetAp();

  @override
  List<Object?> get props => [];
}

/// 디버그: 갓 모드 토글 (데미지로 사망하지 않음).
final class DebugSetGodMode extends CombatEvent {
  final bool enabled;

  const DebugSetGodMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
