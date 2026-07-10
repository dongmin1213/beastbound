import 'package:flutter/foundation.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/core/config/tamed_monster_store.dart';
import 'package:soul_dungeon/core/text/korean_particles.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/combat/content/boss_enemies.dart';
import 'package:soul_dungeon/domain/combat/content/boss_gimmick_text.dart';
import 'package:soul_dungeon/domain/combat/content/card_rarity_resolver.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/domain/combat/logic/enemy_ai.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/boss_flow_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_session_state.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/card_display_formatter.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/chain_bonus.dart';
import 'package:soul_dungeon/domain/combat/logic/starting_deck_builder.dart';

/// 카드 전투 핸들러 — GameScreen에서 추출.
///
/// 카드 전투 진입/진행/종료, 보스 페이즈 전환, 재도전 로직을 담당.
/// M27 해소: _startCardCombat + _startCardBossCombat → 통합 [startCombat].
/// BossFlowHandler 콜백 패턴 동일 적용.
class CardCombatHandler {
  final CombatBloc combatBloc;
  final GameRunController runController;
  final BossFlowHandler bossFlowHandler;

  /// 텍스트 블록 설정 콜백 — setTextBlockData.
  final void Function(
    List<TextBlockData> blocks, {
    bool endCombat,
    bool resetMomentum,
  }) setTextBlockData;

  /// UI 상태 일괄 업데이트 콜백 — GameScreen.setState wrapper.
  final void Function({
    List<TextBlockData>? textBlockDataList,
    int? currentBlockIndex,
    bool? currentBlockComplete,
    bool? inCardCombat,
    bool? inCombat,
    bool? showingChoices,
    bool? choiceSelected,
    CombatSessionState? combatSession,
  }) updateUI;

  /// 기세 티어 조회 (1=low, 2=mid, 3=high).
  final int Function() getMomentumTier;

  /// 현재 기세 원시값 조회 (유물 임계치 판별용).
  final int Function() getCurrentMomentum;

  /// 전투 시작 기세 초기화 — RestoreMomentum(initial + bonus) 발행.
  final void Function(int bonus) applyMomentumBonus;

  /// 카드 플레이 알림 — CardPlayed 발행.
  final void Function(CardType cardType) notifyCardPlayed;

  /// 스크롤 제어.
  final VoidCallback scrollToBottom;
  final bool Function() isUserScrolledUp;

  /// 방 완료 콜백.
  final VoidCallback completeDungeonRoom;

  /// mounted 체크.
  final bool Function() isMounted;

  /// 전투 세션 상태 getter/setter.
  final CombatSessionState Function() getCombatSession;
  final void Function(CombatSessionState) updateCombatSession;

  /// 소울 업그레이드 구매 완료 ID (시작 덱 업그레이드 등).
  final Set<String> purchasedUpgradeIds;

  /// 카드 전투 밸런스 설정 (AP 티어 값 참조용).
  final CardCombatBalanceConfig cardCombatConfig;

  /// 도주 AP 비용 (FleeConfig.apCost 전달).
  final int fleeApCost;

  /// 전투 튜토리얼 모달 표시 콜백 (앱 최초 1회, SharedPreferences 관리).
  final Future<void> Function()? showTutorialModal;

  /// AP 변동 추적 — 직전 턴의 maxActionPoints.
  int _lastTurnMaxAp = 0;

  /// 첫 전투 규칙 요약 표시 여부 (런 당 1회).
  bool _shownApRulesSummary = false;

  /// 이어하기 전투 복원 시 AP 추적 상태 초기화.
  void restoreApTracking(int maxAp) {
    _lastTurnMaxAp = maxAp;
    _shownApRulesSummary = true;
  }

  CardCombatHandler({
    required this.combatBloc,
    required this.runController,
    required this.bossFlowHandler,
    required this.setTextBlockData,
    required this.updateUI,
    required this.getMomentumTier,
    required this.getCurrentMomentum,
    required this.applyMomentumBonus,
    required this.notifyCardPlayed,
    required this.scrollToBottom,
    required this.isUserScrolledUp,
    required this.completeDungeonRoom,
    required this.isMounted,
    required this.getCombatSession,
    required this.updateCombatSession,
    this.purchasedUpgradeIds = const {},
    this.cardCombatConfig = const CardCombatBalanceConfig(),
    this.showTutorialModal,
    this.fleeApCost = 1,
  });

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 전투 진입 (M27 통합)
  // ════════════════════════════════════════════════════════════════════════

