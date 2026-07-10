import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SelectAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_tutorial_modal.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/tamed_monster_store.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/core/events/job_unlock_event.dart';
import 'package:soul_dungeon/core/events/momentum_gain_event.dart';
import 'package:soul_dungeon/core/input/game_input_mapper.dart';
import 'package:soul_dungeon/core/input/input_context.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/config/floor_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/combat/logic/curse_modifier_resolver.dart';
import 'package:soul_dungeon/core/models/curse_modifier_pool.dart';
import 'package:soul_dungeon/domain/combat/logic/starting_deck_builder.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_encounter_data.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/domain/run/run_bloc.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/core/models/tier_effect_calculator.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_upgrade_pool.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_list_widget.dart';
import 'package:soul_dungeon/domain/combat/logic/status_effect_processor.dart';
import 'package:soul_dungeon/domain/combat/models/boss_phase_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/boss_demo_encounter.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/card_combat_view.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/player_status_bar.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/hp_display_widget.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_gauge_widget.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_button.dart';
import 'package:soul_dungeon/presentation/widgets/minimap/minimap_widget.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_state.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_state.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_state.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_state.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_state.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/completed_block_renderer.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/screens/game/room_context.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/shop_room_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/mystery_room_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/npc_room_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/rest_room_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_action_processor.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_outcome_resolver.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_session_state.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/event_room_handler.dart';
import 'package:soul_dungeon/domain/build/bloc/build_bloc.dart';
import 'package:soul_dungeon/core/models/devil_deal_data.dart';
import 'package:soul_dungeon/domain/build/logic/preset_manager.dart';
import 'package:soul_dungeon/core/save/save_manager.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_event.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_state.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/combat/save/combat_state_serializer.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_enemy_generator.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reward_resolver.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/boss_flow_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/card_combat_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/dungeon_navigation_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/ghost/ghost_interaction_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/choice_router.dart';
import 'package:soul_dungeon/presentation/screens/game/prep_phase_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen_actions.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/bloc_listener_stack.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/current_block_renderer.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/room_widget_builder.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/build/data/blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/card_relic_pool.dart';
import 'package:soul_dungeon/domain/build/data/curse_pool.dart';
import 'package:soul_dungeon/domain/build/data/relic_pool.dart';
import 'package:soul_dungeon/core/models/curse_data.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/status_screen_widget.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/widgets/effects/ambient_particle_overlay.dart';
import 'package:soul_dungeon/presentation/widgets/effects/combat_effect_overlay.dart';
import 'package:soul_dungeon/presentation/widgets/effects/continue_loading_overlay.dart';
import 'package:soul_dungeon/presentation/widgets/effects/floor_transition_overlay.dart';
import 'package:soul_dungeon/audio/bloc/audio_bloc.dart';
import 'package:soul_dungeon/presentation/widgets/effects/vignette_overlay.dart';
import 'package:soul_dungeon/presentation/screens/game/debug_cheat_panel.dart';

part 'game_screen_test_api.dart';

class GameScreen extends StatefulWidget {
  final List<String>? initialBlocks;
  final List<TextBlockData>? initialBlockData;
  final GameInputMapper? inputMapper;
  final int charsPerSecondSlow;
  final int charsPerSecondNormal;
  final int charsPerSecondFast;
  final TextSpeed speed;
  final MomentumConfig momentumConfig;
  final CombatBalanceConfig combatConfig;
  final EconomyConfig economyConfig;
  final GameEventBus? gameEventBus;
  final CombatEncounter? initialEncounter;
  final DungeonGenerator? dungeonGenerator;
  final DungeonBalanceConfig dungeonConfig;
  final MysteryConfig mysteryConfig;
  final NpcConfig npcConfig;
  final RestConfig restConfig;
  final EventConfig eventConfig;
  final DispositionConfig dispositionConfig;
  final BuildConfig buildConfig;
  final PrepConfig prepConfig;
  final RarityConfig rarityConfig;
  final SaveManager? saveManager;
  final NarratorBloc? narratorBloc;
  final MetaSaveData? initialMeta;
  final AudioConfig audioConfig;
  final FleeConfig fleeConfig;
  final CardCombatBalanceConfig cardCombatConfig;
  final ChainBonusConfig chainBonusConfig;
  final FloorsConfig floorsConfig;
  final PlayerRunState? initialRunState;
  final Map<String, dynamic>? initialCombatStateRaw;
  final VoidCallback? onRunDeleted;

  /// 스타터 몬스터 id (신규 컨셉) — 지정 시 시작 덱을 이 몬스터의 무브풀로 구성하고
  /// 직업 분화(성향 기반)를 비활성화한다. null이면 기존 무직업 흐름.
  final String? starterMonsterId;

