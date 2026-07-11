import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/core/config/floor_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/room_completed_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/build/bloc/build_bloc.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/combat/content/boss_enemies.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/domain/combat/content/boss_gimmick_text.dart';
import 'package:soul_dungeon/domain/combat/content/encounter_pool.dart';
import 'package:soul_dungeon/domain/combat/content/enemy_pool.dart';
import 'package:soul_dungeon/domain/combat/logic/starting_deck_builder.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/map_node.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/boss_flow_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/combat_session_state.dart';
import 'package:soul_dungeon/domain/narrative/content/boss_text_variants.dart';
import 'package:soul_dungeon/presentation/screens/game/disposition_hint_generator.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/screens/game/path_description_generator.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/boss_encounter_factory.dart';

/// 던전 탐색 핸들러 — GameScreen에서 추출.
///
/// 던전 상태 변화 디스패치, 경로 선택지 표시, 엘리트 확인,
/// 층 진행, 방 완료 로직을 담당.
/// BossFlowHandler/CardCombatHandler 콜백 패턴 동일 적용.
class DungeonNavigationHandler {
  final GameRunController runController;
  final BossFlowHandler bossFlowHandler;
  final CombatBloc combatBloc;
  final BuildBloc buildBloc;
  final GameEventBus gameEventBus;

  /// 텍스트 블록 설정 콜백.
  final void Function(List<TextBlockData> blocks, {bool endCombat})
      setTextBlockData;

  /// UI 상태 일괄 업데이트 콜백 — GameScreen.setState wrapper.
  final void Function({
    List<TextBlockData>? textBlockDataList,
    int? currentBlockIndex,
    bool? currentBlockComplete,
    bool? inCombat,
    bool? showingChoices,
    bool? choiceSelected,
    CombatSessionState? combatSession,
    bool? pendingCombatVictory,
  }) updateUI;

  /// 카드 전투 진입 — CardCombatHandler 위임 (멀티몹 지원).
  final Future<void> Function({
    required List<EnemyCombatData> enemies,
    required RoomType roomType,
  }) startCardCombat;

  /// 보스 카드 전투 진입 — CardCombatHandler 위임.
  final Future<void> Function(int floor, {BossCombatData? bossOverride}) startCardBossCombat;

  /// 방 핸들러 디스패치 — shop/mystery/npc/rest/event.
  final void Function(RoomType roomType, DungeonRoomEntered state)
      dispatchRoomEntry;

  /// 이벤트 핸들러 리셋.
  final VoidCallback resetEventHandler;

  /// DungeonBloc getter (nullable — 던전 미초기화 시).
  final DungeonBloc? Function() getDungeonBloc;

  /// 전투 세션 상태 getter/setter.
  final CombatSessionState Function() getCombatSession;
  final void Function(CombatSessionState) updateCombatSession;

  /// Config.
  final DispositionConfig dispositionConfig;
  final int wandererMaxDeviation;
  final CombatBalanceConfig combatConfig;
  final FloorsConfig floorsConfig;

  /// 소울 업그레이드 구매 완료 ID (시작 덱 업그레이드 등).
  final Set<String> purchasedUpgradeIds;

  /// 자동 저장 콜백.
  final VoidCallback autoSave;

  /// mounted 체크.
  final bool Function() isMounted;

  /// 텍스트 블록 전부 읽었는지 (경로 선택지 표시 조건).
  final bool Function() allBlocksRead;

  /// 층 전환 연출 콜백 — 오버레이 표시 후 onComplete 호출.
  final void Function(int targetFloor, VoidCallback onComplete)? showFloorTransition;

  DungeonNavigationHandler({
    required this.runController,
    required this.bossFlowHandler,
    required this.combatBloc,
    required this.buildBloc,
    required this.gameEventBus,
    required this.setTextBlockData,
    required this.updateUI,
    required this.startCardCombat,
    required this.startCardBossCombat,
    required this.dispatchRoomEntry,
    required this.resetEventHandler,
    required this.getDungeonBloc,
    required this.getCombatSession,
    required this.updateCombatSession,
    required this.dispositionConfig,
    required this.wandererMaxDeviation,
    required this.combatConfig,
    this.floorsConfig = const FloorsConfig([]),
    required this.purchasedUpgradeIds,
    required this.autoSave,
    required this.isMounted,
    required this.allBlocksRead,
    this.showFloorTransition,
  });

