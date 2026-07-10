import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// ChoiceRouter가 GameScreenState에 접근하기 위한 콜백 인터페이스.
///
/// GameScreenState가 이를 구현하고, ChoiceRouter는 인터페이스만 참조.
/// Step 3~4(BossFlowHandler, PrepPhaseHandler)에서도 재사용 가능.
abstract class GameScreenActions {
  // ── 상태 읽기 ──
  bool get isChoiceSelected;
  bool get isInPrepPhase;
  bool get hasDevilDeal;
  String? get pendingEliteNodeId;
  bool get hasPendingBossPrep;

  // ── 핸들러 ──
  void handleRestartRun();
  void handleAdvanceFloor();
  void handleBossChoice(ChoiceData choice);
  void handleBossContinue();
  void handleRetreat();
  void handlePrepChoice(ChoiceData choice);
  void handleDevilChoice(ChoiceData choice);
  void handlePathSelection(ChoiceData choice);
  void handleEliteChallenge();
  void handleEliteAvoid();
  void handleCombatAction(ChoiceData choice);

  // ── 유령 NPC ──
  Future<void> handleGhostChoice(ChoiceData choice);

  // ── 보스 준비 ──
  Future<void> handleBossPrepFight();
  void handleBossPrepStatus();

  // ── 카드 전투 ──
  void handlePlayCard(ChoiceData choice);
  void handleEndTurn();
  void handleAttemptFlee();
  void handleSelectCardReward(ChoiceData choice);

  // ── 상점 카드 제거 ──
  bool get hasPendingCardRemoval;
  void handleCardRemovalChoice(ChoiceData choice);

  // ── 미스터리 방 선택 (모험가의 지도) ──
  bool get hasPendingMysteryChoice;
  void handleMysteryChoice(ChoiceData choice);

  // ── 전직 선택 ──
  void handleClassSelect(ChoiceData choice);
}
