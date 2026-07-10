import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/models/blessing_data.dart';
import 'package:soul_dungeon/core/models/card_blessing_data.dart';
import 'package:soul_dungeon/core/models/card_relic_data.dart';
import 'package:soul_dungeon/core/models/curse_data.dart';
import 'package:soul_dungeon/core/models/relic_data.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/floor_config.dart';
import 'package:soul_dungeon/core/events/card_played_event.dart';
import 'package:soul_dungeon/core/events/combat_reward_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/permadeath_event.dart';
import 'package:soul_dungeon/core/events/player_damaged_event.dart';
import 'package:soul_dungeon/core/events/status_effect_applied_event.dart';
import 'package:soul_dungeon/core/events/truth_reveal_event.dart';
import 'package:soul_dungeon/core/events/deck_shuffled_event.dart';
import 'package:soul_dungeon/core/events/card_drawn_event.dart';
import 'package:soul_dungeon/core/events/card_exhausted_event.dart';
import 'package:soul_dungeon/core/events/combat_ended_event.dart';
import 'package:soul_dungeon/core/events/combat_milestone_event.dart';
import 'package:soul_dungeon/core/events/combat_started_event.dart';
import 'package:soul_dungeon/core/events/chain_bonus_event.dart';
import 'package:soul_dungeon/core/events/momentum_gain_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_encounter_data.dart';
import 'package:soul_dungeon/domain/combat/models/enemy_battle_state.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/core/models/enemy_modifier.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';
import 'package:soul_dungeon/domain/combat/content/encounter_pool.dart';
import 'package:soul_dungeon/domain/combat/logic/action_interaction.dart';
import 'package:soul_dungeon/core/models/curse_modifier_pool.dart';
import 'package:soul_dungeon/domain/combat/logic/card_effect_resolver.dart';
import 'package:soul_dungeon/domain/combat/logic/chain_bonus.dart';
import 'package:soul_dungeon/domain/combat/logic/damage_calculator.dart';
import 'package:soul_dungeon/domain/combat/logic/curse_modifier_resolver.dart';
import 'package:soul_dungeon/domain/combat/logic/deck_manager.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/domain/combat/logic/enemy_ai.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/domain/combat/logic/special_action_resolver.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_defeat_handler.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_result_calculator.dart';
import 'package:soul_dungeon/domain/combat/logic/card_reward_generator.dart';
import 'package:soul_dungeon/domain/combat/logic/environment_card_resolver.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_reward_calculator.dart';
import 'package:soul_dungeon/domain/combat/logic/status_effect_processor.dart';
import 'package:soul_dungeon/domain/combat/models/combat_turn_result.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/core/models/tier_effect_calculator.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';

/// CombatBloc — 전투 로직 소유. 3파일 분리 + 생성자 주입.
///
/// 레거시 플로우: StartCombat → SelectAction* → ResolveCombat → EndCombat
/// 카드 플로우: StartCardCombat → PlayCard*/EndPlayerTurn* → 승리/패배 자동 → EndCombat
class CombatBloc extends Bloc<CombatEvent, CombatState> {
  final GameEventBus gameEventBus;
  final CombatBalanceConfig combatConfig;
  final EconomyConfig economyConfig;
  final TierEffectCalculator tierEffectCalculator;
  final CardCombatBalanceConfig cardCombatConfig;
  final FleeConfig fleeConfig;
  final ChainBonusConfig chainBonusConfig;
  final FloorsConfig floorsConfig;
  final MomentumConfig momentumConfig;
  final Random _random;

  /// 생성자 주입 — build 도메인 풀 리졸버 (cross-domain import 제거).
  final List<CurseData> Function(List<String> ids) resolveCurseIds;
  final List<CardRelicData> Function(List<String> ids) resolveCardRelicIds;
  final List<BlessingData> Function(List<String> ids) resolveBlessingIds;
  final List<CardBlessingData> Function(List<String> ids) resolveCardBlessingIds;
  final List<RelicData> Function(List<String> ids) resolveRelicIds;
  final String windAmuletRelicId;

  /// 소울 업그레이드로 해금된 카드 ID — 카드 보상 풀에 추가.
  final Set<String> unlockedCardIds;

  /// 소울 업그레이드 엘리트 보상 배율.
  final double eliteRewardMultiplier;

  /// 디버그 갓 모드 — kDebugMode에서만 사용.
  bool debugGodMode = false;

  CombatBloc({
    required this.gameEventBus,
    required this.combatConfig,
    required this.economyConfig,
    required this.tierEffectCalculator,
    required this.resolveCurseIds,
    required this.resolveCardRelicIds,
    required this.resolveBlessingIds,
    required this.resolveCardBlessingIds,
    required this.resolveRelicIds,
    this.windAmuletRelicId = 'cr_wind_amulet',
    this.unlockedCardIds = const {},
    this.eliteRewardMultiplier = 1.0,
    this.cardCombatConfig = const CardCombatBalanceConfig(),
    this.fleeConfig = const FleeConfig(),
    this.chainBonusConfig = const ChainBonusConfig(),
    this.floorsConfig = const FloorsConfig([]),
    this.momentumConfig = const MomentumConfig(),
    Random? random,
  })  : _random = random ?? Random(),
        super(const CombatIdle()) {
    // 레거시 이벤트 핸들러
    on<StartCombat>(_onStartCombat);
    on<SelectAction>(_onSelectAction);
    on<SelectSpecialAction>(_onSelectSpecialAction);
    on<SelectEnvironmentAction>(_onSelectEnvironmentAction);
    on<ResolveCombat>(_onResolveCombat);
    on<RestartRun>(_onRestartRun);
    on<EndCombat>(_onEndCombat);
    on<ContinueBossPhase>(_onContinueBossPhase);
    // 카드 전투 이벤트 핸들러
    on<StartCardCombat>(_onStartCardCombat);
    on<StartCardBossCombat>(_onStartCardBossCombat);
    on<ContinueCardBossPhase>(_onContinueCardBossPhase);
    on<PlayCard>(_onPlayCard);
    on<EndPlayerTurn>(_onEndPlayerTurn);
    on<SelectCardReward>(_onSelectCardReward);
    on<AttemptFlee>(_onAttemptFlee);
    on<TameEnemy>(_onTameEnemy);
    on<SelectTarget>(_onSelectTarget);
    on<RestoreCardCombat>(_onRestoreCardCombat);
    // 디버그 전용
    on<DebugSetAp>(_onDebugSetAp);
    on<DebugSetGodMode>(_onDebugSetGodMode);
  }

  // ── 레거시 핸들러 (기존 presentation 호환) ──────────────

  void _onStartCombat(StartCombat event, Emitter<CombatState> emit) {
    emit(CombatActive(
      encounter: event.encounter,
      playerRunState: event.playerRunState,
    ));
    if (kDebugMode) {
      GameLogger.debug(
        LogSystem.combat,
        'Combat started: ${event.encounter.enemyName} '
        '(${event.encounter.totalTurns} turns)',
      );
    }
  }

  void _onSelectAction(SelectAction event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CombatActive) return;

    final turn = current.currentTurn;
    if (turn == null) return;

    final actionResult = ActionInteraction.getResult(
      event.actionType,
      turn.enemyAction,
    );

    final tierEffect = tierEffectCalculator.calculate(
      event.currentMomentumTier,
      actionResult,
    );

    final turnResult = CombatTurnResult(
      turnNumber: turn.turnNumber,
      playerAction: event.actionType,
      enemyAction: turn.enemyAction,
      actionResult: actionResult,
      tierEffect: tierEffect,
    );

    var environmentUnlocked = current.environmentUnlocked;
    var discoveredClues = current.discoveredClues;
    if (event.actionType == ActionType.observe &&
        !current.environmentUnlocked &&
        current.encounter.environmentClues.isNotEmpty) {
      environmentUnlocked = true;
      discoveredClues = List.of(current.encounter.environmentClues);
    }