  /// 카드 전투 진입 — 일반/엘리트 전투 (멀티몹 지원).
  Future<void> startCombat({
    required List<EnemyCombatData> enemies,
    required RoomType roomType,
    String? rewardJobOverride,
  }) async {
    final primaryEnemy = enemies.first;
    final introSuffix = enemies.length > 1
        ? ' 외 ${enemies.length - 1}마리${KoreanParticles.iGa('마리')} 나타났다!\n(${enemies.map((e) => e.name).join(', ')})'
        : '${KoreanParticles.iGa(primaryEnemy.name)} 나타났다!';
    await _startCombatInternal(
      enemyName: primaryEnemy.name,
      introSuffix: introSuffix,
      emitEvent: (deck, tier, momentum) => StartCardCombat(
        enemies: enemies,
        masterDeck: deck,
        playerRunState: runController.playerRunState,
        momentumTier: tier,
        roomType: roomType,
        currentMomentum: momentum,
        rewardJobOverride: rewardJobOverride,
      ),
    );
  }

  /// 보스 카드 전투 진입 — 보스 전투.
  Future<void> startBossCombat(int floor, {BossCombatData? bossOverride}) async {
    final bossData = bossOverride ?? BossEnemies.randomForFloor(floor) ??
        BossEnemies.forFloor(floor);
    if (bossData == null) return;

    // 보스 등장 서술 + 기믹 설명 추가
    final introNarration = BossGimmickText.bossIntroNarration(bossData.id);
    final gimmick = bossData.phases.first.gimmick;
    final gimmickIntro = BossGimmickText.introText(bossData.name, gimmick);

    await _startCombatInternal(
      enemyName: bossData.name,
      introSuffix: '${KoreanParticles.iGa(bossData.name)} 길을 가로막는다!',
      extraIntroBlocks: [
        CompletedBlock(text: introNarration),
        if (gimmickIntro.isNotEmpty)
          CompletedBlock(
            text: gimmickIntro,
            metadata: {'gimmick': 'true'},
          ),
      ],
      emitEvent: (deck, tier, momentum) => StartCardBossCombat(
        bossData: bossData,
        masterDeck: deck,
        playerRunState: runController.playerRunState,
        momentumTier: tier,
        currentMomentum: momentum,
      ),
    );
  }