  // ── 내부 상태 ──────────────────────────────────────────────────────────
  bool _hasShownDungeonIntro = false;
  bool _pendingDungeonIntro = false;
  bool _showedClassChoiceUI = false;
  String? _pendingEliteNodeId;
  int? _pendingBossFloor;
  BossCombatData? _pendingBossData;
  final Set<String> _avoidedEliteNodeIds = {};

  /// 이어하기로 복원된 전투의 방 nodeId — 전투 완료 시 dungeonBloc 갱신에 사용.
  String? _restoredCombatNodeId;

  /// 엘리트 확인 대기 중인 노드 ID.
  String? get pendingEliteNodeId => _pendingEliteNodeId;

  /// 보스 준비 화면 대기 중 여부.
  bool get hasPendingBossPrep => _pendingBossFloor != null;

  /// 던전 인트로 보류 여부 — _advanceToNextBlock에서 확인.
  bool get pendingDungeonIntro => _pendingDungeonIntro;

  /// 던전 인트로 표시 완료 마킹 — 이어하기 전투 복원 시 사용.
  set hasShownDungeonIntro(bool value) => _hasShownDungeonIntro = value;

  /// 디버그 강제 전직 시 resumeAfterClassChange 허용을 위한 외부 플래그.
  set forceResumeAfterClassChange(bool value) => _showedClassChoiceUI = value;

  /// 이어하기로 복원된 전투의 방 nodeId 설정 — 전투 완료 시 dungeonBloc 갱신.
  set restoredCombatNodeId(String? value) => _restoredCombatNodeId = value;

