import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/card_blessing_data.dart';
import 'package:soul_dungeon/core/models/card_relic_data.dart';
import 'package:soul_dungeon/domain/combat/logic/card_effect_resolver.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_defeat_handler.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_result_calculator.dart';
import 'package:soul_dungeon/domain/combat/logic/enemy_ai.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_encounter_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_turn_result.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/domain/combat/models/enemy_battle_state.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

/// CombatBloc 상태 (sealed class — switch exhaustiveness 보장).
sealed class CombatState extends Equatable {
  const CombatState();
}

/// 전투 대기 (초기 상태).
final class CombatIdle extends CombatState {
  const CombatIdle();

  @override
  List<Object?> get props => [];
}

/// 전투 진행 중.
final class CombatActive extends CombatState {
  final CombatEncounterData encounter;
  final int currentTurnIndex;
  final List<CombatTurnResult> turnResults;
  final PlayerRunState playerRunState;
  final bool hpDeductedForCurrentEncounter;
  final bool environmentUnlocked;
  final List<EnvironmentClue> discoveredClues;
  final int currentBossPhaseIndex;

  const CombatActive({
    required this.encounter,
    this.currentTurnIndex = 0,
    this.turnResults = const [],
    required this.playerRunState,
    this.hpDeductedForCurrentEncounter = false,
    this.environmentUnlocked = false,
    this.discoveredClues = const [],
    this.currentBossPhaseIndex = 0,
  });

  /// 전체 턴 수.
  int get totalTurns => encounter.totalTurns;

  /// 모든 턴 완료 여부.
  bool get allTurnsCompleted => currentTurnIndex >= totalTurns;

  /// 현재 턴 정보 (모든 턴 완료 시 null).
  CombatTurnInfo? get currentTurn =>
      currentTurnIndex < totalTurns
          ? encounter.turns[currentTurnIndex]
          : null;

  /// 마지막으로 추가된 턴 결과 (UI가 참조).
  CombatTurnResult? get lastTurnResult =>
      turnResults.isNotEmpty ? turnResults.last : null;

  CombatActive copyWith({
    CombatEncounterData? encounter,
    int? currentTurnIndex,
    List<CombatTurnResult>? turnResults,
    PlayerRunState? playerRunState,
    bool? hpDeductedForCurrentEncounter,
    bool? environmentUnlocked,
    List<EnvironmentClue>? discoveredClues,
    int? currentBossPhaseIndex,
  }) {
    return CombatActive(
      encounter: encounter ?? this.encounter,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      turnResults: turnResults ?? this.turnResults,
      playerRunState: playerRunState ?? this.playerRunState,
      hpDeductedForCurrentEncounter:
          hpDeductedForCurrentEncounter ?? this.hpDeductedForCurrentEncounter,
      environmentUnlocked: environmentUnlocked ?? this.environmentUnlocked,
      discoveredClues: discoveredClues ?? this.discoveredClues,
      currentBossPhaseIndex:
          currentBossPhaseIndex ?? this.currentBossPhaseIndex,
    );
  }

  @override
  List<Object?> get props => [
        encounter,
        currentTurnIndex,
        turnResults,
        playerRunState,
        hpDeductedForCurrentEncounter,
        environmentUnlocked,
        discoveredClues,
        currentBossPhaseIndex,
      ];
}

/// 전투 결과 확정.
final class CombatResolved extends CombatState {
  final CombatEncounterData encounter;
  final CombatResultScore resultScore;
  final PlayerRunState playerRunState;
  final bool hpDeductedForCurrentEncounter;
  final int? hpLost;
  final HpNarrationTier? hpNarrationTier;
  final bool isPermadeath;

  const CombatResolved({
    required this.encounter,
    required this.resultScore,
    required this.playerRunState,
    this.hpDeductedForCurrentEncounter = false,
    this.hpLost,
    this.hpNarrationTier,
    this.isPermadeath = false,
  });

