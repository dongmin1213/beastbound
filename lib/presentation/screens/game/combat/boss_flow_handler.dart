import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/core/events/boss_choice_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/narrative/content/boss_text_variants.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/boss_choice_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_session_state.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/boss_encounter_factory.dart';
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

  /// 보스 승리 → 3선택지 (처치/해방/공존) 표시.
  void handleVictoryFloorTransition() {
    final floor = runController.playerRunState.currentFloor;
    final bossId = BossEncounterFactory.bossId(floor);
    runController.appendFeedbackText('$floor층 보스 처치 완료!');
    setInCombat(false);
    combatBloc.add(const EndCombat());

    // 보스 보상 선택 대기 상태 저장 — 이어하기 시 보상 화면 복원용
    runController.playerRunState = runController.playerRunState.copyWith(
      bossVictoryPending: true,
    );

    final momentum = getMomentumValue();
    final choices = BossChoiceHandler.buildChoices(
      floor: floor,
      bossId: bossId,
      momentum: momentum,
    );

    setTextBlockData([
      TextBlockData(
        text: '보스가 쓰러졌다. 이제 선택할 때다.\n'
            '이 존재를 어떻게 하겠는가?',
        choices: choices,
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

  /// 보스 3선택지 처리 — 처치/해방/공존 + 성향 변경 + 기록 + 층 전환.
  void handleBossChoice(ChoiceData choice) {
    // 잠금 선택지 무시
    if (choice.id.endsWith('_locked')) return;

    // boss_continue는 페이즈 전환
    if (choice.id == 'boss_continue') {
      handleBossContinue();
      return;
    }

    final choiceType = BossChoiceHandler.choiceTypeFromId(choice.id);
    if (choiceType == null) return;

    // 보스 보상 선택 완료 — pending 상태 해제
    runController.playerRunState = runController.playerRunState.copyWith(
      bossVictoryPending: false,
    );

    final floor = runController.playerRunState.currentFloor;
    final bossId = BossEncounterFactory.bossId(floor);
    final playerJobId = runController.playerRunState.currentJobId;

    // 보스 선택 기록
    runController.runBloc.add(RecordBossChoice(BossChoice(
      floor: floor,
      bossId: bossId,
      choiceType: choiceType,
    )));

    // BossChoiceEvent 브로드캐스트 (크로스 시스템 반응용)
    gameEventBus.emit(BossChoiceEvent(
      floor: floor,
      bossId: bossId,
      choiceType: choiceType.name,
      playerJobId: playerJobId,
    ));

    // 성향 변경 (해당 축 +3)
    // 최종 층(5층)에서는 applyDisposition 스킵 — 엔딩 처리 중 전직 평가가
    // 트리거되면 엔딩 텍스트가 전직 선택 UI로 교체되어 게임 진행 불가 버그 발생.
    // 엔딩 결정은 bossChoices 기반이므로 성향값 갱신 불필요.
    if (floor < 5) {
      runController.applyDisposition({
        choiceType.dispositionAxis: BossChoiceHandler.dispositionDelta,
      });
    }

    // 결과 텍스트 — 보스/직업별 변형 적용
    final resultText = BossTextVariants.choiceResultText(
      bossId,
      choiceType,
      jobId: playerJobId,
    );

    if (floor >= 5) {
      // 최종 층 클리어 — 던전 정복.
      showEnding(resultText);
    } else {
      setTextBlockData([
        TextBlockData(
          text: '$resultText\n\n'
              '$floor층을 클리어했다. 더 깊은 곳으로 향하는 계단이 나타난다.',
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
  }

  /// 엔딩 화면 표시 — 보스 선택 결과 텍스트 + 엔딩 텍스트 + 재시작 선택지.
  void showEnding(String bossResultText) {
    const endingText = '던전을 정복했다. 너와 동료들의 여정이 정점에 이르렀다.';

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
        text: '던전의 여정이 끝났다.',
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