  /// 통합 전투 진입 로직 — M27 해소.
  Future<void> _startCombatInternal({
    required String enemyName,
    required String introSuffix,
    required CombatEvent Function(List<CardData> deck, int tier, int momentum) emitEvent,
    List<CompletedBlock>? extraIntroBlocks,
  }) async {
    // 1. 덱 준비 (없으면 직업별 기본 덱, 무전직이면 공통 5장만)
    var deck = runController.playerRunState.masterDeck;
    if (deck.isEmpty) {
      final jobId = runController.playerRunState.currentJobId;
      if (jobId != null) {
        deck = StartingDeckBuilder.build(
          jobId,
          purchasedUpgradeIds: purchasedUpgradeIds,
        );
      } else {
        deck = [...StarterCards.all];
      }
      runController.playerRunState =
          runController.playerRunState.copyWith(masterDeck: deck);
    }

    // 2. 인트로 텍스트
    runController.completedBlocks.add(CompletedBlock(
      text: '$enemyName$introSuffix',
    ));

    // 2.5 추가 인트로 블록 (보스 서술 + 기믹 설명 등)
    if (extraIntroBlocks != null) {
      runController.completedBlocks.addAll(extraIntroBlocks);
    }

    // 첫 전투 규칙 요약 (런 당 1회)
    if (!_shownApRulesSummary) {
      _shownApRulesSummary = true;
      runController.completedBlocks.add(CompletedBlock(
        text: '기세 [저:${cardCombatConfig.apLow}AP / 중:${cardCombatConfig.apMid}AP / 고:${cardCombatConfig.apHigh}AP]\n다양한 유형의 카드를 번갈아 사용하면 기세가 오릅니다.',
        metadata: const {'apRules': true},
      ));
    }

    // O-01: 앱 최초 전투 진입 시 튜토리얼 모달 (SharedPreferences로 1회 제어)
    if (showTutorialModal != null) {
      await showTutorialModal!();
    }

    // 3. 카드 전투 모드 설정
    updateUI(
      textBlockDataList: [],
      currentBlockIndex: 0,
      inCardCombat: true,
      inCombat: true,
      showingChoices: false,
      choiceSelected: false,
    );

    // 4. CombatBloc 이벤트 발행
    final tier = getMomentumTier();
    final momentum = getCurrentMomentum();
    combatBloc.add(emitEvent(deck, tier, momentum));

    // 4.5. NPC 보급품 일회성 보너스 소비 (전투 시작 시 적용 후 리셋)
    final prs = runController.playerRunState;
    if (prs.tempStrengthBonus > 0 || prs.tempBlockBonus > 0 || prs.tempMomentumBonus > 0) {
      runController.playerRunState = prs.copyWith(
        tempStrengthBonus: 0,
        tempBlockBonus: 0,
        tempMomentumBonus: 0,
      );
    }

    // 5. CardCombatActive 상태 도착 시 턴 구분선 + 선택지 표시
    //    firstWhere를 사용하여 EndCombat의 CombatInitial 등 중간 상태를 건너뜀
    //    (재도전 시 EndCombat → StartCardCombat 순서로 이벤트가 발행되므로)
    combatBloc.stream.firstWhere((s) => s is CardCombatActive).timeout(
      const Duration(seconds: 5),
      onTimeout: () => combatBloc.state,
    ).then((state) {
      if (!isMounted()) return;
      if (state is CardCombatActive) {
        _lastTurnMaxAp = state.maxActionPoints;
        // 기세 리셋 + 보너스 적용 — CardCombatActive 수신 즉시 적용하여
        // UI 최초 렌더링 전에 MomentumBloc 상태를 확정시킴.
        applyMomentumBonus(state.initialMomentumBonus);
        runController.completedBlocks.add(CompletedBlock(
          text: '═══════ ${state.currentTurn}턴 ═══════',
          metadata: {'turnDivider': 'true'},
        ));
        updateUI(showingChoices: true);
        scrollToBottom();
      }
    }).catchError((_) {}, test: (e) => e is StateError);
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 카드 플레이 / 턴 종료 / 도주
  // ════════════════════════════════════════════════════════════════════════

  /// 카드 플레이 처리.
  void handlePlayCard(ChoiceData choice) {
    updateUI(choiceSelected: true);

    Future.delayed(const Duration(milliseconds: 100), () async {
      if (!isMounted()) return;

      // choice.id 형식: 'play_card_{cardId}_{handIndex}'
      final cardId = choice.sourceCard?.id ?? choice.id.replaceFirst('play_card_', '');
      final tier = getMomentumTier();

      // 손패 인덱스 추출 (동일 ID 카드 구분용)
      var handIndex = -1;
      final idParts = choice.id.replaceFirst('play_card_', '').split('_');
      if (idParts.length >= 2) {
        handIndex = int.tryParse(idParts.last) ?? -1;
      }

      combatBloc.add(PlayCard(cardId, momentumTier: tier, handIndex: handIndex));

      // PlayCard 처리 완료 대기 — stream.first로 다음 상태 수신
      CombatState newState;
      try {
        newState = await combatBloc.stream.first.timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => combatBloc.state,
        );
      } on StateError {
        updateUI(choiceSelected: false);
        return;
      }
      if (!isMounted()) return;

      // 타임아웃으로 이전 상태를 받았을 수 있음 — 현재 bloc.state 재확인
      if (newState is CardCombatActive && newState.lastPlayResult == null) {
        final currentBlocState = combatBloc.state;
        if (currentBlocState is CardCombatActive &&
            currentBlocState.lastPlayResult != null) {
          newState = currentBlocState;
        }
      }

      if (newState is CardCombatActive) {
        if (newState.lastPlayResult != null) {
          // 카드 사용 성공 — 선택 텍스트 + 결과 텍스트 추가
          runController.completedBlocks.add(CompletedBlock(
            text: choice.text,
            isChoice: true,
          ));
          final comboCount = newState.turnFlags.attacksPlayedThisTurn;
          final chainCount = newState.turnFlags.chainCount;
          final isChain = chainCount >= 2;
          final chainConfig = combatBloc.chainBonusConfig;

          // 연쇄 보너스 데미지 계산 (describeCardPlayResult에 전달)
          var chainBonusDmg = 0;
          if (isChain && newState.lastPlayResult!.damageResult != null) {
            final hpLost = newState.lastPlayResult!.damageResult!.hpLost;
            if (hpLost > 0) {
              chainBonusDmg = ChainBonus.applyToValue(
                hpLost, chainCount, chainConfig,
              );
            }
          }

          final resultText = CombatFlowManager.describeCardPlayResult(
            newState.lastPlayResult!,
            comboCount: comboCount,
            chainBonusDamage: chainBonusDmg,
          );
          final synergy = CombatFlowManager.detectSynergy(
            newState.lastPlayResult!,
            comboCount: comboCount,
          );
          runController.completedBlocks.add(CompletedBlock(
            text: resultText,
            metadata: synergy.hasSynergy
                ? {'synergy': true}
                : isChain
                    ? {'chain': true, 'chainCount': chainCount}
                    : null,
          ));
          // 연쇄 보너스 배지 — 추가 효과(드로우/기세)만 간결하게 표시
          if (isChain) {
            final displayCount = chainCount.clamp(2, 3);
            final drawBonus = ChainBonus.drawBonus(chainCount, chainConfig);
            final momentumBonus = ChainBonus.momentumBonus(chainCount, chainConfig);
            final badgeParts = <String>[];
            if (drawBonus > 0) badgeParts.add('드로우 +$drawBonus');
            if (momentumBonus > 0) badgeParts.add('기세 +$momentumBonus');
            final bonusLabel = '$displayCount연쇄!'
                '${badgeParts.isNotEmpty ? ' ${badgeParts.join(' / ')}' : ''}';
            runController.completedBlocks.add(CompletedBlock(
              text: bonusLabel,
              metadata: const {'chainBadge': true},
            ));
          }
          notifyCardPlayed(newState.lastPlayResult!.card.type);
        } else {
          // 카드 사용 조건 불충족 (기습: 1턴째만, 연환격: 공격 후에만 등)
          runController.completedBlocks.add(const CompletedBlock(
            text: '⚠ 지금은 사용할 수 없는 카드다.',
          ));
        }
        updateUI(choiceSelected: false);
      } else if (newState is CardCombatResolved) {
        _handleCardCombatResolved(newState);
      } else if (newState is CardBossPhaseTransition) {
        _handleCardBossPhaseTransition(newState);
      } else {
        // 예상치 못한 상태 → choiceSelected 해제하여 UI 멈춤 방지
        updateUI(choiceSelected: false);
      }

      if (!isUserScrolledUp()) {
        scrollToBottom();
      }
    });
  }