  @override
  List<Object?> get props => [
        encounter,
        resultScore,
        playerRunState,
        hpDeductedForCurrentEncounter,
        hpLost,
        hpNarrationTier,
        isPermadeath,
      ];
}

/// 보스 페이즈 전환 (중간 상태).
final class BossPhaseTransition extends CombatState {
  final CombatEncounterData encounter;
  final int completedPhaseIndex;
  final int nextPhaseIndex;
  final PlayerRunState playerRunState;

  const BossPhaseTransition({
    required this.encounter,
    required this.completedPhaseIndex,
    required this.nextPhaseIndex,
    required this.playerRunState,
  });

  @override
  List<Object?> get props =>
      [encounter, completedPhaseIndex, nextPhaseIndex, playerRunState];
}

// ── 카드 전투 하위 객체 ──────────────────────────────────

/// 턴 종료 시 리셋되는 플래그 — _onEndPlayerTurn에서 `const TurnFlags()`로 초기화.
final class TurnFlags extends Equatable {
  final bool immuneThisTurn;
  final bool doubleNextAttack;
  final bool exhaustHandAtTurnEnd;
  final int attacksPlayedThisTurn;
  final int cardsPlayedThisTurn;
  final int apModifierNextTurn;
  final int blockRetainPercent;
  final Set<CardType> typesPlayedThisTurn;

  /// 턴 종료 시 남은 AP × value 블록 (절약 카드).
  final int remainingApBlockValue;

  /// 이번 턴 Skill 사용 수 (skillCountDamage 카드용).
  final int skillsPlayedThisTurn;

  /// 마지막 플레이 카드 타입 (연쇄 보너스용).
  final CardType? lastPlayedCardType;

  /// 연쇄 카운터 — 같은 타입 연속 사용 수 (1=첫 장, 2=2연쇄, 3=3연쇄).
  final int chainCount;

  const TurnFlags({
    this.immuneThisTurn = false,
    this.doubleNextAttack = false,
    this.exhaustHandAtTurnEnd = false,
    this.attacksPlayedThisTurn = 0,
    this.cardsPlayedThisTurn = 0,
    this.apModifierNextTurn = 0,
    this.blockRetainPercent = 0,
    this.typesPlayedThisTurn = const {},
    this.remainingApBlockValue = 0,
    this.skillsPlayedThisTurn = 0,
    this.lastPlayedCardType,
    this.chainCount = 0,
  });

  TurnFlags copyWith({
    bool? immuneThisTurn,
    bool? doubleNextAttack,
    bool? exhaustHandAtTurnEnd,
    int? attacksPlayedThisTurn,
    int? cardsPlayedThisTurn,
    int? apModifierNextTurn,
    int? blockRetainPercent,
    Set<CardType>? typesPlayedThisTurn,
    int? remainingApBlockValue,
    int? skillsPlayedThisTurn,
    CardType? lastPlayedCardType,
    int? chainCount,
  }) {
    return TurnFlags(
      immuneThisTurn: immuneThisTurn ?? this.immuneThisTurn,
      doubleNextAttack: doubleNextAttack ?? this.doubleNextAttack,
      exhaustHandAtTurnEnd: exhaustHandAtTurnEnd ?? this.exhaustHandAtTurnEnd,
      attacksPlayedThisTurn: attacksPlayedThisTurn ?? this.attacksPlayedThisTurn,
      cardsPlayedThisTurn: cardsPlayedThisTurn ?? this.cardsPlayedThisTurn,
      apModifierNextTurn: apModifierNextTurn ?? this.apModifierNextTurn,
      blockRetainPercent: blockRetainPercent ?? this.blockRetainPercent,
      typesPlayedThisTurn: typesPlayedThisTurn ?? this.typesPlayedThisTurn,
      remainingApBlockValue: remainingApBlockValue ?? this.remainingApBlockValue,
      skillsPlayedThisTurn: skillsPlayedThisTurn ?? this.skillsPlayedThisTurn,
      lastPlayedCardType: lastPlayedCardType ?? this.lastPlayedCardType,
      chainCount: chainCount ?? this.chainCount,
    );
  }