  /// 층 전환 / 런 리스타트 시 내부 상태 초기화.
  void reset() {
    _hasShownDungeonIntro = false;
    _pendingDungeonIntro = false;
    _showedClassChoiceUI = false;
    _pendingEliteNodeId = null;
    _pendingBossFloor = null;
    _pendingBossData = null;
    _avoidedEliteNodeIds.clear();
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: BlocListener 핸들러
  // ════════════════════════════════════════════════════════════════════════

  /// DungeonBloc 상태 변경 핸들러 — 방 진입 / 경로 표시 디스패치.
  Future<void> onDungeonStateChanged(BuildContext context, DungeonBlocState dState) async {
    switch (dState) {
      case DungeonRoomEntered(:final roomType):
        _pendingDungeonIntro = false;
        final relicMessages = runController.onRoomEntered();
        _resetEliteConfirmation();

        // 보스 방 외 보스 상태 리셋
        if (roomType != RoomType.boss) _resetBossState();
        // 이벤트 방 외 이벤트 핸들러 리셋
        if (roomType != RoomType.event) resetEventHandler();

        switch (roomType) {
          case RoomType.combat:
            final floor = runController.playerRunState.currentFloor;
            final hpMult = floorsConfig.forFloor(floor).enemyHpMultiplier;
            final enemies = EncounterPool.generateNormalEncounter(
              floor,
              enemyHpMultiplier: hpMult,
            );
            await startCardCombat(enemies: enemies, roomType: RoomType.combat);
          case RoomType.elite:
            final floor = runController.playerRunState.currentFloor;
            final hpMult = floorsConfig.forFloor(floor).enemyHpMultiplier;
            var enemy = EnemyPool.randomEliteWithVariant(floor) ??
                EnemyPool.eliteEnemies(1).first;
            if (hpMult != 1.0) {
              enemy = enemy.copyWith(
                hp: (enemy.hp * hpMult).toInt().clamp(1, 9999),
              );
            }
            await startCardCombat(enemies: [enemy], roomType: RoomType.elite);
          case RoomType.boss:
            _enterBoss(dState);
          case RoomType.shop ||
              RoomType.mystery ||
              RoomType.npc ||
              RoomType.rest ||
              RoomType.event:
            dispatchRoomEntry(roomType, dState);
        }

        // 유물 효과 피드백 — 방 콘텐츠 설정 후 표시
        for (final msg in relicMessages) {
          runController.appendFeedbackText(msg);
        }

        tryShowDispositionHint();

      case DungeonFloorReady():
        if (_hasShownDungeonIntro) {
          // 방 완료 후 복귀 — 즉시 경로 선택지 표시
          _pendingDungeonIntro = false;
          showPathChoices(dState);
        } else {
          // 최초 입장 — 인트로 텍스트 완료 후 경로 선택지
          if (allBlocksRead()) {
            _pendingDungeonIntro = false;
            showPathChoices(dState);
          } else {
            _pendingDungeonIntro = true;
          }
        }

      case DungeonInitial():
        break;
      case DungeonBlocError():
        _resetEliteConfirmation();
        // 맵 생성 실패 복구 — 새 시드로 재시도
        GameLogger.warning(LogSystem.dungeon,
            'DungeonBlocError recovery: retrying floor generation');
        final floor = runController.playerRunState.currentFloor;
        final retrySeed = DateTime.now().millisecondsSinceEpoch;
        getDungeonBloc()?.add(GenerateFloor(floor: floor, seed: retrySeed));
        break;
    }
  }

  /// BuildBloc 상태 변경 핸들러 — 분화 텍스트 표시 + AcknowledgeClassChange.
  void onBuildStateChanged(BuildContext context, BuildState bState) {
    if (bState is BuildClassChoosing) {
      // 후보 2개 이상 → 전직 선택 UI 표시 (resumeAfterClassChange 필요)
      _showedClassChoiceUI = true;
      _showClassChangeChoices(
        bState.candidates,
        isSecondClassChange: bState.isSecondClassChange,
      );
    } else if (bState is BuildClassChanging) {
      final job = bState.newJob;
      if (bState.isSecondClassChange) {
        // 2차 전직: 기존 덱에 새 직업 카드 5장 추가 + jobId 갱신
        final existingDeck = runController.playerRunState.masterDeck;
        final newDeck = StartingDeckBuilder.addSecondClassCards(
          existingDeck,
          job.id,
        );
        runController.playerRunState =
            runController.playerRunState.copyWith(masterDeck: newDeck);
        // 2차 전직 jobId도 저장하여 이어하기 시 복원 가능
        runController.setCurrentJob(job.id);
        runController.appendClassChangeText(
          '영혼이 더 높은 경지에 이른다. ${job.displayName}(으)로 각성한다!',
        );
      } else {
        // 1차 전직: 기존 동작
        runController.setCurrentJob(job.id);
        // 시작 덱 생성 (직업 분화 시, 소울 업그레이드 + 저주 카드 반영)
        // 기존 덱에서 스타터 카드 제외한 획득 카드만 보존
        final starterDeck = StartingDeckBuilder.build(
          job.id,
          purchasedUpgradeIds: purchasedUpgradeIds,
          activeCurseIds: runController.playerRunState.activeCurseIds,
        );
        final acquiredCards = runController.playerRunState.masterDeck
            .where((card) => !card.id.startsWith('starter_'))
            .toList();
        final mergedDeck = [...starterDeck, ...acquiredCards];
        runController.playerRunState =
            runController.playerRunState.copyWith(masterDeck: mergedDeck);
        runController.appendClassChangeText(
          '영혼의 깊은 곳에서 ${job.displayName}의 힘이 깨어난다.',
        );
      }
      buildBloc.add(const AcknowledgeClassChange());
    }
  }

  /// 전직 후보 선택 UI 표시.
  void _showClassChangeChoices(
    List<JobPath> candidates, {
    bool isSecondClassChange = false,
  }) {
    final choices = candidates.map((job) {
      final prefix = job.isHidden ? '✦ ' : '';
      return ChoiceData(
        id: 'class_select_${job.id}',
        text: '$prefix${job.displayName}',
        resultTextBlocks: [job.description],
        choiceStyle: job.isHidden ? ChoiceStyle.caution : ChoiceStyle.normal,
      );
    }).toList();

    final headerText = isSecondClassChange
        ? '영혼이 더 높은 경지로 향하는 갈림길에 섰다.'
        : '영혼이 분화의 갈림길에 섰다.';

    setTextBlockData([
      TextBlockData(text: headerText),
      TextBlockData(
        text: '어떤 길을 걸을 것인가?',
        choices: choices,
      ),
    ], endCombat: false);
  }

  /// 전직 후보 선택 처리 — ChoiceRouter에서 호출.
  void handleClassSelect(String jobId) {
    final bState = buildBloc.state;
    if (bState is! BuildClassChoosing) return;

    final selected = bState.candidates.firstWhere(
      (j) => j.id == jobId,
      orElse: () => bState.candidates.first,
    );
    buildBloc.add(SelectClassCandidate(selected));
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 경로 선택지 / 엘리트 확인
  // ════════════════════════════════════════════════════════════════════════

  /// DungeonFloorReady 도착 시 경로 선택지 표시.
  void showPathChoices(DungeonFloorReady dState) {
    final currentNode = dState.floorMap.nodeById(dState.currentNodeId);
    if (currentNode == null) {
      GameLogger.warning(LogSystem.dungeon,
          'showPathChoices: currentNode ${dState.currentNodeId} not found in map');
      return;
    }

    final nextNodes = currentNode.nextNodeIds
        .where((id) => !dState.visitedNodeIds.contains(id))
        .where((id) => !_avoidedEliteNodeIds.contains(id))
        .map((id) => dState.floorMap.nodeById(id))
        .whereType<MapNode>()
        .toList();

    if (nextNodes.isEmpty) {
      final bossId = dState.floorMap.bossNodeId;

      // 보스 클리어 후 복구 — 전직 선택 → completeDungeonRoom 경로로
      // 보스 노드에서 DungeonFloorReady가 된 경우 층 진행 선택지 표시
      if (dState.currentNodeId == bossId &&
          dState.visitedNodeIds.contains(bossId)) {
        _showAdvanceFloorAfterBoss();
        return;
      }

      // 인접 미방문 노드가 없음 — 보스가 직접 연결 + 미방문 시 보스 선택지 제공
      if (currentNode.nextNodeIds.contains(bossId) &&
          !dState.visitedNodeIds.contains(bossId)) {
        final bossNode = dState.floorMap.nodeById(bossId);
        if (bossNode != null) {
          final blocks = <TextBlockData>[];
          if (!_hasShownDungeonIntro) {
            _hasShownDungeonIntro = true;
            final floor = runController.playerRunState.currentFloor;
            blocks.add(TextBlockData(text: _floorIntroText(floor)));
          }
          blocks.add(TextBlockData(
            text: '탐색할 수 있는 길은 모두 지나왔다. 깊은 곳에서 강대한 기운이 느껴진다.',
            choices: [
              ChoiceData(
                id: 'path_$bossId',
                text: '보스의 방으로 향한다',
                resultTextBlocks: const [],
                choiceStyle: ChoiceStyle.caution,
              ),
            ],
          ));
          setTextBlockData(blocks, endCombat: false);
          return;
        }
      }
      // 회피한 엘리트 노드가 있으면 다시 표시 (소프트 락 방지)
      if (_avoidedEliteNodeIds.isNotEmpty) {
        _avoidedEliteNodeIds.clear();
        showPathChoices(dState);
        return;
      }
      GameLogger.warning(LogSystem.dungeon,
          'showPathChoices: no unvisited nextNodes from ${dState.currentNodeId}');
      return;
    }

    final descMap = PathDescriptionGenerator.describeAll(
      nextNodes.map((n) => (n.roomType, n.id)).toList(),
    );

    final choices = nextNodes
        .map((node) => ChoiceData(
              id: 'path_${node.id}',
              text: descMap[node.id] ?? '알 수 없는 통로',
              resultTextBlocks: const [],
            ))
        .toList();

    final pathText = nextNodes.length == 1
        ? '앞에 하나의 길이 보인다.'
        : '앞에 ${nextNodes.length}갈래의 길이 보인다.';

    final blocks = <TextBlockData>[];

    if (!_hasShownDungeonIntro) {
      _hasShownDungeonIntro = true;
      final floor = runController.playerRunState.currentFloor;
      blocks.add(TextBlockData(text: _floorIntroText(floor)));
    }

    blocks.add(TextBlockData(text: pathText, choices: choices));
    setTextBlockData(blocks, endCombat: false);
  }

  /// 텍스트 블록 소진 후 보류된 경로 선택지 표시 — _advanceToNextBlock에서 호출.
  void checkPendingDungeonIntro() {
    if (!_pendingDungeonIntro) return;
    _pendingDungeonIntro = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) return;
      final dState = getDungeonBloc()?.state;
      if (dState is DungeonFloorReady) {
        showPathChoices(dState);
      }
    });
  }

  /// 전직 완료 후 던전 진행 재개.
  ///
  /// 보류된 인트로가 있으면 소진(일반 플로우),
  /// DungeonFloorReady이면 직접 경로 선택지 표시,
  /// DungeonRoomEntered이면 방 완료 처리 후 다음 진행.
  void resumeAfterClassChange() {
    GameLogger.info(LogSystem.dungeon,
        '[RESUME] resumeAfterClassChange called | pendingIntro=$_pendingDungeonIntro showedUI=$_showedClassChoiceUI');
    if (_pendingDungeonIntro) {
      GameLogger.info(LogSystem.dungeon, '[RESUME] → pendingDungeonIntro path');
      checkPendingDungeonIntro();
      return;
    }
    // 자동 전직(후보 1명)은 선택 UI 없이 완료 → 경로 선택지가 이미 표시 중이므로
    // showPathChoices 재호출 시 _showingChoices가 리셋되어 선택 불가 버그 발생.
    // 전직 선택 UI를 표시한 경우에만 경로 선택지를 복원한다.
    if (!_showedClassChoiceUI) {
      GameLogger.info(LogSystem.dungeon, '[RESUME] → EARLY RETURN: _showedClassChoiceUI is false');
      return;
    }
    _showedClassChoiceUI = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) {
        GameLogger.warning(LogSystem.dungeon, '[RESUME] → NOT MOUNTED, abort');
        return;
      }
      final dState = getDungeonBloc()?.state;
      GameLogger.info(LogSystem.dungeon,
          '[RESUME] postFrame → dungeonState=${dState?.runtimeType}');
      if (dState is DungeonFloorReady) {
        // 탐색 화면(디버그 전직 등) — 즉시 경로 선택지 표시
        GameLogger.info(LogSystem.dungeon, '[RESUME] → showPathChoices');
        showPathChoices(dState);
      } else if (dState is DungeonRoomEntered) {
        if (dState.roomType == RoomType.boss) {
          // 보스방에서 전직 발생 → advance_floor 선택지 재표시
          // (보스 보상의 applyDisposition이 전직 트리거 → 기존 advance_floor 텍스트 유실)
          GameLogger.info(LogSystem.dungeon, '[RESUME] → _showAdvanceFloorAfterBoss');
          _showAdvanceFloorAfterBoss();
        } else {
          // 일반 방에서 전직 완료 — 방 완료 처리 후 다음 진행
          GameLogger.info(LogSystem.dungeon, '[RESUME] → completeDungeonRoom');
          completeDungeonRoom();
        }
      } else {
        GameLogger.warning(LogSystem.dungeon,
            '[RESUME] → NO MATCH for dungeonState ${dState?.runtimeType}, screen stuck!');
      }
    });
  }

  /// 보스방 전직 후 층 진행 선택지 표시.
  ///
  /// 보스 보상의 applyDisposition → checkClassChange → 전직 선택 UI 표시 시
  /// 기존 advance_floor 텍스트가 교체되므로, 전직 완료 후 재표시.
  void _showAdvanceFloorAfterBoss() {
    final floor = runController.playerRunState.currentFloor;
    if (floor >= 5) {
      // 최종 층 — 전직 UI로 엔딩 텍스트가 유실된 경우 엔딩 재표시.
      // handleAdvanceFloor()는 6층 생성을 시도하여 게임 프리즈를 유발하므로 금지.
      final bossChoices = runController.playerRunState.bossChoices;
      if (bossChoices.isNotEmpty) {
        final lastChoice = bossChoices.last;
        final resultText = BossTextVariants.choiceResultText(
          lastChoice.bossId,
          lastChoice.choiceType,
          jobId: runController.playerRunState.currentJobId,
        );
        bossFlowHandler.showEnding(resultText);
      }
      return;
    }
    setTextBlockData([
      TextBlockData(
        text: '$floor층을 클리어했다. 더 깊은 곳으로 향하는 계단이 나타난다.',
        choices: [
          ChoiceData(
            id: 'advance_floor',
            text: '${floor + 1}층으로 내려간다',
            resultTextBlocks: const [],
          ),
        ],
      ),
    ], endCombat: false);
  }

  /// 경로 선택 처리 — 엘리트 확인 또는 즉시 진입.
  void handlePathSelection(ChoiceData choice) {
    final nodeId = choice.id.substring(5);
    final dState = getDungeonBloc()?.state;
    if (dState is DungeonFloorReady) {
      final node = dState.floorMap.nodeById(nodeId);
      if (node != null && node.roomType == RoomType.elite) {
        _pendingEliteNodeId = nodeId;
        setTextBlockData(_buildEliteConfirmBlocks(), endCombat: false);
      } else {
        getDungeonBloc()?.add(SelectNode(nodeId));
      }
    }
  }

  /// 엘리트 도전 선택.
  void handleEliteChallenge() {
    final nodeId = _pendingEliteNodeId;
    if (nodeId == null) return;
    _pendingEliteNodeId = null;
    runController.applyDisposition({
      DispositionAxis.struggle: dispositionConfig.eliteChallengeReward,
    });
    getDungeonBloc()?.add(SelectNode(nodeId));
  }

  /// 엘리트 회피 선택.
  void handleEliteAvoid() {
    final avoidedId = _pendingEliteNodeId;
    _pendingEliteNodeId = null;
    if (avoidedId != null) _avoidedEliteNodeIds.add(avoidedId);
    runController.applyDisposition({
      DispositionAxis.shadow: dispositionConfig.eliteAvoidReward,
    });
    _pendingDungeonIntro = true;
    setTextBlockData([
      const TextBlockData(text: '다른 길을 선택하기로 했다.'),
    ], endCombat: false);
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 층 진행 / 방 완료 / 전투 종료
  // ════════════════════════════════════════════════════════════════════════

  /// 층 진행 처리 — 자동 저장, 상태 리셋, 새 층 맵 생성.
  void handleAdvanceFloor() {
    final nextFloor = runController.playerRunState.currentFloor + 1;

    // 층 전환 자동 저장
    autoSave();

    // 층 전환 연출이 있으면 오버레이 → 완료 후 진행
    if (showFloorTransition != null) {
      showFloorTransition!(nextFloor, () => _executeFloorAdvance(nextFloor));
    } else {
      _executeFloorAdvance(nextFloor);
    }
  }

  void _executeFloorAdvance(int nextFloor) {
    // RunBloc 층 진행
    runController.advanceFloor();

    // 층 전환 상태 리셋
    runController.clearCompletedBlocks();
    _hasShownDungeonIntro = false;
    _pendingDungeonIntro = false;
    _showedClassChoiceUI = false;

    updateUI(
      combatSession: getCombatSession().resetBoss(),
      inCombat: false,
      textBlockDataList: [],
      currentBlockIndex: 0,
      currentBlockComplete: false,
      showingChoices: false,
      choiceSelected: false,
    );

    // 새 층 맵 생성
    final newSeed = DateTime.now().millisecondsSinceEpoch;
    runController.playerRunState =
        runController.playerRunState.copyWith(dungeonSeed: newSeed);
    getDungeonBloc()?.add(GenerateFloor(
      floor: nextFloor,
      seed: newSeed,
    ));
  }

  /// 방 콘텐츠 완료 시 호출 — DungeonBloc에 CompleteRoom 발행.
  void completeDungeonRoom() {
    final dState = getDungeonBloc()?.state;
    if (dState is DungeonRoomEntered) {
      gameEventBus.emit(RoomCompletedEvent(nodeId: dState.currentNodeId));
      getDungeonBloc()?.add(const CompleteRoom());
    } else if (dState is DungeonFloorReady) {
      // 이어하기로 복원된 전투 종료
      final combatNodeId = _restoredCombatNodeId;
      if (combatNodeId != null) {
        // 전투 방 nodeId를 visitedNodeIds에 추가 + currentNodeId 갱신
        _restoredCombatNodeId = null;
        gameEventBus.emit(RoomCompletedEvent(nodeId: combatNodeId));
        getDungeonBloc()?.add(CompleteCombatRoom(nodeId: combatNodeId));
      } else {
        showPathChoices(dState);
      }
    }
  }

  /// 전투 종료 + 방 완료 — 레거시 전투 결과 처리 후 방 전환.
  void endCombatAndCompleteRoom() {
    updateUI(inCombat: false, pendingCombatVictory: false);
    combatBloc.add(const EndCombat());
    completeDungeonRoom();
  }

  /// 물러나기 (전투 포기).
  void handleRetreat() => endCombatAndCompleteRoom();

  // ════════════════════════════════════════════════════════════════════════
  // SECTION: 내부 유틸리티
  // ════════════════════════════════════════════════════════════════════════

  void _resetEliteConfirmation() {
    _pendingEliteNodeId = null;
  }

  List<TextBlockData> _buildEliteConfirmBlocks() {
    final hint = GameHintManager.checkAndMark(GameHintManager.hintElite)
        ? '\n\n${GameHintManager.eliteText}'
        : '';
    return [
        TextBlockData(
          text: '이곳에서 강한 적의 기척이 느껴진다. 보상은 크겠지만, 위험 또한 클 것이다.$hint',
        ),
        TextBlockData(
          text: '',
          choices: [
            ChoiceData(
              id: 'elite_challenge',
              text: '⚔ 도전한다',
              resultTextBlocks: const [],
              choiceStyle: ChoiceStyle.caution,
            ),
            ChoiceData(
              id: 'elite_avoid',
              text: '↩ 다른 길을 찾는다',
              resultTextBlocks: const [],
            ),
          ],
        ),
      ];
  }

  void _resetBossState() {
    bossFlowHandler.resetBossState();
  }

  /// BuildBloc에 전직 평가 이벤트 전달 — 성향 변경 후 호출.
  /// 이미 1차 전직 완료(BuildSpecialized) 시 2차 전직 평가,
  /// 미분화(BuildUnspecialized) 시 1차 전직 평가.
  void checkClassChange() {
    final disposition = runController.playerRunState.disposition;
    final bState = buildBloc.state;
    if (bState is BuildSpecialized) {
      // 1차 전직 완료 → 2차 전직 평가
      buildBloc.add(EvaluateSecondClassChange(disposition));
    } else {
      // 미분화 → 1차 전직 평가
      buildBloc.add(EvaluateClassChange(disposition));
    }
  }

  /// 성향 힌트 표시 시도 — 조건 충족 시 CompletedBlock 추가.
  void tryShowDispositionHint() {
    final hint = DispositionHintGenerator.generateHint(
      disposition: runController.playerRunState.disposition,
      roomsSinceLastHint: runController.roomsSinceLastHint,
      hintIndex: runController.hintIndex,
      config: dispositionConfig,
      harmonyMaxDeviation: wandererMaxDeviation,
    );
    if (hint != null) {
      runController.appendDispositionHint(hint);
      runController.onHintShown();
    }
  }

  /// 보스 방 진입 — 준비 화면 표시 후 전투 시작.
  void _enterBoss(DungeonRoomEntered dState) {
    final floor = runController.playerRunState.currentFloor;
    _pendingBossFloor = floor;

    final bossData = BossEnemies.randomForFloor(floor) ??
        BossEnemies.forFloor(floor);
    _pendingBossData = bossData;
    final bossName = bossData?.name ?? '미지의 존재';
    final gimmick = (bossData != null && bossData.phases.isNotEmpty)
        ? bossData.phases.first.gimmick
        : null;
    final hintText = gimmick != null
        ? BossGimmickText.hintText(bossName, gimmick)
        : '특별한 능력은 없는 것 같다.';

    final deck = runController.playerRunState.effectiveDeck;
    final atkCount = deck.where((c) => c.type.name == 'attack').length;
    final sklCount = deck.where((c) => c.type.name == 'skill').length;
    final pwrCount = deck.where((c) => c.type.name == 'power').length;
    final deckSummary = '덱: ${deck.length}장 (공격 $atkCount / 스킬 $sklCount / 파워 $pwrCount)';

    final hp = runController.playerRunState.currentHp;
    final maxHp = runController.playerRunState.maxHp;

    setTextBlockData([
      TextBlockData(text: '보스의 방 앞에 도달했다. 문 너머에서 강대한 기운이 느껴진다.'),
      TextBlockData(text: '— $bossName —\n$hintText'),
      TextBlockData(
        text: '♥ $hp/$maxHp  |  $deckSummary',
        choices: [
          ChoiceData(
            id: 'boss_prep_fight',
            text: '⚔ 전투 시작',
            resultTextBlocks: const [],
            choiceStyle: ChoiceStyle.caution,
          ),
          ChoiceData(
            id: 'boss_prep_status',
            text: '📋 상태 확인',
            resultTextBlocks: const [],
          ),
        ],
      ),
    ], endCombat: false);

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'Boss prep screen: $bossName (floor $floor)');
    }
  }

  /// 보스 준비 화면에서 "전투 시작" 선택.
  Future<void> handleBossPrepFight() async {
    final floor = _pendingBossFloor;
    if (floor == null) return;
    final selectedBoss = _pendingBossData;
    _pendingBossFloor = null;
    _pendingBossData = null;

    final encounter = BossEncounterFactory.create(
      floor: floor,
      combatConfig: combatConfig,
    );
    updateCombatSession(getCombatSession().copyWith(
      bossEncounter: encounter,
      currentBossPhaseIndex: 0,
    ));
    await startCardBossCombat(floor, bossOverride: selectedBoss);

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'Boss fight started: ${encounter.enemyName} (floor $floor)');
    }
  }

  /// 보스 준비 화면에서 "상태 확인" 선택 후 다시 준비 화면 복귀.
  void handleBossPrepStatusReturn() {
    final floor = _pendingBossFloor;
    if (floor == null) return;
    // 기존 _enterBoss에서 선택한 보스 데이터 재사용
    final bossData = _pendingBossData;
    final bossName = bossData?.name ?? '미지의 존재';
    final gimmick = bossData?.phases.first.gimmick;
    final hintText = gimmick != null
        ? BossGimmickText.hintText(bossName, gimmick)
        : '특별한 능력은 없는 것 같다.';

    final deck = runController.playerRunState.effectiveDeck;
    final atkCount = deck.where((c) => c.type.name == 'attack').length;
    final sklCount = deck.where((c) => c.type.name == 'skill').length;
    final pwrCount = deck.where((c) => c.type.name == 'power').length;
    final deckSummary = '덱: ${deck.length}장 (공격 $atkCount / 스킬 $sklCount / 파워 $pwrCount)';

    final hp = runController.playerRunState.currentHp;
    final maxHp = runController.playerRunState.maxHp;

    setTextBlockData([
      TextBlockData(text: '— $bossName —\n$hintText'),
      TextBlockData(
        text: '♥ $hp/$maxHp  |  $deckSummary',
        choices: [
          ChoiceData(
            id: 'boss_prep_fight',
            text: '⚔ 전투 시작',
            resultTextBlocks: const [],
            choiceStyle: ChoiceStyle.caution,
          ),
          ChoiceData(
            id: 'boss_prep_status',
            text: '📋 상태 확인',
            resultTextBlocks: const [],
          ),
        ],
      ),
    ], endCombat: false);
  }

  /// 층별 인트로 텍스트.
  String _floorIntroText(int floor) {
    switch (floor) {
      case 1:
        return '던전 1층에 발을 들인다. 어둠 속에서 여러 갈래의 길이 보인다.';
      case 2:
        return '2층으로 내려선다. 공기가 한층 더 무겁다.';
      case 3:
        return '3층. 벽에서 희미한 빛이 새어 나온다.';
      case 4:
        return '4층. 이곳의 어둠은 살아 움직이는 듯하다.';
      case 5:
        return '최심층에 도달했다. 던전의 심장부가 고동친다.';
      default:
        return '던전 $floor층에 발을 들인다.';
    }
  }

  /// 테스트 전용: 엘리트 확인 진입 시뮬레이션.
  @visibleForTesting
  void enterEliteConfirmForTest(String nodeId) {
    _pendingEliteNodeId = nodeId;
    setTextBlockData(_buildEliteConfirmBlocks(), endCombat: false);
  }
}