  /// 턴 종료 처리.
  void handleEndTurn() {
    updateUI(choiceSelected: true);

    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!isMounted()) return;

      final tier = getMomentumTier();

      runController.completedBlocks.add(const CompletedBlock(
        text: '⏩ 턴 종료',
        isChoice: true,
      ));

      // 절약 카드: 턴 종료 시 남은 AP × value 블록 피드백
      final preState = combatBloc.state;
      if (preState is CardCombatActive &&
          preState.turnFlags.remainingApBlockValue > 0 &&
          preState.actionPoints > 0) {
        final apBlock = preState.actionPoints * preState.turnFlags.remainingApBlockValue;
        runController.completedBlocks.add(CompletedBlock(
          text: '🛡 절약 발동: 남은 AP ${preState.actionPoints} × ${preState.turnFlags.remainingApBlockValue} = $apBlock 블록 획득',
        ));
      }

      combatBloc.add(EndPlayerTurn(momentumTier: tier));
      // bloc 이벤트 처리 완료 대기 — stream.first로 다음 상태 emit 확인
      final CombatState newState;
      try {
        newState = await combatBloc.stream.first.timeout(
          const Duration(seconds: 2),
          onTimeout: () => combatBloc.state,
        );
      } on StateError {
        if (isMounted()) updateUI(choiceSelected: false);
        return;
      }
      if (!isMounted()) return;

