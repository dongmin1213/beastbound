part of 'game_screen.dart';

/// 테스트 전용 API — GameScreenState의 내부 상태 접근 및 시뮬레이션.
///
/// `part of 'game_screen.dart'`로 동일 라이브러리 스코프를 공유하여
/// private 멤버(`_combatBloc`, `_runController` 등) 접근 가능.
extension GameScreenTestApi on GameScreenState {
  /// 테스트 전용: 현재 방 환경 단서 목록 접근.
  @visibleForTesting
  List<EnvironmentClue> get roomEnvironmentCluesForTest {
    final state = _combatBloc.state;
    if (state is CombatActive) return state.encounter.environmentClues;
    return const [];
  }

  /// 테스트 전용: 환경 해금 상태 접근.
  @visibleForTesting
  bool get environmentUnlockedForTest {
    final state = _combatBloc.state;
    if (state is CombatActive) return state.environmentUnlocked;
    return false;
  }

  /// 테스트 전용: 발견된 단서 목록 접근.
  @visibleForTesting
  List<EnvironmentClue> get discoveredCluesForTest {
    final state = _combatBloc.state;
    if (state is CombatActive) return state.discoveredClues;
    return const [];
  }

  /// 테스트 전용: 플레이어 HP 상태 접근.
  @visibleForTesting
  PlayerRunState get playerRunStateForTest => _runController.playerRunState;

  /// 테스트 전용: 상점 진입 시뮬레이션 (AC12/AC13 테스트용).
  @visibleForTesting
  void enterShopForTest(List<ShopItem> items, {int? withGold}) {
    _eventHandler.reset();
    _shopHandler.enterForTest(items, withGold: withGold);
  }

  /// 테스트 전용: 미스터리 방 진입 시뮬레이션.
  @visibleForTesting
  void enterMysteryForTest(MysteryOutcome outcome, {int? withGold, int? withHp}) {
    _mysteryHandler.enterForTest(outcome, withGold: withGold, withHp: withHp);
  }

  /// 테스트 전용: NPC 방 진입 시뮬레이션.
  @visibleForTesting
  void enterNpcForTest(NpcData npcData, {int? withGold}) {
    _npcHandler.enterForTest(npcData, withGold: withGold);
  }

  /// 테스트 전용: 휴식 방 진입 시뮬레이션.
  @visibleForTesting
  void enterRestForTest({int? withHp, int? withMaxHp}) {
    _restHandler.enterForTest(withHp: withHp, withMaxHp: withMaxHp);
  }

  /// 테스트 전용: 보스 방 진입 시뮬레이션.
  @visibleForTesting
  void enterBossForTest({int? withHp, CombatEncounter? encounter}) {
    if (withHp != null) {
      _runController.playerRunState = _runController.playerRunState.copyWith(currentHp: withHp);
      _runController.runBloc.add(SetPlayerRunState(_runController.playerRunState));
    }
    final bossEncounter = encounter ??
        BossDemoEncounter.create(combatConfig: widget.combatConfig);
    _combatSession = _combatSession.copyWith(
      bossEncounter: bossEncounter,
      currentBossPhaseIndex: 0,
    );
    setCombatEncounter(bossEncounter);
  }

  /// 테스트 전용: 이벤트 방 진입 시뮬레이션.
  @visibleForTesting
  void enterEventForTest(EventRoomData eventData, {int? withGold, int? withHp}) {
    _bossFlowHandler.resetBossState();
    _eventHandler.enterForTest(eventData, withGold: withGold, withHp: withHp);
  }

  /// 테스트 전용: 런 리셋 시뮬레이션 (퍼마데스 후 재시작).
  @visibleForTesting
  void resetRunForTest(int maxHp) {
    _runController.resetRun(maxHp);
  }

  /// 테스트 전용: 방 진입 시뮬레이션.
  @visibleForTesting
  void simulateRoomEnteredForTest() {
    _runController.onRoomEntered();
  }

  /// 테스트 전용: completedBlocks 읽기.
  @visibleForTesting
  List<CompletedBlock> get completedBlocksForTest =>
      _runController.completedBlocks;

  /// 테스트 전용: pending 전직 블록을 completedBlocks로 flush.
  ///
  /// DungeonBloc 없이 전직 테스트 시 resumeAfterClassChange()가
  /// setTextBlockData()를 호출할 수 없어 pending 블록이 flush되지 않는 문제 해결.
  @visibleForTesting
  void flushPendingBlocksForTest() {
    _runController.clearCompletedBlocks();
  }

  /// 테스트 전용: 악마의 거래 진입 시뮬레이션.
  @visibleForTesting
  void enterDevilDealForTest(DevilDealData deal) {
    _eventHandler.reset();
    // ignore: invalid_use_of_visible_for_testing_member
    _shopHandler.enterDevilDealForTest(deal);
  }

  /// 테스트 전용: 엘리트 확인 진입 시뮬레이션 (enterShopForTest 패턴 동일).
  @visibleForTesting
  void enterEliteConfirmForTest({String nodeId = 'elite_node'}) {
    // ignore: invalid_use_of_visible_for_testing_member
    _dungeonNavHandler.enterEliteConfirmForTest(nodeId);
  }

  /// 테스트 전용: 카드 전투 진입 시뮬레이션.
  @visibleForTesting
  void enterCardCombatForTest(
    EnemyCombatData enemy,
    List<CardData> masterDeck, {
    int? withHp,
    RoomType roomType = RoomType.combat,
  }) {
    if (withHp != null) {
      _runController.playerRunState = _runController.playerRunState.copyWith(
        currentHp: withHp,
      );
      _runController.runBloc.add(SetPlayerRunState(_runController.playerRunState));
    }

    // ignore: invalid_use_of_protected_member
    setState(() {
      _inCardCombat = true;
      _inCombat = true;
      _showingChoices = true;
      _choiceSelected = false;
    });

    _combatBloc.add(StartCardCombat(
      enemies: [enemy],
      masterDeck: masterDeck,
      playerRunState: _runController.playerRunState,
      roomType: roomType,
    ));
  }

  /// 테스트 전용: 카드 전투 모드 여부.
  @visibleForTesting
  bool get inCardCombatForTest => _inCardCombat;

  /// 테스트 전용: CombatBloc 상태 접근.
  @visibleForTesting
  CombatState get combatStateForTest => _combatBloc.state;
}