  const GameScreen({
    super.key,
    this.initialBlocks,
    this.initialBlockData,
    this.inputMapper,
    this.charsPerSecondSlow = 20,
    this.charsPerSecondNormal = 40,
    this.charsPerSecondFast = 80,
    this.speed = TextSpeed.normal,
    this.momentumConfig = const MomentumConfig(),
    this.combatConfig = const CombatBalanceConfig(),
    this.economyConfig = const EconomyConfig(),
    this.gameEventBus,
    this.initialEncounter,
    this.dungeonGenerator,
    this.dungeonConfig = const DungeonBalanceConfig(),
    this.mysteryConfig = const MysteryConfig(),
    this.npcConfig = const NpcConfig(),
    this.restConfig = const RestConfig(),
    this.eventConfig = const EventConfig(),
    this.dispositionConfig = const DispositionConfig(),
    this.buildConfig = const BuildConfig(),
    this.prepConfig = const PrepConfig(),
    this.rarityConfig = const RarityConfig(),
    this.saveManager,
    this.narratorBloc,
    this.initialMeta,
    this.audioConfig = const AudioConfig(),
    this.fleeConfig = const FleeConfig(),
    this.cardCombatConfig = const CardCombatBalanceConfig(),
    this.chainBonusConfig = const ChainBonusConfig(),
    this.floorsConfig = const FloorsConfig([]),
    this.initialRunState,
    this.initialCombatStateRaw,
    this.onRunDeleted,
    this.starterMonsterId,
  });

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver
    implements GameScreenActions {
  // ════════════════════════════════════════════════════════════════════════
  // SECTION: Instance Variables
  // ════════════════════════════════════════════════════════════════════════
  late final GameInputMapper _inputMapper;
  final ScrollController _scrollController = ScrollController();

  // 반응형 스케일링 캐시 (didChangeDependencies에서 갱신)
  late EdgeInsets _cachedScreenPadding;
  late double _cachedBlockSpacing;
  late double _cachedSmallSpacing;

  late final ChoiceRouter _choiceRouter;
  late final GameRunController _runController;
  int _currentBlockIndex = 0;
  bool _currentBlockComplete = false;
  bool _userScrolledUp = false;
  bool _showingChoices = false;
  bool _choiceSelected = false;

  /// 디버그 갓 모드 (kDebugMode only).
  bool _debugGodMode = false;

  late List<TextBlockData> _textBlockDataList;

  final GlobalKey<TypewriterWidgetState> _typewriterKey = GlobalKey();

  // 전투 세션 상태 (encounter, boss, phaseIndex) — immutable
  CombatSessionState _combatSession = const CombatSessionState();

  // 전투 행동 처리기 + 결과 판정기
  late final CombatActionProcessor _actionProcessor;
  late final CombatOutcomeResolver _outcomeResolver;

  // 보스 플로우 핸들러 (Step 3 추출)
  late final BossFlowHandler _bossFlowHandler;
  // 카드 전투 핸들러 (Step 6b 추출)
  late final CardCombatHandler _cardCombatHandler;
  // 던전 탐색 핸들러 (Step 6d 추출)
  late final DungeonNavigationHandler _dungeonNavHandler;
  late final PrepPhaseHandler _prepPhaseHandler;

  // 유령 NPC 상호작용 핸들러
  GhostInteractionHandler? _ghostInteractionHandler;

  // 전투 중 게이지 표시 (UI 상태 — presentation 소유)
  bool _inCombat = false;

  // 카드 전투 모드 여부
  bool _inCardCombat = false;

  /// 카드 보상 선택 단계인지 여부.
  bool get _isCardRewardPhase {
    if (!_inCardCombat || !_showingChoices) return false;
    final choices = _currentChoices;
    if (choices == null) return false;
    return choices.any((c) => c.id.startsWith('card_reward_') || c.id == 'skip_reward');
  }

  // autoSave 동시 실행 방지
  bool _autoSaving = false;

  // 카드 핸드 선택지 캐싱 — 깜빡임 방지
  List<ChoiceData>? _cachedCardHandChoices;
  int _lastHandCacheKey = 0;
  int _lastCachedAp = -1;
  int _lastCachedStr = -1;
  int _lastCachedDex = -1;
  bool _lastCachedWeak = false;
  bool _lastCachedVuln = false;

  // 전투 승리 결과 대기 — 결과 블록 탭 후 방 전환
  bool _pendingCombatVictory = false;

  // 티어 효과 계산기 (기세 단계 × 행동 결과 → 티어 적용 결과)
  late final TierEffectCalculator _tierEffectCalculator;

  // CombatBloc (전투 로직 소유)
  late final CombatBloc _combatBloc;

  // BuildBloc (직업 분화)
  late final BuildBloc _buildBloc;

  // NarratorBloc (서술자 신뢰도) — app.dart에서 주입 또는 initState에서 생성
  NarratorBloc? _narratorBloc;

  // MetaSaveData (런 간 영구 기록)
  // MetaSaveData는 ProgressionBloc이 관리 — widget.initialMeta로 초기화됨

  // DungeonBloc (던전 탐색/내비게이션)
  DungeonBloc? _dungeonBloc;

  // Room Handlers (5종)
  late final RoomContext _roomContext;
  late final ShopRoomHandler _shopHandler;
  late final MysteryRoomHandler _mysteryHandler;
  late final NpcRoomHandler _npcHandler;
  late final RestRoomHandler _restHandler;
  late final EventRoomHandler _eventHandler;

  // 준비 페이즈 상태
  bool _inPrepPhase = false;
  // 이어하기 로딩 오버레이
  bool _showContinueLoading = false;
  bool _continueLoadingReady = false;
  // 미니맵 모달 중복 오픈 방지
  bool _minimapDialogOpen = false;
  final PresetManager _presetManager = PresetManager();

  // 히든 직업 해금 구독
  StreamSubscription<JobUnlockEvent>? _jobUnlockSub;

  // GameEventBus 참조 (convenience accessor)
  GameEventBus get _gameEventBus => _runController.gameEventBus;

  // 현재 층의 비주얼 테마
  FloorThemeVisuals get _currentFloorVisuals =>
      FloorThemeVisuals.fromFloor(_runController.playerRunState.currentFloor);

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: Lifecycle (initState / didChangeDependencies / dispose)
  // ════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _inputMapper = widget.inputMapper ?? GameInputMapper();
    _choiceRouter = ChoiceRouter(actions: this);
    _tierEffectCalculator = TierEffectCalculator(config: widget.momentumConfig);

    final isContinue = widget.initialRunState != null;
    var initialPlayerState = widget.initialRunState ??
        PlayerRunState.initial(maxHp: widget.combatConfig.basePlayerHp);

    // 새 게임에서만 시작 보너스/덱/저주 적용 — 이어하기 시 이미 저장된 값 사용
    if (!isContinue) {
      // 소울 업그레이드 시작 보너스 적용 (HP, 골드, 모멘텀)
      if (widget.initialMeta != null) {
        final bonuses = SoulUpgradePool.startingBonuses(
            widget.initialMeta!.upgradeLevels);
        if (bonuses.hpBonus > 0 || bonuses.goldBonus > 0 || bonuses.momentumBonus > 0) {
          initialPlayerState = initialPlayerState.copyWith(
            maxHp: initialPlayerState.maxHp + bonuses.hpBonus,
            currentHp: initialPlayerState.currentHp + bonuses.hpBonus,
            gold: initialPlayerState.gold + bonuses.goldBonus,
            tempMomentumBonus: initialPlayerState.tempMomentumBonus + bonuses.momentumBonus,
          );
        }
      }

      // 시작 덱 초기화. 스타터 몬스터가 지정되면 그 몬스터의 무브풀로,
      // 아니면 공통 시작 카드(무직업)로.
      if (initialPlayerState.masterDeck.isEmpty) {
        final purchasedIds =
            widget.initialMeta?.purchasedUpgradeIds ?? const <String>{};
        final starterId = widget.starterMonsterId;
        initialPlayerState = initialPlayerState.copyWith(
          masterDeck: starterId != null
              ? StartingDeckBuilder.buildFromMonster(
                  starterId,
                  purchasedUpgradeIds: purchasedIds,
                )
              : StartingDeckBuilder.buildCommon(
                  purchasedUpgradeIds: purchasedIds,
                ),
        );
        // 스타터 몬스터는 동료 — 도감에 자동 포획 등록.
        if (starterId != null) {
          TamedMonsterStore.markTamed(starterId);
        }
      }

      // E9 저주 런타임 연동 — 클리어 횟수 기반 저주 모디파이어 적용
      if (initialPlayerState.activeCurseIds.isEmpty) {
        final clearCount = widget.initialMeta?.clearCount ?? 0;
        final curseIds = CurseModifierResolver.generateCurseIds(clearCount);
        if (curseIds.isNotEmpty) {
          initialPlayerState = initialPlayerState.copyWith(
            activeCurseIds: curseIds,
          );
        }
      }
    }

    final gameEventBus = widget.gameEventBus ?? GameEventBus();

    _runController = GameRunController(
      initialState: initialPlayerState,
      runBloc: RunBloc(initialPlayerState: initialPlayerState, gameEventBus: gameEventBus),
      gameEventBus: gameEventBus,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      isScrolledUp: () => _userScrolledUp,
      scrollToBottom: _scrollToBottom,
    );

    // BuildBloc 초기화 (RunBloc과 동일 수명 주기)
    _buildBloc = BuildBloc(
      config: widget.buildConfig,
      gameEventBus: gameEventBus,
      unlockedHiddenJobIds: widget.initialMeta?.unlockedHiddenJobIds ?? const {},
    );
    _buildBloc.add(InitializeBuild(
      currentJobId: initialPlayerState.currentJobId,
    ));

    _combatSession = _combatSession.copyWith(currentEncounter: widget.initialEncounter);
    _textBlockDataList = _resolveInitialBlocks();
    _scrollController.addListener(_onScroll);

    // RoomContext + Room Handlers 초기화
    _roomContext = RoomContext(
      runController: _runController,
      setTextBlockData: setTextBlockData,
      notifyStateChanged: () {
        if (mounted) setState(() {});
      },
      getDungeonBloc: () => _dungeonBloc,
      getUserScrolledUp: () => _userScrolledUp,
      scrollToBottom: _scrollToBottom,
    );
    _shopHandler = ShopRoomHandler(
      context: _roomContext,
      economyConfig: widget.economyConfig,
      rarityConfig: widget.rarityConfig,
      shopDiscountRate: widget.initialMeta != null
          ? SoulUpgradePool.shopDiscountRate(widget.initialMeta!.upgradeLevels)
          : 0.0,
      hasFreeCardRemoval: widget.initialMeta != null
          ? SoulUpgradePool.hasFreeCardRemoval(widget.initialMeta!.upgradeLevels)
          : false,
    );
    final soulGainMult = widget.initialMeta != null
        ? SoulUpgradePool.soulGainMultiplier(widget.initialMeta!.upgradeLevels)
        : 1.0;
    _mysteryHandler = MysteryRoomHandler(
      context: _roomContext,
      mysteryConfig: widget.mysteryConfig,
      economyConfig: widget.economyConfig,
      soulGainMultiplier: soulGainMult,
    );
    // Ghost Interaction Handler 초기화 (NpcRoomHandler에 주입).
    _ghostInteractionHandler = GhostInteractionHandler(
      gameEventBus: _gameEventBus,
      setTextBlockData: setTextBlockData,
    );
    _npcHandler = NpcRoomHandler(
      context: _roomContext,
      npcConfig: widget.npcConfig,
      economyConfig: widget.economyConfig,
      ghostPool: _initialGhostPool(),
      currentRunNumber: _currentRunNumber(),
      ghostInteractionHandler: _ghostInteractionHandler,
    );
    _restHandler = RestRoomHandler(
      context: _roomContext,
      restConfig: widget.restConfig,
      bonusHealRate: widget.initialMeta != null
          ? SoulUpgradePool.restHealBonusRate(widget.initialMeta!.upgradeLevels)
          : 0.0,
    );
    _eventHandler = EventRoomHandler(
      context: _roomContext,
      eventConfig: widget.eventConfig,
      dispositionConfig: widget.dispositionConfig,
      economyConfig: widget.economyConfig,
      soulGainMultiplier: soulGainMult,
    );

    // CombatBloc 초기화
    _combatBloc = CombatBloc(
      gameEventBus: _gameEventBus,
      combatConfig: widget.combatConfig,
      economyConfig: widget.economyConfig,
      tierEffectCalculator: _tierEffectCalculator,
      fleeConfig: widget.fleeConfig,
      chainBonusConfig: widget.chainBonusConfig,
      floorsConfig: widget.floorsConfig,
      resolveCurseIds: CursePool.resolveCurseIds,
      resolveCardRelicIds: CardRelicPool.resolveIds,
      resolveBlessingIds: BlessingPool.resolveIds,
      resolveCardBlessingIds: CardBlessingPool.resolveIds,
      resolveRelicIds: RelicPool.resolveIds,
      windAmuletRelicId: CardRelicPool.windAmulet.id,
      unlockedCardIds: widget.initialMeta?.unlockedCardIds ?? const {},
      eliteRewardMultiplier: widget.initialMeta != null
          ? SoulUpgradePool.eliteRewardMultiplier(widget.initialMeta!.upgradeLevels)
          : 1.0,
      momentumConfig: widget.momentumConfig,
    );

    // Combat Processor + Resolver 초기화
    _actionProcessor = CombatActionProcessor(combatBloc: _combatBloc);
    _outcomeResolver = CombatOutcomeResolver(
      combatBloc: _combatBloc,
      runController: _runController,
      getSessionState: () => _combatSession,
      economyConfig: widget.economyConfig,
      soulGainMultiplier: soulGainMult,
    );

    // Boss Flow Handler 초기화 (Step 3)
    _bossFlowHandler = BossFlowHandler(
      combatBloc: _combatBloc,
      getCombatSession: () => _combatSession,
      updateCombatSession: (s) => _combatSession = s,
      runController: _runController,
      gameEventBus: _gameEventBus,
      economyConfig: widget.economyConfig,
      soulGainMultiplier: soulGainMult,
      setTextBlockData: setTextBlockData,
      setInCombat: (inCombat) {
        if (mounted) setState(() => _inCombat = inCombat);
      },
      getMomentumValue: () {
        final momentumState = context.read<MomentumBloc>().state;
        return momentumState is MomentumUpdated ? momentumState.value : 0;
      },
      recordRunCompleted: _recordRunCompleted,
      getUnlockedMemoryCount: () => _getUnlockedMemoryIds().length,
    );

    // Card Combat Handler 초기화 (Step 6b)
    _cardCombatHandler = CardCombatHandler(
      combatBloc: _combatBloc,
      runController: _runController,
      bossFlowHandler: _bossFlowHandler,
      setTextBlockData: setTextBlockData,
      updateUI: _updateUI,
      getMomentumTier: _momentumTierInt,
      getCurrentMomentum: _currentMomentumValue,
      applyMomentumBonus: (int bonus) {
        final bloc = context.read<MomentumBloc>();
        bloc.add(RestoreMomentum(
          value: (bloc.config.initialValue + bonus)
              .clamp(bloc.config.min, bloc.config.max),
          consecutiveCount: 0,
        ));
      },
      notifyCardPlayed: (cardType) =>
          context.read<MomentumBloc>().add(CardPlayed(cardType)),
      scrollToBottom: _scrollToBottom,
      isUserScrolledUp: () => _userScrolledUp,
      completeDungeonRoom: completeDungeonRoom,
      isMounted: () => mounted,
      getCombatSession: () => _combatSession,
      updateCombatSession: (s) => _combatSession = s,
      purchasedUpgradeIds: widget.initialMeta?.purchasedUpgradeIds ?? const {},
      cardCombatConfig: widget.cardCombatConfig,
      showTutorialModal: _showTutorialIfNeeded,
      fleeApCost: widget.fleeConfig.apCost,
    );

    // Dungeon Navigation Handler 초기화 (Step 6d)
    _dungeonNavHandler = DungeonNavigationHandler(
      runController: _runController,
      bossFlowHandler: _bossFlowHandler,
      combatBloc: _combatBloc,
      buildBloc: _buildBloc,
      gameEventBus: _gameEventBus,
      setTextBlockData: setTextBlockData,
      updateUI: _updateUI,
      startCardCombat: ({required enemies, required roomType}) async =>
          await _cardCombatHandler.startCombat(enemies: enemies, roomType: roomType),
      startCardBossCombat: (floor, {bossOverride}) async =>
          await _cardCombatHandler.startBossCombat(floor, bossOverride: bossOverride),
      dispatchRoomEntry: (type, state) {
        switch (type) {
          case RoomType.shop:
            _shopHandler.enter(state);
          case RoomType.mystery:
            _mysteryHandler.enter(state);
          case RoomType.npc:
            _npcHandler.enter(state);
          case RoomType.rest:
            _restHandler.enter(state);
          case RoomType.event:
            _eventHandler.enter(state);
          default:
            break;
        }
      },
      resetEventHandler: () => _eventHandler.reset(),
      getDungeonBloc: () => _dungeonBloc,
      getCombatSession: () => _combatSession,
      updateCombatSession: (s) => _combatSession = s,
      dispositionConfig: widget.dispositionConfig,
      wandererMaxDeviation: widget.buildConfig.wandererMaxDeviation,
      combatConfig: widget.combatConfig,
      floorsConfig: widget.floorsConfig,
      purchasedUpgradeIds: widget.initialMeta?.purchasedUpgradeIds ?? const {},
      autoSave: _autoSave,
      isMounted: () => mounted,
      allBlocksRead: () => _currentBlockIndex >= _textBlockDataList.length,
      showFloorTransition: _showFloorTransition,
    );

    // 성향 변화 → 전직 체크 자동 연결 (다음 프레임으로 지연 — 현재 텍스트 처리 완료 후).
    // 스타터 몬스터 모드에서는 직업 분화를 비활성화한다(직업 개념 폐기).
    if (widget.starterMonsterId == null) {
      _runController.onDispositionChanged = () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _dungeonNavHandler.checkClassChange();
        });
      };
    }

    // 세이브 로드 시 전직 재평가 — 성향이 임계치 이상인데 직업 미분화인 경우 보정
    if (widget.starterMonsterId == null &&
        initialPlayerState.currentJobId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dungeonNavHandler.checkClassChange();
      });
    }

    // Prep Phase Handler 초기화 (Step 4)
    _prepPhaseHandler = PrepPhaseHandler(
      runController: _runController,
      presetManager: _presetManager,
      prepConfig: widget.prepConfig,
      setTextBlockData: (blocks, {bool endCombat = false}) {
        setTextBlockData(blocks, endCombat: endCombat);
      },
      setInPrepPhase: (inPrepPhase) {
        if (mounted) setState(() => _inPrepPhase = inPrepPhase);
      },
      getDungeonBloc: () => _dungeonBloc,
      showFloorTransition: _showFloorTransition,
      isMounted: () => mounted,
    );

    // Ghost Interaction Handler — NpcRoomHandler에 주입됨.
    // 초기화는 NpcRoomHandler 생성 이전에 완료 (initState 초반).

    // CombatRewardEvent 구독
    _runController.initRewardSubscription(() => mounted);

    // 히든 직업 해금 이벤트 구독
    _jobUnlockSub = _gameEventBus.on<JobUnlockEvent>().listen((event) {
      if (mounted) {
        _showJobUnlockNotification(event.displayName);
        // BuildBloc에 해금 정보 갱신
        final progressionState = context.read<ProgressionBloc>().state;
        if (progressionState is ProgressionLoaded) {
          _buildBloc.updateUnlockedHiddenJobIds(
            progressionState.unlockedHiddenJobIds,
          );
        }
      }
    });

    // initialEncounter가 있으면 StartCombat 발행
    if (_combatSession.currentEncounter != null) {
      _combatBloc.add(StartCombat(
        encounter: _toDomainEncounter(_combatSession.currentEncounter!),
        playerRunState: _runController.playerRunState,
      ));
    }

    _scheduleAutoAdvanceIfNeeded();

    // NarratorBloc — 외부 주입 우선, 없으면 자체 생성
    // E9 저주: 서술자 왜곡 시작 층 오프셋 적용
    _narratorBloc = widget.narratorBloc;
    if (_narratorBloc == null && widget.gameEventBus != null) {
      final narratorCurses = CurseModifierPool.resolveIds(
        _runController.playerRunState.activeCurseIds,
      );
      final floorOffset =
          CurseModifierResolver.resolveNarratorFloorOffset(narratorCurses);
      _narratorBloc = NarratorBloc(
        gameEventBus: _gameEventBus,
        microFloor: (2 + floorOffset).clamp(1, 5),
        unreliableFloor: (3 + floorOffset).clamp(1, 5),
        heavyFloor: (4 + floorOffset).clamp(1, 5),
      );
    }

    // MetaSaveData 초기화 (주입 또는 기본값)
    // MetaSaveData는 ProgressionBloc이 관리 (app.dart에서 initialize)

    // DungeonBloc 초기화 (dungeonGenerator 주입 시)
    if (widget.dungeonGenerator != null && widget.gameEventBus != null) {
      _dungeonBloc = DungeonBloc(
        dungeonGenerator: widget.dungeonGenerator!,
        gameEventBus: _gameEventBus,
      );
      if (widget.initialRunState != null) {
        // 이어하기: 준비 페이즈 스킵, 저장된 층에서 시작 + 로딩 오버레이
        _showContinueLoading = true;
        final rs = widget.initialRunState!;

        // 기세 상태 복원
        if (rs.momentumValue != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<MomentumBloc>().add(RestoreMomentum(
                value: rs.momentumValue!,
                consecutiveCount: rs.momentumConsecutiveCount,
              ));
            }
          });
        }

        if (rs.dungeonSeed != null && rs.dungeonNodeId != null) {
          // 던전 맵 상태 복원
          _dungeonBloc!.add(RestoreFloor(
            floor: rs.currentFloor,
            seed: rs.dungeonSeed!,
            currentNodeId: rs.dungeonNodeId!,
            visitedNodeIds: rs.dungeonVisitedNodeIds,
          ));
        } else {
          // 하위 호환: 던전 상태 없는 기존 세이브
          _dungeonBloc!.add(GenerateFloor(
            floor: rs.currentFloor,
            seed: DateTime.now().millisecondsSinceEpoch,
          ));
        }
        // BlocListener 마운트 전 RestoreFloor 완료 시 안전장치
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _showContinueLoading &&
              _dungeonBloc?.state is DungeonFloorReady) {
            setState(() => _continueLoadingReady = true);
          }
        });
      } else if (widget.initialBlockData == null && widget.initialEncounter == null) {
        // 새 게임: 준비 페이즈 표시
        _showPrepPhase();
      } else {
        // 테스트 모드: 바로 1층
        _dungeonBloc!.add(GenerateFloor(
          floor: 1,
          seed: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedScreenPadding = AppTheme.scaledScreenPadding(context);
    _cachedBlockSpacing = AppTheme.scaledBlockSpacing(context);
    _cachedSmallSpacing = ResponsiveScale.scaleVerticalPadding(context, 8);
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: Text Engine (blocks / scroll / rendering)
  // ════════════════════════════════════════════════════════════════════════
  /// CombatEncounter(presentation) → CombatEncounterData(domain) 변환.
  CombatEncounterData _toDomainEncounter(CombatEncounter encounter) {
    // 보스 인카운터: bossPhases 변환
    List<BossPhaseData>? domainBossPhases;
    if (encounter.bossPhases != null) {
      domainBossPhases = encounter.bossPhases!.indexed.map((indexed) {
        final (i, phase) = indexed;
        return BossPhaseData(
          phaseName: 'phase${i + 1}',
          turns: phase.turns
              .map((t) => CombatTurnInfo(
                    turnNumber: t.turnNumber,
                    enemyAction: t.enemyAction.type,
                  ))
              .toList(),
        );
      }).toList();
    }

    return CombatEncounterData(
      roomType: encounter.roomType,
      enemyName: encounter.enemyName,
      environmentClues: encounter.environmentClues,
      turns: encounter.turns
          .map((t) => CombatTurnInfo(
                turnNumber: t.turnNumber,
                enemyAction: t.enemyAction.type,
              ))
          .toList(),
      bossPhases: domainBossPhases,
    );
  }

  List<TextBlockData> _resolveInitialBlocks() {
    if (widget.initialBlockData != null) {
      return List<TextBlockData>.from(widget.initialBlockData!);
    }
    if (widget.initialBlocks != null) {
      return TextBlockData.fromSimpleTexts(widget.initialBlocks!);
    }
    return [];
  }

  /// Backward-compatible API: simple text blocks without choices.
  void setTextBlocks(List<String> blocks) {
    setTextBlockData(TextBlockData.fromSimpleTexts(blocks));
  }

  /// CombatEncounter로 전투 시작.
  void setCombatEncounter(CombatEncounter encounter) {
    final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
    setTextBlockData(blocks);
    // setTextBlockData가 _combatSession.currentEncounter를 null로 초기화하므로
    // 그 이후에 전투 데이터를 설정해야 함
    _combatSession = _combatSession.copyWith(currentEncounter: encounter);
    // CombatBloc: 전투 시작 (EndCombat은 setTextBlockData에서 이미 발행됨)
    _combatBloc.add(StartCombat(
      encounter: _toDomainEncounter(encounter),
      playerRunState: _runController.playerRunState,
    ));
  }

  /// New API: text blocks with optional choices.
  void setTextBlockData(List<TextBlockData> blocks, {bool endCombat = true, bool resetMomentum = true}) {
    setState(() {
      _textBlockDataList = List<TextBlockData>.from(blocks);
      _runController.clearCompletedBlocks();
      _currentBlockIndex = 0;
      _currentBlockComplete = false;
      _showingChoices = false;
      _choiceSelected = false;
      // 전투 상태 초기화
      _combatSession = _combatSession.copyWith(clearCurrentEncounter: true);
      // 보스 페이즈 전환 시에는 전투 중 상태 유지 (기세 리셋 방지)
      if (resetMomentum) {
        _inCombat = false;
        _inCardCombat = false;
      }
    });
    // 기세 초기화 → MomentumBloc
    // 보스 페이즈 전환 시에는 기세 유지 (AC4: 동일 전투 내 연속성)
    if (resetMomentum) {
      context.read<MomentumBloc>().add(const MomentumReset());
    }
    // 전투 상태 초기화 → CombatBloc
    if (endCombat) {
      _combatBloc.add(const EndCombat());
    }
  }

  /// 핸들러 공용 UI 상태 일괄 업데이트 콜백.
  void _updateUI({
    List<TextBlockData>? textBlockDataList,
    int? currentBlockIndex,
    bool? currentBlockComplete,
    bool? inCardCombat,
    bool? inCombat,
    bool? showingChoices,
    bool? choiceSelected,
    CombatSessionState? combatSession,
    bool? pendingCombatVictory,
  }) {
    setState(() {
      if (textBlockDataList != null) _textBlockDataList = textBlockDataList;
      if (currentBlockIndex != null) _currentBlockIndex = currentBlockIndex;
      if (currentBlockComplete != null) _currentBlockComplete = currentBlockComplete;
      if (inCardCombat != null) _inCardCombat = inCardCombat;
      if (inCombat != null) _inCombat = inCombat;
      if (showingChoices != null) _showingChoices = showingChoices;
      if (choiceSelected != null) _choiceSelected = choiceSelected;
      if (combatSession != null) _combatSession = combatSession;
      if (pendingCombatVictory != null) _pendingCombatVictory = pendingCombatVictory;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    _userScrolledUp = (maxScroll - currentScroll) > 50;
  }

  /// 앱 최초 전투 진입 시 튜토리얼 모달 표시 (SharedPreferences로 1회 제어).
  Future<void> _showTutorialIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('tutorial_combat_shown') ?? false) return;
    if (!mounted) return;
    await CombatTutorialModal.show(context);
    await prefs.setBool('tutorial_combat_shown', true);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleTap() {
    // Ignore background taps when showing choices
    if (_showingChoices) return;

    _inputMapper.isTextAnimating =
        _typewriterKey.currentState?.isAnimating ?? false;

    final action = _inputMapper.mapGesture(GameGesture.tap);
    switch (action) {
      case SkipText():
        _typewriterKey.currentState?.skipToEnd();
      case AdvanceText():
        _advanceToNextBlock();
      case NoAction():
        break;
    }
  }

  void _advanceToNextBlock() {
    if (!_currentBlockComplete) return;
    if (_currentBlockIndex >= _textBlockDataList.length) return;

    final block = _textBlockDataList[_currentBlockIndex];

    setState(() {
      _runController.completedBlocks.add(CompletedBlock(
        text: block.text,
        blockType: block.blockType,
        metadata: block.metadata,
      ));
      _currentBlockIndex++;
      _currentBlockComplete = false;
      _showingChoices = false;
      _choiceSelected = false;

      // combatPhase 감지
      if (block.metadata?['combatPhase'] == 'end') {
        _inCombat = false;
        if (kDebugMode) {
          GameLogger.debug(LogSystem.momentum, 'Combat ended, hiding gauge');
        }
      }

      // 전투 승리 결과 블록을 읽은 후 방 전환
      if (_pendingCombatVictory &&
          block.blockType == TextBlockType.combatOutcome) {
        _pendingCombatVictory = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _endCombatAndCompleteRoom();
        });
      }
    });

    // 다음 블록의 combatPhase 확인
    if (_currentBlockIndex < _textBlockDataList.length) {
      final nextBlock = _textBlockDataList[_currentBlockIndex];
      if (nextBlock.metadata?['combatPhase'] == 'start' && !_inCombat) {
        setState(() {
          _inCombat = true;
        });
        // 기세 리셋 → MomentumBloc
        context.read<MomentumBloc>().add(const MomentumReset());
        if (kDebugMode) {
          GameLogger.debug(LogSystem.momentum, 'Combat started, showing gauge');
        }
      }
    }

    _scheduleAutoAdvanceIfNeeded();

    // 텍스트 블록 소진 후 보류된 경로 선택지 표시
    if (_currentBlockIndex >= _textBlockDataList.length) {
      _dungeonNavHandler.checkPendingDungeonIntro();
      _prepPhaseHandler.checkPendingFloorGeneration();
    }

    if (!_userScrolledUp) {
      _scrollToBottom();
    }
  }

  /// 현재 블록이 자동 진행 대상(turnDivider, combatPreview)이면 스케줄링.
  /// build() 내 side effect를 방지하기 위해 상태 변경 후 호출.
  void _scheduleAutoAdvanceIfNeeded() {
    if (_currentBlockIndex >= _textBlockDataList.length) return;
    final block = _textBlockDataList[_currentBlockIndex];

    switch (block.blockType) {
      case TextBlockType.turnDivider:
        // 턴 구분자: 자동 완료 + 자동 진행
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_currentBlockComplete) {
            _onBlockComplete();
            _advanceToNextBlock();
          }
        });
      case TextBlockType.combatPreview || TextBlockType.combatResult:
        // 행동 예고 / 전투 결과: 자동 완료 (진행은 탭으로)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_currentBlockComplete) {
            _onBlockComplete();
          }
        });
      case TextBlockType.combatOutcome:
        // 전투 결과 표시: pending이면 CombatBloc으로 결과 판정 후 자동 완료
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted && !_currentBlockComplete) {
            await _resolvePendingOutcome();
            if (mounted) {
              _onBlockComplete();
            }
          }
        });
      case TextBlockType.environmentNarration:
      case TextBlockType.environmentDiscovery:
      case TextBlockType.dispositionHint:
      case TextBlockType.classChange:
      case TextBlockType.normal:
        break;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: Combat (action processing / resolve / retry / boss phases)
  // ════════════════════════════════════════════════════════════════════════
  /// combatOutcome 블록이 'pending' 상태이면 CombatOutcomeResolver로 결과 판정.
  Future<void> _resolvePendingOutcome() async {
    final action = await _outcomeResolver.resolvePendingOutcome(
      _textBlockDataList, _currentBlockIndex, () => mounted,
    );
    if (!mounted) return;
    setState(() {});

    if (action == ResolveAction.bossVictory) {
      _handleBossVictoryFloorTransition();
    } else if (action == ResolveAction.combatVictory) {
      _runController.appendFeedbackText('전투 승리!');
      setState(() { _pendingCombatVictory = true; });
    } else if (action == ResolveAction.combatDefeat) {
      // D-04: 비-퍼마데스 패배 → HP 손실 후 다음 방 진행
      _runController.appendFeedbackText('패배했지만 앞으로 나아간다...');
      setState(() { _pendingCombatVictory = true; }); // 방 완료 트리거 재사용
    }
  }

  /// 보스 승리 → 3선택지 (처치/해방/공존) 표시.
  void _handleBossVictoryFloorTransition() {
    _bossFlowHandler.handleVictoryFloorTransition();
  }

  void _onBlockComplete() {
    final currentBlock = _currentBlockIndex < _textBlockDataList.length
        ? _textBlockDataList[_currentBlockIndex]
        : null;

    setState(() {
      _currentBlockComplete = true;
      if (currentBlock != null && currentBlock.hasChoices) {
        _showingChoices = true;
      }
    });
    _inputMapper.isTextAnimating = false;

    if (_showingChoices && !_userScrolledUp) {
      _scrollToBottom();
    }
  }

  void _onChoiceSelected(ChoiceData choice) {
    _choiceRouter.route(choice);
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: GameScreenActions 구현
  // ════════════════════════════════════════════════════════════════════════
  @override
  bool get isChoiceSelected => _choiceSelected;
  @override
  bool get isInPrepPhase => _inPrepPhase;
  @override
  bool get hasDevilDeal => _shopHandler.hasDevilDeal;
  @override
  String? get pendingEliteNodeId => _dungeonNavHandler.pendingEliteNodeId;

  @override
  void handleRestartRun() => _handleRestartRun();
  @override
  void handleAdvanceFloor() => _dungeonNavHandler.handleAdvanceFloor();
  @override
  void handleBossChoice(ChoiceData choice) => _handleBossChoice(choice);
  @override
  void handleBossContinue() => _handleBossContinue();
  @override
  void handleRetreat() => _dungeonNavHandler.handleRetreat();
  @override
  void handlePrepChoice(ChoiceData choice) => _handlePrepChoice(choice);
  @override
  void handleDevilChoice(ChoiceData choice) =>
      _shopHandler.handleDevilChoice(choice);
  @override
  bool get hasPendingCardRemoval => _shopHandler.hasPendingCardRemoval;
  @override
  void handleCardRemovalChoice(ChoiceData choice) =>
      _shopHandler.handleCardRemovalChoice(choice);

  @override
  bool get hasPendingMysteryChoice => _mysteryHandler.hasPendingMysteryChoice;
  @override
  void handleMysteryChoice(ChoiceData choice) {
    if (_mysteryHandler.handleMysteryChoice(choice)) {
      setState(() {});
    }
  }

  @override
  Future<void> handleGhostChoice(ChoiceData choice) async {
    // 유령 상호작용 완료 → NPC 방 종료.
    if (choice.id == 'ghost_continue' && _npcHandler.isShowingGhost) {
      _runController.appendFeedbackText('유령의 잔상이 사라졌다.');
      _npcHandler.onGhostComplete();
      return;
    }

    // 유령 PvP 전투 — 승리 보상은 유령 직업 카드.
    if (choice.id == 'ghost_fight') {
      final ghost = _npcHandler.currentGhost;
      if (ghost != null) {
        final ghostEnemy = GhostEnemyGenerator.generate(ghost);
        _npcHandler.clearGhostForCombat();
        await _cardCombatHandler.startCombat(
          enemies: [ghostEnemy],
          roomType: RoomType.elite,
          rewardJobOverride: ghost.jobId,
        );
      }
      return;
    }

    // 보상/리스크 판정 + 적용.
    final level = _npcHandler.ghostReactionLevel;
    if (level != null) {
      final outcome = GhostRewardResolver.resolve(
        choiceId: choice.id,
        level: level,
      );
      _applyGhostOutcome(outcome);
    }

    _ghostInteractionHandler?.handleGhostChoice(choice);
  }

  /// 유령 보상/리스크 적용 → 피드백 텍스트 추가.
  void _applyGhostOutcome(GhostOutcome outcome) {
    final rc = _runController;
    final prs = rc.playerRunState;

    // 보상 적용.
    if (outcome.hasReward) {
      switch (outcome.rewardType) {
        case 'hp':
          final heal = outcome.rewardValue;
          final newHp = (prs.currentHp + heal).clamp(0, prs.maxHp);
          final actual = newHp - prs.currentHp;
          if (actual > 0) {
            rc.playerRunState = prs.copyWith(currentHp: newHp);
            rc.runBloc.add(ChangeHp(actual));
            rc.appendFeedbackText('유령의 기운이 감돌며 HP가 $actual 회복되었다.');
          }
        case 'momentum':
          rc.gameEventBus.emit(MomentumGainEvent(amount: outcome.rewardValue));
          rc.appendFeedbackText('유령의 기억이 기세를 ${outcome.rewardValue} 충전했다.');
        case 'gold':
          final gold = outcome.rewardValue;
          rc.playerRunState = rc.playerRunState.copyWith(
            gold: rc.playerRunState.gold + gold,
          );
          rc.runBloc.add(GainGold(gold));
          rc.gameEventBus.emit(GoldGainedEvent(
            amount: gold,
            totalGold: rc.playerRunState.gold,
          ));
          rc.appendFeedbackText('유령이 남긴 $gold 골드를 주웠다.');
      }
    }

    // 리스크 적용.
    if (outcome.hasRisk) {
      switch (outcome.riskType) {
        case 'hpLoss':
          final loss = outcome.riskValue;
          final newHp = (rc.playerRunState.currentHp - loss).clamp(1, rc.playerRunState.maxHp);
          final actual = rc.playerRunState.currentHp - newHp;
          if (actual > 0) {
            rc.playerRunState = rc.playerRunState.copyWith(currentHp: newHp);
            rc.runBloc.add(ChangeHp(-actual));
            rc.appendFeedbackText('유령의 한기에 HP가 $actual 감소했다.');
          }
        case 'momentumReset':
          context.read<MomentumBloc>().add(const MomentumReset());
          rc.appendFeedbackText('유령의 슬픔이 기세를 잠식했다.');
      }
    }
  }

  @override
  void handlePathSelection(ChoiceData choice) =>
      _dungeonNavHandler.handlePathSelection(choice);

  @override
  void handleEliteChallenge() => _dungeonNavHandler.handleEliteChallenge();

  @override
  void handleEliteAvoid() => _dungeonNavHandler.handleEliteAvoid();

  @override
  bool get hasPendingBossPrep => _dungeonNavHandler.hasPendingBossPrep;

  @override
  Future<void> handleBossPrepFight() => _dungeonNavHandler.handleBossPrepFight();

  @override
  void handleBossPrepStatus() async {
    await _showStatusDialog();
    if (!mounted) return;
    _dungeonNavHandler.handleBossPrepStatusReturn();
  }

  @override
  void handleCombatAction(ChoiceData choice) {
    if (kDebugMode) {
      GameLogger.debug(LogSystem.ui, 'Choice selected: ${choice.id}');
    }

    setState(() {
      _choiceSelected = true;
    });

    // After highlight delay, process the selection
    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      // 400ms 딜레이 중 setTextBlockData 호출 등으로 인덱스 무효화 방지
      if (_currentBlockIndex >= _textBlockDataList.length) {
        setState(() { _choiceSelected = false; });
        return;
      }
      final currentBlock = _textBlockDataList[_currentBlockIndex];

      // Determine result blocks
      final List<TextBlockData> resultBlocks;

      try {
        if (choice.actionType != null) {
          resultBlocks = await _actionProcessor.process(
            choice,
            momentumBloc: context.read<MomentumBloc>(),
          );
          if (!mounted) return;
        } else {
          // 기존 방식: resultTextBlocks 사용
          resultBlocks = choice.resultTextBlocks
              .map((t) => TextBlockData(text: t))
              .toList();
        }
      } catch (_) {
        if (mounted) setState(() { _choiceSelected = false; });
        return;
      }

      setState(() {
        // Add current text block to completed
        _runController.completedBlocks.add(CompletedBlock(
          text: currentBlock.text,
          blockType: currentBlock.blockType,
          metadata: currentBlock.metadata,
        ));

        // Add selected choice text to completed blocks as choice history
        _runController.completedBlocks.add(CompletedBlock(
          text: choice.text,
          isChoice: true,
        ));

        final insertIndex = _currentBlockIndex + 1;
        _textBlockDataList.insertAll(insertIndex, resultBlocks);

        // Move to next block
        _currentBlockIndex++;
        _currentBlockComplete = false;
        _showingChoices = false;
        _choiceSelected = false;
      });

      if (!_userScrolledUp) {
        _scrollToBottom();
      }

      // Auto-advance past empty result text blocks or auto-advancing block types
      // (deferred to next frame to avoid nested setState calls)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_currentBlockIndex < _textBlockDataList.length &&
            _textBlockDataList[_currentBlockIndex].text.isEmpty) {
          _onBlockComplete();
          _advanceToNextBlock();
        } else {
          _scheduleAutoAdvanceIfNeeded();
        }
      });
    });
  }

  // ── 카드 전투 핸들러 (CardCombatHandler 위임) ─────────────

  /// 기세 티어 → int 변환 (1=low, 2=mid, 3=high).
  int _momentumTierInt() {
    final momentumState = context.read<MomentumBloc>().state;
    return switch (momentumState) {
      MomentumUpdated(:final tier) => tier.index + 1,
      MomentumInitial() => 1,
    };
  }

  /// 현재 기세 원시값 (유물 임계치 판별용).
  int _currentMomentumValue() {
    final momentumState = context.read<MomentumBloc>().state;
    return switch (momentumState) {
      MomentumUpdated(:final value) => value,
      MomentumInitial() => 0,
    };
  }

  @override
  void handlePlayCard(ChoiceData choice) => _cardCombatHandler.handlePlayCard(choice);

  @override
  void handleEndTurn() => _cardCombatHandler.handleEndTurn();

  @override
  void handleAttemptFlee() => _cardCombatHandler.handleAttemptFlee();

  @override
  void handleSelectCardReward(ChoiceData choice) =>
      _cardCombatHandler.handleSelectCardReward(choice);

  @override
  void handleClassSelect(ChoiceData choice) {
    setState(() {
      _choiceSelected = true;
    });
    final jobId = choice.id.substring('class_select_'.length);
    _dungeonNavHandler.handleClassSelect(jobId);
  }

  void _handleBossContinue() => _cardCombatHandler.handleBossContinue();

  void _handleBossChoice(ChoiceData choice) => _cardCombatHandler.handleBossChoice(choice);

  /// 층 전환 연출 — 전체 화면 오버레이 "접속 중..." 표시.
  void _showFloorTransition(int targetFloor, VoidCallback onComplete) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, _, _) => FloorTransitionOverlay(
          targetFloor: targetFloor,
          onComplete: () {
            Navigator.of(context).pop();
            onComplete();
          },
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppTheme.enableAnimations
            ? const Duration(milliseconds: 300)
            : Duration.zero,
      ),
    );
  }

  // _handleAdvanceFloor → DungeonNavigationHandler에 위임 (handleAdvanceFloor에서 직접 호출)

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: Prep Phase (준비 페이즈)
  // ════════════════════════════════════════════════════════════════════════

  void _showPrepPhase() {
    _prepPhaseHandler.showPrepPhase();
  }

  void _handlePrepChoice(ChoiceData choice) {
    _prepPhaseHandler.handlePrepChoice(choice);
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 디버그 치트 (kDebugMode only)
  // ════════════════════════════════════════════════════════════════════════

  void _showDebugCheatPanel() {
    if (!kDebugMode) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DebugCheatPanel(
        godModeEnabled: _debugGodMode,
        onToggleGodMode: () {
          setState(() => _debugGodMode = !_debugGodMode);
          _combatBloc.add(DebugSetGodMode(_debugGodMode));
        },
        onFullHeal: () {
          final prs = _runController.playerRunState;
          _runController.playerRunState = prs.copyWith(currentHp: prs.maxHp);
          _runController.runBloc.add(SetPlayerRunState(_runController.playerRunState));
          setState(() {});
        },
        onSetAp99: () {
          _combatBloc.add(const DebugSetAp());
        },
        onSetGold9999: () {
          final prs = _runController.playerRunState;
          _runController.playerRunState = prs.copyWith(gold: 9999);
          _runController.runBloc.add(SetPlayerRunState(_runController.playerRunState));
          setState(() {});
        },
        onForceClassChange: (job) {
          _buildBloc.add(DebugForceClassChange(job));
          // 디버그 강제 전직: 경로 선택지 복원을 위해 플래그 설정
          _dungeonNavHandler.forceResumeAfterClassChange = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _dungeonNavHandler.resumeAfterClassChange();
          });
        },
        onShowClassChoices: (candidates, {bool isSecond = false}) {
          _buildBloc.add(DebugShowClassChoices(
            candidates,
            isSecondClassChange: isSecond,
          ));
        },
        onSimulateBossClassChange: _dungeonBloc != null ? () {
          // 던전을 보스방 진입 상태로 전환 → 전직 선택 UI 표시
          _dungeonBloc!.add(const RestoreRoom(roomType: RoomType.boss));
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            _buildBloc.add(DebugShowClassChoices(
              [Warrior(), Reaper()],
              isSecondClassChange: false,
            ));
          });
        } : null,
      ),
    );
  }

  void _handleRestartRun() {
    // 퍼마데스: 메타에 사망 기록 (엔딩 완료 시에는 _showEnding에서 이미 처리)
    if (_runController.isPermadeath) {
      _recordPermadeath();
    }

    // BGM 정지 (이벤트/미스터리 방 사망 등 PermadeathEvent 미발행 경우 대비)
    if (mounted) {
      context.read<AudioBloc>().add(const StopBgm());
    }

    // isFirstRun = false (튜토리얼 이후 반복 런)
    widget.dungeonGenerator?.markFirstRunDone();

    // 런 세이브 삭제 (새 런 시작) + app.dart 상태 동기화
    widget.saveManager?.deleteRun();
    widget.onRunDeleted?.call();

    // 타이틀 화면으로 복귀
    if (mounted) {
      context.go('/');
    }
  }

  List<ChoiceData>? get _currentChoices {
    // 카드 전투 모드: 손패 → 선택지 변환 (카드만, 턴종료/도주 제외)
    if (_inCardCombat) {
      final state = _combatBloc.state;
      if (state is CardCombatActive) {
        final handKey = Object.hashAll(state.hand.map((c) => c.id));
        final ap = state.actionPoints;
        final str = StatusEffectProcessor.stacks(
          state.playerStatuses,
          StatusEffectType.strength,
        );
        final dex = StatusEffectProcessor.stacks(
          state.playerStatuses,
          StatusEffectType.dexterity,
        );
        final isWeak = StatusEffectProcessor.hasActive(
          state.playerStatuses,
          StatusEffectType.weak,
        );
        final isVuln = StatusEffectProcessor.hasActive(
          state.enemyStatuses,
          StatusEffectType.vulnerable,
        );
        if (handKey == _lastHandCacheKey &&
            ap == _lastCachedAp &&
            str == _lastCachedStr &&
            dex == _lastCachedDex &&
            isWeak == _lastCachedWeak &&
            isVuln == _lastCachedVuln &&
            _cachedCardHandChoices != null) {
          return _cachedCardHandChoices;
        }
        _lastHandCacheKey = handKey;
        _lastCachedAp = ap;
        _lastCachedStr = str;
        _lastCachedDex = dex;
        _lastCachedWeak = isWeak;
        _lastCachedVuln = isVuln;
        _cachedCardHandChoices = CombatFlowManager.buildCardHandChoices(
          hand: state.hand,
          actionPoints: state.actionPoints,
          playerStrength: str,
          playerDexterity: dex,
          isPlayerWeakened: isWeak,
          isEnemyVulnerable: isVuln,
        );
        return _cachedCardHandChoices;
      }
      // 전투 종료 후(보상 선택 등): 텍스트 블록 선택지로 폴스루
    }

    if (_currentBlockIndex >= _textBlockDataList.length) return null;
    final blockChoices = _textBlockDataList[_currentBlockIndex].choices;
    // 전투 선택지 블록이면 추가 선택지 합류
    final combatState = _combatBloc.state;
    if (combatState is CombatActive &&
        blockChoices != null &&
        blockChoices.isNotEmpty) {
      final extraChoices = <ChoiceData>[];
      // 직업 특수 행동 (BuildSpecialized/BuildAdvancedSpecialized 상태일 때)
      final bState = _buildBloc.state;
      if (bState is BuildAdvancedSpecialized) {
        extraChoices.add(CombatFlowManager.buildSpecialActionChoice(
          bState.secondaryJob.specialActionType,
        ));
      } else if (bState is BuildSpecialized) {
        extraChoices.add(CombatFlowManager.buildSpecialActionChoice(
          bState.currentJob.specialActionType,
        ));
      }
      // 환경 해금 상태이면 환경 선택지
      if (combatState.environmentUnlocked &&
          combatState.discoveredClues.isNotEmpty) {
        extraChoices.addAll(
          CombatFlowManager.buildEnvironmentChoices(
              combatState.discoveredClues),
        );
      }
      if (extraChoices.isNotEmpty) {
        return [...blockChoices, ...extraChoices];
      }
    }
    return blockChoices;
  }

  Widget _buildCompletedBlock(BuildContext context, CompletedBlock block) {
    return CompletedBlockRenderer.build(context, block);
  }

  // ── 던전 탐색 핸들러 (DungeonNavigationHandler 위임) ─────────────

  Future<void> _onDungeonStateChanged(BuildContext context, DungeonBlocState dState) async {
    if (!mounted) return;
    // 이어하기 로딩 오버레이 처리
    if (_showContinueLoading) {
      if (dState is DungeonFloorReady) {
        setState(() => _continueLoadingReady = true);
      } else if (dState is DungeonBlocError) {
        // 복원 실패 시 오버레이 해제 → 정상 에러 핸들러로 폴스루
        setState(() {
          _showContinueLoading = false;
          _continueLoadingReady = false;
        });
        // fall through to normal handler (retries with new seed)
      } else {
        return; // 다른 상태는 오버레이 닫힌 후 처리
      }
    }
    if (_showContinueLoading) return;
    await _dungeonNavHandler.onDungeonStateChanged(context, dState);
    if (dState is DungeonFloorReady) {
      // 던전 맵 상태를 PlayerRunState에 동기화 + 방 완료 → currentRoomType 초기화
      _runController.playerRunState =
          _runController.playerRunState.copyWith(
        dungeonSeed: dState.floorMap.seed,
        dungeonNodeId: dState.currentNodeId,
        dungeonVisitedNodeIds: dState.visitedNodeIds,
        currentRoomType: null,
      );
      _autoSave();
    } else if (dState is DungeonRoomEntered) {
      // 전투 방(combat/elite/boss)은 동기화+저장 스킵 — 이어하기 시 직전 안전 지점 복귀
      // RestoreFloor가 DungeonFloorReady로만 복원하므로 전투 방 nodeId를
      // visitedNodeIds에 포함시키면 전투를 치르지 않고 넘어가는 exploit 발생
      final isCombatRoom = switch (dState.roomType) {
        RoomType.combat || RoomType.elite || RoomType.boss => true,
        _ => false,
      };
      if (!isCombatRoom) {
        _runController.playerRunState =
            _runController.playerRunState.copyWith(
          dungeonSeed: dState.floorMap.seed,
          dungeonNodeId: dState.currentNodeId,
          dungeonVisitedNodeIds: dState.visitedNodeIds,
          currentRoomType: dState.roomType,
        );
        _autoSave();
      }
    }
  }

  /// 이어하기 로딩 오버레이 닫기 → 던전 상태 처리 재개.
  Future<void> _dismissContinueLoading() async {
    if (!_showContinueLoading) return;
    setState(() {
      _showContinueLoading = false;
      _continueLoadingReady = false;
    });

    // 보스 보상 선택 대기 중이면 보상 화면 복원
    if (widget.initialRunState?.bossVictoryPending == true) {
      _bossFlowHandler.handleVictoryFloorTransition();
      return;
    }

    // 전투 중 저장된 상태가 있으면 전투 복원
    if (_tryRestoreCombatState()) return;

    // 비전투 방(휴식/상점/NPC/이벤트/미스터리)에서 저장된 경우 방 재진입
    final savedRoomType = widget.initialRunState?.currentRoomType;
    if (savedRoomType != null) {
      _dungeonBloc?.add(RestoreRoom(roomType: savedRoomType));
      return;
    }

    // _onDungeonStateChanged에 위임하여 중복 방지
    final dState = _dungeonBloc?.state;
    if (dState != null) {
      await _onDungeonStateChanged(context, dState);
    }
  }

  /// 저장된 전투 상태 복원 시도. 성공 시 true.
  bool _tryRestoreCombatState() {
    final combatRaw = widget.initialCombatStateRaw;
    if (combatRaw == null) return false;

    final restoredState = CombatStateSerializer.fromJson(
      combatRaw,
      cardResolver: CardPool.findById,
      blessingResolver: CardBlessingPool.resolveIds,
      relicResolver: CardRelicPool.resolveIds,
      playerRunState: _runController.playerRunState,
    );

    if (restoredState == null) {
      // 전투 상태 복원 실패 → 던전 맵으로 폴백
      GameLogger.warning(
        LogSystem.save,
        'Combat state restore failed — falling back to dungeon map',
      );
      return false;
    }

    // 전투 인트로 텍스트 — 적 이름 + 현재 턴 표시
    final enemyName = restoredState.enemies.length > 1
        ? '${restoredState.enemy.name} 외 ${restoredState.enemies.length - 1}마리'
        : restoredState.enemy.name;
    _runController.completedBlocks.add(CompletedBlock(
      text: '[$enemyName]과(와)의 전투를 이어서 진행한다.',
    ));
    // 턴 구분선
    _runController.completedBlocks.add(CompletedBlock(
      text: '═══════ ${restoredState.currentTurn}턴 ═══════',
      metadata: {'turnDivider': 'true'},
    ));

    // 전투 UI 플래그 설정 — showingChoices 포함
    _updateUI(
      inCardCombat: true,
      inCombat: true,
      showingChoices: true,
      textBlockDataList: [],
      currentBlockIndex: 0,
      currentBlockComplete: false,
      choiceSelected: false,
    );

    // CombatBloc에 저장된 상태 복원
    _combatBloc.add(RestoreCardCombat(
      savedState: restoredState,
    ));

    // CardCombatHandler AP 추적 상태 초기화
    _cardCombatHandler.restoreApTracking(restoredState.maxActionPoints);

    // 던전 인트로 이미 표시 완료로 마킹 — 전투 종료 후 중복 인트로 방지
    _dungeonNavHandler.hasShownDungeonIntro = true;

    // 전투 방 nodeId 복원 — 전투 완료 시 dungeonBloc 갱신에 사용
    final combatNodeId = combatRaw['_dungeonNodeId'] as String?;
    _dungeonNavHandler.restoredCombatNodeId = combatNodeId;

    GameLogger.info(
      LogSystem.save,
      'Combat state restored: turn ${restoredState.currentTurn}, '
      'enemies: ${restoredState.enemies.length}, '
      'combatNodeId: $combatNodeId',
    );
    return true;
  }

  void _onBuildStateChanged(BuildContext context, BuildState bState) {
      if (kDebugMode) {
        GameLogger.debug(LogSystem.ui,
            '[BUILD_STATE] ${bState.runtimeType} | inCombat=$_inCombat inCardCombat=$_inCardCombat choiceSelected=$_choiceSelected');
      }
      _dungeonNavHandler.onBuildStateChanged(context, bState);
      // 전직 완료 후 던전 진행 재개 (디버그 강제 전직 시에도 안전)
      // 전투 중에는 호출 금지 — 엘리트 도전 성향 보상으로 전직 발생 시
      // resumeAfterClassChange가 completeDungeonRoom을 호출하여 방 즉시 완료되는 버그 방지
      if (bState is BuildSpecialized || bState is BuildAdvancedSpecialized) {
        if (!_inCombat && !_inCardCombat) {
          if (kDebugMode) {
            GameLogger.debug(LogSystem.ui,
                '[BUILD_STATE] → scheduling resumeAfterClassChange (100ms)');
          }
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _dungeonNavHandler.resumeAfterClassChange();
          });
        } else {
          if (kDebugMode) {
            GameLogger.debug(LogSystem.ui,
                '[BUILD_STATE] → SKIP resumeAfterClassChange (combat active)');
          }
        }
      }
  }

  void completeDungeonRoom() => _dungeonNavHandler.completeDungeonRoom();

  void _endCombatAndCompleteRoom() =>
      _dungeonNavHandler.endCombatAndCompleteRoom();

  @override
  // ════════════════════════════════════════════════════════════════════════
  // SECTION: Build
  // ════════════════════════════════════════════════════════════════════════
  Widget build(BuildContext context) {
    Widget body = Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 배경색 전환 레이어 (탐색 ↔ 전투) — 층별 테마 색상
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            color: _inCardCombat
                ? _currentFloorVisuals.combatBackground
                : _currentFloorVisuals.backgroundColor,
          ),
          // 앰비언트 파티클 오버레이 — 층별 분위기 연출
          AmbientParticleOverlay(themeVisuals: _currentFloorVisuals),
          SafeArea(
        child: GestureDetector(
          key: const ValueKey('game_screen_tap_area'),
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: _inCardCombat
              // ── 카드 전투: 전용 위젯으로 격리 (Reforged 1단계) ──
              // 이후 이 위젯 내부를 Flame GameWidget 씬으로 교체한다.
              ? CardCombatView(
                  combatBloc: _combatBloc,
                  momentumConfig: widget.momentumConfig,
                  floorVisuals: _currentFloorVisuals,
                  currentFloor: _runController.playerRunState.currentFloor,
                  playerJobId: _runController.playerRunState.currentJobId,
                  showActionButtons: _showingChoices &&
                      _combatBloc.state is! CardBossPhaseTransition &&
                      !_isCardRewardPhase,
                  choiceSelected: _choiceSelected,
                  textScrollArea: _buildTextScrollArea(context),
                  bottomChoiceArea: _buildBottomChoiceArea(context),
                  combatActionButtons: _buildCombatActionButtons(context),
                  onSelectTarget: (index) =>
                      _combatBloc.add(SelectTarget(index)),
                )
              // ── 탐색 모드 ──
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 상단 고정 상태 바 ──
                    if (!_inPrepPhase)
                      PlayerStatusBar(
                        currentHp: _runController.playerRunState.currentHp,
                        maxHp: _runController.playerRunState.maxHp,
                        currentFloor: _runController.playerRunState.currentFloor,
                        backgroundColor: _currentFloorVisuals.frameBackground,
                      ),
                    // ── 상단: 스크롤 가능한 스토리 텍스트 영역 ──
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        foregroundDecoration: const BoxDecoration(
                          // 탐색 모드: 미세 채도 절제 오버레이
                          color: Color(0x0800000A),
                        ),
                        child: _buildTextScrollArea(context),
                      ),
                    ),
                    // ── 하단 고정: 미니맵 토글 + 선택지 ──
                    if (_dungeonBloc != null) _buildMinimapToggleBar(),
                    _buildBottomChoiceArea(context),
                  ],
                ),
        ),
      ),
          // 전투 이펙트 오버레이 (피격/방어/회복 틴트 플래시)
          CombatEffectOverlay(gameEventBus: _gameEventBus),
          // CRT 비네트 오버레이 (최상위) — 층별 색상 틴트
          VignetteOverlay(vignetteColor: _currentFloorVisuals.vignetteColor),
          // 이어하기 로딩 오버레이 (모든 UI 위에 표시)
          if (_showContinueLoading)
            Positioned.fill(
              child: ContinueLoadingOverlay(
                floor: _runController.playerRunState.currentFloor,
                isReady: _continueLoadingReady,
                onComplete: _dismissContinueLoading,
              ),
            ),
          // 디버그 치트 FAB (kDebugMode only, 스크린샷 모드에서는 숨김)
          if (kDebugMode &&
              !const bool.fromEnvironment('HIDE_DEBUG_FAB'))
            Positioned(
              right: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: _showDebugCheatPanel,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _debugGodMode
                        ? const Color(0xAAFF4444)
                        : const Color(0x66444444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bug_report,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // 뒤로가기 무시 — 게임 중 실수로 앱 종료 방지
      },
      child: BlocListenerStack(
        buildBloc: _buildBloc,
        onBuildStateChanged: _onBuildStateChanged,
        dungeonBloc: _dungeonBloc,
        onDungeonStateChanged: _dungeonBloc != null
            ? _onDungeonStateChanged
            : null,
        shopBloc: _shopHandler.bloc,
        onShopStateChanged: _shopHandler.bloc != null
            ? (context, shopState) {
                if (shopState is ShopClosed) _shopHandler.onClosed(shopState);
              }
            : null,
        mysteryBloc: _mysteryHandler.bloc,
        onMysteryStateChanged: _mysteryHandler.bloc != null
            ? (context, mysteryState) {
                if (mysteryState is MysteryCompleted) {
                  _mysteryHandler.onCompleted(mysteryState);
                }
              }
            : null,
        restBloc: _restHandler.bloc,
        onRestStateChanged: _restHandler.bloc != null
            ? (context, restState) {
                if (restState is RestClosed) _restHandler.onClosed(restState);
              }
            : null,
        eventRoomBloc: _eventHandler.bloc,
        onEventRoomStateChanged: _eventHandler.bloc != null
            ? (context, eventState) {
                if (eventState is EventRoomCompleted) {
                  _eventHandler.onCompleted(eventState);
                }
              }
            : null,
        npcBloc: _npcHandler.bloc,
        onNpcStateChanged: _npcHandler.bloc != null
            ? (context, npcState) {
                if (npcState is NpcClosed) _npcHandler.onClosed(npcState);
              }
            : null,
        child: body,
      ),
    );
  }

  /// 스크롤 가능한 텍스트 영역 (탐색/전투 공용).
  Widget _buildTextScrollArea(BuildContext context) {
    final hasCurrentBlock = _currentBlockIndex < _textBlockDataList.length;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _inCardCombat
            ? _cachedScreenPadding.left * 0.5
            : _cachedScreenPadding.left,
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: _cachedScreenPadding.top,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final block in _runController.completedBlocks)
                Padding(
                  padding: EdgeInsets.only(bottom: _cachedBlockSpacing),
                  child: _buildCompletedBlock(context, block),
                ),
              if (hasCurrentBlock)
                Padding(
                  padding: EdgeInsets.only(bottom: _cachedBlockSpacing),
                  child: CurrentBlockRenderer(
                    blockData: _textBlockDataList[_currentBlockIndex],
                    blockIndex: _currentBlockIndex,
                    typewriterKey: _typewriterKey,
                    speed: widget.speed,
                    charsPerSecondSlow: widget.charsPerSecondSlow,
                    charsPerSecondNormal: widget.charsPerSecondNormal,
                    charsPerSecondFast: widget.charsPerSecondFast,
                    onComplete: _onBlockComplete,
                  ),
                ),
              // HP 표시 + 기세 게이지 (전투 중, 카드 전투 시 HUD가 대체)
              if (_inCombat && !_inCardCombat)
                Padding(
                  padding: EdgeInsets.only(bottom: _cachedSmallSpacing),
                  child: HpDisplayWidget(
                    currentHp: _runController.playerRunState.currentHp,
                    maxHp: _runController.playerRunState.maxHp,
                    narratorState: _narratorBloc?.state,
                  ),
                ),
              // O-03: 기세 게이지 2층부터 표시
              if (_inCombat && !_inCardCombat && _runController.playerRunState.currentFloor >= 2)
                BlocBuilder<MomentumBloc, MomentumState>(
                  buildWhen: (prev, curr) =>
                      prev.runtimeType != curr.runtimeType ||
                      (prev is MomentumUpdated &&
                          curr is MomentumUpdated &&
                          (prev.value != curr.value ||
                              prev.tier != curr.tier)),
                  builder: (context, state) {
                    final tierInt = switch (state) {
                      MomentumUpdated(:final tier) => tier.index + 1,
                      MomentumInitial() => 1,
                    };
                    final ap = widget.cardCombatConfig.apForTier(tierInt);
                    return Padding(
                      padding: EdgeInsets.only(bottom: _cachedSmallSpacing),
                      child: switch (state) {
                        MomentumInitial() => MomentumGaugeWidget(
                            momentum: 0,
                            config: widget.momentumConfig,
                            apForCurrentTier: ap,
                          ),
                        MomentumUpdated(:final value, :final lastDelta) =>
                          MomentumGaugeWidget(
                            momentum: value,
                            lastDelta: lastDelta,
                            config: widget.momentumConfig,
                            apForCurrentTier: ap,
                          ),
                      },
                    );
                  },
                ),
              // 방 유형별 위젯 (Shop/Mystery/Event/Rest/NPC)
              ...RoomWidgetBuilder.build(
                shopHandler: _shopHandler,
                mysteryHandler: _mysteryHandler,
                eventHandler: _eventHandler,
                restHandler: _restHandler,
                npcHandler: _npcHandler,
                blockSpacing: _cachedBlockSpacing,
                unlockedMemoryIds: _getUnlockedMemoryIds(),
                frameBackground: _currentFloorVisuals.frameBackground,
              ),
              // 끝 표시 (현재 블록 없을 때)
              if (!hasCurrentBlock &&
                  _runController.completedBlocks.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: _cachedSmallSpacing),
                  child: Text(
                    '\u25bc',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 하단 고정 선택지 영역 — 상단 구분선 + ChoiceListWidget.
  /// ChoiceListWidget 내부에서 visible=false 시 AnimatedOpacity(0)+IgnorePointer 처리.
  Widget _buildBottomChoiceArea(BuildContext context) {
    final choices = _currentChoices ?? const <ChoiceData>[];
    final visible = _showingChoices && choices.isNotEmpty;

    // 카드 전투: RetroWindowFrame 내부이므로 Container 장식 불필요
    if (_inCardCombat) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: _cachedSmallSpacing),
        child: ChoiceListWidget(
          choices: choices,
          visible: _showingChoices,
          onChoiceSelected: _onChoiceSelected,
          isCardCombat: true,
          currentFloor: _runController.playerRunState.currentFloor,
        ),
      );
    }

    // 탐색 모드: 층별 배경색 그라데이션
    final bgColor = _currentFloorVisuals.backgroundColor;
    final choiceContent = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _cachedScreenPadding.left,
          vertical: _cachedSmallSpacing,
        ),
        child: ChoiceListWidget(
          choices: choices,
          visible: _showingChoices,
          onChoiceSelected: _onChoiceSelected,
          currentFloor: _runController.playerRunState.currentFloor,
        ),
      ),
    );

    return Container(
      decoration: visible
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor.withValues(alpha: 0.0),
                  bgColor.withValues(alpha: 0.7),
                  bgColor.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            )
          : const BoxDecoration(),
      constraints: visible
          ? BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            )
          : const BoxConstraints(),
      child: choiceContent,
    );
  }

  /// 카드 전투 중 하단 고정 액션 버튼 (턴 종료 / 도주).
  Widget _buildCombatActionButtons(BuildContext context) {
    final combatState = _combatBloc.state;
    final isBoss = combatState is CardCombatActive &&
        combatState.roomType == RoomType.boss;
    final actions = CombatFlowManager.buildCombatActionButtons(
      isBoss: isBoss,
      fleeApCost: widget.fleeConfig.apCost,
    );

    final buttons = <Widget>[];

    // 몬스터 테이밍: 제압된 적이 있으면 '길들이기' 버튼을 앞에 추가.
    if (combatState is CardCombatActive && combatState.canTame) {
      final tameIdx = combatState.suppressedTargetIndex!;
      buttons.add(
        Expanded(
          flex: 3,
          child: RetroButton(
            label: '🐾 길들이기',
            onTap: () => _cardCombatHandler.handleTame(tameIdx),
            backgroundColor: const Color(0xFF243A24),
            borderColor: const Color(0xFF6FCF6F),
            textColor: const Color(0xFFB8F0B8),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          ),
        ),
      );
      buttons.add(const SizedBox(width: 8));
    }

    for (int i = 0; i < actions.length; i++) {
      if (i > 0) buttons.add(const SizedBox(width: 8));
      final isEndTurn = actions[i].id == 'end_turn';
      buttons.add(
        Expanded(
          flex: isEndTurn ? 3 : 2,
          child: RetroButton(
            label: actions[i].text,
            onTap: () => _onChoiceSelected(actions[i]),
            backgroundColor: isEndTurn
                ? _currentFloorVisuals.combatEndTurnBg
                : _currentFloorVisuals.combatFleeBg,
            borderColor: isEndTurn
                ? _currentFloorVisuals.combatEndTurnBorder
                : _currentFloorVisuals.combatFleeBorder,
            textColor: isEndTurn
                ? AppTheme.combatEndTurnText
                : AppTheme.combatFleeText,
            fontWeight: isEndTurn ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _cachedScreenPadding.left,
        vertical: 8,
      ),
      child: Row(
        children: [
          // 도움말 버튼 — 전투 중 캐릭터 상태 확인
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: Color(0xFF888888),
                size: 18,
              ),
              padding: EdgeInsets.zero,
              onPressed: _showStatusDialog,
              tooltip: '캐릭터 상태',
            ),
          ),
          const SizedBox(width: 4),
          ...buttons,
        ],
      ),
    );
  }

  /// 미니맵 열기 버튼 바 (DungeonBloc 활성 시).
  ///
  /// - DungeonFloorReady: 캐릭터 상태 + 미니맵 아이콘
  /// - DungeonRoomEntered (상점/이벤트/휴식 등): 캐릭터 상태 아이콘만
  Widget _buildMinimapToggleBar() {
    return BlocBuilder<DungeonBloc, DungeonBlocState>(
      bloc: _dungeonBloc,
      buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      builder: (context, dState) {
        if (dState is DungeonFloorReady) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFFB0B0B0),
                    size: 22,
                  ),
                  onPressed: _showStatusDialog,
                  tooltip: '캐릭터 상태',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.map_outlined,
                    color: AppTheme.minimapToggleColor,
                    size: 24,
                  ),
                  onPressed: () => _showMinimapDialog(dState),
                  tooltip: '미니맵 열기',
                ),
              ],
            ),
          );
        }

        // 상점/이벤트/휴식 방 — 캐릭터 상태 아이콘만 표시 (보유 카드/유물 확인용)
        if (dState is DungeonRoomEntered) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFFB0B0B0),
                    size: 22,
                  ),
                  onPressed: _showStatusDialog,
                  tooltip: '캐릭터 상태',
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// 미니맵 모달 다이얼로그 — 화면 중앙에 팝업.
  void _showMinimapDialog(DungeonFloorReady dState) {
    if (_minimapDialogOpen) return;
    _minimapDialogOpen = true;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return BlocBuilder<DungeonBloc, DungeonBlocState>(
          bloc: _dungeonBloc,
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, currentState) {
            if (currentState is! DungeonFloorReady) {
              return const SizedBox.shrink();
            }
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 360,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: MinimapWidget(
                    floorMap: currentState.floorMap,
                    currentNodeId: currentState.currentNodeId,
                    visitedNodeIds: currentState.visitedNodeIds,
                    frameBackground: _currentFloorVisuals.frameBackground,
                    titleBarColor: _currentFloorVisuals.combatUiTint,
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (mounted) _minimapDialogOpen = false;
    });
  }

  /// 캐릭터 상태 다이얼로그 — 빌드 전체 확인.
  Future<void> _showStatusDialog() {
    final state = _runController.playerRunState;
    final allBlessings = CardBlessingPool.resolveIds(state.ownedBlessingIds);
    // 상점 저주 아이템은 축복이 아닌 저주 섹션에 표시
    final blessings = allBlessings
        .where((b) => !CardBlessingPool.cursedIds.contains(b.id))
        .toList();
    final cursedBlessings = allBlessings
        .where((b) => CardBlessingPool.cursedIds.contains(b.id))
        .map((b) => CurseData(
              id: b.id,
              name: b.name,
              description: b.description,
              effectType: b.effectType,
              effectValue: b.effectValue,
            ))
        .toList();
    final relics = CardRelicPool.resolveIds(state.ownedRelicIds);
    final curses = [
      ...CursePool.resolveCurseIds(state.activeCurseIds.toList()),
      ...cursedBlessings,
    ];

    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: StatusScreenWidget(
              runState: state,
              blessings: blessings,
              relics: relics,
              curses: curses,
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _autoSave();
      context.read<AudioBloc>().add(const PauseBgm());
    } else if (state == AppLifecycleState.resumed) {
      context.read<AudioBloc>().add(const ResumeBgm());
    }
  }

  Future<void> _autoSave() async {
    // 레거시 전투 중에는 저장 스킵 (카드 전투는 저장 지원).
    if (_inCombat && !_inCardCombat) return;
    // 이어하기 로딩 중에는 저장 스킵 — 던전 상태 복원 완료 전 불완전한 상태 저장 방지
    if (_showContinueLoading) return;
    if (!mounted) return;
    final saveManager = widget.saveManager;
    if (saveManager == null) return;
    // 동시 저장 방지 — 이전 저장이 완료될 때까지 스킵
    if (_autoSaving) return;
    _autoSaving = true;

    // 기세 상태를 PlayerRunState에 동기화
    final momentumState = context.read<MomentumBloc>().state;
    var runState = _runController.playerRunState;
    if (momentumState is MomentumUpdated) {
      runState = runState.copyWith(
        momentumValue: momentumState.value,
        momentumConsecutiveCount: momentumState.consecutiveSameAction,
      );
    } else {
      runState = runState.copyWith(
        momentumValue: null,
        momentumConsecutiveCount: 0,
      );
    }

    // 카드 전투 중이면 전투 상태도 직렬화하여 저장
    Map<String, dynamic>? combatStateRaw;
    if (_inCardCombat) {
      final combatState = _combatBloc.state;
      if (combatState is CardCombatActive) {
        combatStateRaw = CombatStateSerializer.toJson(combatState);
        // 전투 방 nodeId를 함께 저장 — 이어하기 시 방 완료 처리에 필요
        final dState = _dungeonBloc?.state;
        if (dState is DungeonRoomEntered) {
          combatStateRaw['_dungeonNodeId'] = dState.currentNodeId;
        }
      }
    }

    final data = RunSaveData(
      playerRunState: runState,
      savedAt: DateTime.now(),
      cardCombatStateRaw: combatStateRaw,
    );
    try {
      await saveManager.saveRun(data);
    } finally {
      _autoSaving = false;
    }
  }

  /// 해금된 기억 조각 ID Set — ProgressionBloc 경유.
  Set<String> _getUnlockedMemoryIds() {
    final state = context.read<ProgressionBloc>().state;
    if (state is ProgressionLoaded) return state.unlockedMemoryIds;
    return const {};
  }

  /// 런 완료 기록 — ProgressionBloc 경유.
  void _recordRunCompleted(String endingName) {
    final jobId = _runController.playerRunState.currentJobId;
    context.read<ProgressionBloc>().add(
      RecordRunCompletion(endingName: endingName, jobId: jobId),
    );
  }

  /// 히든 직업 해금 알림 — SnackBar로 표시.
  void _showJobUnlockNotification(String jobDisplayName) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '\u2728 새로운 직업 해금: $jobDisplayName',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1),
        ),
      ),
    );
  }

  /// 유령 NPC 풀 초기화 — MetaSaveData에서 역직렬화.
  List<GhostNpcData> _initialGhostPool() {
    final meta = widget.initialMeta;
    if (meta == null || meta.ghostNpcPoolRaw.isEmpty) return const [];
    return GhostNpcData.fromRawList(meta.ghostNpcPoolRaw);
  }

  /// 현재 런 번호 (1-based) — totalRuns + 1.
  int _currentRunNumber() {
    final meta = widget.initialMeta;
    if (meta == null) return 1;
    return meta.totalRuns + 1;
  }

  /// 퍼마데스 기록 — ProgressionBloc 경유 + 유령 풀 등록.
  void _recordPermadeath() {
    final prs = _runController.playerRunState;
    final floor = prs.currentFloor;

    // 유령 풀에 현재 캐릭터 등록.
    final dispositionMap = <String, int>{
      for (final entry in prs.disposition.entries) entry.key.name: entry.value,
    };
    final ghostData = GhostNpcData(
      deathFloor: floor,
      jobId: prs.currentJobId ?? 'wanderer',
      dispositionSnapshot: dispositionMap,
      runNumber: _currentRunNumber(),
    );

    context.read<ProgressionBloc>().add(
      RecordDeath(
        floorReached: floor,
        ghostDataRaw: ghostData.toJson(),
      ),
    );
  }

  @override
  void dispose() {
    _jobUnlockSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _runController.dispose();
    _buildBloc.close();
    _combatBloc.close();
    _runController.runBloc.close();
    _shopHandler.dispose();
    _mysteryHandler.dispose();
    _npcHandler.dispose();
    _restHandler.dispose();
    _eventHandler.dispose();
    // NarratorBloc: 외부 주입이 아닌 경우에만 close
    if (widget.narratorBloc == null) {
      _narratorBloc?.close();
    }
    _dungeonBloc?.close();
    _scrollController.dispose();
    super.dispose();
  }
}
