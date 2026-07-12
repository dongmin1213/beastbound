import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/floor_region.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_session_state.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 보스 전투 플로우 관리 — 승리 후 3선택지, 페이즈 전환, 엔딩 표시.
///
/// GameScreen에서 추출 (Step 3). 보스 관련 5개 메서드를 위임.
class BossFlowHandler {
  final CombatBloc combatBloc;
  final CombatSessionState Function() getCombatSession;
  final void Function(CombatSessionState) updateCombatSession;
  final GameRunController runController;
  final GameEventBus gameEventBus;
  final EconomyConfig economyConfig;
  final double soulGainMultiplier;

  /// 텍스트 블록 설정 콜백.
  final void Function(
    List<TextBlockData> blocks, {
    bool endCombat,
    bool resetMomentum,
  }) setTextBlockData;

  /// 전투 UI 표시 상태 설정 콜백.
  final void Function(bool inCombat) setInCombat;

  /// 현재 기세 값 조회 콜백.
  final int Function() getMomentumValue;

  /// 런 완료 기록 콜백.
  final void Function(String endingName) recordRunCompleted;

  /// 해금된 기억 수 조회 콜백 (초월 엔딩 조건).
  final int Function() getUnlockedMemoryCount;

  BossFlowHandler({
    required this.combatBloc,
    required this.getCombatSession,
    required this.updateCombatSession,
    required this.runController,
    required this.gameEventBus,
    required this.setTextBlockData,
    required this.setInCombat,
    required this.getMomentumValue,
    required this.recordRunCompleted,
    required this.getUnlockedMemoryCount,
    this.economyConfig = const EconomyConfig(),
    this.soulGainMultiplier = 1.0,
  });

  /// 보스 승리 → 제압한 주인을 길들여 동료로. (선택지 없음 — 보스=자동 테이밍)
  ///
  /// 원작의 6선택지(처치/해방/공존/…)는 성향·직업분화·엔딩에 영향을 줬으나 그
  /// 시스템이 모두 제거되어 순수 잔재였다. BEASTBOUND에선 보스 처치=길들이기이므로
  /// 선택 없이 "동료 획득 + 층 전환"으로 직행한다.
  void handleVictoryFloorTransition() {
    final floor = runController.playerRunState.currentFloor;
    runController.appendFeedbackText('$floor층 영역의 주인 제압!');
    setInCombat(false);
    combatBloc.add(const EndCombat());

    if (FloorRegion.isFinalFloor(floor)) {
      // 최종 층 — 심연의 주인마저 길들였다.
      showEnding('심연의 주인마저 무릎 꿇리고 길들였다.');
      return;
    }

    // 이어하기 시 이 화면(층 전환 대기)을 복원하기 위한 플래그.
    runController.playerRunState = runController.playerRunState.copyWith(
      bossVictoryPending: true,
    );

    setTextBlockData([
      TextBlockData(
        text: '영역의 주인을 제압해 길들였다. 강력한 동료가 곁에 선다.\n\n'
            '$floor층을 넘어섰다. 더 깊은 곳으로 향하는 길이 열린다.',
        choices: [
          ChoiceData(
            id: 'advance_floor',
            text: '${floor + 1}층으로 내려간다',
            resultTextBlocks: const [],
          ),
        ],
      ),
    ], endCombat: false, resetMomentum: true);
  }

  /// 보스 다음 페이즈 전환 — 기세 유지.
  void handleBossContinue() {
    final session = getCombatSession();
    if (session.bossEncounter == null) return;

    final nextPhaseIndex = session.currentBossPhaseIndex + 1;
    final phases = session.bossEncounter!.bossPhases;
    if (phases == null || nextPhaseIndex >= phases.length) return;
    combatBloc.add(const ContinueBossPhase());

    final nextPhase = phases[nextPhaseIndex];
    final phaseEncounter = CombatEncounter(
      roomType: session.bossEncounter!.roomType,
      enemyName: session.bossEncounter!.enemyName,
      introText: nextPhase.introText,
      turns: nextPhase.turns,
      victoryText: session.bossEncounter!.victoryText,
      defeatText: session.bossEncounter!.defeatText,
    );

    final blocks = CombatFlowManager.toDynamicTextBlocks(phaseEncounter);
    setTextBlockData(blocks, endCombat: false, resetMomentum: false);
    updateCombatSession(session.copyWith(
      currentBossPhaseIndex: nextPhaseIndex,
      currentEncounter: phaseEncounter,
    ));
    setInCombat(true);
  }

  /// 보스 전투 중 선택 처리 — 다단 페이즈 전환(boss_continue)만 담당.
  /// (원작의 처치/해방/공존 등 보스 처치 선택지는 제거됨 — 보스=자동 테이밍.)
  void handleBossChoice(ChoiceData choice) {
    if (choice.id == 'boss_continue') {
      handleBossContinue();
    }
    // 그 외 boss_* 선택지는 더 이상 생성되지 않음.
  }

  /// 엔딩 화면 표시 — 보스 선택 결과 텍스트 + 엔딩 텍스트 + 재시작 선택지.
  void showEnding(String bossResultText) {
    const endingText = '가장 깊은 곳의 지배자마저 무릎 꿇렸다. 너와 동료들의 유대가 정점에 이르렀다.';

    // RunBloc에 런 완료 이벤트 발행
    runController.runBloc.add(const AdvanceFloor());

    // 메타 데이터 업데이트
    recordRunCompleted('clear');

    // 클리어 소울 보상 계산 (표시용 — 배율 적용)
    final baseSoul = SoulCalculator.calculateClearReward(
      economyConfig.soulBaseGain,
    );
    final soulGained = (baseSoul * soulGainMultiplier).toInt();

    setTextBlockData([
      TextBlockData(text: bossResultText),
      TextBlockData(text: endingText),
      CombatFlowManager.buildRunSummaryBlock(
        runState: runController.playerRunState,
        soulGained: soulGained,
        showSoulHint: GameHintManager.checkAndMark(GameHintManager.hintSoul),
        isVictory: true,
      ),
      TextBlockData(
        text: '이번 여정이 끝났다.',
        choices: [
          const ChoiceData(
            id: 'restart_run',
            text: '새로운 여정을 시작한다',
            resultTextBlocks: [],
          ),
        ],
      ),
    ], endCombat: false, resetMomentum: true);
  }

  /// 보스 상태 리셋 — 비보스 방 진입 시 호출.
  void resetBossState() {
    updateCombatSession(getCombatSession().resetBoss());
  }
}
