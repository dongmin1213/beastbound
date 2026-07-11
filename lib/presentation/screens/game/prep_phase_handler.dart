import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/domain/build/logic/prep_phase.dart';
import 'package:soul_dungeon/domain/build/logic/preset_manager.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';


/// 준비 페이즈 플로우 관리 — 선택지 표시, 프리셋, 보너스 적용.
///
/// GameScreen에서 추출 (Step 4). 3개 메서드를 위임.
class PrepPhaseHandler {
  final GameRunController runController;
  final PresetManager presetManager;
  final PrepConfig prepConfig;

  /// 텍스트 블록 설정 콜백.
  final void Function(
    List<TextBlockData> blocks, {
    bool endCombat,
  }) setTextBlockData;

  /// 준비 페이즈 상태 설정 콜백.
  final void Function(bool inPrepPhase) setInPrepPhase;

  /// DungeonBloc 접근 콜백 (lazy — 런 시작 전에는 null 가능).
  final DungeonBloc? Function() getDungeonBloc;

  /// 층 전환 연출 콜백 — 오버레이 표시 후 onComplete 호출.
  final void Function(int targetFloor, VoidCallback onComplete)?
      showFloorTransition;

  /// mounted 체크.
  final bool Function() isMounted;

  /// 테스트 시 랜덤 시드 주입용.
  final Random? random;

  PrepPhaseHandler({
    required this.runController,
    required this.presetManager,
    required this.prepConfig,
    required this.setTextBlockData,
    required this.setInPrepPhase,
    required this.getDungeonBloc,
    this.showFloorTransition,
    this.random,
    bool Function()? isMounted,
  }) : isMounted = isMounted ?? (() => true);

  // ── 내부 상태 ──────────────────────────────────────────────────────────
  bool _pendingFloorGeneration = false;
  int _pendingSeed = 0;

  /// 준비 페이즈 표시 — 6개 선택지 셔플 + 프리셋 빠른 시작.
  void showPrepPhase() {
    setInPrepPhase(true);
    final allChoices = PrepPhaseData.getChoices(
      startingGoldBonus: prepConfig.startingGoldBonus,
      startingHpBonus: prepConfig.startingHpBonus,
      startingBlessingId: prepConfig.startingBlessingId,
      startingRelicId: prepConfig.startingRelicId,
      mercyHpBonus: prepConfig.mercyHpBonus,
      balancedGold: prepConfig.balancedGold,
      balancedHp: prepConfig.balancedHp,
    );

    // 전체 선택지 셔플 후 3개만 표시
    final choices = (List<PrepChoice>.from(allChoices)..shuffle(random ?? Random()))
        .take(3)
        .toList();

    final choiceDataList = choices
        .map((c) => ChoiceData(
              id: c.id,
              text: '${c.name} — ${c.description}',
              resultTextBlocks: [],
            ))
        .toList();

    // 프리셋 빠른 시작 선택지 추가
    for (final preset in presetManager.presets) {
      choiceDataList.add(ChoiceData(
        id: preset.id,
        text: '⚡ ${preset.name} — 이전 선택 빠른 적용',
        resultTextBlocks: [],
      ));
    }

    setTextBlockData([
      const TextBlockData(text: PrepPhaseData.introText),
      TextBlockData(
        text: PrepPhaseData.choicePromptText,
        choices: choiceDataList,
      ),
    ], endCombat: false);
  }

  /// 준비 페이즈 선택 처리 — 프리셋 or 일반 선택.
  void handlePrepChoice(ChoiceData choice) {
    setInPrepPhase(false);

    // 프리셋 빠른 시작인 경우 — 저장된 선택을 적용
    if (choice.id.startsWith('preset_')) {
      final preset = presetManager.findById(choice.id);
      if (preset != null) {
        applyPrepChoiceById(preset.prepChoiceId);
        return;
      }
    }

    // 일반 준비 페이즈 선택 — 적용 후 프리셋 저장
    applyPrepChoiceById(choice.id);
    presetManager.savePreset(presetManager.createFromLastRun(choice.id));
  }