    emit(current.copyWith(
      currentTurnIndex: current.currentTurnIndex + 1,
      turnResults: [...current.turnResults, turnResult],
      environmentUnlocked: environmentUnlocked,
      discoveredClues: discoveredClues,
    ));
  }

  void _onSelectSpecialAction(
    SelectSpecialAction event,
    Emitter<CombatState> emit,
  ) {
    final current = state;
    if (current is! CombatActive) return;

    final turn = current.currentTurn;
    if (turn == null) return;

    final actionResult = SpecialActionResolver.getResult(
      event.specialActionType,
      turn.enemyAction,
    );

    final tierEffect = tierEffectCalculator.calculate(
      event.currentMomentumTier,
      actionResult,
    );

    final turnResult = CombatTurnResult(
      turnNumber: turn.turnNumber,
      playerAction: ActionType.special,
      enemyAction: turn.enemyAction,
      actionResult: actionResult,
      tierEffect: tierEffect,
      specialActionType: event.specialActionType,
    );

    emit(current.copyWith(
      currentTurnIndex: current.currentTurnIndex + 1,
      turnResults: [...current.turnResults, turnResult],
    ));
  }

  void _onSelectEnvironmentAction(
    SelectEnvironmentAction event,
    Emitter<CombatState> emit,
  ) {
    final current = state;
    if (current is! CombatActive) return;

    final turn = current.currentTurn;
    if (turn == null) return;

    const actionResult = ActionResult.effective;
    final tierEffect = tierEffectCalculator.calculate(
      event.currentMomentumTier,
      actionResult,
    );

    final turnResult = CombatTurnResult(
      turnNumber: turn.turnNumber,
      playerAction: ActionType.environment,
      enemyAction: turn.enemyAction,
      actionResult: actionResult,
      tierEffect: tierEffect,
    );

    emit(current.copyWith(
      currentTurnIndex: current.currentTurnIndex + 1,
      turnResults: [...current.turnResults, turnResult],
    ));
  }

  void _onResolveCombat(ResolveCombat event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CombatActive) return;

    final threshold = switch (current.encounter.roomType) {
      RoomType.elite => combatConfig.eliteVictoryThreshold,
      RoomType.boss => combatConfig.bossVictoryThreshold,
      _ => combatConfig.normalVictoryThreshold,
    };

    final resultScore = CombatResultCalculator.calculate(
      current.turnResults.map((r) => r.actionResult.name).toList(),
      victoryThreshold: threshold,
    );

    if (resultScore.outcome == CombatOutcome.victory) {
      if (current.encounter.isBoss &&
          current.currentBossPhaseIndex <
              current.encounter.totalBossPhases - 1) {
        final nextIndex = current.currentBossPhaseIndex + 1;
        if (kDebugMode) {
          GameLogger.debug(
            LogSystem.combat,
            'Boss phase transition: ${current.currentBossPhaseIndex} → $nextIndex',
          );
        }
        emit(BossPhaseTransition(
          encounter: current.encounter,
          completedPhaseIndex: current.currentBossPhaseIndex,
          nextPhaseIndex: nextIndex,
          playerRunState: current.playerRunState,
        ));
        return;
      }

      final floorGoldMult = floorsConfig
          .forFloor(current.playerRunState.currentFloor)
          .goldMultiplier;
      final reward = CombatRewardCalculator.calculate(
        roomType: current.encounter.roomType,
        economyConfig: economyConfig,
        goldMultiplier: floorGoldMult,
        eliteRewardMultiplier: eliteRewardMultiplier,
      );
      gameEventBus.emit(CombatRewardEvent(
        goldAmount: reward.goldAmount,
        rewardTag: reward.rewardTag,
      ));

      if (kDebugMode) {
        GameLogger.debug(
          LogSystem.combat,
          'Combat victory: score=${resultScore.score}, '
          'reward=${reward.goldAmount} gold',
        );
      }

      emit(CombatResolved(
        encounter: current.encounter,
        resultScore: resultScore,
        playerRunState: current.playerRunState,
        hpDeductedForCurrentEncounter:
            current.hpDeductedForCurrentEncounter,
      ));
    } else {
      var playerRunState = current.playerRunState;
      int? hpLost;
      HpNarrationTier? tier;
      var hpDeducted = current.hpDeductedForCurrentEncounter;
      var isPermadeath = false;

      if (!hpDeducted) {
        hpLost = CombatDefeatHandler.calculateHpLoss(
          current.encounter.roomType,
          combatConfig,
        );
        playerRunState = CombatDefeatHandler.applyDamage(
          playerRunState,
          hpLost,
        );
        gameEventBus.emit(PlayerDamagedEvent(
          hpLost: hpLost,
          remainingHp: playerRunState.currentHp,
        ));
        hpDeducted = true;

        tier = CombatDefeatHandler.hpNarrationTier(playerRunState);
        isPermadeath = CombatDefeatHandler.isPermadeath(playerRunState);

        if (isPermadeath) {
          gameEventBus.emit(PermadeathEvent(
            finalHp: 0,
            defeatedBy: current.encounter.enemyName,
          ));
        }

        if (kDebugMode) {
          GameLogger.debug(
            LogSystem.combat,
            'Combat defeat: hpLost=$hpLost, remaining=${playerRunState.currentHp}, '
            'permadeath=$isPermadeath',
          );
        }
      }

      emit(CombatResolved(
        encounter: current.encounter,
        resultScore: resultScore,
        playerRunState: playerRunState,
        hpDeductedForCurrentEncounter: hpDeducted,
        hpLost: hpLost,
        hpNarrationTier: tier,
        isPermadeath: isPermadeath,
      ));
    }
  }

  void _onRestartRun(RestartRun event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CombatResolved) return;

    emit(CombatActive(
      encounter: current.encounter,
      playerRunState: PlayerRunState.initial(maxHp: event.maxHp),
    ));
  }

  void _onContinueBossPhase(
    ContinueBossPhase event,
    Emitter<CombatState> emit,
  ) {
    final current = state;
    if (current is! BossPhaseTransition) return;

    final nextPhase = current.encounter.bossPhases![current.nextPhaseIndex];
    final nextEncounter = CombatEncounterData(
      roomType: current.encounter.roomType,
      enemyName: current.encounter.enemyName,
      environmentClues: const [],
      turns: nextPhase.turns,
      bossPhases: current.encounter.bossPhases,
    );

    emit(CombatActive(
      encounter: nextEncounter,
      playerRunState: current.playerRunState,
      currentBossPhaseIndex: current.nextPhaseIndex,
    ));

    if (kDebugMode) {
      GameLogger.debug(
        LogSystem.combat,
        'Boss phase ${current.nextPhaseIndex} started: '
        '${nextPhase.turns.length} turns',
      );
    }
  }

  void _onEndCombat(EndCombat event, Emitter<CombatState> emit) {
    emit(const CombatIdle());
  }

  // ── 카드 전투 핸들러 ──────────────────────────────────

  void _onStartCardCombat(
    StartCardCombat event,
    Emitter<CombatState> emit,
  ) {
    // 초기 AP는 event.momentumTier 대신 실제 초기 기세값에서 산출 (첫 턴 불일치 수정)
    // totalMomentumBonus는 아래에서 계산되므로, 우선 event.momentumTier를 임시 사용
    // → 최종 AP는 totalMomentumBonus 확정 후 재산출
    var ap = cardCombatConfig.apForTier(event.momentumTier);

    // 악마의 거래 저주 해결 (드로우/AP 감소 등 초기화 전 필요)
    final devilCurses = resolveCurseIds(event.playerRunState.activeCurseIds);
    var initialHandSize = cardCombatConfig.initialHandSize;
    var devilEnemyStrength = 0;
    for (final dc in devilCurses) {
      switch (dc.effectType) {
        case 'drawPenalty':
          initialHandSize = (initialHandSize - dc.effectValue).clamp(1, 99);
        case 'firstTurnApPenalty':
          ap = (ap - dc.effectValue).clamp(1, 99);
        case 'enemyDamageBonus':
          devilEnemyStrength += dc.effectValue ~/ 5; // 10% → +2 힘
      }
    }

    // 덱 초기화 + 첫 손패 드로우
    var deck = DeckManager.initialize(event.masterDeck);
    deck = DeckManager.draw(deck, initialHandSize);

    // 적 리스트 빈 경우 방어
    if (event.enemies.isEmpty) {
      emit(const CombatIdle());
      return;
    }

    // 환경 카드 결정 (첫 번째 적의 floor 기준)
    final primaryEnemy = event.enemies.first;
    final envBase = EnvironmentCardResolver.resolveBase(
      floor: primaryEnemy.floor,
    );
    final envObserved = EnvironmentCardResolver.resolveObserved(
      floor: primaryEnemy.floor,
    );

    // 축복/유물 해결
    final blessings = _resolveAllBlessings(
      event.playerRunState.ownedBlessingIds,
    );
    final relics = resolveCardRelicIds(
      event.playerRunState.ownedRelicIds,
    );

    // E9 저주: 적 힘 보너스
    final curses = CurseModifierPool.resolveIds(
      event.playerRunState.activeCurseIds,
    );
    final curseResult = CurseModifierResolver.resolveCombatStart(curses);

    // ── 축복/유물 combatStart 효과 ──
    var initialStatuses = <StatusEffect>[];
    var initialMaxHp = event.playerRunState.maxHp;
    var initialPlayerHp = event.playerRunState.currentHp;
    for (final b in blessings) {
      switch (b.effectType) {
        case 'gainStrength':
          initialStatuses = StatusEffectProcessor.addEffect(
            initialStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: b.effectValue),
          );
        case 'gainDexterity':
          initialStatuses = StatusEffectProcessor.addEffect(
            initialStatuses,
            StatusEffect(type: StatusEffectType.dexterity, stacks: b.effectValue),
          );
        case 'innateBonusDraw':
          deck = DeckManager.draw(deck, b.effectValue);
        case 'strengthWithHpPenalty':
          // maxHP 감소는 구매 시 즉시 적용됨 — 전투 시작 시 힘만 부여
          initialStatuses = StatusEffectProcessor.addEffect(
            initialStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: b.effectValue),
          );
      }
    }
    for (final r in relics) {
      switch (r.effectType) {
        case 'gainStrength':
          initialStatuses = StatusEffectProcessor.addEffect(
            initialStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: r.effectValue),
          );
        case 'addPoisonJar':
          deck = DeckManager.addToHand(deck, ColorlessCards.poisonJar);
      }
    }

    // ── 런레벨 축복 combatStart 효과 ──
    var initialBlock = 0;
    var totalMomentumBonus = 0;
    final runBlessings = resolveBlessingIds(
      event.playerRunState.ownedBlessingIds,
    );
    for (final rb in runBlessings) {
      switch (rb.effectType) {
        case 'attackBonus':
          initialStatuses = StatusEffectProcessor.addEffect(
            initialStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: rb.effectValue),
          );
        case 'defenseBonus':
          initialBlock += rb.effectValue;
        case 'momentumBonus':
          totalMomentumBonus += rb.effectValue;
        case 'attackAndDefenseBonus':
          initialStatuses = StatusEffectProcessor.addEffect(
            initialStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: rb.effectValue),
          );
          initialBlock += rb.effectValue + 1;
        case 'healBonus':
          final heal = rb.effectValue;
          initialPlayerHp = (initialPlayerHp + heal).clamp(0, initialMaxHp);
        case 'healOnCombatStart':
          // blessing_004 생명의 축복: 전투 시작 시 HP 회복
          initialPlayerHp = (initialPlayerHp + rb.effectValue).clamp(0, initialMaxHp);
        case 'momentumOnCombatStart':
          // blessing_005 기세의 축복: 전투 시작 시 기세 +N
          totalMomentumBonus += rb.effectValue;
        case 'bonusApFirstTurn':
          // blessing_007 집중의 축복: 전투 시작 시 AP +N (첫 턴만)
          ap += rb.effectValue;
        case 'bonusDraw':
          deck = DeckManager.draw(deck, rb.effectValue);
      }
    }

    // ── NPC 보급품 일회성 보너스 소비 ──
    if (event.playerRunState.tempStrengthBonus > 0) {
      initialStatuses = StatusEffectProcessor.addEffect(
        initialStatuses,
        StatusEffect(
          type: StatusEffectType.strength,
          stacks: event.playerRunState.tempStrengthBonus,
        ),
      );
    }
    if (event.playerRunState.tempBlockBonus > 0) {
      initialBlock += event.playerRunState.tempBlockBonus;
    }
    totalMomentumBonus += event.playerRunState.tempMomentumBonus;

    // ── 런레벨 유물 combatStart 효과 ──
    final runRelics = resolveRelicIds(
      event.playerRunState.ownedRelicIds,
    );
    for (final rr in runRelics.where((r) => r.conditionType == 'combatStart')) {
      switch (rr.passiveEffect) {
        case 'momentumGain':
          totalMomentumBonus += rr.effectValue;
        case 'defenseBonus':
          initialBlock += rr.effectValue;
      }
    }

    // ── 런레벨 유물 momentumThreshold 효과 (기세 ≥ 60일 때) ──
    for (final rr in runRelics.where((r) => r.conditionType == 'momentumThreshold')) {
      if (event.currentMomentum >= 60) {
        switch (rr.passiveEffect) {
          case 'attackBonus':
            initialStatuses = StatusEffectProcessor.addEffect(
              initialStatuses,
              StatusEffect(type: StatusEffectType.strength, stacks: rr.effectValue),
            );
        }
      }
    }

    // ── 악마의 거래 저주 combatStart 효과 ──
    for (final dc in devilCurses) {
      switch (dc.effectType) {
        case 'combatStartHpLoss':
          initialPlayerHp = (initialPlayerHp - dc.effectValue).clamp(1, initialMaxHp);
        case 'momentumGainPenalty':
          totalMomentumBonus -= dc.effectValue ~/ 2;
        case 'momentumDecayPenalty':
          totalMomentumBonus -= dc.effectValue ~/ 2;
      }
    }

    // 초기 기세값 기반 AP 재산출 — event.momentumTier는 MomentumBloc 초기화 전의
    // 잘못된 값일 수 있으므로, 실제 초기 기세(initialValue + totalMomentumBonus)로 보정.
    final actualInitialMomentum = (momentumConfig.initialValue + totalMomentumBonus)
        .clamp(momentumConfig.min, momentumConfig.max);
    final correctTier = actualInitialMomentum >= momentumConfig.thresholdHigh
        ? MomentumTier.high
        : actualInitialMomentum >= momentumConfig.thresholdMedium
            ? MomentumTier.medium
            : MomentumTier.low;
    final correctTierInt = correctTier.index + 1;
    // firstTurnApPenalty는 이미 ap에 반영됨 — 기존 페널티 보존하면서 기저 AP만 교체
    final baseDiff = cardCombatConfig.apForTier(correctTierInt) -
        cardCombatConfig.apForTier(event.momentumTier);
    ap = (ap + baseDiff).clamp(1, 99);

    // EnemyBattleState 리스트 생성 (멀티몹 지원 + 패턴 오프셋)
    final totalEnemyStrength = curseResult.enemyStrengthBonus + devilEnemyStrength;
    final offsets = EncounterPool.calculateOffsets(event.enemies);
    final enemyStates = [
      for (var i = 0; i < event.enemies.length; i++)
        EnemyBattleState.fromData(
          event.enemies[i],
          strengthBonus: totalEnemyStrength,
          patternOffset: offsets[i],
        ),
    ];

    emit(CardCombatActive(
      enemies: enemyStates,
      playerHp: initialPlayerHp,
      playerMaxHp: initialMaxHp,
      playerBlock: initialBlock,
      deckState: deck,
      actionPoints: ap,
      maxActionPoints: ap,
      playerStatuses: initialStatuses,
      playerRunState: event.playerRunState,
      roomType: event.roomType,
      environmentCard: envBase,
      environmentCardObserved: envObserved,
      activeBlessings: blessings,
      activeRelics: relics,
      lastMomentumTier: correctTierInt,
      initialMomentumBonus: totalMomentumBonus,
      rewardJobOverride: event.rewardJobOverride,
    ));
    gameEventBus.emit(CombatStartedEvent(
      isElite: event.roomType == RoomType.elite,
    ));

    if (kDebugMode) {
      GameLogger.debug(
        LogSystem.combat,
        'Card combat started: ${primaryEnemy.name} '
        '(${event.enemies.length} enemies, HP: ${primaryEnemy.hp}, AP: $ap, '
        'blessings: ${blessings.length}, relics: ${relics.length}, '
        'curseStr: ${curseResult.enemyStrengthBonus})',
      );
    }
  }

  void _onStartCardBossCombat(
    StartCardBossCombat event,
    Emitter<CombatState> emit,
  ) {
    final boss = event.bossData;
    final phase = boss.phaseAt(0);
    var ap = cardCombatConfig.apForTier(event.momentumTier);

    // 악마의 거래 저주 해결 (드로우/AP 감소 등 초기화 전 필요)
    final bossDevilCurses = resolveCurseIds(event.playerRunState.activeCurseIds);
    for (final dc in bossDevilCurses) {
      switch (dc.effectType) {
        case 'firstTurnApPenalty':
          ap = (ap - dc.effectValue).clamp(1, 99);
      }
    }

    // 보스 Phase 1의 EnemyCombatData 생성 — 층별 HP 배율 적용
    final bossHpMult = floorsConfig.forFloor(boss.floor).enemyHpMultiplier;
    final bossEnemy = EnemyCombatData(
      id: boss.id,
      name: boss.name,
      hp: (phase.hp * bossHpMult).toInt().clamp(1, 9999),
      atk: phase.atk,
      def: phase.def,
      floor: boss.floor,
      pattern: phase.pattern,
    );

    var deck = DeckManager.initialize(event.masterDeck);

    // web 기믹: 첫 턴부터 드로우 감소 적용
    var initialDraw = cardCombatConfig.initialHandSize;
    final webGimmick = EnemyAI.resolveGimmick(phase.gimmick, phase.hp);
    // 악마의 거래: 드로우 페널티
    for (final dc in bossDevilCurses) {
      if (dc.effectType == 'drawPenalty') {
        initialDraw -= dc.effectValue;
      }
    }
    initialDraw -= webGimmick.playerDrawPenalty;
    if (initialDraw < 1) initialDraw = 1;
    deck = DeckManager.draw(deck, initialDraw);

    // 보스 환경 카드 결정
    final envBase = EnvironmentCardResolver.resolveBase(
      floor: boss.floor,
      bossId: boss.id,
    );
    final envObserved = EnvironmentCardResolver.resolveObserved(
      floor: boss.floor,
      bossId: boss.id,
    );

    // 축복/유물 해결
    final blessings = _resolveAllBlessings(
      event.playerRunState.ownedBlessingIds,
    );
    final relics = resolveCardRelicIds(
      event.playerRunState.ownedRelicIds,
    );

    // ── 축복/유물 combatStart 효과 ──
    var bossInitStatuses = <StatusEffect>[];
    var bossInitMaxHp = event.playerRunState.maxHp;
    var bossInitPlayerHp = event.playerRunState.currentHp;
    for (final b in blessings) {
      switch (b.effectType) {
        case 'gainStrength':
          bossInitStatuses = StatusEffectProcessor.addEffect(
            bossInitStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: b.effectValue),
          );
        case 'gainDexterity':
          bossInitStatuses = StatusEffectProcessor.addEffect(
            bossInitStatuses,
            StatusEffect(type: StatusEffectType.dexterity, stacks: b.effectValue),
          );
        case 'innateBonusDraw':
          deck = DeckManager.draw(deck, b.effectValue);
        case 'strengthWithHpPenalty':
          // maxHP 감소는 구매 시 즉시 적용됨 — 전투 시작 시 힘만 부여
          bossInitStatuses = StatusEffectProcessor.addEffect(
            bossInitStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: b.effectValue),
          );
      }
    }
    for (final r in relics) {
      switch (r.effectType) {
        case 'gainStrength':
          bossInitStatuses = StatusEffectProcessor.addEffect(
            bossInitStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: r.effectValue),
          );
        case 'addPoisonJar':
          deck = DeckManager.addToHand(deck, ColorlessCards.poisonJar);
      }
    }

    // ── 런레벨 축복 combatStart 효과 (보스 전투) ──
    var bossInitBlock = 0;
    var bossTotalMomentumBonus = 0;
    final bossRunBlessings = resolveBlessingIds(
      event.playerRunState.ownedBlessingIds,
    );
    for (final rb in bossRunBlessings) {
      switch (rb.effectType) {
        case 'attackBonus':
          bossInitStatuses = StatusEffectProcessor.addEffect(
            bossInitStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: rb.effectValue),
          );
        case 'defenseBonus':
          bossInitBlock += rb.effectValue;
        case 'momentumBonus':
          bossTotalMomentumBonus += rb.effectValue;
        case 'attackAndDefenseBonus':
          bossInitStatuses = StatusEffectProcessor.addEffect(
            bossInitStatuses,
            StatusEffect(type: StatusEffectType.strength, stacks: rb.effectValue),
          );
          bossInitBlock += rb.effectValue + 1;
        case 'healBonus':
          final heal = rb.effectValue;
          bossInitPlayerHp = (bossInitPlayerHp + heal).clamp(0, bossInitMaxHp);
        case 'healOnCombatStart':
          // blessing_004 생명의 축복: 전투 시작 시 HP 회복
          bossInitPlayerHp = (bossInitPlayerHp + rb.effectValue).clamp(0, bossInitMaxHp);
        case 'momentumOnCombatStart':
          // blessing_005 기세의 축복: 전투 시작 시 기세 +N
          bossTotalMomentumBonus += rb.effectValue;
        case 'bonusApFirstTurn':
          // blessing_007 집중의 축복: 전투 시작 시 AP +N (첫 턴만)
          ap += rb.effectValue;
        case 'bonusDraw':
          deck = DeckManager.draw(deck, rb.effectValue);
      }
    }

    // ── 런레벨 유물 combatStart 효과 (보스 전투) ──
    final bossRunRelics = resolveRelicIds(
      event.playerRunState.ownedRelicIds,
    );
    for (final rr in bossRunRelics.where((r) => r.conditionType == 'combatStart')) {
      switch (rr.passiveEffect) {
        case 'momentumGain':
          bossTotalMomentumBonus += rr.effectValue;
        case 'defenseBonus':
          bossInitBlock += rr.effectValue;
      }
    }

    // ── 런레벨 유물 momentumThreshold 효과 (보스 전투, 기세 ≥ 60) ──
    for (final rr in bossRunRelics.where((r) => r.conditionType == 'momentumThreshold')) {
      if (event.currentMomentum >= 60) {
        switch (rr.passiveEffect) {
          case 'attackBonus':
            bossInitStatuses = StatusEffectProcessor.addEffect(
              bossInitStatuses,
              StatusEffect(type: StatusEffectType.strength, stacks: rr.effectValue),
            );
        }
      }
    }

    // ── NPC 보급품 일회성 보너스 소비 (보스 전투) ──
    if (event.playerRunState.tempStrengthBonus > 0) {
      bossInitStatuses = StatusEffectProcessor.addEffect(
        bossInitStatuses,
        StatusEffect(
          type: StatusEffectType.strength,
          stacks: event.playerRunState.tempStrengthBonus,
        ),
      );
    }
    if (event.playerRunState.tempBlockBonus > 0) {
      bossInitBlock += event.playerRunState.tempBlockBonus;
    }
    bossTotalMomentumBonus += event.playerRunState.tempMomentumBonus;

    // ── 악마의 거래 저주 combatStart 효과 (보스 전투) ──
    var bossDevilEnemyStrength = 0;
    for (final dc in bossDevilCurses) {
      switch (dc.effectType) {
        case 'combatStartHpLoss':
          bossInitPlayerHp = (bossInitPlayerHp - dc.effectValue).clamp(1, bossInitMaxHp);
        case 'momentumGainPenalty':
          bossTotalMomentumBonus -= dc.effectValue ~/ 2;
        case 'momentumDecayPenalty':
          bossTotalMomentumBonus -= dc.effectValue ~/ 2;
        case 'enemyDamageBonus':
          bossDevilEnemyStrength += dc.effectValue ~/ 5;
      }
    }

    // 초기 기세값 기반 AP 재산출 (일반 전투와 동일)
    final bossActualMomentum = (momentumConfig.initialValue + bossTotalMomentumBonus)
        .clamp(momentumConfig.min, momentumConfig.max);
    final bossCorrectTier = bossActualMomentum >= momentumConfig.thresholdHigh
        ? MomentumTier.high
        : bossActualMomentum >= momentumConfig.thresholdMedium
            ? MomentumTier.medium
            : MomentumTier.low;
    final bossCorrectTierInt = bossCorrectTier.index + 1;
    final bossBaseDiff = cardCombatConfig.apForTier(bossCorrectTierInt) -
        cardCombatConfig.apForTier(event.momentumTier);
    ap = (ap + bossBaseDiff).clamp(1, 99);

    emit(CardCombatActive(
      enemies: [EnemyBattleState.fromData(bossEnemy, strengthBonus: bossDevilEnemyStrength)],
      playerHp: bossInitPlayerHp,
      playerMaxHp: bossInitMaxHp,
      playerBlock: bossInitBlock,
      deckState: deck,
      actionPoints: ap,
      maxActionPoints: ap,
      playerStatuses: bossInitStatuses,
      playerRunState: event.playerRunState,
      roomType: RoomType.boss,
      bossData: boss,
      currentBossPhase: 0,
      environmentCard: envBase,
      environmentCardObserved: envObserved,
      activeBlessings: blessings,
      activeRelics: relics,
      lastMomentumTier: bossCorrectTierInt,
      initialMomentumBonus: bossTotalMomentumBonus,
    ));
    gameEventBus.emit(CombatStartedEvent(isBoss: true));

    if (kDebugMode) {
      GameLogger.debug(
        LogSystem.combat,
        'Card boss combat started: ${boss.name} '
        'Phase 1 (HP: ${phase.hp}, ATK: ${phase.atk}, '
        'blessings: ${blessings.length}, relics: ${relics.length})',
      );
    }
  }

  void _onContinueCardBossPhase(
    ContinueCardBossPhase event,
    Emitter<CombatState> emit,
  ) {
    final current = state;
    if (current is! CardBossPhaseTransition) return;

    final boss = current.bossData;
    final nextPhase = boss.phaseAt(current.nextPhaseIndex);
    final ap = cardCombatConfig.apForTier(event.momentumTier);

    // 다음 페이즈 HP에도 층별 배율 적용
    final phaseHpMult = floorsConfig.forFloor(boss.floor).enemyHpMultiplier;
    final bossEnemy = EnemyCombatData(
      id: boss.id,
      name: boss.name,
      hp: (nextPhase.hp * phaseHpMult).toInt().clamp(1, 9999),
      atk: nextPhase.atk,
      def: nextPhase.def,
      floor: boss.floor,
      pattern: nextPhase.pattern,
    );

    // 덱 리셔플 (기존 덱 상태 유지, 손패만 다시 드로우)
    var deck = DeckManager.reshuffleAll(current.deckState);
    var phaseDraw = cardCombatConfig.initialHandSize;
    final phaseWebGimmick = EnemyAI.resolveGimmick(nextPhase.gimmick, nextPhase.hp);
    phaseDraw -= phaseWebGimmick.playerDrawPenalty;
    if (phaseDraw < 1) phaseDraw = 1;
    deck = DeckManager.draw(deck, phaseDraw);

    // ── 페이즈 2 첫 턴: 기존 Power/축복/유물 턴-시작 효과 즉시 적용 ──
    var playerBlock = 0;
    var playerHp = current.playerHp;
    var blessingBonusDraw = 0;
    final pe = current.powerEffects;

    // blockPerTurnStart Power: 매 턴 블록
    if (pe.blockPerTurnStart > 0) {
      playerBlock += pe.blockPerTurnStart;
    }

    // conditionalBlockPerTurnStart: HP <30% 시 블록
    if (pe.conditionalBlockPerTurnStart > 0 &&
        playerHp < (current.playerMaxHp * 0.3).toInt()) {
      playerBlock += pe.conditionalBlockPerTurnStart;
    }

    // healPerTurn Power: 매 턴 HP 회복
    if (pe.healPerTurn > 0) {
      playerHp = (playerHp + pe.healPerTurn)
          .clamp(0, current.playerMaxHp);
    }

    // lostHpToBlockPerTurn Power: (maxHp - currentHp) × N% 블록
    if (pe.lostHpToBlockPerTurnPercent > 0) {
      final lostHp = current.playerMaxHp - playerHp;
      if (lostHp > 0) {
        playerBlock +=
            (lostHp * pe.lostHpToBlockPerTurnPercent / 100).toInt();
      }
    }

    // poisonPerTurnStart Power: 적에게 독 (페이즈 2 적은 새로운 상태)
    var enemyStatuses = <StatusEffect>[];
    if (pe.poisonPerTurnStart > 0) {
      enemyStatuses = StatusEffectProcessor.addEffect(
        enemyStatuses,
        StatusEffect(
          type: StatusEffectType.poison,
          stacks: pe.poisonPerTurnStart,
        ),
      );
    }

    // drawPerTurn Power: 추가 드로우
    if (pe.drawPerTurn > 0) {
      deck = DeckManager.draw(deck, pe.drawPerTurn);
    }

    // retrievePerTurn Power: 버림 더미에서 복귀
    if (pe.retrievePerTurn > 0 && deck.discardPile.isNotEmpty) {
      final rng = Random();
      final retrieveCount =
          pe.retrievePerTurn.clamp(0, deck.discardPile.length);
      final shuffledDiscard = List.of(deck.discardPile)..shuffle(rng);
      final retrieved = shuffledDiscard.take(retrieveCount).toList();
      final remaining = List.of(deck.discardPile);
      for (final card in retrieved) {
        remaining.remove(card);
      }
      deck = DeckState(
        drawPile: deck.drawPile,
        hand: [...deck.hand, ...retrieved],
        discardPile: remaining,
        exhaustPile: deck.exhaustPile,
      );
    }

    // 축복 turnStart 효과
    for (final b in current.activeBlessings) {
      switch (b.effectType) {
        case 'autoBlock':
          playerBlock += b.effectValue;
        case 'bonusDraw':
          blessingBonusDraw += b.effectValue;
        case 'bonusApWithHpCost':
          // cb_overload: AP +1, HP -3 (최소 HP 1 유지)
          playerHp = (playerHp - (b.secondaryValue ?? 3)).clamp(1, current.playerMaxHp);
        case 'healPerTurn':
          // blessing_008 재생의 축복: 매 턴 시작 시 HP 회복
          playerHp = (playerHp + b.effectValue).clamp(0, current.playerMaxHp);
        default:
          break;
      }
    }

    // 유물 turnStart 효과
    for (final r in current.activeRelics) {
      switch (r.effectType) {
        case 'bonusDraw':
          blessingBonusDraw += r.effectValue;
        default:
          break;
      }
    }

    // 축복/유물 보너스 드로우 적용
    if (blessingBonusDraw > 0) {
      deck = DeckManager.draw(deck, blessingBonusDraw);
    }

    // bonusApWithHpCost 등으로 HP가 0 이하가 되면 사망 처리
    if (playerHp <= 0) {
      playerHp = playerHp.clamp(0, current.playerMaxHp);
    }

    // 악마의 거래 저주: 적 공격력 보너스 (페이즈 1과 동일하게 적용)
    var devilEnemyStrength = 0;
    final devilCurses = resolveCurseIds(current.playerRunState.activeCurseIds);
    for (final dc in devilCurses) {
      if (dc.effectType == 'enemyDamageBonus') {
        devilEnemyStrength += dc.effectValue ~/ 5;
      }
    }

    emit(CardCombatActive(
      enemies: [EnemyBattleState(
        data: bossEnemy,
        currentHp: bossEnemy.hp,
        maxHp: bossEnemy.hp,
        strength: devilEnemyStrength,
        statuses: enemyStatuses,
      )],
      playerHp: playerHp,
      playerMaxHp: current.playerMaxHp,
      playerBlock: playerBlock,
      deckState: deck,
      actionPoints: ap,
      maxActionPoints: ap,
      playerRunState: current.playerRunState,
      playerStatuses: current.playerStatuses,
      currentTurn: current.currentTurn,
      powerEffects: current.powerEffects,
      roomType: RoomType.boss,
      bossData: boss,
      currentBossPhase: current.nextPhaseIndex,
      activeBlessings: current.activeBlessings,
      activeRelics: current.activeRelics,
      lastMomentumTier: event.momentumTier,
    ));

    if (kDebugMode) {
      GameLogger.debug(
        LogSystem.combat,
        'Boss phase ${current.nextPhaseIndex + 1}: '
        '${boss.name} (HP: ${nextPhase.hp}, ATK: ${nextPhase.atk})',
      );
    }
  }

  void _onPlayCard(PlayCard event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CardCombatActive) {
      emit(state);
      return;
    }

    // 손패에서 카드 찾기 (handIndex 우선, 동일 ID 카드 구분)
    final CardData card;
    final int resolvedHandIndex;
    if (event.handIndex >= 0 && event.handIndex < current.hand.length &&
        current.hand[event.handIndex].id == event.cardId) {
      card = current.hand[event.handIndex];
      resolvedHandIndex = event.handIndex;
    } else {
      final found = current.hand
          .where((c) => c.id == event.cardId)
          .firstOrNull;
      if (found == null) {
        emit(current.copyWith(clearLastPlayResult: true));
        return;
      }
      card = found;
      resolvedHandIndex = current.hand.indexOf(found);
    }

    // 쿨다운 체크 — 쿨다운 중인 카드 사용 불가
    if (current.cooldownCards.containsKey(card.id) &&
        current.cooldownCards[card.id]! > 0) {
      emit(current.copyWith(clearLastPlayResult: true));
      return;
    }

    // AP 확인 (nextSkillApDiscount + allSkillApDiscount Power 적용)
    var effectiveApCost = card.apCost;
    if (card.type == CardType.skill) {
      final totalDiscount = current.nextSkillApDiscount +
          current.powerEffects.allSkillApDiscount;
      if (totalDiscount > 0) {
        effectiveApCost = (effectiveApCost - totalDiscount).clamp(0, 99);
      }
    }
    if (current.actionPoints < effectiveApCost) {
      emit(current.copyWith(clearLastPlayResult: true));
      return;
    }

    // 죽은 적 가드 — 선택된 적이 이미 죽었으면 첫 살아있는 적으로 전환
    var effectiveTargetIndex = current.selectedTargetIndex
        .clamp(0, current.enemies.length - 1);
    if (current.enemies[effectiveTargetIndex].isDead) {
      final liveIdx = current.enemies.indexWhere((e) => !e.isDead);
      if (liveIdx == -1) return; // 모두 사망 — 이미 승리 처리됨
      effectiveTargetIndex = liveIdx;
    }

    // 조건 체크: firstTurnOnly / chainAttackOnly
    for (final effect in card.effects) {
      if (effect.condition == 'firstTurnOnly' && current.currentTurn != 0) {
        emit(current.copyWith(clearLastPlayResult: true));
        return;
      }
      if (effect.condition == 'chainAttackOnly' &&
          current.turnFlags.attacksPlayedThisTurn == 0) {
        emit(current.copyWith(clearLastPlayResult: true));
        return;
      }
    }

    // 카드 효과 계산 (effectiveTargetIndex 기준 적 참조)
    final effectiveEnemy = current.enemies[effectiveTargetIndex];
    final playerStr = StatusEffectProcessor.stacks(
      current.playerStatuses,
      StatusEffectType.strength,
    );
    final playerDex = StatusEffectProcessor.stacks(
      current.playerStatuses,
      StatusEffectType.dexterity,
    );

    // allAttackPiercing Power: Attack 카드 관통 (적 블록 무시)
    final piercingBlock = (current.powerEffects.allAttackPiercing &&
            card.type == CardType.attack)
        ? 0
        : effectiveEnemy.block;

    final result = CardEffectResolver.resolve(
      card: card,
      playerStrength: playerStr,
      playerDexterity: playerDex,
      playerStatuses: current.playerStatuses,
      enemyStatuses: effectiveEnemy.statuses,
      enemyBlock: piercingBlock,
      deckState: current.deckState,
      momentumTier: event.momentumTier,
      playerHp: current.playerHp,
      playerMaxHp: current.playerMaxHp,
      currentTurn: current.currentTurn,
      attacksPlayedThisTurn: current.turnFlags.attacksPlayedThisTurn,
      doubleNextAttack: current.turnFlags.doubleNextAttack,
      playerBlock: current.playerBlock,
      enemyHp: effectiveEnemy.currentHp,
      enemyMaxHp: effectiveEnemy.maxHp,
      skillsPlayedThisTurn: current.turnFlags.skillsPlayedThisTurn,
      handIndex: resolvedHandIndex,
    );

    // 카드 플레이 이벤트 emit (AudioBloc 등 외부 시스템 알림)
    gameEventBus.emit(CardPlayedEvent(
      cardType: card.type.name,
      cardId: card.id,
    ));

    // Exhaust 카드 SFX
    if (card.isExhaust) {
      gameEventBus.emit(CardExhaustedEvent(cardId: card.id, cardName: card.name));
    }

    // ── 연쇄 보너스 계산 ──
    final isCurseCard = card.id.startsWith('curse_');
    final newChainCount = isCurseCard
        ? current.turnFlags.chainCount
        : ChainBonus.updateChainCount(
            current.turnFlags.lastPlayedCardType,
            card.type,
            current.turnFlags.chainCount,
          );
    final chainBonusPct = ChainBonus.bonusPercent(newChainCount, chainBonusConfig);
    if (newChainCount >= 2 && !isCurseCard) {
      gameEventBus.emit(ChainBonusEvent(
        chainCount: newChainCount,
        bonusPercent: chainBonusPct,
      ));
    }

    // 적 HP/블록 계산 (effectiveTargetIndex 기준)
    var newEnemyHp = effectiveEnemy.currentHp;
    var newEnemyBlock = effectiveEnemy.block;
    if (result.damageResult != null) {
      newEnemyBlock -= result.damageResult!.blockAbsorbed;
      if (newEnemyBlock < 0) newEnemyBlock = 0;
      newEnemyHp -= result.damageResult!.hpLost;

      // 연쇄 데미지 보너스 (블록 무시, 직접 HP 차감)
      if (chainBonusPct > 0 && result.damageResult!.hpLost > 0) {
        final chainDmg = ChainBonus.applyToValue(
          result.damageResult!.hpLost,
          newChainCount,
          chainBonusConfig,
        );
        newEnemyHp -= chainDmg;
      }
    }

    // 전투 마일스톤 SFX (hit/block)
    if (result.damageResult != null && result.damageResult!.hpLost > 0) {
      gameEventBus.emit(CombatMilestoneEvent(type: CombatMilestoneType.hit));
    }
    if (result.damageResult != null && result.damageResult!.blockAbsorbed > 0) {
      gameEventBus.emit(CombatMilestoneEvent(type: CombatMilestoneType.block));
    }

    // reflect 기믹: 플레이어 카드 데미지의 15% 반사
    // Phase 3-C: 반응형 reflect — 힘 ≥ 5 시 25%, 연쇄 3+ 시 2배
    var reflectDamage = 0;
    if (current.bossData != null && result.damageResult != null) {
      final reflectPhase = current.bossData!.phaseAt(current.currentBossPhase);
      final playerStr = StatusEffectProcessor.stacks(
        current.playerStatuses, StatusEffectType.strength,
      );
      final reflectGimmick = EnemyAI.resolveGimmickAdvanced(
        reflectPhase.gimmick,
        effectiveEnemy.maxHp,
        bossId: current.bossData!.id,
        playerStrength: playerStr,
        chainCount: current.turnFlags.chainCount,
      );
      if (reflectGimmick.reflectPercent > 0 && result.damageResult!.hpLost > 0) {
        reflectDamage =
            (result.damageResult!.hpLost * reflectGimmick.reflectPercent / 100)
                .toInt();
        // Phase 3-C: doubleReflectDamage — 반사 데미지 2배
        if (reflectGimmick.doubleReflectDamage) {
          reflectDamage *= 2;
        }
      }
    }

    // 플레이어 HP/블록 계산
    var newPlayerHp = current.playerHp - result.selfDamage + result.healAmount
        - reflectDamage;
    if (newPlayerHp > current.playerMaxHp) newPlayerHp = current.playerMaxHp;
    if (newPlayerHp < 0) newPlayerHp = 0;

    var newPlayerBlock = current.playerBlock + result.blockGained;

    // 연쇄 보너스는 공격(데미지)에만 적용 — 방어(블록)에는 적용하지 않음

    // 상태 효과 적용
    final regenCap = current.playerRunState.currentJobId == 'highPriest'
        ? null
        : combatConfig.maxRegenStacks;
    var playerStatuses = List<StatusEffect>.from(current.playerStatuses);
    for (final s in result.newPlayerStatuses) {
      playerStatuses = StatusEffectProcessor.addEffect(playerStatuses, s,
          regenCap: regenCap);
      gameEventBus.emit(StatusEffectAppliedEvent(
        effectType: s.type.name,
        target: 'player',
      ));
    }

    var enemyStatuses = List<StatusEffect>.from(effectiveEnemy.statuses);
    for (final s in result.newEnemyStatuses) {
      enemyStatuses = StatusEffectProcessor.addEffect(enemyStatuses, s);
      gameEventBus.emit(StatusEffectAppliedEvent(
        effectType: s.type.name,
        target: 'enemy',
      ));
    }

    // cleanse 처리 (정화) — 모든 디버프 제거
    if (result.requestCleanse) {
      playerStatuses = playerStatuses
          .where((s) => !s.type.isDebuff)
          .toList();
    }

    // 드로우 효과
    var updatedDeck = result.updatedDeck;
    if (result.drawCount > 0) {
      updatedDeck = DeckManager.draw(updatedDeck, result.drawCount);
    }

    // 연쇄 드로우 보너스
    final chainDrawCount = ChainBonus.drawBonus(newChainCount, chainBonusConfig);
    if (chainDrawCount > 0) {
      updatedDeck = DeckManager.draw(updatedDeck, chainDrawCount);
    }

    // copyLastAttack 처리 (그림자 분신)
    if (result.requestCopyLastAttack && current.lastPlayedAttack != null) {
      updatedDeck = DeckManager.addToHand(
        updatedDeck,
        current.lastPlayedAttack!,
      );
    }

    // generateRandomCard 처리 (카드 생성)
    if (result.generateCardCount > 0) {
      final rng = Random();
      final colorlessBase = ColorlessCards.base;
      for (var i = 0; i < result.generateCardCount; i++) {
        final randomCard = colorlessBase[rng.nextInt(colorlessBase.length)];
        updatedDeck = DeckManager.addToHand(updatedDeck, randomCard);
      }
    }

    // randomDebuffs 처리 (대혼란)
    if (result.randomDebuffCount > 0) {
      final rng = Random();
      const debuffTypes = [
        StatusEffectType.poison,
        StatusEffectType.burn,
        StatusEffectType.weak,
        StatusEffectType.vulnerable,
      ];
      for (var i = 0; i < result.randomDebuffCount; i++) {
        final debuffType = debuffTypes[rng.nextInt(debuffTypes.length)];
        final debuff = StatusEffect(
          type: debuffType,
          stacks: debuffType == StatusEffectType.poison ? 3 : 1,
          turnsRemaining:
              (debuffType == StatusEffectType.weak ||
                      debuffType == StatusEffectType.vulnerable)
                  ? 2
                  : null,
        );
        enemyStatuses = StatusEffectProcessor.addEffect(enemyStatuses, debuff);
      }
    }

    // mimicEnemyDamage 처리 (모방)
    final lastAction = current.lastEnemyAction;
    if (result.mimicEnemyMultiplier > 0 && lastAction != null) {
      final enemyDmg = lastAction.damage;
      if (enemyDmg > 0) {
        final mimicDmg = (enemyDmg * result.mimicEnemyMultiplier / 100).toInt();
        newEnemyHp -= mimicDmg;
      }
    }

    // blockPerCardPlayed 처리 (연속 적응)
    if (result.blockPerCardPlayedValue > 0) {
      // +1 for the current card being played
      final totalCards = current.turnFlags.cardsPlayedThisTurn + 1;
      newPlayerBlock += totalCards * result.blockPerCardPlayedValue;
    }

    // ── 히든잡 즉시 효과 ──

    // 사신: 처형 (적 HP가 maxHp * percent / 100 이하면 즉사)
    if (result.executeHpPercent > 0 && newEnemyHp > 0) {
      final threshold =
          (effectiveEnemy.maxHp * result.executeHpPercent / 100).toInt();
      if (newEnemyHp <= threshold) {
        newEnemyHp = 0;
      }
    }

    // 조율사: 적 힘 흡수
    var newEnemyStrength = effectiveEnemy.strength;
    if (result.absorbStrengthValue > 0) {
      final absorbed = min(result.absorbStrengthValue, newEnemyStrength);
      newEnemyStrength -= absorbed;
      if (absorbed > 0) {
        playerStatuses = StatusEffectProcessor.addEffect(
          playerStatuses,
          StatusEffect(
            type: StatusEffectType.strength,
            stacks: absorbed,
          ),
        );
      }
    }

    // 조율사: 적응형 데미지 (적 마지막 행동이 공격이면 high, 아니면 low)
    if (result.adaptiveDamageHigh > 0 || result.adaptiveDamageLow > 0) {
      final lastAction = current.lastEnemyAction;
      final adaptiveDmg = (lastAction?.type.isAttack ?? false)
          ? result.adaptiveDamageHigh
          : result.adaptiveDamageLow;
      if (adaptiveDmg > 0) {
        // 적 블록 고려
        final blockAbs = min(newEnemyBlock, adaptiveDmg);
        newEnemyBlock -= blockAbs;
        newEnemyHp -= (adaptiveDmg - blockAbs);
      }
    }

    // 조율사: 최저 스탯 부스트 (strength vs dexterity 중 낮은 쪽 +value)
    // Power 카드는 턴당 효과로 누적하므로 즉시 적용하지 않음
    if (result.boostLowestStatValue > 0 && card.type != CardType.power) {
      final currentStr = StatusEffectProcessor.stacks(
        playerStatuses,
        StatusEffectType.strength,
      );
      final currentDex = StatusEffectProcessor.stacks(
        playerStatuses,
        StatusEffectType.dexterity,
      );
      final boostType = currentStr <= currentDex
          ? StatusEffectType.strength
          : StatusEffectType.dexterity;
      playerStatuses = StatusEffectProcessor.addEffect(
        playerStatuses,
        StatusEffect(type: boostType, stacks: result.boostLowestStatValue),
      );
    }

    // 환술사: 마지막 카드 재실행 (마지막 공격의 데미지/블록만 재적용, 무한루프 방지)
    if (result.replayLastCardCount > 0 && current.lastPlayedAttack != null) {
      final replayCard = current.lastPlayedAttack!;
      for (var i = 0; i < result.replayLastCardCount; i++) {
        // 데미지 재적용
        if (replayCard.damage != null && replayCard.damage! > 0) {
          final replayStr = StatusEffectProcessor.stacks(
            playerStatuses,
            StatusEffectType.strength,
          );
          final isWeakened = StatusEffectProcessor.hasActive(
            playerStatuses,
            StatusEffectType.weak,
          );
          final isVulnerable = StatusEffectProcessor.hasActive(
            enemyStatuses,
            StatusEffectType.vulnerable,
          );
          final replayDmgResult = DamageCalculator.calculatePlayerDamage(
            baseDamage: replayCard.damage!,
            strength: replayStr,
            isWeakened: isWeakened,
            targetIsVulnerable: isVulnerable,
            targetBlock: newEnemyBlock,
          );
          newEnemyBlock -= replayDmgResult.blockAbsorbed;
          if (newEnemyBlock < 0) newEnemyBlock = 0;
          newEnemyHp -= replayDmgResult.hpLost;
        }
        // 블록 재적용
        if (replayCard.block != null && replayCard.block! > 0) {
          final replayDex = StatusEffectProcessor.stacks(
            playerStatuses,
            StatusEffectType.dexterity,
          );
          var replayBlock = replayCard.block! + replayDex;
          if (replayBlock < 0) replayBlock = 0;
          newPlayerBlock += replayBlock;
        }
      }
    }

    // ── 보스 환경카드 즉시 효과 ──

    // regenNullify: 적 heal 무효화 (N턴)
    var newEnemyHealBlockedTurns = effectiveEnemy.healBlockedTurns;
    if (result.regenNullifyTurns > 0) {
      newEnemyHealBlockedTurns += result.regenNullifyTurns;
    }

    // stunEnemy: 적 행동 차단 (N턴)
    var newEnemyStunnedTurns = effectiveEnemy.stunnedTurns;
    if (result.stunEnemyTurns > 0) {
      newEnemyStunnedTurns += result.stunEnemyTurns;
    }

    // resetEnemyBuff: 적 힘/버프 초기화
    if (result.resetEnemyBuff) {
      newEnemyStrength = 0;
      // strength 상태효과도 제거
      enemyStatuses = enemyStatuses
          .where((s) => s.type != StatusEffectType.strength)
          .toList();
    }

    // drainNullify: 적 흡혈 무효화 (N턴)
    var newEnemyDrainBlockedTurns = effectiveEnemy.drainBlockedTurns;
    if (result.drainNullifyTurns > 0) {
      newEnemyDrainBlockedTurns += result.drainNullifyTurns;
    }

    // momentumGain: GameEventBus 경유 기세 증가
    if (result.momentumGainAmount > 0) {
      gameEventBus.emit(MomentumGainEvent(amount: result.momentumGainAmount));
    }

    // 연쇄 기세 보너스
    final chainMomentum = ChainBonus.momentumBonus(newChainCount, chainBonusConfig);
    if (chainMomentum > 0) {
      gameEventBus.emit(MomentumGainEvent(amount: chainMomentum));
    }

    // fleeGuaranteed: 도주 100% 성공 플래그
    var newFleeGuaranteed = current.fleeGuaranteed;
    if (result.setFleeGuaranteed) {
      newFleeGuaranteed = true;
    }

    // apBonus: 조율사 전타입 AP 보너스가 아래에서 추가될 수 있음
    var newAp = current.actionPoints - effectiveApCost + result.apGain;

    // 플래그 업데이트
    final newDoubleNext = result.setDoubleNextAttack ||
        (current.turnFlags.doubleNextAttack && card.type != CardType.attack);
    final newImmune = result.setImmuneThisTurn || current.turnFlags.immuneThisTurn;
    final newExhaustHand =
        result.setExhaustHandAtTurnEnd || current.turnFlags.exhaustHandAtTurnEnd;
    final newApModNext =
        current.turnFlags.apModifierNextTurn + result.apModifierNextTurn;
    final newAttacksPlayed = current.turnFlags.attacksPlayedThisTurn +
        (card.type == CardType.attack ? 1 : 0);
    final newCardsPlayed =
        current.turnFlags.cardsPlayedThisTurn + (isCurseCard ? 0 : 1);
    final newLastAttack =
        card.type == CardType.attack ? card : current.lastPlayedAttack;
    final newPoisonPerTurn =
        current.powerEffects.poisonPerTurnStart + result.poisonPerTurnStart;
    final newBlockPerTurn =
        current.powerEffects.blockPerTurnStart + result.blockPerTurnStart;
    final newConditionalBlockPerTurn =
        current.powerEffects.conditionalBlockPerTurnStart + result.conditionalBlockPerTurnStart;
    final newBlockRetain =
        current.turnFlags.blockRetainPercent > 0
            ? current.turnFlags.blockRetainPercent
            : result.blockRetainPercent;
    final newRetrievePerTurn =
        current.powerEffects.retrievePerTurn + result.retrievePerTurn;

    // ── 히든잡 턴 간 지속 플래그 누적 ──
    final newSelfDamagePerTurn =
        current.powerEffects.selfDamagePerTurn + result.selfDamagePerTurn;
    final newStrengthPerTurn =
        current.powerEffects.strengthPerTurn + result.strengthPerTurn;
    final newGenerateAttackPerTurn =
        current.powerEffects.generateAttackPerTurn + result.generateAttackPerTurn;
    final newTransformHand =
        result.setTransformHand || current.powerEffects.transformHand;
    final newAllTypesApBonus =
        result.setAllTypesApBonus || current.powerEffects.allTypesApBonus;
    // boostLowestStat: Power 카드에서만 턴당 효과로 누적
    final newBoostLowestStatPerTurn =
        result.boostLowestStatValue > 0 && card.type == CardType.power
            ? current.powerEffects.boostLowestStatPerTurn + result.boostLowestStatValue
            : current.powerEffects.boostLowestStatPerTurn;

    // ── 콘텐츠 확장 Power 효과 누적 ──
    final newDodgeChance =
        current.powerEffects.dodgeChancePercent + result.dodgeChancePercent;
    final newLostHpToBlock =
        current.powerEffects.lostHpToBlockPerTurnPercent + result.lostHpToBlockPerTurnPercent;
    final newHealPerTurn =
        current.powerEffects.healPerTurn + result.healPerTurnValue;
    final newDrawPerTurn =
        current.powerEffects.drawPerTurn + result.drawPerTurnValue;
    final newReflectChance =
        current.powerEffects.reflectDamageChancePercent + result.reflectDamageChancePercent;
    final newRemainingApBlock =
        result.remainingApBlockValue > 0
            ? result.remainingApBlockValue
            : current.turnFlags.remainingApBlockValue;

    // ── Phase 3-B Power 효과 누적 ──
    final newLifestealOnAllAttacks =
        current.powerEffects.lifestealOnAllAttacksPercent +
            result.lifestealOnAllAttacksPercent;
    final newHealPerTurnConditional =
        current.powerEffects.healPerTurnConditional +
            result.healPerTurnConditionalValue;
    final newHealPerTurnCondition =
        result.healPerTurnCondition ?? current.powerEffects.healPerTurnCondition;
    final newOverflowToBlock =
        current.powerEffects.overflowToBlockPercent +
            result.overflowToBlockPercent;
    final newMomentumGainOnDodge =
        current.powerEffects.momentumGainOnDodge +
            result.momentumGainOnDodgeValue;
    final newPoisonDmgReduction =
        current.powerEffects.poisonDamageReduction +
            result.poisonDamageReductionValue;
    final newPoisonDmgReductionCap = result.poisonDamageReductionCap > 0
        ? result.poisonDamageReductionCap
        : current.powerEffects.poisonDamageReductionCap;
    final newDmgReductionWhenBlock =
        current.powerEffects.damageReductionWhenBlock +
            result.damageReductionWhenBlockValue;
    final newDmgReductionWhenBlockThreshold =
        result.damageReductionWhenBlockThreshold > 0
            ? result.damageReductionWhenBlockThreshold
            : current.powerEffects.damageReductionWhenBlockThreshold;
    final newHealOnDamageTaken =
        current.powerEffects.healOnDamageTaken +
            result.healOnDamageTakenValue;
    final newHealOnReflect =
        current.powerEffects.healOnReflect + result.healOnReflectValue;

    // ── Phase 4 Power 효과 누적 ──
    final newAllAttackPiercing =
        result.setAllAttackPiercing || current.powerEffects.allAttackPiercing;
    final newAllSkillApDiscount =
        current.powerEffects.allSkillApDiscount + result.allSkillApDiscountValue;

    // randomBuff: 랜덤 버프 1개 부여 (힘/민첩/가시/재생 중 1)
    if (result.randomBuffCount > 0) {
      final buffTypes = [
        StatusEffectType.strength,
        StatusEffectType.dexterity,
        StatusEffectType.thorn,
        StatusEffectType.regenerate,
      ];
      for (int i = 0; i < result.randomBuffCount; i++) {
        final buffType = buffTypes[_random.nextInt(buffTypes.length)];
        playerStatuses = StatusEffectProcessor.addEffect(
          playerStatuses,
          StatusEffect(type: buffType, stacks: 1),
        );
      }
    }

    // ── Phase 3-B 지속 상태 업데이트 ──
    // nextSkillApDiscount: Skill 사용 시 소비, 아니면 누적
    var newNextSkillApDiscount = current.nextSkillApDiscount;
    if (card.type == CardType.skill && current.nextSkillApDiscount > 0) {
      newNextSkillApDiscount = 0; // 소비됨
    }
    if (result.nextSkillApDiscountValue > 0) {
      newNextSkillApDiscount += result.nextSkillApDiscountValue;
    }

    // immuneNextHits: 누적
    final newImmuneNextHits =
        current.immuneNextHitsRemaining + result.immuneNextHitsCount;

    // nextHitDamageReduction: 누적
    final newNextHitDmgReduction = current.nextHitDamageReductionPercent > 0
        ? current.nextHitDamageReductionPercent
        : result.nextHitDamageReductionPercent;

    // cooldown 트래킹: 현재 카드에 cooldownAfterUse가 있으면 등록
    var newCooldownCards = Map<String, int>.from(current.cooldownCards);
    if (result.cooldownTurns > 0) {
      newCooldownCards[card.id] = result.cooldownTurns;
    }

    // Skill 카드 카운트
    final newSkillsPlayed = current.turnFlags.skillsPlayedThisTurn +
        (card.type == CardType.skill ? 1 : 0);

    // 힘 ↔ 민첩 교환
    if (result.requestSwapStrDex) {
      final curStr = StatusEffectProcessor.stacks(
          playerStatuses, StatusEffectType.strength);
      final curDex = StatusEffectProcessor.stacks(
          playerStatuses, StatusEffectType.dexterity);
      playerStatuses = playerStatuses
          .where((s) =>
              s.type != StatusEffectType.strength &&
              s.type != StatusEffectType.dexterity)
          .toList();
      if (curDex > 0) {
        playerStatuses = StatusEffectProcessor.addEffect(
          playerStatuses,
          StatusEffect(type: StatusEffectType.strength, stacks: curDex),
        );
      }
      if (curStr > 0) {
        playerStatuses = StatusEffectProcessor.addEffect(
          playerStatuses,
          StatusEffect(type: StatusEffectType.dexterity, stacks: curStr),
        );
      }
    }

    // 조율사: 전타입 AP 보너스 — 이번 턴 플레이한 카드 타입 추적
    var newTypesPlayed = Set<CardType>.from(current.turnFlags.typesPlayedThisTurn);
    newTypesPlayed.add(card.type);

    // 조율사: 전타입 AP 보너스 — 3타입 모두 등장하면 AP +1 (턴 당 1회)
    var apBonus = 0;
    if (newAllTypesApBonus &&
        newTypesPlayed.contains(CardType.attack) &&
        newTypesPlayed.contains(CardType.skill) &&
        newTypesPlayed.contains(CardType.power) &&
        !(current.turnFlags.typesPlayedThisTurn.contains(CardType.attack) &&
            current.turnFlags.typesPlayedThisTurn.contains(CardType.skill) &&
            current.turnFlags.typesPlayedThisTurn.contains(CardType.power))) {
      apBonus = 1;
    }
    newAp += apBonus;

    // ── 축복/유물 카드 플레이 효과 ──

    // onCardPlay: cb_swift (첫 카드 AP 할인)
    if (!isCurseCard && current.turnFlags.cardsPlayedThisTurn == 0) {
      for (final b in current.activeBlessings) {
        if (b.effectType == 'firstCardApDiscount') {
          newAp += b.effectValue;
        }
      }
    }

    // onCardPlay: cb_chain (0 AP 카드 → 드로우)
    if (!isCurseCard && card.apCost == 0) {
      for (final b in current.activeBlessings) {
        if (b.effectType == 'zeroApDraw') {
          updatedDeck = DeckManager.draw(updatedDeck, b.effectValue);
        }
      }
    }

    // onAttack: 축복 효과 (Attack 카드만)
    if (card.type == CardType.attack) {
      for (final b in current.activeBlessings) {
        switch (b.effectType) {
          case 'lifeSteal':
            // cb_leech: 공격 데미지 20% HP 회복
            if (result.damageResult != null && result.damageResult!.hpLost > 0) {
              final leechHeal =
                  (result.damageResult!.hpLost * b.effectValue / 100).toInt();
              if (leechHeal > 0) {
                newPlayerHp += leechHeal;
                if (newPlayerHp > current.playerMaxHp) {
                  newPlayerHp = current.playerMaxHp;
                }
              }
            }
          case 'copyAttackChance':
            // cb_afterimage: 25% 확률 공격 카드 복사
            if (_random.nextInt(100) < b.effectValue) {
              updatedDeck = DeckManager.addToHand(updatedDeck, card);
            }
          case 'attackBurn':
            // cb_flame_blood: 모든 Attack에 화상 추가
            enemyStatuses = StatusEffectProcessor.addEffect(
              enemyStatuses,
              StatusEffect(type: StatusEffectType.burn, stacks: b.effectValue),
            );
          case 'globalLifesteal':
            // cb_vampire: 모든 Attack에 N% 흡혈
            if (result.damageResult != null && result.damageResult!.hpLost > 0) {
              final leechHeal =
                  (result.damageResult!.hpLost * b.effectValue / 100).toInt();
              if (leechHeal > 0) {
                newPlayerHp += leechHeal;
                if (newPlayerHp > current.playerMaxHp) {
                  newPlayerHp = current.playerMaxHp;
                }
              }
            }
          case 'executeThreshold':
            // cb_reaper: 적 HP < 5% 시 즉사
            if (newEnemyHp > 0) {
              final threshold =
                  (effectiveEnemy.maxHp * b.effectValue / 100).toInt();
              if (newEnemyHp <= threshold) {
                newEnemyHp = 0;
              }
            }
        }
      }
    }

    // ── Phase 3-B: lifestealOnAllAttacks Power ──
    if (card.type == CardType.attack &&
        current.powerEffects.lifestealOnAllAttacksPercent > 0 &&
        result.damageResult != null &&
        result.damageResult!.hpLost > 0) {
      final lifestealHeal = (result.damageResult!.hpLost *
              current.powerEffects.lifestealOnAllAttacksPercent /
              100)
          .toInt();
      if (lifestealHeal > 0) {
        newPlayerHp += lifestealHeal;
        if (newPlayerHp > current.playerMaxHp) {
          newPlayerHp = current.playerMaxHp;
        }
      }
    }

    // ── Phase 3-B: overflowToBlock Power ──
    if (current.powerEffects.overflowToBlockPercent > 0 &&
        result.damageResult != null &&
        result.damageResult!.hpLost > newEnemyHp.clamp(0, 99999) &&
        newEnemyHp < 0) {
      // 오버킬 데미지 = 적 HP가 0 미만으로 내려간 양
      final overkill = -newEnemyHp;
      final overflowBlock =
          (overkill * current.powerEffects.overflowToBlockPercent / 100)
              .toInt();
      newPlayerBlock += overflowBlock;
    }

    // onBlock relic: cr_thorn_shield (블록 10+ 시 가시 데미지)
    if (result.blockGained > 0) {
      for (final r in current.activeRelics) {
        if (r.effectType == 'thornOnBlock' &&
            newPlayerBlock >= (r.conditionValue ?? 0)) {
          newEnemyHp -= r.effectValue;
        }
      }
    }

    // observe(revealIntent) 사용 시:
    // value > 0: 적 의도 공개 + 서술자 왜곡 해제 + 환경 카드 해금
    // value == 0: 환경 카드 해금만
    var envGranted = current.environmentGranted;
    var intentRevealed = current.intentRevealed;
    var intentRevealTurns = current.intentRevealTurns;
    final revealEffect =
        card.effects.where((e) => e.type == CardEffectType.revealIntent).firstOrNull;
    if (revealEffect != null) {
      final revealTurns = revealEffect.value;

      // 적 의도 공개 + 서술자 왜곡 해제 (value > 0인 경우만)
      if (revealTurns > 0) {
        intentRevealed = true;
        intentRevealTurns = revealTurns;
        gameEventBus.emit(TruthRevealEvent(turns: revealTurns));
      }

      if (!current.environmentGranted &&
          current.environmentCardObserved != null) {
        updatedDeck = DeckManager.addToHand(
          updatedDeck,
          current.environmentCardObserved!,
        );
        envGranted = true;
      }
    }

    // ── 기세 High 전환 감지 (cb_momentum_burst, cr_destruction_hammer) ──
    var updatedHighBonusDmg = current.momentumHighBonusDamage;
    if (event.momentumTier >= 3 && current.lastMomentumTier < 3) {
      // cb_momentum_burst: 기세 High 진입 시 즉시 적 데미지
      for (final b in current.activeBlessings) {
        if (b.effectType == 'momentumHighDamage') {
          newEnemyHp -= b.effectValue;
        }
      }
      // cr_destruction_hammer: 기세 High 진입 시 다음 Attack 데미지 보너스 설정
      for (final r in current.activeRelics) {
        if (r.effectType == 'bonusAttackDamage') {
          updatedHighBonusDmg += r.effectValue;
        }
      }
    }
    // cr_destruction_hammer 보너스 소비 (Attack 카드에 적용)
    if (card.type == CardType.attack && updatedHighBonusDmg > 0) {
      newEnemyHp -= updatedHighBonusDmg;
      updatedHighBonusDmg = 0;
    }

    // ── 멀티몹 enemies 리스트 구축 (effectiveTargetIndex 기준) ──
    var updatedEnemies = List<EnemyBattleState>.from(current.enemies);
    updatedEnemies[effectiveTargetIndex] =
        updatedEnemies[effectiveTargetIndex].copyWith(
      currentHp: newEnemyHp,
      block: newEnemyBlock,
      strength: newEnemyStrength,
      statuses: enemyStatuses,
      healBlockedTurns: newEnemyHealBlockedTurns,
      stunnedTurns: newEnemyStunnedTurns,
      drainBlockedTurns: newEnemyDrainBlockedTurns,
    );

    // AoE: 다른 살아있는 적에게도 카드 효과 적용
    if (card.effectiveTargetType == CardTargetType.all) {
      for (var i = 0; i < updatedEnemies.length; i++) {
        if (i == effectiveTargetIndex) continue;
        if (updatedEnemies[i].isDead) continue;
        updatedEnemies[i] = _resolveAoeAgainstEnemy(
          card: card,
          enemy: updatedEnemies[i],
          current: current,
          momentumTier: event.momentumTier,
        );
      }
    }

    // 킬 판정 + onKill 효과 (사신 healOnKill은 킬당 1회)
    for (var i = 0; i < updatedEnemies.length; i++) {
      if (updatedEnemies[i].isDead && !current.enemies[i].isDead) {
        if (result.healOnKill > 0) {
          newPlayerHp += result.healOnKill;
          if (newPlayerHp > current.playerMaxHp) {
            newPlayerHp = current.playerMaxHp;
          }
        }
      }
    }

    // 전원 사망 → 승리
    if (updatedEnemies.every((e) => e.isDead)) {
      var killMaxHp = current.playerMaxHp;
      for (final b in current.activeBlessings) {
        if (b.effectType == 'maxHpOnKill') {
          killMaxHp += b.effectValue;
          newPlayerHp += b.effectValue;
        }
      }
      for (final r in current.activeRelics) {
        if (r.effectType == 'healOnKill') {
          newPlayerHp += r.effectValue;
        }
      }
      if (newPlayerHp > killMaxHp) newPlayerHp = killMaxHp;
      final killState = killMaxHp != current.playerMaxHp
          ? current.copyWith(playerMaxHp: killMaxHp, enemies: updatedEnemies)
          : current.copyWith(enemies: updatedEnemies);
      _emitCardCombatVictory(killState, newPlayerHp, emit);
      return;
    }

    // 플레이어 사망 (자해 데미지, 갓 모드 시 HP 1 유지)
    if (debugGodMode && newPlayerHp <= 0) newPlayerHp = 1;
    if (newPlayerHp <= 0) {
      _emitCardCombatDefeat(current, emit);
      return;
    }

    // 선택된 적 사망 시 다음 살아있는 적으로 자동 전환
    var newSelectedTarget = effectiveTargetIndex;
    if (updatedEnemies[newSelectedTarget].isDead) {
      final nextLive = updatedEnemies.indexWhere((e) => !e.isDead);
      if (nextLive != -1) newSelectedTarget = nextLive;
    }

    emit(current.copyWith(
      enemies: updatedEnemies,
      selectedTargetIndex: newSelectedTarget,
      playerHp: newPlayerHp,
      playerBlock: newPlayerBlock,
      deckState: updatedDeck,
      actionPoints: newAp,
      playerStatuses: playerStatuses,
      lastPlayResult: result,
      lastPlayedAttack: newLastAttack,
      turnFlags: TurnFlags(
        immuneThisTurn: newImmune,
        doubleNextAttack: newDoubleNext,
        apModifierNextTurn: newApModNext,
        exhaustHandAtTurnEnd: newExhaustHand,
        attacksPlayedThisTurn: newAttacksPlayed,
        cardsPlayedThisTurn: newCardsPlayed,
        blockRetainPercent: newBlockRetain,
        typesPlayedThisTurn: newTypesPlayed,
        remainingApBlockValue: newRemainingApBlock,
        skillsPlayedThisTurn: newSkillsPlayed,
        lastPlayedCardType: isCurseCard ? current.turnFlags.lastPlayedCardType : card.type,
        chainCount: newChainCount,
      ),
      powerEffects: PowerEffects(
        poisonPerTurnStart: newPoisonPerTurn,
        blockPerTurnStart: newBlockPerTurn,
        conditionalBlockPerTurnStart: newConditionalBlockPerTurn,
        retrievePerTurn: newRetrievePerTurn,
        selfDamagePerTurn: newSelfDamagePerTurn,
        strengthPerTurn: newStrengthPerTurn,
        generateAttackPerTurn: newGenerateAttackPerTurn,
        transformHand: newTransformHand,
        allTypesApBonus: newAllTypesApBonus,
        boostLowestStatPerTurn: newBoostLowestStatPerTurn,
        dodgeChancePercent: newDodgeChance,
        lostHpToBlockPerTurnPercent: newLostHpToBlock,
        healPerTurn: newHealPerTurn,
        drawPerTurn: newDrawPerTurn,
        reflectDamageChancePercent: newReflectChance,
        lifestealOnAllAttacksPercent: newLifestealOnAllAttacks,
        healPerTurnConditional: newHealPerTurnConditional,
        healPerTurnCondition: newHealPerTurnCondition,
        overflowToBlockPercent: newOverflowToBlock,
        momentumGainOnDodge: newMomentumGainOnDodge,
        poisonDamageReduction: newPoisonDmgReduction,
        poisonDamageReductionCap: newPoisonDmgReductionCap,
        damageReductionWhenBlock: newDmgReductionWhenBlock,
        damageReductionWhenBlockThreshold: newDmgReductionWhenBlockThreshold,
        healOnDamageTaken: newHealOnDamageTaken,
        healOnReflect: newHealOnReflect,
        allAttackPiercing: newAllAttackPiercing,
        allSkillApDiscount: newAllSkillApDiscount,
      ),
      environmentGranted: envGranted,
      intentRevealed: intentRevealed,
      intentRevealTurns: intentRevealTurns,
      fleeGuaranteed: newFleeGuaranteed,
      fleeFailed: false,
      lastMomentumTier: event.momentumTier,
      momentumHighBonusDamage: updatedHighBonusDmg,
      nextSkillApDiscount: newNextSkillApDiscount,
      immuneNextHitsRemaining: newImmuneNextHits,
      nextHitDamageReductionPercent: newNextHitDmgReduction,
      cooldownCards: newCooldownCards,
    ));
  }

  void _onEndPlayerTurn(EndPlayerTurn event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CardCombatActive) return;
    _processEndOfTurn(current, emit, momentumTier: event.momentumTier);
  }

  /// 턴 종료 공통 로직 — EndPlayerTurn과 AttemptFlee(실패) 공유.
  void _processEndOfTurn(
    CardCombatActive current,
    Emitter<CombatState> emit, {
    required int momentumTier,
    bool fleeFailed = false,
  }) {
    final nextTurn = current.currentTurn + 1;

    // 0. 턴 종료 시 남은 AP × value 블록 (remainingApBlock 카드 효과)
    var currentForEnemy = current;
    if (current.turnFlags.remainingApBlockValue > 0 && current.actionPoints > 0) {
      final apBlock = current.actionPoints * current.turnFlags.remainingApBlockValue;
      currentForEnemy = current.copyWith(
        playerBlock: current.playerBlock + apBlock,
      );
      // 절약 블록 적용 중간 상태 emit — UI에 블록 표시
      emit(currentForEnemy);
    }

    // 0.5 exhaustHandAtTurnEnd 처리 (전력 질주)
    var preDeck = currentForEnemy.deckState;
    if (currentForEnemy.turnFlags.exhaustHandAtTurnEnd) {
      for (final c in preDeck.hand) {
        preDeck = DeckManager.exhaustFromHand(preDeck, c.id);
      }
    }

    // 1. 턴 종료 버리기 (Retain 유지, Ethereal 소진)
    var deck = DeckManager.endTurnDiscard(preDeck);

    // ── 2~6. 멀티몹 적 행동 루프 ──
    var updatedEnemies = List<EnemyBattleState>.from(currentForEnemy.enemies);
    var playerHp = currentForEnemy.playerHp;
    var playerBlock = currentForEnemy.playerBlock;
    var playerStatuses = List<StatusEffect>.from(current.playerStatuses);
    EnemyActionResult? lastEnemyAction;
    final List<(String, EnemyActionResult)> allEnemyActions = [];
    var newPerfectFormDisabled = current.perfectFormDisabledTurns;
    // Phase 3-B: 적 행동 루프에서 누적 추적
    var loopImmuneNextHits = current.immuneNextHitsRemaining;
    var loopNextHitDmgReduction = current.nextHitDamageReductionPercent;
    var playerTookHpDamageThisTurn = false;

    for (var ei = 0; ei < updatedEnemies.length; ei++) {
      if (updatedEnemies[ei].isDead) continue;

      final enemyState = updatedEnemies[ei];

      // 3. 적 행동 (스턴 시 스킵)
      // 독/화상으로 죽을 적에게는 HP override 비활성 (회복으로 생존 방지)
      final pendingTickDmg = StatusEffectProcessor.stacks(
            enemyState.statuses, StatusEffectType.poison) +
          StatusEffectProcessor.stacks(
            enemyState.statuses, StatusEffectType.burn);
      final willDieFromTick = enemyState.currentHp <= pendingTickDmg;
      // Phase 3-C: resolveActionAdvanced — 플레이어 상태 반응형 AI
      final enemyAction = EnemyAI.resolveActionAdvanced(
        enemyState.data,
        currentForEnemy.currentTurn,
        enemyStrength: enemyState.strength,
        patternOffset: enemyState.patternOffset,
        enemyHpRatio: willDieFromTick
            ? null
            : enemyState.currentHp / enemyState.maxHp,
        playerBlock: playerBlock,
        currentTurnNumber: currentForEnemy.currentTurn,
        isBoss: currentForEnemy.bossData != null,
        lastOverrideAction: enemyState.lastOverrideAction,
        enragedTurns: enemyState.enragedTurns,
        random: _random,
      );

      final playerHpBefore = playerHp;
      final enemyPhase = _resolveEnemyAction(
        current: currentForEnemy,
        enemyAction: enemyAction,
        enemyOverride: enemyState,
        playerHpOverride: playerHp,
        playerBlockOverride: playerBlock,
        immuneNextHitsOverride: loopImmuneNextHits,
        nextHitDmgReductionOverride: loopNextHitDmgReduction,
      );
      playerHp = enemyPhase.playerHp;
      playerBlock = enemyPhase.playerBlock;
      loopImmuneNextHits = enemyPhase.immuneNextHits;
      loopNextHitDmgReduction = enemyPhase.nextHitDmgReduction;
      var eHp = enemyPhase.enemyHp;
      var eBlock = enemyPhase.enemyBlock;
      var eStrength = enemyPhase.enemyStrength;

      // Phase 3-B: 회피 성공 시 기세 획득
      if (enemyPhase.dodged && current.powerEffects.momentumGainOnDodge > 0) {
        gameEventBus.emit(MomentumGainEvent(
          amount: current.powerEffects.momentumGainOnDodge,
        ));
      }

      // Phase 3-B: 피격 추적 (healOnDamageTaken)
      if (playerHp < playerHpBefore) {
        playerTookHpDamageThisTurn = true;
        gameEventBus.emit(PlayerDamagedEvent(
          hpLost: playerHpBefore - playerHp,
          remainingHp: playerHp,
        ));
      }

      // 3.5 축복 onHit 효과 (적 공격이 플레이어를 타격했을 때)
      if (enemyState.stunnedTurns <= 0 &&
          enemyAction.type.isAttack &&
          !currentForEnemy.turnFlags.immuneThisTurn) {
        final playerTookHpDamage = playerHp < playerHpBefore;
        for (final b in current.activeBlessings) {
          if (b.effectType == 'thornDamage') {
            eHp -= b.effectValue;
          } else if (b.effectType == 'freeStrike' && playerTookHpDamage) {
            deck = DeckManager.addToHand(deck, ColorlessCards.preemptiveStrike);
          }
        }
      }

      // 3.6 축복 cb_perfect_form 피격 시 비활성화
      if (enemyState.stunnedTurns <= 0 &&
          enemyAction.type.isAttack &&
          !currentForEnemy.turnFlags.immuneThisTurn &&
          playerHp < playerHpBefore) {
        for (final b in current.activeBlessings) {
          if (b.effectType == 'conditionalBonusAp') {
            newPerfectFormDisabled = b.secondaryValue ?? 2;
          }
        }
      }

      // 4. 적 상태 효과 틱 (독/화상 → 적 데미지)
      var eStatuses = List<StatusEffect>.from(enemyState.statuses);
      final enemyTick = StatusEffectProcessor.tick(eStatuses);
      eHp -= enemyTick.damage;
      eHp += enemyTick.heal;
      if (eHp > enemyState.maxHp) eHp = enemyState.maxHp;
      eStatuses = StatusEffectProcessor.removeExpired(enemyTick.effects);

      // 4.1 cb_poison_master: 독 데미지 2배 (추가 독 데미지)
      var extraTickDamage = 0;
      for (final b in current.activeBlessings) {
        if (b.effectType == 'poisonMultiplier') {
          final poisonStacks = StatusEffectProcessor.stacks(
            enemyState.statuses,
            StatusEffectType.poison,
          );
          if (poisonStacks > 0) {
            final extra = poisonStacks * (b.effectValue - 1);
            eHp -= extra;
            extraTickDamage += extra;
          }
        }
      }

      // 4.2 cb_vampire: globalLifesteal — 독/화상 틱 데미지에서도 흡혈
      final totalTickDamage = enemyTick.damage + extraTickDamage;
      if (totalTickDamage > 0) {
        for (final b in current.activeBlessings) {
          if (b.effectType == 'globalLifesteal') {
            final tickHeal = (totalTickDamage * b.effectValue / 100).toInt();
            if (tickHeal > 0) {
              playerHp += tickHeal;
              if (playerHp > current.playerMaxHp) playerHp = current.playerMaxHp;
            }
          }
        }
      }

      // 5.1 맹독(venomous) 적 공격 시 독 3 부여
      if (enemyState.stunnedTurns <= 0 &&
          enemyAction.type.isAttack &&
          enemyState.data.modifier == EnemyModifierType.venomous) {
        playerStatuses = StatusEffectProcessor.addEffect(
          playerStatuses,
          const StatusEffect(type: StatusEffectType.poison, stacks: 3),
        );
      }

      // 6. 가시 반사 데미지 (적 스턴 시 스킵)
      if (enemyState.stunnedTurns <= 0 && enemyAction.type.isAttack) {
        final thornStacks = StatusEffectProcessor.stacks(
          current.playerStatuses,
          StatusEffectType.thorn,
        );
        if (thornStacks > 0) {
          eHp -= thornStacks;
        }

        // 6.5 피격 시 데미지 반사 (reflectDamageChance Power)
        if (current.powerEffects.reflectDamageChancePercent > 0 &&
            !currentForEnemy.turnFlags.immuneThisTurn &&
            _random.nextInt(100) < current.powerEffects.reflectDamageChancePercent) {
          eHp -= enemyAction.damage;
          // Phase 3-B: healOnReflect — 반사 성공 시 HP 회복
          if (current.powerEffects.healOnReflect > 0) {
            playerHp = (playerHp + current.powerEffects.healOnReflect)
                .clamp(0, current.playerMaxHp);
          }
        }
      }

      // 적 상태 카운트다운
      var newStunned = enemyState.stunnedTurns;
      if (newStunned > 0) newStunned -= 1;
      var newHealBlocked = enemyState.healBlockedTurns;
      if (newHealBlocked > 0) newHealBlocked -= 1;
      var newDrainBlocked = enemyState.drainBlockedTurns;
      if (newDrainBlocked > 0) newDrainBlocked -= 1;

      // Phase 3-C: 격노(enrage) 카운트다운 + 새 격노 적용
      var newEnragedTurns = enemyState.enragedTurns;
      if (newEnragedTurns > 0) newEnragedTurns -= 1;
      if (enemyAction.isEnrage) {
        newEnragedTurns = 2; // ATK×1.5 for 2 turns
      }

      // Phase 3-C: 장기전 힘 보너스 영구 적용
      if (enemyAction.longCombatStrengthBonus > 0) {
        eStrength += enemyAction.longCombatStrengthBonus;
      }

      // Phase 3-C: 오버라이드 추적 (같은 오버라이드 연속 방지)
      final newLastOverride = enemyAction.overrideApplied;

      // Phase 3-C: 엘리트 페이즈 전환 — HP 50% 이하 시 공격적 패턴 전환
      var newData = enemyState.data;
      var newPhaseShifted = enemyState.phaseShifted;
      if (enemyState.data.isElite &&
          !enemyState.phaseShifted &&
          eHp > 0 &&
          eHp <= enemyState.maxHp * 0.5 &&
          enemyState.data.alternatePatterns.isNotEmpty) {
        // 대체 패턴 중 가장 공격적인 패턴 선택
        // (공격 행동 비율이 가장 높은 패턴)
        var bestPattern = enemyState.data.alternatePatterns.first;
        var bestAttackRatio = 0.0;
        for (final alt in enemyState.data.alternatePatterns) {
          if (alt.isEmpty) continue;
          final atkCount = alt.where((a) => a.isAttack || a == EnemyActionType.buff).length;
          final ratio = atkCount / alt.length;
          if (ratio > bestAttackRatio) {
            bestAttackRatio = ratio;
            bestPattern = alt;
          }
        }
        newData = enemyState.data.copyWith(pattern: bestPattern);
        newPhaseShifted = true;
        if (kDebugMode) {
          GameLogger.debug(LogSystem.combat,
            'Phase 3-C: Elite ${enemyState.data.name} phase shifted (HP ${(eHp / enemyState.maxHp * 100).toInt()}%)',
          );
        }
      }

      // Phase 3-C: 일반 몹 패턴 전환 — HP 50% 이하 시 대체 패턴 전환
      var newPatternSwitched = enemyState.patternSwitched;
      if (!enemyState.data.isElite &&
          currentForEnemy.bossData == null &&
          !enemyState.patternSwitched &&
          eHp > 0 &&
          eHp <= enemyState.maxHp * 0.5 &&
          enemyState.data.alternatePatterns.isNotEmpty) {
        final altPatterns = enemyState.data.alternatePatterns;
        final selectedPattern = altPatterns[_random.nextInt(altPatterns.length)];
        newData = enemyState.data.copyWith(pattern: selectedPattern);
        newPatternSwitched = true;
        if (kDebugMode) {
          GameLogger.debug(LogSystem.combat,
            'Phase 3-C: Normal ${enemyState.data.name} pattern switched (HP ${(eHp / enemyState.maxHp * 100).toInt()}%)',
          );
        }
      }

      updatedEnemies[ei] = enemyState.copyWith(
        data: newData,
        currentHp: eHp,
        block: eBlock,
        strength: eStrength,
        statuses: eStatuses,
        stunnedTurns: newStunned,
        healBlockedTurns: newHealBlocked,
        drainBlockedTurns: newDrainBlocked,
        phaseShifted: newPhaseShifted,
        patternSwitched: newPatternSwitched,
        lastOverrideAction: newLastOverride,
        clearLastOverrideAction: newLastOverride == null,
        enragedTurns: newEnragedTurns,
      );

      // 적 행동 추적 (비-스턴만)
      if (enemyState.stunnedTurns <= 0) {
        lastEnemyAction = enemyAction;
        allEnemyActions.add((enemyState.data.name, enemyAction));
      }
    }

    // 5. 플레이어 상태 효과 틱 (모든 적 행동 후 1회)
    final playerTick = StatusEffectProcessor.tick(playerStatuses);
    playerHp -= playerTick.damage;
    playerHp += playerTick.heal;
    if (playerHp > current.playerMaxHp) playerHp = current.playerMaxHp;
    playerStatuses = StatusEffectProcessor.removeExpired(playerTick.effects);

    // 6.7 기세 High 전환 감지 (턴 종료 시점) — 전체 살아있는 적에게 적용
    var updatedHighBonusDmg = current.momentumHighBonusDamage;
    if (momentumTier >= 3 && current.lastMomentumTier < 3) {
      for (final b in current.activeBlessings) {
        if (b.effectType == 'momentumHighDamage') {
          for (var mi = 0; mi < updatedEnemies.length; mi++) {
            if (updatedEnemies[mi].isDead) continue;
            updatedEnemies[mi] = updatedEnemies[mi].copyWith(
              currentHp: updatedEnemies[mi].currentHp - b.effectValue,
            );
          }
        }
      }
      for (final r in current.activeRelics) {
        if (r.effectType == 'bonusAttackDamage') {
          updatedHighBonusDmg += r.effectValue;
        }
      }
    }

    // 7. 플레이어 사망 체크 (갓 모드 시 HP 1 유지)
    if (debugGodMode && playerHp <= 0) playerHp = 1;
    if (playerHp <= 0) {
      _emitCardCombatDefeat(current, emit);
      return;
    }

    // 8. 전원 사망 체크 (독/화상/가시)
    if (updatedEnemies.every((e) => e.isDead)) {
      var tickKillMaxHp = current.playerMaxHp;
      for (final b in current.activeBlessings) {
        if (b.effectType == 'maxHpOnKill') {
          tickKillMaxHp += b.effectValue;
          playerHp += b.effectValue;
        }
      }
      for (final r in current.activeRelics) {
        if (r.effectType == 'healOnKill') {
          playerHp += r.effectValue;
        }
      }
      if (playerHp > tickKillMaxHp) playerHp = tickKillMaxHp;
      final tickKillState = tickKillMaxHp != current.playerMaxHp
          ? current.copyWith(playerMaxHp: tickKillMaxHp, enemies: updatedEnemies)
          : current.copyWith(enemies: updatedEnemies);
      _emitCardCombatVictory(tickKillState, playerHp, emit);
      return;
    }

    // 9. (턴 제한 제거됨)

    // 9.5 보스 기믹 (regen/drain) — 턴 종료 시 적용 (보스는 항상 1체)
    // Phase 3-C: resolveGimmickAdvanced — 플레이어 상태 반응형 기믹
    if (current.bossData != null) {
      final bossEnemy = updatedEnemies[0];
      if (bossEnemy.stunnedTurns <= 0) {
        final phase = current.bossData!.phaseAt(current.currentBossPhase);

        // 플레이어 디버프 카운트 계산
        final playerDebuffCount =
            playerStatuses.where((s) => s.isDebuff).length;
        final playerPoisonStacks = StatusEffectProcessor.stacks(
          playerStatuses, StatusEffectType.poison,
        );
        final playerBurnStacks = StatusEffectProcessor.stacks(
          playerStatuses, StatusEffectType.burn,
        );
        final playerStrengthStacks = StatusEffectProcessor.stacks(
          playerStatuses, StatusEffectType.strength,
        );

        // Power 카드 사용 여부 확인
        final playerUsedPower =
            current.turnFlags.typesPlayedThisTurn.contains(CardType.power);
        final playerUsedSkill =
            current.turnFlags.typesPlayedThisTurn.contains(CardType.skill);

        final gimmick = EnemyAI.resolveGimmickAdvanced(
          phase.gimmick,
          bossEnemy.maxHp,
          bossId: current.bossData!.id,
          playerBlock: playerBlock,
          playerHp: playerHp,
          playerMaxHp: current.playerMaxHp,
          playerPoisonStacks: playerPoisonStacks,
          playerBurnStacks: playerBurnStacks,
          playerStrength: playerStrengthStacks,
          exhaustPileSize: deck.exhaustPile.length,
          attacksPlayedThisTurn: current.turnFlags.attacksPlayedThisTurn,
          chainCount: current.turnFlags.chainCount,
          cardsPlayedThisTurn: current.turnFlags.cardsPlayedThisTurn,
          turnNumber: currentForEnemy.currentTurn,
          playerDebuffCount: playerDebuffCount,
          consecutiveHitTurns: bossEnemy.consecutiveHitTurns,
          playerUsedPowerThisTurn: playerUsedPower,
          playerUsedSkillThisTurn: playerUsedSkill,
        );

        var bossHp = bossEnemy.currentHp;
        var bossStrength = bossEnemy.strength;

        // regen: 매 턴 HP 회복 (enemyHealBlocked 시 무효화)
        if (gimmick.healAmount > 0 && bossEnemy.healBlockedTurns <= 0) {
          bossHp = (bossHp + gimmick.healAmount).clamp(0, bossEnemy.maxHp);
        }

        // drain: 공격 시 데미지의 일부 HP 회복 (enemyDrainBlocked 시 무효화)
        if (gimmick.drainPercent > 0 &&
            lastEnemyAction != null &&
            lastEnemyAction.type.isAttack &&
            bossEnemy.drainBlockedTurns <= 0) {
          final drainHeal = lastEnemyAction.damage * gimmick.drainPercent ~/ 100;
          bossHp = (bossHp + drainHeal).clamp(0, bossEnemy.maxHp);
        }

        // rage: 피격 시 힘 증가 (이번 턴 플레이어가 공격했을 때)
        if (gimmick.strengthOnHit > 0 &&
            current.turnFlags.attacksPlayedThisTurn > 0) {
          bossStrength += gimmick.strengthOnHit;
        }

        // Phase 3-C: rage berserk — 광폭화 (ATK×2, 1턴 = strength 2배)
        if (gimmick.berserk) {
          bossStrength = bossStrength * 2;
        }

        // bleed: 적 공격 시 플레이어에게 화상 (기본 2, 반응형 4)
        if (gimmick.bleedBurnStacks > 0 &&
            lastEnemyAction != null &&
            lastEnemyAction.type.isAttack) {
          playerStatuses = StatusEffectProcessor.addEffect(
            playerStatuses,
            StatusEffect(
              type: StatusEffectType.burn,
              stacks: gimmick.bleedBurnStacks,
            ),
          );
        }

        // Phase 3-C: burnBurst — 화상 즉발 폭발 (모든 화상 → 즉시 데미지)
        if (gimmick.burnBurst) {
          final burnTotal = StatusEffectProcessor.stacks(
            playerStatuses, StatusEffectType.burn,
          );
          if (burnTotal > 0) {
            playerHp -= burnTotal;
            // 화상 스택 제거
            playerStatuses = playerStatuses
                .where((s) => s.type != StatusEffectType.burn)
                .toList();
            if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss burnBurst: $burnTotal instant damage');
          }
        }

        // corruption: 매 턴 플레이어 랜덤 디버프 1
        if (gimmick.applyRandomDebuff && !gimmick.debuffImmunity) {
          const debuffOptions = [
            StatusEffectType.weak,
            StatusEffectType.vulnerable,
          ];
          final debuffType = debuffOptions[_random.nextInt(debuffOptions.length)];
          playerStatuses = StatusEffectProcessor.addEffect(
            playerStatuses,
            StatusEffect(type: debuffType, stacks: 1, turnsRemaining: 1),
          );
        }

        // Phase 3-C: extraAttack — 추가 공격 (rat_monarch)
        if (gimmick.extraAttack && lastEnemyAction != null) {
          final extraDmg = lastEnemyAction.damage;
          final absorbed = playerBlock.clamp(0, extraDmg);
          playerBlock -= absorbed;
          playerHp -= (extraDmg - absorbed);
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss extraAttack: $extraDmg damage');
        }

        // voidGimmick: 매 턴 손패 랜덤 1장 소진
        if (gimmick.exhaustRandomCard && deck.hand.isNotEmpty) {
          final rng = _random;
          final exhaustIdx = rng.nextInt(deck.hand.length);
          final exhaustCard = deck.hand[exhaustIdx];
          deck = DeckManager.exhaustFromHand(deck, exhaustCard.id);
          gameEventBus.emit(CardExhaustedEvent(
            cardId: exhaustCard.id,
            cardName: exhaustCard.name,
          ));
        }

        // Phase 3-C: exhaustDamage — 소진 카드 기반 데미지 (ghost_convict)
        if (gimmick.exhaustDamage > 0) {
          playerHp -= gimmick.exhaustDamage;
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss exhaustDamage: ${gimmick.exhaustDamage}');
        }

        // Phase 3-C: directHpDamage — 직접 HP 데미지 (void_sovereign)
        if (gimmick.directHpDamage > 0) {
          playerHp -= gimmick.directHpDamage;
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss directHpDamage: ${gimmick.directHpDamage}');
        }

        // Phase 3-C: 보스 rage 연속 피격 카운터 업데이트
        var newConsecutiveHits = bossEnemy.consecutiveHitTurns;
        if (current.turnFlags.attacksPlayedThisTurn > 0) {
          newConsecutiveHits += 1;
        } else {
          newConsecutiveHits = 0;
        }

        updatedEnemies[0] = bossEnemy.copyWith(
          currentHp: bossHp,
          strength: bossStrength,
          consecutiveHitTurns: newConsecutiveHits,
        );
      }
    }

    // 9.5 보스 기믹 데미지 후 사망 체크 (healPerTurn 등으로 부활 방지)
    if (debugGodMode && playerHp <= 0) playerHp = 1;
    if (playerHp <= 0) {
      _emitCardCombatDefeat(current, emit);
      return;
    }

    // 10. 독안개 Power: 매 턴 시작 시 모든 살아있는 적에게 독 부여
    if (current.powerEffects.poisonPerTurnStart > 0) {
      for (var pi = 0; pi < updatedEnemies.length; pi++) {
        if (updatedEnemies[pi].isDead) continue;
        var pStatuses = List<StatusEffect>.from(updatedEnemies[pi].statuses);
        pStatuses = StatusEffectProcessor.addEffect(
          pStatuses,
          StatusEffect(
            type: StatusEffectType.poison,
            stacks: current.powerEffects.poisonPerTurnStart,
          ),
        );
        updatedEnemies[pi] = updatedEnemies[pi].copyWith(statuses: pStatuses);
      }
    }

    // 10.5 신성 보호막 Power: 매 턴 시작 시 블록 부여
    // (블록 리셋 전에 계산하지 않음 — 리셋 후 적용)

    // 10.7 retrievePerTurn: 매 턴 버림 더미에서 랜덤 N장 손패 복귀
    if (current.powerEffects.retrievePerTurn > 0 && deck.discardPile.isNotEmpty) {
      final rng = Random();
      final retrieveCount =
          current.powerEffects.retrievePerTurn.clamp(0, deck.discardPile.length);
      final shuffledDiscard = List.of(deck.discardPile)..shuffle(rng);
      final retrieved = shuffledDiscard.take(retrieveCount).toList();
      final remaining = List.of(deck.discardPile);
      for (final card in retrieved) {
        remaining.remove(card);
      }
      deck = DeckState(
        drawPile: deck.drawPile,
        hand: [...deck.hand, ...retrieved],
        discardPile: remaining,
        exhaustPile: deck.exhaustPile,
      );
    }

    // 11. 새 턴 준비: 블록 리셋, 드로우, AP (+ apModifierNextTurn + 보스 web)
    // blockRetain: 블록 유지 % 처리 (카드 효과 + cb_patience 축복)
    var blockRetainPercent = current.turnFlags.blockRetainPercent;
    for (final b in current.activeBlessings) {
      if (b.effectType == 'retainBlock' && blockRetainPercent < b.effectValue) {
        blockRetainPercent = b.effectValue;
      }
    }
    if (blockRetainPercent > 0 && playerBlock > 0) {
      playerBlock =
          (playerBlock * blockRetainPercent / 100).toInt();
    } else {
      playerBlock = 0;
    }

    // 11.5 blockPerTurnStart Power: 매 턴 시작 시 블록 부여 (리셋 후)
    if (current.powerEffects.blockPerTurnStart > 0) {
      playerBlock += current.powerEffects.blockPerTurnStart;
    }

    // 11.5b conditionalBlockPerTurnStart: HP <30% 시에만 블록 부여
    if (current.powerEffects.conditionalBlockPerTurnStart > 0 &&
        playerHp < (current.playerMaxHp * 0.3).toInt()) {
      playerBlock += current.powerEffects.conditionalBlockPerTurnStart;
    }

    // 11.51 healPerTurn Power: 매 턴 HP 회복 + 재생 뱃지 누적
    if (current.powerEffects.healPerTurn > 0) {
      final isHighPriest =
          current.playerRunState.currentJobId == 'highPriest';
      final cap = isHighPriest ? null : combatConfig.maxRegenStacks;
      final currentRegenStacks = StatusEffectProcessor.stacks(
        playerStatuses,
        StatusEffectType.regenerate,
      );
      final healAmount = current.powerEffects.healPerTurn;
      playerHp = (playerHp + healAmount).clamp(0, current.playerMaxHp);
      // 재생 스택 누적 (대사제는 캡 없음, 나머지는 cap 초과 시 추가 안 함)
      if (cap == null || currentRegenStacks < cap) {
        playerStatuses = StatusEffectProcessor.addEffect(
          playerStatuses,
          StatusEffect(
            type: StatusEffectType.regenerate,
            stacks: healAmount,
          ),
          regenCap: cap,
        );
      }
    }

    // 11.511 Phase 3-B healPerTurnConditional Power: 조건부 매 턴 HP 회복
    if (current.powerEffects.healPerTurnConditional > 0) {
      bool conditionMet = false;
      final cond = current.powerEffects.healPerTurnCondition;
      if (cond == 'strengthGte2') {
        final str = StatusEffectProcessor.stacks(
          playerStatuses,
          StatusEffectType.strength,
        );
        conditionMet = str >= 2;
      } else {
        conditionMet = true; // 조건 없으면 항상 적용
      }
      if (conditionMet) {
        playerHp = (playerHp + current.powerEffects.healPerTurnConditional)
            .clamp(0, current.playerMaxHp);
      }
    }

    // 11.512 Phase 3-B healOnDamageTaken Power: 이번 턴 피격 시 HP 회복
    if (current.powerEffects.healOnDamageTaken > 0 && playerTookHpDamageThisTurn) {
      playerHp = (playerHp + current.powerEffects.healOnDamageTaken)
          .clamp(0, current.playerMaxHp);
    }

    // 11.52 lostHpToBlockPerTurn Power: (maxHp - currentHp) × N% 블록
    if (current.powerEffects.lostHpToBlockPerTurnPercent > 0) {
      final lostHp = current.playerMaxHp - playerHp;
      if (lostHp > 0) {
        playerBlock +=
            (lostHp * current.powerEffects.lostHpToBlockPerTurnPercent / 100)
                .toInt();
      }
    }

    // 11.6 축복 turnStart: 블록/드로우/HP/AP 효과
    var blessingBonusDraw = 0;
    for (final b in current.activeBlessings) {
      switch (b.effectType) {
        case 'autoBlock':
          // cb_reflex: 매 턴 블록 자동 획득
          playerBlock += b.effectValue;
        case 'bonusDraw':
          // cb_quick_feet: 매 턴 +1 드로우
          blessingBonusDraw += b.effectValue;
        case 'bonusApWithHpCost':
          // cb_overload: AP +1, HP -3 (최소 HP 1 유지)
          playerHp = (playerHp - (b.secondaryValue ?? 3)).clamp(1, current.playerMaxHp);
        case 'periodicBonusAp':
          // cb_sands_of_time: 5턴마다 AP +2
          // nextTurn은 이미 +1된 값
        case 'conditionalBonusAp':
          // cb_perfect_form: +1 AP (비활성 중이면 스킵)
        case 'healPerTurn':
          // blessing_008 재생의 축복: 매 턴 시작 시 HP 회복
          playerHp = (playerHp + b.effectValue).clamp(0, current.playerMaxHp);
      }
    }

    // 11.7 축복 turnStart: 버림더미 복귀 (cb_tenacity)
    for (final b in current.activeBlessings) {
      if (b.effectType == 'retrieveDiscard' && deck.discardPile.isNotEmpty) {
        final rng = Random();
        final count = b.effectValue.clamp(0, deck.discardPile.length);
        final shuffled = List.of(deck.discardPile)..shuffle(rng);
        final retrieved = shuffled.take(count).toList();
        final remaining = List.of(deck.discardPile);
        for (final c in retrieved) {
          remaining.remove(c);
        }
        deck = DeckState(
          drawPile: deck.drawPile,
          hand: [...deck.hand, ...retrieved],
          discardPile: remaining,
          exhaustPile: deck.exhaustPile,
        );
      }
    }

    // 11.8 유물 turnStart
    for (final r in current.activeRelics) {
      switch (r.effectType) {
        case 'bonusDraw':
          // cr_magic_stone: 매 턴 +1 드로우
          blessingBonusDraw += r.effectValue;
        case 'mirrorCopy':
          // cr_mirror_shard: 10% 확률 손패 1장 복사
          if (deck.hand.isNotEmpty &&
              _random.nextInt(100) < (r.conditionValue ?? 10)) {
            final copyCard = deck.hand[_random.nextInt(deck.hand.length)];
            deck = DeckManager.addToHand(deck, copyCard);
          }
      }
    }

    var nextAp = cardCombatConfig.apForTier(momentumTier) +
        current.turnFlags.apModifierNextTurn;

    // shackle 기믹: AP -1 (보스는 항상 1체)
    // Phase 3-C: 반응형 shackle — 조건 충족 시 AP 패널티 해제
    if (current.bossData != null && !updatedEnemies[0].isDead &&
        updatedEnemies[0].stunnedTurns <= 0) {
      final shacklePhase = current.bossData!.phaseAt(current.currentBossPhase);
      final playerUsedSkill =
          current.turnFlags.typesPlayedThisTurn.contains(CardType.skill);
      final shackleGimmick = EnemyAI.resolveGimmickAdvanced(
        shacklePhase.gimmick,
        updatedEnemies[0].maxHp,
        bossId: current.bossData!.id,
        cardsPlayedThisTurn: current.turnFlags.cardsPlayedThisTurn,
        playerUsedSkillThisTurn: playerUsedSkill,
      );
      if (shackleGimmick.playerApPenalty > 0) {
        // apPenaltyRemoved: 1장만 사용 시 완전 해제
        if (shackleGimmick.apPenaltyRemoved) {
          // AP 패널티 없음
        } else if (shackleGimmick.halfApPenaltyRemoved &&
            _random.nextDouble() < 0.5) {
          // halfApPenaltyRemoved: 50% 확률로 해제
        } else {
          nextAp -= shackleGimmick.playerApPenalty;
        }
      }
    }

    // 축복 AP 보너스
    for (final b in current.activeBlessings) {
      if (b.effectType == 'bonusApWithHpCost') {
        nextAp += b.effectValue;
      } else if (b.effectType == 'periodicBonusAp') {
        // cb_sands_of_time: 매 N턴마다 AP +value
        final period = b.secondaryValue ?? 5;
        if (nextTurn > 0 && nextTurn % period == 0) {
          nextAp += b.effectValue;
        }
      } else if (b.effectType == 'conditionalBonusAp') {
        // cb_perfect_form: AP +1 (비활성 중 아닐 때만)
        if (newPerfectFormDisabled <= 0) {
          nextAp += b.effectValue;
        }
      }
    }

    if (nextAp < 0) nextAp = 0;
    final powerDrawBonus = current.powerEffects.drawPerTurn;
    var totalDraw = cardCombatConfig.drawPerTurn + blessingBonusDraw + powerDrawBonus;

    // web 기믹: 드로우 감소 (보스는 항상 1체)
    // Phase 3-C: 반응형 web — 0AP 카드 사용 시 추가 드로우 감소
    if (current.bossData != null && !updatedEnemies[0].isDead) {
      final phase = current.bossData!.phaseAt(current.currentBossPhase);
      final webGimmickAdv = EnemyAI.resolveGimmickAdvanced(
        phase.gimmick,
        updatedEnemies[0].maxHp,
        bossId: current.bossData!.id,
        cardsPlayedThisTurn: current.turnFlags.cardsPlayedThisTurn,
        attacksPlayedThisTurn: current.turnFlags.attacksPlayedThisTurn,
      );
      totalDraw -= webGimmickAdv.playerDrawPenalty;
      if (totalDraw < 1) totalDraw = 1;
    }
    final drawPileWasEmpty = deck.drawPile.isEmpty && deck.discardPile.isNotEmpty;
    deck = DeckManager.draw(deck, totalDraw);
    if (drawPileWasEmpty) {
      gameEventBus.emit(DeckShuffledEvent());

      // onShuffle: cb_infinite_cycle (힘 +1, 민첩 +1)
      for (final b in current.activeBlessings) {
        if (b.effectType == 'shuffleBuff') {
          playerStatuses = StatusEffectProcessor.addEffect(
            playerStatuses,
            StatusEffect(
                type: StatusEffectType.strength, stacks: b.effectValue),
          );
          playerStatuses = StatusEffectProcessor.addEffect(
            playerStatuses,
            StatusEffect(
                type: StatusEffectType.dexterity, stacks: b.effectValue),
          );
        }
      }
    }
    gameEventBus.emit(CardDrawnEvent(count: totalDraw));

    // 11.9 turnEnd: cb_echo (마지막 플레이 카드 다음 턴 손패 복사)
    if (current.lastPlayResult != null) {
      for (final b in current.activeBlessings) {
        if (b.effectType == 'copyLastPlayed' &&
            current.lastPlayResult!.card.type == CardType.attack) {
          deck = DeckManager.addToHand(deck, current.lastPlayResult!.card);
        }
      }
    }

    // perfectFormDisabledTurns 카운트다운
    if (newPerfectFormDisabled > 0) {
      newPerfectFormDisabled -= 1;
    }

    // 12. 환경 카드 자동 부여 (턴 3, 미부여 시)
    var envGranted = current.environmentGranted;
    if (nextTurn >= 3 &&
        !current.environmentGranted &&
        current.environmentCard != null) {
      deck = DeckManager.addToHand(deck, current.environmentCard!);
      envGranted = true;
    }

    // 13. 의도 공개 카운트다운
    var intentRevealed = current.intentRevealed;
    var intentRevealTurns = current.intentRevealTurns;
    if (intentRevealTurns > 0) {
      intentRevealTurns -= 1;
      if (intentRevealTurns <= 0) {
        intentRevealed = false;
      }
    }

    // ── 히든잡 턴당 효과 ──
    final jobEffects = _applyHiddenJobPerTurnEffects(
      current: current,
      playerHp: playerHp,
      playerStatuses: playerStatuses,
      deck: deck,
    );
    playerHp = jobEffects.playerHp;
    playerStatuses = jobEffects.playerStatuses;
    deck = jobEffects.deck;

    // 히든잡 자해 사망 체크 (갓 모드 시 HP 1 유지)
    if (debugGodMode && playerHp <= 0) playerHp = 1;
    if (playerHp <= 0) {
      _emitCardCombatDefeat(current, emit);
      return;
    }

    // 14. 보스 환경카드 효과 카운트다운 (이제 적 루프 내에서 처리됨)
    final wasRegenBlocked = current.enemies.isNotEmpty &&
        current.enemies[0].healBlockedTurns > 0;

    // 선택된 적 사망 시 다음 살아있는 적으로 자동 전환
    var newSelectedTarget = current.selectedTargetIndex
        .clamp(0, updatedEnemies.length - 1);
    if (updatedEnemies[newSelectedTarget].isDead) {
      final nextLive = updatedEnemies.indexWhere((e) => !e.isDead);
      if (nextLive != -1) newSelectedTarget = nextLive;
    }

    // Phase 3-B: 쿨다운 카드 카운트다운 (턴 종료 시 1 감소, 0이면 제거)
    var newCooldownCards = <String, int>{};
    for (final entry in current.cooldownCards.entries) {
      final remaining = entry.value - 1;
      if (remaining > 0) {
        newCooldownCards[entry.key] = remaining;
      }
    }

    emit(current.copyWith(
      enemies: updatedEnemies,
      selectedTargetIndex: newSelectedTarget,
      deckState: deck,
      playerHp: playerHp,
      playerBlock: playerBlock,
      actionPoints: nextAp,
      maxActionPoints: nextAp,
      playerStatuses: playerStatuses,
      currentTurn: nextTurn,
      lastEnemyActions: allEnemyActions,
      clearLastPlayResult: true,
      turnFlags: const TurnFlags(),
      environmentGranted: envGranted,
      intentRevealed: intentRevealed,
      intentRevealTurns: intentRevealTurns,
      regenBlockedThisTurn: wasRegenBlocked,
      fleeFailed: fleeFailed,
      perfectFormDisabledTurns: newPerfectFormDisabled,
      lastMomentumTier: momentumTier,
      momentumHighBonusDamage: updatedHighBonusDmg,
      immuneNextHitsRemaining: loopImmuneNextHits,
      nextHitDamageReductionPercent: loopNextHitDmgReduction,
      cooldownCards: newCooldownCards,
    ));
  }

  void _onSelectCardReward(
    SelectCardReward event,
    Emitter<CombatState> emit,
  ) {
    final current = state;
    if (current is! CardCombatResolved) return;

    if (event.selectedCardId != null) {
      final selected = current.cardRewardOptions.where(
        (c) => c.id == event.selectedCardId,
      );
      if (selected.isNotEmpty) {
        final updatedRunState = current.playerRunState.copyWith(
          masterDeck: [...current.playerRunState.masterDeck, selected.first],
        );
        emit(CardCombatResolved(
          outcome: current.outcome,
          enemies: current.enemies,
          playerHp: current.playerHp,
          playerMaxHp: current.playerMaxHp,
          playerRunState: updatedRunState,
          hpLost: current.hpLost,
          hpNarrationTier: current.hpNarrationTier,
          isPermadeath: current.isPermadeath,
          roomType: current.roomType,
          cardRewardOptions: const [],
        ));
      }
    }

    emit(const CombatIdle());
  }

  void _onAttemptFlee(AttemptFlee event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CardCombatActive) return;

    // 보스 전투 도주 불가
    if (current.roomType == RoomType.boss) return;

    // AP 부족 시 도주 불가
    if (current.actionPoints < fleeConfig.apCost) return;

    // AP 소모
    final apAfterFlee = current.actionPoints - fleeConfig.apCost;

    // 성공률 계산: 기본(50%) + 바람의 부적(+30%) + 도주 보장(→100%)
    double successRate = fleeConfig.baseSuccessRate;
    if (current.playerRunState.ownedRelicIds.contains(windAmuletRelicId)) {
      successRate += fleeConfig.windAmuletBonus;
    }
    if (current.fleeGuaranteed) {
      successRate = 1.0;
    }
    successRate = successRate.clamp(0.0, 1.0);

    final roll = _random.nextDouble();
    if (roll >= successRate) {
      // 도주 실패 — AP 소모 후 적 턴 실행 (턴 종료와 동일)
      final updatedCurrent = current.copyWith(
        actionPoints: apAfterFlee,
      );
      _processEndOfTurn(
        updatedCurrent,
        emit,
        momentumTier: event.momentumTier,
        fleeFailed: true,
      );
      return;
    }

    // 도주 성공 — HP/골드 페널티 적용
    final hpPenalty = (current.playerMaxHp * fleeConfig.hpPenaltyPercent)
        .toInt()
        .clamp(1, 999);
    final newHp = (current.playerHp - hpPenalty).clamp(1, current.playerMaxHp);
    final newGold =
        (current.playerRunState.gold - fleeConfig.goldPenalty).clamp(0, 99999);
    final updatedRunState = current.playerRunState.copyWith(
      currentHp: newHp,
      gold: newGold,
    );

    // 전투 종료 이벤트 → AudioBloc이 층별 BGM으로 전환
    gameEventBus.emit(CombatEndedEvent(
      currentFloor: current.playerRunState.currentFloor,
    ));

    emit(CardCombatResolved(
      outcome: CombatOutcome.fled,
      enemies: current.enemies.map((e) => e.data).toList(),
      playerHp: newHp,
      playerMaxHp: current.playerMaxHp,
      playerRunState: updatedRunState,
      roomType: current.roomType,
    ));
  }

  // ── 카드 전투 헬퍼 ────────────────────────────────────

  /// 적 행동 해석 — 스턴/약화/취약 반영 후 HP/블록 변화.
  /// [enemyOverride] 제공 시 해당 적 상태 사용 (멀티몹 지원).
  ({
    int playerHp,
    int playerBlock,
    int enemyHp,
    int enemyBlock,
    int enemyStrength,
    int immuneNextHits,
    int nextHitDmgReduction,
    bool dodged,
  }) _resolveEnemyAction({
    required CardCombatActive current,
    required EnemyActionResult enemyAction,
    EnemyBattleState? enemyOverride,
    int? playerHpOverride,
    int? playerBlockOverride,
    int? immuneNextHitsOverride,
    int? nextHitDmgReductionOverride,
  }) {
    var playerHp = playerHpOverride ?? current.playerHp;
    var playerBlock = playerBlockOverride ?? current.playerBlock;
    var immuneNextHits = immuneNextHitsOverride ?? current.immuneNextHitsRemaining;
    var nextHitDmgReduction =
        nextHitDmgReductionOverride ?? current.nextHitDamageReductionPercent;
    var dodged = false;

    final stunnedTurns = enemyOverride?.stunnedTurns ?? current.enemyStunnedTurns;
    final enemyStatuses = enemyOverride?.statuses ?? current.enemyStatuses;
    final healBlocked = enemyOverride?.healBlockedTurns ?? current.enemyHealBlockedTurns;
    final enemyMaxHp = enemyOverride?.maxHp ?? current.enemyMaxHp;

    var enemyHp = enemyOverride?.currentHp ?? current.enemyHp;
    var enemyBlock = 0; // 적 블록은 매 턴 리셋
    var enemyStrength = enemyOverride?.strength ?? current.enemyStrength;

    if (stunnedTurns > 0) {
      // 적 스턴 중: 행동 스킵
    } else {
      switch (enemyAction.type) {
        case EnemyActionType.attack:
        case EnemyActionType.heavy:
          if (!current.turnFlags.immuneThisTurn) {
            // Phase 3-B: immuneNextHits 판정
            if (immuneNextHits > 0) {
              immuneNextHits -= 1;
              break; // 피격 무효
            }
            // 회피 판정 (dodgeChance Power)
            if (current.powerEffects.dodgeChancePercent > 0 &&
                _random.nextInt(100) < current.powerEffects.dodgeChancePercent) {
              dodged = true;
              break; // 회피 성공 → 데미지 스킵
            }
            var effectiveDmg = enemyAction.damage;
            if (StatusEffectProcessor.hasActive(
                enemyStatuses, StatusEffectType.weak)) {
              effectiveDmg = (effectiveDmg * 0.75).toInt();
            }
            if (StatusEffectProcessor.hasActive(
                current.playerStatuses, StatusEffectType.vulnerable)) {
              effectiveDmg = (effectiveDmg * 1.5).toInt();
            }
            // HP ≤ 20% 유물 피해 감소
            if (playerHp <= (current.playerMaxHp * 0.2).ceil()) {
              for (final rr in resolveRelicIds(
                  current.playerRunState.ownedRelicIds)
                  .where((r) => r.conditionType == 'hpThreshold' &&
                      r.passiveEffect == 'damageReduction')) {
                effectiveDmg -= rr.effectValue;
              }
              if (effectiveDmg < 0) effectiveDmg = 0;
            }
            // Phase 3-B: nextHitDamageReduction (다음 피격 데미지 N% 감소)
            if (nextHitDmgReduction > 0) {
              effectiveDmg =
                  (effectiveDmg * (100 - nextHitDmgReduction) / 100).toInt();
              nextHitDmgReduction = 0; // 소비됨
            }
            // Phase 3-B: poisonDamageReduction (적 독 스택당 피해 감소)
            if (current.powerEffects.poisonDamageReduction > 0) {
              final poisonStacks = StatusEffectProcessor.stacks(
                enemyStatuses,
                StatusEffectType.poison,
              );
              if (poisonStacks > 0) {
                var reduction = poisonStacks *
                    current.powerEffects.poisonDamageReduction;
                final cap = current.powerEffects.poisonDamageReductionCap;
                if (cap > 0 && reduction > cap) reduction = cap;
                effectiveDmg -= reduction;
                if (effectiveDmg < 0) effectiveDmg = 0;
              }
            }
            // Phase 3-B: damageReductionWhenBlock (블록 ≥ 임계값 시 피해 감소)
            if (current.powerEffects.damageReductionWhenBlock > 0 &&
                playerBlock >=
                    current.powerEffects.damageReductionWhenBlockThreshold) {
              effectiveDmg -= current.powerEffects.damageReductionWhenBlock;
              if (effectiveDmg < 0) effectiveDmg = 0;
            }
            final absorbed = playerBlock.clamp(0, effectiveDmg);
            playerBlock -= absorbed;
            playerHp -= (effectiveDmg - absorbed);
          }
        case EnemyActionType.defend:
          enemyBlock += enemyAction.block;
        case EnemyActionType.heal:
          if (healBlocked <= 0) {
            enemyHp = (enemyHp + enemyAction.healAmount)
                .clamp(0, enemyMaxHp);
          }
        case EnemyActionType.buff:
          enemyStrength += enemyAction.buffStrength;
        case EnemyActionType.charge:
        case EnemyActionType.observe:
          break;
      }
    }

    return (
      playerHp: playerHp,
      playerBlock: playerBlock,
      enemyHp: enemyHp,
      enemyBlock: enemyBlock,
      enemyStrength: enemyStrength,
      immuneNextHits: immuneNextHits,
      nextHitDmgReduction: nextHitDmgReduction,
      dodged: dodged,
    );
  }

  /// AoE 카드가 선택 대상 외 적에게 효과를 적용하는 헬퍼.
  /// CardEffectResolver를 각 적별로 호출하여 데미지/상태효과를 개별 적용.
  EnemyBattleState _resolveAoeAgainstEnemy({
    required CardData card,
    required EnemyBattleState enemy,
    required CardCombatActive current,
    required int momentumTier,
  }) {
    final playerStr = StatusEffectProcessor.stacks(
      current.playerStatuses, StatusEffectType.strength,
    );
    final playerDex = StatusEffectProcessor.stacks(
      current.playerStatuses, StatusEffectType.dexterity,
    );

    final aoeResult = CardEffectResolver.resolve(
      card: card,
      playerStrength: playerStr,
      playerDexterity: playerDex,
      playerStatuses: current.playerStatuses,
      enemyStatuses: enemy.statuses,
      enemyBlock: enemy.block,
      deckState: current.deckState,
      momentumTier: momentumTier,
      playerHp: current.playerHp,
      playerMaxHp: current.playerMaxHp,
      currentTurn: current.currentTurn,
      attacksPlayedThisTurn: current.turnFlags.attacksPlayedThisTurn,
      doubleNextAttack: current.turnFlags.doubleNextAttack,
      playerBlock: current.playerBlock,
      enemyHp: enemy.currentHp,
      enemyMaxHp: enemy.maxHp,
      skillsPlayedThisTurn: current.turnFlags.skillsPlayedThisTurn,
    );

    var hp = enemy.currentHp;
    var block = enemy.block;
    var statuses = List<StatusEffect>.from(enemy.statuses);

    // 데미지 적용
    if (aoeResult.damageResult != null) {
      block -= aoeResult.damageResult!.blockAbsorbed;
      if (block < 0) block = 0;
      hp -= aoeResult.damageResult!.hpLost;
    }

    // 상태 효과 적용
    for (final s in aoeResult.newEnemyStatuses) {
      statuses = StatusEffectProcessor.addEffect(statuses, s);
    }

    // 랜덤 디버프 (대혼란 등)
    if (aoeResult.randomDebuffCount > 0) {
      final rng = Random();
      const debuffTypes = [
        StatusEffectType.poison,
        StatusEffectType.burn,
        StatusEffectType.weak,
        StatusEffectType.vulnerable,
      ];
      for (var i = 0; i < aoeResult.randomDebuffCount; i++) {
        final debuffType = debuffTypes[rng.nextInt(debuffTypes.length)];
        final debuff = StatusEffect(
          type: debuffType,
          stacks: debuffType == StatusEffectType.poison ? 3 : 1,
          turnsRemaining:
              (debuffType == StatusEffectType.weak ||
                      debuffType == StatusEffectType.vulnerable)
                  ? 2
                  : null,
        );
        statuses = StatusEffectProcessor.addEffect(statuses, debuff);
      }
    }

    // 처형 (사신)
    if (aoeResult.executeHpPercent > 0 && hp > 0) {
      final threshold =
          (enemy.maxHp * aoeResult.executeHpPercent / 100).toInt();
      if (hp <= threshold) hp = 0;
    }

    // 축복 공격 효과 (attackBurn, executeThreshold)
    if (card.type == CardType.attack) {
      for (final b in current.activeBlessings) {
        switch (b.effectType) {
          case 'attackBurn':
            statuses = StatusEffectProcessor.addEffect(
              statuses,
              StatusEffect(
                type: StatusEffectType.burn,
                stacks: b.effectValue,
              ),
            );
          case 'executeThreshold':
            if (hp > 0) {
              final threshold =
                  (enemy.maxHp * b.effectValue / 100).toInt();
              if (hp <= threshold) hp = 0;
            }
        }
      }
    }

    // 유물 thornOnBlock — 블록 발생 시 가시 데미지
    if (aoeResult.blockGained > 0) {
      for (final r in current.activeRelics) {
        if (r.effectType == 'thornOnBlock' &&
            current.playerBlock >= (r.conditionValue ?? 0)) {
          hp -= r.effectValue;
        }
      }
    }

    return enemy.copyWith(
      currentHp: hp,
      block: block,
      statuses: statuses,
    );
  }

  /// 히든잡 턴당 효과 — 자해/힘/카드생성/핸드변환/스탯부스트.
  ({int playerHp, List<StatusEffect> playerStatuses, DeckState deck})
  _applyHiddenJobPerTurnEffects({
    required CardCombatActive current,
    required int playerHp,
    required List<StatusEffect> playerStatuses,
    required DeckState deck,
  }) {
    // 사신: 턴당 자해
    if (current.powerEffects.selfDamagePerTurn > 0) {
      playerHp -= current.powerEffects.selfDamagePerTurn;
    }

    // 사신: 턴당 힘 획득
    if (current.powerEffects.strengthPerTurn > 0) {
      playerStatuses = StatusEffectProcessor.addEffect(
        playerStatuses,
        StatusEffect(
          type: StatusEffectType.strength,
          stacks: current.powerEffects.strengthPerTurn,
        ),
      );
    }

    // 환술사: 턴당 공격카드 생성
    if (current.powerEffects.generateAttackPerTurn > 0) {
      final rng = Random();
      final attackCards = ColorlessCards.base
          .where((c) => c.type == CardType.attack)
          .toList();
      if (attackCards.isNotEmpty) {
        for (var i = 0; i < current.powerEffects.generateAttackPerTurn; i++) {
          final randomAttack = attackCards[rng.nextInt(attackCards.length)];
          deck = DeckManager.addToHand(deck, randomAttack);
        }
      }
    }

    // 환술사: 핸드 변환 — 손패 1장을 랜덤 카드로 교체
    if (current.powerEffects.transformHand && deck.hand.isNotEmpty) {
      final rng = Random();
      final colorlessBase = ColorlessCards.base;
      final targetIdx = rng.nextInt(deck.hand.length);
      final replacement = colorlessBase[rng.nextInt(colorlessBase.length)];
      final newHand = List<CardData>.from(deck.hand);
      newHand[targetIdx] = replacement;
      deck = DeckState(
        drawPile: deck.drawPile,
        hand: newHand,
        discardPile: deck.discardPile,
        exhaustPile: deck.exhaustPile,
      );
    }

    // 조율사: 턴당 최저 스탯 부스트
    if (current.powerEffects.boostLowestStatPerTurn > 0) {
      final currentStr = StatusEffectProcessor.stacks(
        playerStatuses,
        StatusEffectType.strength,
      );
      final currentDex = StatusEffectProcessor.stacks(
        playerStatuses,
        StatusEffectType.dexterity,
      );
      final boostType = currentStr <= currentDex
          ? StatusEffectType.strength
          : StatusEffectType.dexterity;
      playerStatuses = StatusEffectProcessor.addEffect(
        playerStatuses,
        StatusEffect(
          type: boostType,
          stacks: current.powerEffects.boostLowestStatPerTurn,
        ),
      );
    }

    return (
      playerHp: playerHp,
      playerStatuses: playerStatuses,
      deck: deck,
    );
  }

  void _emitCardCombatVictory(
    CardCombatActive current,
    int playerHp,
    Emitter<CombatState> emit,
  ) {
    // 보스 페이즈 전환 체크
    if (current.hasNextBossPhase) {
      final nextPhase = current.currentBossPhase + 1;
      if (kDebugMode) {
        GameLogger.debug(
          LogSystem.combat,
          'Boss phase transition: ${current.currentBossPhase} → $nextPhase',
        );
      }
      emit(CardBossPhaseTransition(
        bossData: current.bossData!,
        completedPhaseIndex: current.currentBossPhase,
        nextPhaseIndex: nextPhase,
        playerHp: playerHp,
        playerMaxHp: current.playerMaxHp,
        deckState: current.deckState,
        playerRunState: current.playerRunState.copyWith(
          currentHp: playerHp,
          maxHp: current.playerMaxHp,
        ),
        playerStatuses: current.playerStatuses,
        currentTurn: current.currentTurn,
        powerEffects: current.powerEffects,
        activeBlessings: current.activeBlessings,
        activeRelics: current.activeRelics,
      ));
      return;
    }

    final cardFloorGoldMult = floorsConfig
        .forFloor(current.playerRunState.currentFloor)
        .goldMultiplier;
    final reward = CombatRewardCalculator.calculate(
      roomType: current.roomType,
      economyConfig: economyConfig,
      goldMultiplier: cardFloorGoldMult,
      eliteRewardMultiplier: eliteRewardMultiplier,
    );
    gameEventBus.emit(CombatRewardEvent(
      goldAmount: reward.goldAmount,
      rewardTag: reward.rewardTag,
    ));
    gameEventBus.emit(CombatMilestoneEvent(type: CombatMilestoneType.victory));
    gameEventBus.emit(CombatEndedEvent(
      currentFloor: current.playerRunState.currentFloor,
    ));

    if (kDebugMode) {
      GameLogger.debug(
        LogSystem.combat,
        'Card combat victory: ${current.enemy.name}, '
        'playerHp=$playerHp, reward=${reward.goldAmount} gold',
      );
    }

    // 카드 보상 생성 (승리 시) — 저주 감소 적용
    // 유령 PvP: rewardJobOverride가 있으면 유령 직업 카드 보상.
    final jobId = current.rewardJobOverride ?? current.playerRunState.currentJobId ?? 'warrior';
    final ownedIds = current.playerRunState.masterDeck.map((c) => c.id).toSet();
    final victoryCurses = CurseModifierPool.resolveIds(
      current.playerRunState.activeCurseIds,
    );
    final rewardReduction =
        CurseModifierResolver.resolveRewardReduction(victoryCurses);
    final rewardCount =
        (cardCombatConfig.cardRewardCount - rewardReduction).clamp(1, 10);
    final cardRewards = CardRewardGenerator.generate(
      jobId: jobId,
      count: rewardCount,
      ownedCardIds: ownedIds,
      unlockedCardIds: unlockedCardIds,
    );

    emit(CardCombatResolved(
      outcome: CombatOutcome.victory,
      enemies: current.enemies.map((e) => e.data).toList(),
      playerHp: playerHp,
      playerMaxHp: current.playerMaxHp,
      playerRunState: current.playerRunState.copyWith(
        currentHp: playerHp,
        maxHp: current.playerMaxHp,
      ),
      roomType: current.roomType,
      cardRewardOptions: cardRewards,
    ));
  }

  // ── 몬스터 테이밍: 제압된 적 길들이기 ──

  /// 제압된 적 길들이기 요청 처리.
  /// 대상이 생존 + 제압(HP ≤ 임계치) 상태일 때만 포획 종료.
  void _onTameEnemy(TameEnemy event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CardCombatActive) return;

    final idx = event.index;
    if (idx < 0 || idx >= current.enemies.length) return;
    final target = current.enemies[idx];
    if (target.isDead) return;
    if (target.maxHp <= 0 ||
        target.currentHp > target.maxHp * CardCombatActive.suppressHpRatio) {
      // 제압되지 않음 — 무시 (UI가 막지만 방어적으로).
      return;
    }

    _emitCardCombatTame(current, target, emit);
  }

  /// 길들이기 성공 → 전투 종료. 카드 보상 대신 몬스터 포획 플래그.
  void _emitCardCombatTame(
    CardCombatActive current,
    EnemyBattleState target,
    Emitter<CombatState> emit,
  ) {
    gameEventBus.emit(CombatMilestoneEvent(type: CombatMilestoneType.victory));
    gameEventBus.emit(CombatEndedEvent(
      currentFloor: current.playerRunState.currentFloor,
    ));

    if (kDebugMode) {
      GameLogger.debug(
        LogSystem.combat,
        'Monster tamed: ${target.data.name} (${target.data.id})',
      );
    }

    emit(CardCombatResolved(
      outcome: CombatOutcome.victory,
      enemies: current.enemies.map((e) => e.data).toList(),
      playerHp: current.playerHp,
      playerMaxHp: current.playerMaxHp,
      playerRunState: current.playerRunState.copyWith(
        currentHp: current.playerHp,
        maxHp: current.playerMaxHp,
      ),
      roomType: current.roomType,
      cardRewardOptions: const [], // 길들이기는 카드 보상 대신 몬스터 획득.
      tamedEnemyId: target.data.id,
    ));
  }

  /// 카드 전투 패배 = 항상 퍼마데스.
  /// HP 사망 / 턴 제한 초과 / 자해 사망 모두 런 종료.
  void _emitCardCombatDefeat(
    CardCombatActive current,
    Emitter<CombatState> emit,
  ) {
    final hpLoss = current.playerRunState.currentHp;
    final runState = current.playerRunState.copyWith(currentHp: 0);

    gameEventBus.emit(PlayerDamagedEvent(
      hpLost: hpLoss,
      remainingHp: 0,
    ));
    gameEventBus.emit(CombatMilestoneEvent(type: CombatMilestoneType.defeat));
    gameEventBus.emit(CombatEndedEvent(
      currentFloor: current.playerRunState.currentFloor,
    ));

    gameEventBus.emit(PermadeathEvent(
      finalHp: 0,
      defeatedBy: current.enemy.name,
    ));

    if (kDebugMode) {
      GameLogger.debug(
        LogSystem.combat,
        'Card combat defeat → permadeath: ${current.enemy.name}, '
        'combatHp=${current.playerHp}, runHp=$hpLoss',
      );
    }

    // 소울 보상 계산 (표시용)
    final soulGained =
        runState.currentFloor * economyConfig.soulBaseGain;

    emit(CardCombatResolved(
      outcome: CombatOutcome.defeat,
      enemies: current.enemies.map((e) => e.data).toList(),
      playerHp: 0,
      playerMaxHp: runState.maxHp,
      playerRunState: runState,
      hpLost: hpLoss,
      hpNarrationTier: HpNarrationTier.dead,
      isPermadeath: true,
      roomType: current.roomType,
      soulGained: soulGained,
    ));
  }

  // ── 멀티몹 타겟 선택 ────────────────────────────────────

  void _onSelectTarget(SelectTarget event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CardCombatActive) return;
    if (event.targetIndex < 0 || event.targetIndex >= current.enemies.length) {
      return;
    }
    // 죽은 적은 선택 불가 — 가장 가까운 살아있는 적으로 보정
    if (current.enemies[event.targetIndex].isDead) return;
    emit(current.copyWith(selectedTargetIndex: event.targetIndex));
  }

  /// BlessingPool effectType → BlessingTrigger 매핑 (턴/피격 기반 축복).
  static const _runBlessingTriggerMap = <String, BlessingTrigger>{
    'healPerTurn': BlessingTrigger.turnStart,
    'firstHitReduction': BlessingTrigger.onHit,
    'retainBlock': BlessingTrigger.turnEnd,
  };

  /// CardBlessingPool + BlessingPool 턴/피격 기반 축복을 통합 해결.
  ///
  /// resolveCardBlessingIds(cb_*)은 그대로, resolveBlessingIds(blessing_*/npc_*/devil_*)
  /// 중 턴/피격 기반 effectType은 CardBlessingData로 변환하여 병합.
  List<CardBlessingData> _resolveAllBlessings(List<String> ids) {
    final result = resolveCardBlessingIds(ids);

    final runBlessings = resolveBlessingIds(ids);
    for (final rb in runBlessings) {
      final trigger = _runBlessingTriggerMap[rb.effectType];
      if (trigger == null) continue;
      if (result.any((b) => b.id == rb.id)) continue;
      result.add(CardBlessingData(
        id: rb.id,
        name: rb.name,
        description: rb.description,
        rarity: rb.rarity,
        trigger: trigger,
        effectType: rb.effectType,
        effectValue: rb.effectValue,
      ));
    }

    return result;
  }

  // ── 전투 상태 복원 (이어하기) ──────────────────────────

  void _onRestoreCardCombat(
    RestoreCardCombat event,
    Emitter<CombatState> emit,
  ) {
    emit(event.savedState);
    GameLogger.info(
      LogSystem.combat,
      'Card combat restored: turn ${event.savedState.currentTurn}, '
      'enemies: ${event.savedState.enemies.length}',
    );
  }

  // ── 디버그 전용 핸들러 ──────────────────────────────────

  void _onDebugSetAp(DebugSetAp event, Emitter<CombatState> emit) {
    final current = state;
    if (current is! CardCombatActive) return;
    emit(current.copyWith(actionPoints: 99));
  }

  void _onDebugSetGodMode(DebugSetGodMode event, Emitter<CombatState> emit) {
    debugGodMode = event.enabled;
  }
}