  @override
  List<Object?> get props => [
        immuneThisTurn, doubleNextAttack, exhaustHandAtTurnEnd,
        attacksPlayedThisTurn, cardsPlayedThisTurn, apModifierNextTurn,
        blockRetainPercent, typesPlayedThisTurn,
        remainingApBlockValue, skillsPlayedThisTurn,
        lastPlayedCardType, chainCount,
      ];
}

/// Power 카드 누적 효과 — 전투 시작 시 초기값, 턴 간 유지.
final class PowerEffects extends Equatable {
  final int poisonPerTurnStart;
  final int blockPerTurnStart;
  final int conditionalBlockPerTurnStart;
  final int retrievePerTurn;
  final int selfDamagePerTurn;
  final int strengthPerTurn;
  final int generateAttackPerTurn;
  final bool transformHand;
  final bool allTypesApBonus;
  final int boostLowestStatPerTurn;

  /// 콘텐츠 확장 Power 효과.
  final int dodgeChancePercent;
  final int lostHpToBlockPerTurnPercent;
  final int healPerTurn;
  final int drawPerTurn;
  final int reflectDamageChancePercent;

  /// Phase 3-B Power 효과.
  final int lifestealOnAllAttacksPercent;
  final int healPerTurnConditional;
  final String? healPerTurnCondition;
  final int overflowToBlockPercent;
  final int momentumGainOnDodge;
  final int poisonDamageReduction;
  final int poisonDamageReductionCap;
  final int damageReductionWhenBlock;
  final int damageReductionWhenBlockThreshold;
  final int healOnDamageTaken;
  final int healOnReflect;

  /// Phase 4 Power 효과.
  final bool allAttackPiercing;
  final int allSkillApDiscount;

  const PowerEffects({
    this.poisonPerTurnStart = 0,
    this.blockPerTurnStart = 0,
    this.conditionalBlockPerTurnStart = 0,
    this.retrievePerTurn = 0,
    this.selfDamagePerTurn = 0,
    this.strengthPerTurn = 0,
    this.generateAttackPerTurn = 0,
    this.transformHand = false,
    this.allTypesApBonus = false,
    this.boostLowestStatPerTurn = 0,
    this.dodgeChancePercent = 0,
    this.lostHpToBlockPerTurnPercent = 0,
    this.healPerTurn = 0,
    this.drawPerTurn = 0,
    this.reflectDamageChancePercent = 0,
    this.lifestealOnAllAttacksPercent = 0,
    this.healPerTurnConditional = 0,
    this.healPerTurnCondition,
    this.overflowToBlockPercent = 0,
    this.momentumGainOnDodge = 0,
    this.poisonDamageReduction = 0,
    this.poisonDamageReductionCap = 0,
    this.damageReductionWhenBlock = 0,
    this.damageReductionWhenBlockThreshold = 0,
    this.healOnDamageTaken = 0,
    this.healOnReflect = 0,
    this.allAttackPiercing = false,
    this.allSkillApDiscount = 0,
  });

