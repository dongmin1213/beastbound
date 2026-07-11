import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/core/models/tier_effect_calculator.dart';
import 'package:soul_dungeon/domain/build/data/blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_relic_pool.dart';
import 'package:soul_dungeon/domain/build/data/curse_pool.dart';
import 'package:soul_dungeon/domain/build/data/relic_pool.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/run/run_bloc.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/boss_flow_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_session_state.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

void main() {
  late GameEventBus gameEventBus;
  late RunBloc runBloc;
  late CombatBloc combatBloc;
  late GameRunController runController;
  late BossFlowHandler handler;

  // 콜백 기록용
  late List<List<TextBlockData>> capturedTextBlocks;
  late List<bool> capturedEndCombat;
  late List<String> capturedEndingNames;

  const combatConfig = CombatBalanceConfig();
  const economyConfig = EconomyConfig();
  const momentumConfig = MomentumConfig();
  final tierEffectCalculator = TierEffectCalculator(config: momentumConfig);

  setUp(() {
    gameEventBus = GameEventBus();
    capturedTextBlocks = [];
    capturedEndCombat = [];
    capturedEndingNames = [];
  });

  tearDown(() {
    combatBloc.close();
    runBloc.close();
    gameEventBus.dispose();
  });

  /// 지정 층에서 BossFlowHandler를 생성하고 bossChoices를 주입.
  void setupHandler({
    required int floor,
    List<BossChoice> existingBossChoices = const [],
  }) {
    final initialState = PlayerRunState.initial(maxHp: 100).copyWith(
      currentFloor: floor,
      bossVictoryPending: true,
      bossChoices: existingBossChoices,
    );

    runBloc = RunBloc(
      initialPlayerState: initialState,
      gameEventBus: gameEventBus,
    );

    runController = GameRunController(
      initialState: initialState,
      runBloc: runBloc,
      gameEventBus: gameEventBus,
      onStateChanged: () {},
      isScrolledUp: () => false,
      scrollToBottom: () {},
    );

    combatBloc = CombatBloc(
      gameEventBus: gameEventBus,
      combatConfig: combatConfig,
      economyConfig: economyConfig,
      tierEffectCalculator: tierEffectCalculator,
      resolveCurseIds: CursePool.resolveCurseIds,
      resolveCardRelicIds: CardRelicPool.resolveIds,
      resolveBlessingIds: BlessingPool.resolveIds,
      resolveCardBlessingIds: CardBlessingPool.resolveIds,
      resolveRelicIds: RelicPool.resolveIds,
    );

    handler = BossFlowHandler(
      combatBloc: combatBloc,
      getCombatSession: () => const CombatSessionState(),
      updateCombatSession: (_) {},
      runController: runController,
      gameEventBus: gameEventBus,
      economyConfig: economyConfig,
      soulGainMultiplier: 1.0,
      setTextBlockData: (blocks, {bool endCombat = false, bool resetMomentum = false}) {
        capturedTextBlocks.add(blocks);
        capturedEndCombat.add(endCombat);
      },
      setInCombat: (_) {},
      getMomentumValue: () => 100,
      recordRunCompleted: (name) => capturedEndingNames.add(name),
      getUnlockedMemoryCount: () => 0,
    );
  }

  group('BossFlowHandler — 5층 보스 버그 수정 검증', () {
    test('10층(최종)에서 handleBossChoice 시 showEnding을 호출한다', () {
      final existingChoices = [
        const BossChoice(floor: 1, bossId: 'boss_ash', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'boss_tide', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 3, bossId: 'boss_thorn', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 4, bossId: 'boss_void', choiceType: BossChoiceType.slay),
      ];
      setupHandler(floor: 10, existingBossChoices: existingChoices);

      handler.handleBossChoice(const ChoiceData(
        id: 'boss_slay',
        text: '처치한다',
        resultTextBlocks: [],
      ));

      // showEnding이 호출되어 엔딩 텍스트 블록이 설정되어야 한다
      expect(capturedTextBlocks, isNotEmpty,
          reason: '5층 보스 선택 후 텍스트 블록이 설정되어야 한다');

      // 마지막 텍스트 블록에 restart_run 선택지가 있어야 한다 (엔딩 화면)
      final lastBlocks = capturedTextBlocks.last;
      final hasRestart = lastBlocks.any((block) =>
          block.choices?.any((c) => c.id == 'restart_run') ?? false);
      expect(hasRestart, isTrue,
          reason: '엔딩 화면에는 restart_run 선택지가 있어야 한다');

      // recordRunCompleted 콜백이 호출되어야 한다
      expect(capturedEndingNames, isNotEmpty,
          reason: '런 완료 기록이 남아야 한다');
    });

    test('1~4층에서는 advance_floor 선택지가 표시된다 (showEnding 아님)', () {
      setupHandler(floor: 3);

      handler.handleBossChoice(const ChoiceData(
        id: 'boss_slay',
        text: '처치한다',
        resultTextBlocks: [],
      ));

      expect(capturedTextBlocks, isNotEmpty);
      final lastBlocks = capturedTextBlocks.last;

      // advance_floor 선택지가 있어야 한다
      final hasAdvance = lastBlocks.any((block) =>
          block.choices?.any((c) => c.id == 'advance_floor') ?? false);
      expect(hasAdvance, isTrue,
          reason: '1~4층에서는 advance_floor 선택지가 표시되어야 한다');

      // restart_run은 없어야 한다
      final hasRestart = lastBlocks.any((block) =>
          block.choices?.any((c) => c.id == 'restart_run') ?? false);
      expect(hasRestart, isFalse,
          reason: '1~4층에서는 restart_run 선택지가 없어야 한다');

      // recordRunCompleted 콜백이 호출되지 않아야 한다
      expect(capturedEndingNames, isEmpty,
          reason: '1~4층에서는 런 완료 기록이 없어야 한다');
    });

    test('잠금 선택지(_locked)는 무시된다', () {
      setupHandler(floor: 5);

      handler.handleBossChoice(const ChoiceData(
        id: 'boss_slay_locked',
        text: '처치한다 (잠금)',
        resultTextBlocks: [],
      ));

      // 아무 텍스트 블록도 설정되지 않아야 한다
      expect(capturedTextBlocks, isEmpty,
          reason: '잠금 선택지는 무시되어야 한다');
    });
  });
}
