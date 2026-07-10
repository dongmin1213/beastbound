import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_result_calculator.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_session_state.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';

enum ResolveAction { none, bossVictory, combatVictory, combatDefeat }

/// 전투 결과 판정 — combatOutcome 블록 교체, 패배/재도전/퍼마데스 처리.
class CombatOutcomeResolver {
  final CombatBloc combatBloc;
  final GameRunController runController;
  final CombatSessionState Function() getSessionState;
  final EconomyConfig economyConfig;
  final double soulGainMultiplier;

  CombatOutcomeResolver({
    required this.combatBloc,
    required this.runController,
    required this.getSessionState,
    this.economyConfig = const EconomyConfig(),
    this.soulGainMultiplier = 1.0,
  });

  /// 현재 블록이 pending combatOutcome이면 CombatBloc으로 결과 판정.
  /// textBlockDataList를 직접 수정. 호출자가 setState로 UI 갱신.
  Future<ResolveAction> resolvePendingOutcome(
    List<TextBlockData> textBlockDataList,
    int currentBlockIndex,
    bool Function() isMounted,
  ) async {
    if (currentBlockIndex >= textBlockDataList.length) {
      return ResolveAction.none;
    }
    final block = textBlockDataList[currentBlockIndex];
    if (block.blockType != TextBlockType.combatOutcome) {
      return ResolveAction.none;
    }
    if (block.metadata?['combatOutcome'] != 'pending') {
      return ResolveAction.none;
    }

    // CombatBloc에 ResolveCombat 발행 + 결과 대기
    final nextStateFuture = combatBloc.stream.first;
    combatBloc.add(const ResolveCombat());
    final CombatState resolvedState;
    try {
      resolvedState = await nextStateFuture;
    } on StateError {
      return ResolveAction.none;
    }
    if (!isMounted()) return ResolveAction.none;

    // 보스 페이즈 전환 처리
    if (resolvedState is BossPhaseTransition) {
      _handleBossPhaseTransition(
        resolvedState, textBlockDataList, currentBlockIndex,
      );
      return ResolveAction.none;
    }

    if (resolvedState is! CombatResolved) return ResolveAction.none;
    final resolved = resolvedState;
    // HP 동기화 — 금화는 CombatRewardEvent 핸들러에서 별도 처리하므로 보존
    runController.playerRunState = resolved.playerRunState.copyWith(
      gold: runController.playerRunState.gold,
    );
    runController.runBloc.add(SyncFromCombat(resolved.playerRunState));

    _resolveOutcomeFromBloc(resolved, currentBlockIndex, textBlockDataList);

    // 승리 판정
    if (resolved.resultScore.outcome == CombatOutcome.victory) {
      if (getSessionState().bossEncounter != null) {
        return ResolveAction.bossVictory;
      }
      return ResolveAction.combatVictory;
    }
    // D-04: 비-퍼마데스 패배 → 다음 방 자동 진행
    if (resolved.resultScore.outcome == CombatOutcome.defeat &&
        !resolved.isPermadeath) {
      return ResolveAction.combatDefeat;
    }
    return ResolveAction.none;
  }

  /// CombatResolved 결과로 combatOutcome 블록 교체 + 패배 블록 삽입.
  void _resolveOutcomeFromBloc(
    CombatResolved resolved,
    int outcomeIndex,
    List<TextBlockData> textBlockDataList,
  ) {
    if (getSessionState().currentEncounter == null) return;

    textBlockDataList[outcomeIndex] = CombatFlowManager.buildOutcomeBlock(
      getSessionState().currentEncounter!, resolved.resultScore,
    );

    if (resolved.resultScore.outcome == CombatOutcome.defeat) {
      if (resolved.hpLost != null) {
        // HP 손실 서술 블록
        textBlockDataList.insert(
          outcomeIndex + 1,
          CombatFlowManager.buildDefeatHpBlock(
            hpLost: resolved.hpLost!,
            remainingHp: resolved.playerRunState.currentHp,
            maxHp: resolved.playerRunState.maxHp,
            tier: resolved.hpNarrationTier!,
          ),
        );

        if (resolved.isPermadeath) {
          // D-04: 퍼마데스 — 런 요약 + 재시작
          final baseSoul = SoulCalculator.calculateDeathReward(
            runController.playerRunState.currentFloor,
            economyConfig.soulBaseGain,
          );
          final soulGained = (baseSoul * soulGainMultiplier).toInt();
          textBlockDataList.insert(
            outcomeIndex + 2,
            CombatFlowManager.buildPermadeathBlock(),
          );
          textBlockDataList.insert(
            outcomeIndex + 3,
            CombatFlowManager.buildRunSummaryBlock(
              runState: runController.playerRunState,
              soulGained: soulGained,
              showSoulHint: GameHintManager.checkAndMark(GameHintManager.hintSoul),
            ),
          );
          textBlockDataList.insert(
            outcomeIndex + 4,
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
          );
        }
        // D-04: 비-퍼마데스 패배는 다음 방 자동 진행
        // (더 이상 retry/retreat 루프 없음)
      }
    }
  }

  /// 보스 페이즈 전환 처리 — 전환 텍스트 + HP 정보 + 계속 선택지 삽입.
  void _handleBossPhaseTransition(
    BossPhaseTransition transition,
    List<TextBlockData> textBlockDataList,
    int currentBlockIndex,
  ) {
    if (getSessionState().bossEncounter == null) return;

    runController.playerRunState = transition.playerRunState;
    runController.runBloc.add(SetPlayerRunState(transition.playerRunState));

    final phases = getSessionState().bossEncounter!.bossPhases;
    final transitionText = (phases != null &&
            transition.completedPhaseIndex < phases.length)
        ? phases[transition.completedPhaseIndex].transitionText
        : null;
    final hpInfo =
        '[HP: ${runController.playerRunState.currentHp}/${runController.playerRunState.maxHp}]';

    // 현재 outcome 블록을 전환 텍스트로 교체
    textBlockDataList[currentBlockIndex] = TextBlockData(
      text: '${transitionText ?? ''}\n\n$hpInfo',
      blockType: TextBlockType.combatOutcome,
      metadata: const {'combatOutcome': 'boss_transition'},
    );

    // 다음 블록에 boss_continue 선택지 삽입
    textBlockDataList.insert(
      currentBlockIndex + 1,
      TextBlockData(
        text: '',
        choices: [
          ChoiceData(
            id: 'boss_continue',
            text: '다음 페이즈 시작',
            resultTextBlocks: const [],
          ),
        ],
      ),
    );
  }
}