  PowerEffects copyWith({
    int? poisonPerTurnStart,
    int? blockPerTurnStart,
    int? conditionalBlockPerTurnStart,
    int? retrievePerTurn,
    int? selfDamagePerTurn,
    int? strengthPerTurn,
    int? generateAttackPerTurn,
    bool? transformHand,
    bool? allTypesApBonus,
    int? boostLowestStatPerTurn,
    int? dodgeChancePercent,
    int? lostHpToBlockPerTurnPercent,
    int? healPerTurn,
    int? drawPerTurn,
    int? reflectDamageChancePercent,
    int? lifestealOnAllAttacksPercent,
    int? healPerTurnConditional,
    String? healPerTurnCondition,
    int? overflowToBlockPercent,
    int? momentumGainOnDodge,
    int? poisonDamageReduction,
    int? poisonDamageReductionCap,
    int? damageReductionWhenBlock,
    int? damageReductionWhenBlockThreshold,
    int? healOnDamageTaken,
    int? healOnReflect,
    bool? allAttackPiercing,
    int? allSkillApDiscount,
  }) {
    return PowerEffects(
      poisonPerTurnStart: poisonPerTurnStart ?? this.poisonPerTurnStart,
      blockPerTurnStart: blockPerTurnStart ?? this.blockPerTurnStart,
      conditionalBlockPerTurnStart: conditionalBlockPerTurnStart ?? this.conditionalBlockPerTurnStart,
      retrievePerTurn: retrievePerTurn ?? this.retrievePerTurn,
      selfDamagePerTurn: selfDamagePerTurn ?? this.selfDamagePerTurn,
      strengthPerTurn: strengthPerTurn ?? this.strengthPerTurn,
      generateAttackPerTurn: generateAttackPerTurn ?? this.generateAttackPerTurn,
      transformHand: transformHand ?? this.transformHand,
      allTypesApBonus: allTypesApBonus ?? this.allTypesApBonus,
      boostLowestStatPerTurn: boostLowestStatPerTurn ?? this.boostLowestStatPerTurn,
      dodgeChancePercent: dodgeChancePercent ?? this.dodgeChancePercent,
      lostHpToBlockPerTurnPercent: lostHpToBlockPerTurnPercent ?? this.lostHpToBlockPerTurnPercent,
      healPerTurn: healPerTurn ?? this.healPerTurn,
      drawPerTurn: drawPerTurn ?? this.drawPerTurn,
      reflectDamageChancePercent: reflectDamageChancePercent ?? this.reflectDamageChancePercent,
      lifestealOnAllAttacksPercent: lifestealOnAllAttacksPercent ?? this.lifestealOnAllAttacksPercent,
      healPerTurnConditional: healPerTurnConditional ?? this.healPerTurnConditional,
      healPerTurnCondition: healPerTurnCondition ?? this.healPerTurnCondition,
      overflowToBlockPercent: overflowToBlockPercent ?? this.overflowToBlockPercent,
      momentumGainOnDodge: momentumGainOnDodge ?? this.momentumGainOnDodge,
      poisonDamageReduction: poisonDamageReduction ?? this.poisonDamageReduction,
      poisonDamageReductionCap: poisonDamageReductionCap ?? this.poisonDamageReductionCap,
      damageReductionWhenBlock: damageReductionWhenBlock ?? this.damageReductionWhenBlock,
      damageReductionWhenBlockThreshold: damageReductionWhenBlockThreshold ?? this.damageReductionWhenBlockThreshold,
      healOnDamageTaken: healOnDamageTaken ?? this.healOnDamageTaken,
      healOnReflect: healOnReflect ?? this.healOnReflect,
      allAttackPiercing: allAttackPiercing ?? this.allAttackPiercing,
      allSkillApDiscount: allSkillApDiscount ?? this.allSkillApDiscount,
    );
  }

  @override
  List<Object?> get props => [
        poisonPerTurnStart, blockPerTurnStart, conditionalBlockPerTurnStart,
        retrievePerTurn,
        selfDamagePerTurn, strengthPerTurn, generateAttackPerTurn,
        transformHand, allTypesApBonus, boostLowestStatPerTurn,
        dodgeChancePercent, lostHpToBlockPerTurnPercent,
        healPerTurn, drawPerTurn, reflectDamageChancePercent,
        lifestealOnAllAttacksPercent, healPerTurnConditional,
        healPerTurnCondition, overflowToBlockPercent,
        momentumGainOnDodge, poisonDamageReduction,
        poisonDamageReductionCap, damageReductionWhenBlock,
        damageReductionWhenBlockThreshold, healOnDamageTaken, healOnReflect,
        allAttackPiercing, allSkillApDiscount,
      ];
}

// ── 카드 전투 상태 ──────────────────────────────────────