      if (newState is CardCombatActive) {
        if (newState.lastEnemyActions.isNotEmpty) {
          // 멀티몹: 한 블록으로 합쳐 작은 화면에서 스크롤로 밀리지 않게 함
          final lines = <String>[];
          for (final (name, action) in newState.lastEnemyActions) {
            lines.add(CombatFlowManager.describeEnemyAction(name, action));
          }
          runController.completedBlocks.add(CompletedBlock(
            text: lines.join('\n'),
          ));
        } else if (newState.currentTurn > 1) {
          // 적 전원 기절 — 행동 스킵 텍스트
          final stunText = CombatFlowManager.describeEnemyStunned(
            newState.enemy.name,
          );
          runController.completedBlocks.add(CompletedBlock(text: stunText));
        }
        // 보스 기믹 턴별 피드백
        _appendGimmickFeedback(newState);
        // AP 변동 텍스트 (턴 구분선 직전에 삽입)
        if (_lastTurnMaxAp > 0 && newState.maxActionPoints != _lastTurnMaxAp) {
          final arrow = newState.maxActionPoints > _lastTurnMaxAp
              ? '기세 상승!'
              : '기세 하락!';
          runController.completedBlocks.add(CompletedBlock(
            text: '$arrow ${_lastTurnMaxAp}AP → ${newState.maxActionPoints}AP',
            metadata: const {'apChange': true},
          ));
          // 기세 첫 변동 힌트
          GameHintManager.shouldShow(GameHintManager.hintMomentum).then((show) {
            if (show) {
              runController.completedBlocks.add(
                CompletedBlock(text: GameHintManager.momentumText),
              );
            }
          });
        }
        _lastTurnMaxAp = newState.maxActionPoints;
        runController.completedBlocks.add(CompletedBlock(
          text: '═══════ ${newState.currentTurn}턴 ═══════',
          metadata: {'turnDivider': 'true'},
        ));
        updateUI(choiceSelected: false);
      } else if (newState is CardCombatResolved) {
        // 턴 종료 중 적 사망 = 상태이상 피니시 (독/화상/가시)
        if (newState.outcome == CombatOutcome.victory) {
          final finishText = CombatFlowManager.describeStatusFinish(
            newState.enemy.name,
          );
          runController.completedBlocks.add(CompletedBlock(
            text: finishText,
            metadata: const {'synergy': true},
          ));
        }
        _handleCardCombatResolved(newState);
      } else if (newState is CardBossPhaseTransition) {
        _handleCardBossPhaseTransition(newState);
      } else {
        updateUI(choiceSelected: false);
      }

