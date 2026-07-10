import 'package:flutter/foundation.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_event.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_result_generator.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_state.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/presentation/screens/game/room_context.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

class MysteryRoomHandler {
  final RoomContext _ctx;
  final MysteryConfig mysteryConfig;
  final EconomyConfig economyConfig;
  final double soulGainMultiplier;

  MysteryBloc? _mysteryBloc;
  bool _showingMystery = false;

  /// relic_011 모험가의 지도: 2개 결과 중 선택 대기.
  bool _pendingMysteryChoice = false;
  final Map<String, MysteryOutcome> _mysteryChoices = {};

  MysteryBloc? get bloc => _mysteryBloc;
  bool get isShowing => _showingMystery;
  bool get hasPendingMysteryChoice => _pendingMysteryChoice;

  MysteryRoomHandler({
    required RoomContext context,
    required this.mysteryConfig,
    this.economyConfig = const EconomyConfig(),
    this.soulGainMultiplier = 1.0,
  }) : _ctx = context;

  void enter(DungeonRoomEntered dState) {
    final floorNumber = dState.floorMap.floorNumber;
    final seed = dState.currentNodeId.hashCode;

    // relic_011 모험가의 지도: 2개 결과 중 선택
    final hasMap = _ctx.runController.playerRunState.ownedRelicIds
        .contains('relic_011');

    if (hasMap) {
      _enterWithChoice(floorNumber, seed);
      return;
    }

    _ctx.setTextBlockData([
      const TextBlockData(
        text: '어둠 속에서 무언가의 기운이 느껴진다...',
      ),
    ]);

    final outcome = MysteryResultGenerator.generate(
      floor: floorNumber,
      mysteryConfig: mysteryConfig,
      seed: seed,
    );

    _mysteryBloc?.close();
    _mysteryBloc = MysteryBloc(gameEventBus: _ctx.runController.gameEventBus);
    _mysteryBloc!.add(RevealMystery(outcome));

    _showingMystery = true;
    _ctx.notifyStateChanged();

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'Mystery entered: ${outcome.runtimeType}, gold=${_ctx.runController.playerRunState.gold}');
    }
  }

  /// relic_011 모험가의 지도: 2개 결과 생성 → 선택지 표시.
  void _enterWithChoice(int floor, int seed) {
    final outcome1 = MysteryResultGenerator.generate(
      floor: floor,
      mysteryConfig: mysteryConfig,
      seed: seed,
    );
    final outcome2 = MysteryResultGenerator.generate(
      floor: floor,
      mysteryConfig: mysteryConfig,
      seed: seed + 7919, // 다른 시드로 2번째 결과 생성
    );

    _mysteryChoices.clear();
    _mysteryChoices['mystery_choice_0'] = outcome1;
    _mysteryChoices['mystery_choice_1'] = outcome2;
    _pendingMysteryChoice = true;

    final desc1 = _outcomeChoiceText(outcome1);
    final desc2 = _outcomeChoiceText(outcome2);

    _ctx.setTextBlockData([
      const TextBlockData(
        text: '모험가의 지도가 빛을 발한다. 앞에 두 갈래 길이 보인다...',
      ),
      TextBlockData(
        text: '',
        choices: [
          ChoiceData(
            id: 'mystery_choice_0',
            text: desc1,
            resultTextBlocks: const [],
          ),
          ChoiceData(
            id: 'mystery_choice_1',
            text: desc2,
            resultTextBlocks: const [],
          ),
        ],
      ),
    ]);

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'Mystery choice: ${outcome1.runtimeType} vs ${outcome2.runtimeType}');
    }
  }

  /// 결과를 선택지 텍스트로 변환.
  String _outcomeChoiceText(MysteryOutcome outcome) {
    final label = switch (outcome) {
      TreasureOutcome() => '보물의 기운',
      TrapOutcome() => '위험한 기운',
      EncounterOutcome() => '전투의 기운',
      EventOutcome() => '신비한 기운',
      MinorOutcome() => '희미한 기운',
    };
    final effect = <String>[];
    if (outcome.goldChange > 0) effect.add('+${outcome.goldChange}G');
    if (outcome.hpChange < 0) effect.add('${outcome.hpChange}HP');
    return effect.isEmpty ? label : '$label (${effect.join(', ')})';
  }

  /// relic_011 선택 처리. 반환값: 처리 여부.
  bool handleMysteryChoice(ChoiceData choice) {
    if (!_pendingMysteryChoice) return false;
    final outcome = _mysteryChoices[choice.id];
    if (outcome == null) return false;

    _pendingMysteryChoice = false;
    _mysteryChoices.clear();

    // MysteryBloc을 통해 정상 플로우로 처리
    _mysteryBloc?.close();
    _mysteryBloc = MysteryBloc(gameEventBus: _ctx.runController.gameEventBus);
    _mysteryBloc!.add(RevealMystery(outcome));

    _showingMystery = true;
    _ctx.notifyStateChanged();

    return true;
  }

  void onCompleted(MysteryCompleted state) {
    final outcome = state.outcome;
    final rc = _ctx.runController;

    // 골드 변화
    if (outcome.goldChange > 0) {
      rc.playerRunState = rc.playerRunState.copyWith(
        gold: rc.playerRunState.gold + outcome.goldChange,
      );
      rc.runBloc.add(GainGold(outcome.goldChange));
    }

    // HP 변화
    if (outcome.hpChange < 0) {
      final newHp = rc.playerRunState.currentHp + outcome.hpChange;
      rc.playerRunState = rc.playerRunState.copyWith(
        currentHp: newHp < 0 ? 0 : newHp,
      );
      rc.runBloc.add(ChangeHp(outcome.hpChange));
    }

    _showingMystery = false;
    _ctx.notifyStateChanged();

    // side effect
    if (outcome.goldChange > 0) {
      rc.gameEventBus.emit(GoldGainedEvent(
        amount: outcome.goldChange,
        totalGold: rc.playerRunState.gold,
      ));
    }

    // HP ≤ 0 → permadeath 처리
    if (rc.playerRunState.currentHp <= 0) {
      final baseSoul = SoulCalculator.calculateDeathReward(
        rc.playerRunState.currentFloor,
        economyConfig.soulBaseGain,
      );
      final soulGained = (baseSoul * soulGainMultiplier).toInt();
      _ctx.setTextBlockData([
        TextBlockData(
          text: '${-outcome.hpChange} HP 손실! 치명적인 함정에 의해 쓰러졌다...',
        ),
        const TextBlockData(
          text: '어둠이 밀려온다... 의식이 점점 흐려진다.',
        ),
        CombatFlowManager.buildRunSummaryBlock(
          runState: rc.playerRunState,
          soulGained: soulGained,
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
      ]);
      _mysteryBloc?.close();
      _mysteryBloc = null;
      return;
    }

    // 피드백 텍스트 — permadeath가 아닌 경우만
    if (outcome.goldChange > 0) {
      rc.appendFeedbackText('${outcome.goldChange} 골드 획득!');
    }
    if (outcome.hpChange < 0) {
      rc.appendFeedbackText('${-outcome.hpChange} HP 손실!');
    }

    _mysteryBloc?.close();
    _mysteryBloc = null;
    _ctx.getDungeonBloc()?.add(const CompleteRoom());
  }

  void enterForTest(MysteryOutcome outcome, {int? withGold, int? withHp}) {
    final rc = _ctx.runController;
    if (withGold != null) {
      rc.playerRunState = rc.playerRunState.copyWith(gold: withGold);
    }
    if (withHp != null) {
      rc.playerRunState = rc.playerRunState.copyWith(currentHp: withHp);
    }
    rc.syncToRunBloc();
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '어둠 속에서 무언가의 기운이 느껴진다...',
      ),
    ]);
    _mysteryBloc?.close();
    _mysteryBloc = MysteryBloc(gameEventBus: rc.gameEventBus);
    _mysteryBloc!.add(RevealMystery(outcome));
    _showingMystery = true;
    _ctx.notifyStateChanged();
  }

  void dispose() {
    _mysteryBloc?.close();
  }
}