/// 카드 전투 진행 중 — 멀티몹 전투 지원.
final class CardCombatActive extends CombatState {
  // ── 멀티몹 적 상태 (핵심 필드) ──
  final List<EnemyBattleState> enemies;
  final int selectedTargetIndex;

  // ── 플레이어 ──
  final int playerHp;
  final int playerMaxHp;
  final int playerBlock;
  final DeckState deckState;
  final int actionPoints;
  final int maxActionPoints;
  final List<StatusEffect> playerStatuses;
  final int currentTurn;
  final PlayerRunState playerRunState;
  final CardPlayResult? lastPlayResult;
  final List<(String, EnemyActionResult)> lastEnemyActions;
  final RoomType roomType;

  /// 하위 호환: 마지막 적의 행동 (모방/적응형 데미지/보스 기믹용)
  EnemyActionResult? get lastEnemyAction =>
      lastEnemyActions.isNotEmpty ? lastEnemyActions.last.$2 : null;

  // ── 턴 플래그 + Power 효과 (하위 객체) ──
  final TurnFlags turnFlags;
  final PowerEffects powerEffects;
  final CardData? lastPlayedAttack;

  // ── 보스 전투 ──
  final BossCombatData? bossData;
  final int currentBossPhase;

  // ── 환경 카드 ──
  final CardData? environmentCard;
  final CardData? environmentCardObserved;
  final bool environmentGranted;

  // ── 적 의도 표시 ──
  final bool intentRevealed;
  final int intentRevealTurns;

  // ── 보스 환경카드 효과 (전역) ──
  final bool regenBlockedThisTurn;

  // ── 도주 ──
  final bool fleeGuaranteed;
  final bool fleeFailed;

  // ── 축복/유물 ──
  final List<CardBlessingData> activeBlessings;
  final List<CardRelicData> activeRelics;
  final int perfectFormDisabledTurns;

  // ── 기세 High 전환 추적 ──
  final int lastMomentumTier;
  final int momentumHighBonusDamage;

  // ── 전투 시작 기세 초기 보너스 (presentation에서 RestoreMomentum에 사용) ──
  final int initialMomentumBonus;

  // ── Phase 3-B 지속 상태 ──
  /// 다음 Skill AP 할인 (소비성, 사용 시 0으로).
  final int nextSkillApDiscount;

  /// 다음 N회 피격 무효 카운터.
  final int immuneNextHitsRemaining;

  /// 다음 피격 데미지 N% 감소 (소비성, 사용 시 0으로).
  final int nextHitDamageReductionPercent;

  /// 카드 쿨다운 추적 (cardId → 남은 턴 수).
  final Map<String, int> cooldownCards;

  /// 보상 카드 직업 오버라이드 (유령 PvP: 유령 직업 카드 보상).
  final String? rewardJobOverride;

  const CardCombatActive({
    required this.enemies,
    this.selectedTargetIndex = 0,
    required this.playerHp,
    required this.playerMaxHp,
    this.playerBlock = 0,
    required this.deckState,
    required this.actionPoints,
    required this.maxActionPoints,
    this.playerStatuses = const [],
    this.currentTurn = 0,
    required this.playerRunState,
    this.lastPlayResult,
    this.lastEnemyActions = const [],
    this.roomType = RoomType.combat,
    this.turnFlags = const TurnFlags(),
    this.powerEffects = const PowerEffects(),
    this.lastPlayedAttack,
    this.bossData,
    this.currentBossPhase = 0,
    this.environmentCard,
    this.environmentCardObserved,
    this.environmentGranted = false,
    this.intentRevealed = false,
    this.intentRevealTurns = 0,
    this.regenBlockedThisTurn = false,
    this.fleeGuaranteed = false,
    this.fleeFailed = false,
    this.activeBlessings = const [],
    this.activeRelics = const [],
    this.perfectFormDisabledTurns = 0,
    this.lastMomentumTier = 1,
    this.momentumHighBonusDamage = 0,
    this.initialMomentumBonus = 0,
    this.nextSkillApDiscount = 0,
    this.immuneNextHitsRemaining = 0,
    this.nextHitDamageReductionPercent = 0,
    this.cooldownCards = const {},
    this.rewardJobOverride,
  });