      if (!isUserScrolledUp()) {
        scrollToBottom();
      }
    });
  }

  /// 도주 시도 처리.
  void handleAttemptFlee() {
    // AP 부족 시 즉시 피드백 — bloc에 보내지 않음
    final preState = combatBloc.state;
    if (preState is CardCombatActive &&
        preState.actionPoints < fleeApCost) {
      runController.completedBlocks.add(const CompletedBlock(
        text: 'AP가 부족하여 도주할 수 없다.',
      ));
      // updateUI로 즉시 리빌드 트리거
      updateUI(choiceSelected: false);
      if (!isUserScrolledUp()) scrollToBottom();
      return;
    }

    updateUI(choiceSelected: true);

    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!isMounted()) return;

      runController.completedBlocks.add(const CompletedBlock(
        text: '🏃 도주',
        isChoice: true,
      ));

      final tier = getMomentumTier();

      combatBloc.add(AttemptFlee(momentumTier: tier));

      // stream.first로 다음 상태 emit 대기 (Duration.zero보다 신뢰적)
      CombatState newState;
      try {
        newState = await combatBloc.stream.first.timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => combatBloc.state,
        );
      } on StateError {
        updateUI(choiceSelected: false);
        return;
      }
      if (!isMounted()) return;

      // 타임아웃 폴백 — fleeFailed 체크
      if (newState is CardCombatActive && !newState.fleeFailed) {
        final currentBlocState = combatBloc.state;
        if (currentBlocState is CardCombatActive && currentBlocState.fleeFailed) {
          newState = currentBlocState;
        } else if (currentBlocState is CardCombatResolved) {
          newState = currentBlocState;
        }
      }

      if (newState is CardCombatResolved) {
        _handleCardCombatResolved(newState);
      } else if (newState is CardCombatActive && newState.fleeFailed) {
        // 도주 실패 — 적 턴 실행 후 새 턴 시작
        runController.completedBlocks.add(const CompletedBlock(
          text: '도주에 실패했다!',
        ));
        if (newState.lastEnemyActions.isNotEmpty) {
          // 멀티몹: 한 블록으로 합쳐 작은 화면에서 스크롤로 밀리지 않게 함
          final lines = <String>[];
          for (final (name, action) in newState.lastEnemyActions) {
            lines.add(CombatFlowManager.describeEnemyAction(name, action));
          }
          runController.completedBlocks.add(CompletedBlock(
            text: lines.join('\n'),
          ));
        } else {
          // 적 전원 기절 — 행동 스킵 텍스트
          final stunText = CombatFlowManager.describeEnemyStunned(
            newState.enemy.name,
          );
          runController.completedBlocks.add(CompletedBlock(text: stunText));
        }
        // AP 변동 텍스트
        if (_lastTurnMaxAp > 0 && newState.maxActionPoints != _lastTurnMaxAp) {
          final arrow = newState.maxActionPoints > _lastTurnMaxAp
              ? '기세 상승!'
              : '기세 하락!';
          runController.completedBlocks.add(CompletedBlock(
            text: '$arrow ${_lastTurnMaxAp}AP → ${newState.maxActionPoints}AP',
            metadata: const {'apChange': true},
          ));
        }
        _lastTurnMaxAp = newState.maxActionPoints;
        runController.completedBlocks.add(CompletedBlock(
          text: '═══════ ${newState.currentTurn}턴 ═══════',
          metadata: {'turnDivider': 'true'},
        ));
        updateUI(choiceSelected: false);
        if (!isUserScrolledUp()) {
          scrollToBottom();
        }
      } else {
        updateUI(choiceSelected: false);
      }
    });
  }

  /// 제압된 적 길들이기 처리 — 전투를 포획으로 종료.
  /// [index] 적이 제압 상태일 때만 유효 (도주 흐름을 미러링).
  void handleTame(int index) {
    final preState = combatBloc.state;
    if (preState is! CardCombatActive) return;
    if (preState.suppressedTargetIndex != index) return; // 방어

    final name = preState.enemies[index].data.name;
    updateUI(choiceSelected: true);

    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!isMounted()) return;

      runController.completedBlocks.add(CompletedBlock(
        text: '🐾 $name 길들이기',
        isChoice: true,
      ));

      combatBloc.add(TameEnemy(index));

      CombatState newState;
      try {
        newState = await combatBloc.stream.first.timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => combatBloc.state,
        );
      } on StateError {
        updateUI(choiceSelected: false);
        return;
      }
      if (!isMounted()) return;

      if (newState is CardCombatResolved) {
        _handleCardCombatResolved(newState);
      } else {
        updateUI(choiceSelected: false);
      }
    });
  }

  /// 카드 보상 선택 처리.
  void handleSelectCardReward(ChoiceData choice) {
    final selectedCardId = choice.id == 'skip_reward'
        ? null
        : choice.id.replaceFirst('card_reward_', '');

    // 선택한 카드를 즉시 로컬 상태에 반영 (Bloc 비동기 처리 전에 동기화)
    if (selectedCardId != null) {
      final combatState = combatBloc.state;
      if (combatState is CardCombatResolved) {
        final selected = combatState.cardRewardOptions.where(
          (c) => c.id == selectedCardId,
        );
        if (selected.isNotEmpty) {
          final updatedState = runController.playerRunState.copyWith(
            masterDeck: [
              ...runController.playerRunState.masterDeck,
              selected.first,
            ],
          );
          runController.playerRunState = updatedState;
          runController.runBloc.add(SyncFromCombat(updatedState));
        }
      }
    }

    combatBloc.add(SelectCardReward(selectedCardId: selectedCardId));
    endCardCombatAndCompleteRoom();
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 전투 결과 처리
  // ════════════════════════════════════════════════════════════════════════

  /// CardCombatResolved 상태 처리 — 승리/패배/도주 분기.
  void _handleCardCombatResolved(CardCombatResolved resolved) {
    // HP 동기화 — 금화는 CombatRewardEvent 핸들러에서 별도 처리하므로 보존
    runController.playerRunState = resolved.playerRunState.copyWith(
      gold: runController.playerRunState.gold,
    );
    runController.runBloc.add(SyncFromCombat(runController.playerRunState));

    switch (resolved.outcome) {
      case CombatOutcome.victory:
        if (resolved.isTamed && resolved.tamedEnemyId != null) {
          TamedMonsterStore.markTamed(resolved.tamedEnemyId!);
        }
        runController.completedBlocks.add(CompletedBlock(
          text: resolved.isTamed ? '🐾 몬스터를 길들였다!' : '✦ 전투 승리!',
        ));

        if (resolved.roomType == RoomType.boss) {
          updateUI(
            inCardCombat: false,
            choiceSelected: false,
            showingChoices: false,
          );
          bossFlowHandler.handleVictoryFloorTransition();
        } else if (resolved.cardRewardOptions.isNotEmpty) {
          final rewardChoices = resolved.cardRewardOptions
              .map((card) {
                final rarity = CardRarityResolver.resolve(card);
                final rarityLabel = CardRarityResolver.label(rarity);
                return ChoiceData(
                  id: 'card_reward_${card.id}',
                  text: '[$rarityLabel] ${CardDisplayFormatter.formatCardLine(card)}',
                  resultTextBlocks: const [],
                  sourceCard: card,
                  cardType: card.type,
                  apCost: card.apCost,
                );
              })
              .toList();
          rewardChoices.add(const ChoiceData(
            id: 'skip_reward',
            text: '건너뛰기',
            resultTextBlocks: [],
          ));
          final session = getCombatSession();
          updateUI(
            inCardCombat: true,
            choiceSelected: false,
            textBlockDataList: [
              TextBlockData(
                text: resolved.isTamed
                    ? '길들인 몬스터의 힘을 배운다 — 카드를 선택하세요.'
                    : '카드 보상을 선택하세요.',
                choices: rewardChoices,
              ),
            ],
            currentBlockIndex: 0,
            currentBlockComplete: false,
            showingChoices: false,
            combatSession: session.copyWith(clearCurrentEncounter: true),
          );
        } else {
          updateUI(
            inCardCombat: false,
            choiceSelected: false,
            showingChoices: false,
          );
          runController.appendFeedbackText(
              resolved.isTamed ? '몬스터를 길들였다!' : '전투 승리!');
          _endCombatAndCompleteRoom();
        }

      case CombatOutcome.defeat:
        updateUI(
          inCardCombat: false,
          choiceSelected: false,
        );
        if (resolved.isPermadeath) {
          // D-04: 퍼마데스 — 런 요약 + 재시작
          setTextBlockData([
            CombatFlowManager.buildPermadeathBlock(),
            CombatFlowManager.buildRunSummaryBlock(
              runState: runController.playerRunState,
              soulGained: resolved.soulGained,
              showSoulHint: GameHintManager.checkAndMark(GameHintManager.hintSoul),
            ),
            TextBlockData(
              text: '',
              choices: [
                ChoiceData(
                  id: 'restart_run',
                  text: '처음부터 다시 시작',
                  resultTextBlocks: const [],
                ),
              ],
            ),
          ], endCombat: false);
          // setTextBlockData가 completedBlocks를 클리어하므로 이후에 추가
          runController.completedBlocks.add(const CompletedBlock(
            text: '어둠이 밀려온다...',
          ));
        } else {
          // D-04: 일반 패배 — HP 손실 후 바로 다음 방 진행
          if (resolved.hpLost != null && resolved.hpNarrationTier != null) {
            runController.completedBlocks.add(CompletedBlock(
              text: CombatFlowManager.buildDefeatHpBlock(
                hpLost: resolved.hpLost!,
                remainingHp: resolved.playerRunState.currentHp,
                maxHp: resolved.playerRunState.maxHp,
                tier: resolved.hpNarrationTier!,
              ).text,
            ));
          }
          runController.completedBlocks.add(const CompletedBlock(
            text: '패배했지만 앞으로 나아간다...',
          ));
          _endCombatAndCompleteRoom();
        }

      case CombatOutcome.fled:
        runController.completedBlocks.add(const CompletedBlock(
          text: '도주에 성공했다.',
        ));
        updateUI(
          inCardCombat: false,
          choiceSelected: false,
          showingChoices: false,
        );
        _endCombatAndCompleteRoom();
    }
  }

  /// 카드 보스 페이즈 전환 처리 — 전투 화면 내에서 전환 메시지 + "계속" 선택지.
  void _handleCardBossPhaseTransition(CardBossPhaseTransition transition) {
    final phaseName = '페이즈 ${transition.nextPhaseIndex + 1}';
    final name = transition.bossData.name;
    runController.completedBlocks.add(CompletedBlock(
      text: '$name${KoreanParticles.iGa(name)} 형태를 바꾼다! ($phaseName)',
    ));
    runController.completedBlocks.add(const CompletedBlock(
      text: '보스가 다음 페이즈로 전환합니다.',
    ));
    updateUI(
      choiceSelected: false,
      inCardCombat: true,
      textBlockDataList: [
        const TextBlockData(
          text: '',
          choices: [
            ChoiceData(
              id: 'boss_continue',
              text: '계속 싸운다',
              resultTextBlocks: [],
            ),
          ],
        ),
      ],
      currentBlockIndex: 0,
      currentBlockComplete: true,
      showingChoices: true,
    );
    if (!isUserScrolledUp()) {
      scrollToBottom();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 전투 종료 / 재도전 / 보스 분기
  // ════════════════════════════════════════════════════════════════════════

  /// 카드 전투 종료 + 방 완료.
  void endCardCombatAndCompleteRoom() {
    updateUI(inCardCombat: false, inCombat: false);
    combatBloc.add(const EndCombat());
    completeDungeonRoom();
  }

  void _endCombatAndCompleteRoom() {
    updateUI(inCombat: false);
    combatBloc.add(const EndCombat());
    completeDungeonRoom();
  }

  /// 보스 다음 페이즈 전환.
  void handleBossContinue() {
    // 카드 전투 보스 페이즈 전환
    if (combatBloc.state is CardBossPhaseTransition) {
      final tier = getMomentumTier();
      combatBloc.add(ContinueCardBossPhase(momentumTier: tier));
      combatBloc.stream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => combatBloc.state,
      ).then((state) {
        if (!isMounted()) return;
        if (state is CardCombatActive) {
          _lastTurnMaxAp = state.maxActionPoints;
          // 보스 페이즈 전환 시 기세 유지 — applyMomentumBonus 호출하지 않음
          runController.completedBlocks.add(CompletedBlock(
            text: '═══════ ${state.currentTurn}턴 ═══════',
            metadata: {'turnDivider': 'true'},
          ));
          updateUI(
            inCardCombat: true,
            showingChoices: true,
            choiceSelected: false,
          );
          scrollToBottom();
        }
      }).catchError((_) {}, test: (e) => e is StateError);
      return;
    }
    // 레거시 보스 페이즈 전환
    bossFlowHandler.handleBossContinue();
  }

  /// 보스 3선택지 처리 위임.
  void handleBossChoice(ChoiceData choice) {
    bossFlowHandler.handleBossChoice(choice);
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 보스 기믹 피드백
  // ════════════════════════════════════════════════════════════════════════

  /// 보스 기믹 발동 시 피드백 텍스트 추가.
  void _appendGimmickFeedback(CardCombatActive state) {
    if (state.bossData == null) return;

    final phase = state.bossData!.phaseAt(state.currentBossPhase);
    final gimmick = phase.gimmick;
    if (gimmick == BossGimmick.none || gimmick == BossGimmick.formShift) return;

    final result = EnemyAI.resolveGimmick(gimmick, state.enemyMaxHp);
    final isRegenBlocked = state.regenBlockedThisTurn;
    final text = BossGimmickText.triggerText(
      state.enemy.name,
      gimmick,
      healAmount: isRegenBlocked ? 0 : result.healAmount,
      drainAmount: state.lastEnemyAction != null &&
              state.lastEnemyAction!.type.isAttack
          ? state.lastEnemyAction!.damage * result.drainPercent ~/ 100
          : 0,
      strengthGain: result.strengthOnHit,
      regenBlocked: isRegenBlocked && gimmick == BossGimmick.regen,
    );

    if (text.isNotEmpty) {
      runController.completedBlocks.add(CompletedBlock(
        text: text,
        metadata: const {'gimmick': true},
      ));
    }
  }
}