  /// 선택 ID로 보너스 적용 + 결과 텍스트 표시.
  ///
  /// 던전 생성은 즉시 시작하지 않고, 결과 텍스트를 사용자가 읽은 뒤
  /// [checkPendingFloorGeneration]이 호출될 때 시작한다.
  void applyPrepChoiceById(String prepChoiceId) {
    final prepChoices = PrepPhaseData.getChoices(
      startingGoldBonus: prepConfig.startingGoldBonus,
      startingHpBonus: prepConfig.startingHpBonus,
      startingBlessingId: prepConfig.startingBlessingId,
      startingRelicId: prepConfig.startingRelicId,
      mercyHpBonus: prepConfig.mercyHpBonus,
      balancedGold: prepConfig.balancedGold,
      balancedHp: prepConfig.balancedHp,
    );
    final selected = prepChoices.where((c) => c.id == prepChoiceId).firstOrNull;
    if (selected == null) return;

    String resultText;
    switch (selected.bonusType) {
      case PrepBonusType.gold:
        runController.playerRunState = runController.playerRunState.copyWith(
          gold: runController.playerRunState.gold + selected.bonusValue,
        );
        runController.runBloc.add(GainGold(selected.bonusValue));
        resultText = '${selected.bonusValue} 골드를 챙겼다.';
      case PrepBonusType.hp:
        runController.playerRunState = runController.playerRunState.copyWith(
          maxHp: runController.playerRunState.maxHp + selected.bonusValue,
          currentHp:
              runController.playerRunState.currentHp + selected.bonusValue,
        );
        runController.runBloc.add(ChangeMaxHp(selected.bonusValue));
        resultText = '생명력이 강화되었다. (HP +${selected.bonusValue})';
      case PrepBonusType.blessing:
        final bId = selected.blessingId!;
        runController.playerRunState = runController.playerRunState.copyWith(
          ownedBlessingIds: [
            ...runController.playerRunState.ownedBlessingIds,
            bId,
          ],
        );
        runController.runBloc.add(AcquireBlessing(bId));
        resultText = '축복의 기운이 깃들었다.';
      case PrepBonusType.relic:
        final rId = selected.relicId!;
        runController.playerRunState = runController.playerRunState.copyWith(
          ownedRelicIds: [
            ...runController.playerRunState.ownedRelicIds,
            rId,
          ],
        );
        runController.runBloc.add(AcquireRelic(rId));
        resultText = '고대의 유물이 빛을 발한다.';
      case PrepBonusType.balanced:
        final goldAmount = selected.bonusValue;
        final hpAmount = selected.secondaryValue;
        runController.playerRunState = runController.playerRunState.copyWith(
          gold: runController.playerRunState.gold + goldAmount,
          maxHp: runController.playerRunState.maxHp + hpAmount,
          currentHp: runController.playerRunState.currentHp + hpAmount,
        );
        runController.runBloc.add(GainGold(goldAmount));
        runController.runBloc.add(ChangeMaxHp(hpAmount));
        resultText = '방랑자의 지혜가 깃들었다. (골드 +$goldAmount, HP +$hpAmount)';
    }

    // 결과 표시 — 던전 생성은 결과 텍스트 소진 후 보류
    runController.completedBlocks.add(CompletedBlock(
      text: PrepPhaseData.choicePromptText,
    ));
    runController.completedBlocks.add(CompletedBlock(
      text: '${selected.name} — ${selected.description}',
      isChoice: true,
    ));

    // 첫 런 목표 힌트 — 결과 텍스트 뒤에 자연스럽게 삽입
    final blocks = <TextBlockData>[TextBlockData(text: resultText)];
    GameHintManager.shouldShow(GameHintManager.hintGoal).then((show) {
      if (show && isMounted()) {
        runController.appendFeedbackText(GameHintManager.goalText);
      }
    });

    setTextBlockData(blocks, endCombat: false);

    // 던전 생성을 보류 — 결과 텍스트 소진 후 시작
    _pendingFloorGeneration = true;
    _pendingSeed = DateTime.now().millisecondsSinceEpoch;
  }

  /// 결과 텍스트 소진 후 보류된 던전 생성 시작 — _advanceToNextBlock에서 호출.
  void checkPendingFloorGeneration() {
    if (!_pendingFloorGeneration) return;
    _pendingFloorGeneration = false;
    final seed = _pendingSeed;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) return;
      if (showFloorTransition != null) {
        showFloorTransition!(1, () {
          getDungeonBloc()!.add(GenerateFloor(floor: 1, seed: seed));
        });
      } else {
        getDungeonBloc()!.add(GenerateFloor(floor: 1, seed: seed));
      }
    });
  }
}