  // ── 하위 호환 getter (선택된 적 기준) ──
  EnemyBattleState get selectedEnemy => enemies[selectedTargetIndex];
  EnemyCombatData get enemy => selectedEnemy.data;
  int get enemyHp => selectedEnemy.currentHp;
  int get enemyMaxHp => selectedEnemy.maxHp;
  int get enemyBlock => selectedEnemy.block;
  int get enemyStrength => selectedEnemy.strength;
  List<StatusEffect> get enemyStatuses => selectedEnemy.statuses;
  int get enemyHealBlockedTurns => selectedEnemy.healBlockedTurns;
  int get enemyStunnedTurns => selectedEnemy.stunnedTurns;
  int get enemyDrainBlockedTurns => selectedEnemy.drainBlockedTurns;

  // ── 기본 getter ──
  bool get isPlayerDead => playerHp <= 0;
  bool get isEnemyDead => enemies.every((e) => e.isDead);
  bool get allEnemiesDead => isEnemyDead;
  List<EnemyBattleState> get livingEnemies =>
      enemies.where((e) => !e.isDead).toList();
  int get handCount => deckState.handCount;
  List<CardData> get hand => deckState.hand;

  /// 보스 전투 여부.
  bool get isBoss => bossData != null;

  /// 남은 보스 페이즈 여부.
  bool get hasNextBossPhase =>
      bossData != null && currentBossPhase < bossData!.totalPhases - 1;

  /// 특정 인덱스의 적 상태를 교체한 새 enemies 리스트로 copyWith.
  CardCombatActive copyWithEnemyAt(int index, EnemyBattleState newState) {
    final newEnemies = List<EnemyBattleState>.from(enemies);
    newEnemies[index] = newState;
    return copyWith(enemies: newEnemies);
  }

  CardCombatActive copyWith({
    // ── 멀티몹 ──
    List<EnemyBattleState>? enemies,
    int? selectedTargetIndex,
    // ── 하위 호환 적 플랫 파라미터 (선택된 적 업데이트용) ──
    EnemyCombatData? enemy,
    int? enemyHp,
    int? enemyMaxHp,
    int? enemyBlock,
    int? enemyStrength,
    List<StatusEffect>? enemyStatuses,
    int? enemyHealBlockedTurns,
    int? enemyStunnedTurns,
    int? enemyDrainBlockedTurns,
    // ── 플레이어/기타 ──
    int? playerHp,
    int? playerMaxHp,
    int? playerBlock,
    DeckState? deckState,
    int? actionPoints,
    int? maxActionPoints,
    List<StatusEffect>? playerStatuses,
    int? currentTurn,
    PlayerRunState? playerRunState,
    CardPlayResult? lastPlayResult,
    List<(String, EnemyActionResult)>? lastEnemyActions,
    RoomType? roomType,
    bool clearLastPlayResult = false,
    bool clearLastEnemyActions = false,
    TurnFlags? turnFlags,
    PowerEffects? powerEffects,
    CardData? lastPlayedAttack,
    bool clearLastPlayedAttack = false,
    BossCombatData? bossData,
    bool clearBossData = false,
    int? currentBossPhase,
    CardData? environmentCard,
    bool clearEnvironmentCard = false,
    CardData? environmentCardObserved,
    bool clearEnvironmentCardObserved = false,
    bool? environmentGranted,
    bool? intentRevealed,
    int? intentRevealTurns,
    bool? regenBlockedThisTurn,
    bool? fleeGuaranteed,
    bool? fleeFailed,
    List<CardBlessingData>? activeBlessings,
    List<CardRelicData>? activeRelics,
    int? perfectFormDisabledTurns,
    int? lastMomentumTier,
    int? momentumHighBonusDamage,
    int? initialMomentumBonus,
    int? nextSkillApDiscount,
    int? immuneNextHitsRemaining,
    int? nextHitDamageReductionPercent,
    Map<String, int>? cooldownCards,
    String? rewardJobOverride,
    bool clearRewardJobOverride = false,
  }) {
    // 적 플랫 파라미터가 있으면 선택된 적 업데이트
    var resolvedEnemies = enemies ?? this.enemies;
    final targetIdx = selectedTargetIndex ?? this.selectedTargetIndex;

    final hasEnemyFlatParams = enemy != null || enemyHp != null ||
        enemyMaxHp != null || enemyBlock != null || enemyStrength != null ||
        enemyStatuses != null || enemyHealBlockedTurns != null ||
        enemyStunnedTurns != null || enemyDrainBlockedTurns != null;

    if (enemies == null && hasEnemyFlatParams && resolvedEnemies.isNotEmpty) {
      final target = resolvedEnemies[targetIdx];
      resolvedEnemies = List<EnemyBattleState>.from(resolvedEnemies);
      resolvedEnemies[targetIdx] = target.copyWith(
        data: enemy,
        currentHp: enemyHp,
        maxHp: enemyMaxHp,
        block: enemyBlock,
        strength: enemyStrength,
        statuses: enemyStatuses,
        healBlockedTurns: enemyHealBlockedTurns,
        stunnedTurns: enemyStunnedTurns,
        drainBlockedTurns: enemyDrainBlockedTurns,
      );
    }

    return CardCombatActive(
      enemies: resolvedEnemies,
      selectedTargetIndex: targetIdx,
      playerHp: playerHp ?? this.playerHp,
      playerMaxHp: playerMaxHp ?? this.playerMaxHp,
      playerBlock: playerBlock ?? this.playerBlock,
      deckState: deckState ?? this.deckState,
      actionPoints: actionPoints ?? this.actionPoints,
      maxActionPoints: maxActionPoints ?? this.maxActionPoints,
      playerStatuses: playerStatuses ?? this.playerStatuses,
      currentTurn: currentTurn ?? this.currentTurn,
      playerRunState: playerRunState ?? this.playerRunState,
      lastPlayResult: clearLastPlayResult ? null : (lastPlayResult ?? this.lastPlayResult),
      lastEnemyActions: clearLastEnemyActions ? const [] : (lastEnemyActions ?? this.lastEnemyActions),
      roomType: roomType ?? this.roomType,
      turnFlags: turnFlags ?? this.turnFlags,
      powerEffects: powerEffects ?? this.powerEffects,
      lastPlayedAttack: clearLastPlayedAttack ? null : (lastPlayedAttack ?? this.lastPlayedAttack),
      bossData: clearBossData ? null : (bossData ?? this.bossData),
      currentBossPhase: currentBossPhase ?? this.currentBossPhase,
      environmentCard: clearEnvironmentCard ? null : (environmentCard ?? this.environmentCard),
      environmentCardObserved: clearEnvironmentCardObserved ? null : (environmentCardObserved ?? this.environmentCardObserved),
      environmentGranted: environmentGranted ?? this.environmentGranted,
      intentRevealed: intentRevealed ?? this.intentRevealed,
      intentRevealTurns: intentRevealTurns ?? this.intentRevealTurns,
      regenBlockedThisTurn: regenBlockedThisTurn ?? this.regenBlockedThisTurn,
      fleeGuaranteed: fleeGuaranteed ?? this.fleeGuaranteed,
      fleeFailed: fleeFailed ?? this.fleeFailed,
      activeBlessings: activeBlessings ?? this.activeBlessings,
      activeRelics: activeRelics ?? this.activeRelics,
      perfectFormDisabledTurns: perfectFormDisabledTurns ?? this.perfectFormDisabledTurns,
      lastMomentumTier: lastMomentumTier ?? this.lastMomentumTier,
      momentumHighBonusDamage: momentumHighBonusDamage ?? this.momentumHighBonusDamage,
      initialMomentumBonus: initialMomentumBonus ?? this.initialMomentumBonus,
      nextSkillApDiscount: nextSkillApDiscount ?? this.nextSkillApDiscount,
      immuneNextHitsRemaining: immuneNextHitsRemaining ?? this.immuneNextHitsRemaining,
      nextHitDamageReductionPercent: nextHitDamageReductionPercent ?? this.nextHitDamageReductionPercent,
      cooldownCards: cooldownCards ?? this.cooldownCards,
      rewardJobOverride: clearRewardJobOverride ? null : (rewardJobOverride ?? this.rewardJobOverride),
    );
  }

  @override
  List<Object?> get props => [
        enemies, selectedTargetIndex,
        playerHp, playerMaxHp, playerBlock,
        deckState, actionPoints, maxActionPoints,
        playerStatuses,
        currentTurn, playerRunState,
        lastPlayResult, lastEnemyActions, roomType,
        turnFlags, powerEffects, lastPlayedAttack,
        bossData, currentBossPhase,
        environmentCard, environmentCardObserved, environmentGranted,
        intentRevealed, intentRevealTurns,
        regenBlockedThisTurn,
        fleeGuaranteed, fleeFailed,
        activeBlessings, activeRelics,
        perfectFormDisabledTurns,
        lastMomentumTier, momentumHighBonusDamage, initialMomentumBonus,
        nextSkillApDiscount, immuneNextHitsRemaining,
        nextHitDamageReductionPercent, cooldownCards,
        rewardJobOverride,
      ];
}

/// 카드 전투 결과 확정.
final class CardCombatResolved extends CombatState {
  final CombatOutcome outcome;
  final List<EnemyCombatData> enemies;
  final int playerHp;
  final int playerMaxHp;
  final PlayerRunState playerRunState;
  final int? hpLost;
  final HpNarrationTier? hpNarrationTier;
  final bool isPermadeath;
  final RoomType roomType;
  final List<CardData> cardRewardOptions;

  /// 퍼마데스 시 획득 소울 수 (표시용).
  final int soulGained;

  /// 하위 호환 getter — 첫 번째 적 데이터.
  EnemyCombatData get enemy => enemies.first;

  const CardCombatResolved({
    required this.outcome,
    required this.enemies,
    required this.playerHp,
    required this.playerMaxHp,
    required this.playerRunState,
    this.hpLost,
    this.hpNarrationTier,
    this.isPermadeath = false,
    this.roomType = RoomType.combat,
    this.cardRewardOptions = const [],
    this.soulGained = 0,
  });

  @override
  List<Object?> get props => [
        outcome, enemies, playerHp, playerMaxHp,
        playerRunState, hpLost, hpNarrationTier,
        isPermadeath, roomType, cardRewardOptions,
        soulGained,
      ];
}

/// 카드 보스 페이즈 전환 (중간 상태).
final class CardBossPhaseTransition extends CombatState {
  final BossCombatData bossData;
  final int completedPhaseIndex;
  final int nextPhaseIndex;
  final int playerHp;
  final int playerMaxHp;
  final DeckState deckState;
  final PlayerRunState playerRunState;
  final List<StatusEffect> playerStatuses;
  final int currentTurn;
  final PowerEffects powerEffects;
  final List<CardBlessingData> activeBlessings;
  final List<CardRelicData> activeRelics;

  const CardBossPhaseTransition({
    required this.bossData,
    required this.completedPhaseIndex,
    required this.nextPhaseIndex,
    required this.playerHp,
    required this.playerMaxHp,
    required this.deckState,
    required this.playerRunState,
    this.playerStatuses = const [],
    this.currentTurn = 0,
    this.powerEffects = const PowerEffects(),
    this.activeBlessings = const [],
    this.activeRelics = const [],
  });

  @override
  List<Object?> get props => [
        bossData, completedPhaseIndex, nextPhaseIndex,
        playerHp, playerMaxHp, deckState, playerRunState,
        playerStatuses, currentTurn, powerEffects,
        activeBlessings, activeRelics,
      ];
}
