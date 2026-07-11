import 'package:soul_dungeon/presentation/screens/game/game_screen_actions.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 선택지 라우팅 — `_onChoiceSelected()` God Method의 if/else 분기를 정리.
///
/// 각 분기를 [GameScreenActions] 인터페이스를 통해 위임하므로
/// GameScreenState의 private 멤버에 직접 의존하지 않음.
/// E5.5에서 카드 전투 분기(play_card, card_reward, end_turn 등)를
/// 이 라우터에 추가하면 GameScreen 확장 없이 분기 관리 가능.
class ChoiceRouter {
  final GameScreenActions actions;

  ChoiceRouter({required this.actions});

  /// 선택지를 적절한 핸들러로 라우팅.
  void route(ChoiceData choice) {
    if (actions.isChoiceSelected) return;

    final id = choice.id;

    // 퍼마데스 후 재시작
    if (id == 'restart_run') return actions.handleRestartRun();

    // 층 전환
    if (id == 'advance_floor') return actions.handleAdvanceFloor();

    // 전투 패배 후 물러나기
    if (id == 'retreat') return actions.handleRetreat();

    // 유령 NPC 선택지

    // 보스 페이즈 전환
    if (id == 'boss_continue') return actions.handleBossContinue();

    // 보스 준비 화면 (boss_prep_* → boss_* 보다 먼저 체크)
    if (id == 'boss_prep_fight' && actions.hasPendingBossPrep) {
      actions.handleBossPrepFight();
      return;
    }
    if (id == 'boss_prep_status' && actions.hasPendingBossPrep) {
      return actions.handleBossPrepStatus();
    }

    // 보스 3선택지 (처치/해방/공존)
    if (id.startsWith('boss_')) return actions.handleBossChoice(choice);

    // 준비 페이즈 선택 (일반 선택 또는 프리셋 빠른 시작)
    if (actions.isInPrepPhase &&
        (id.startsWith('prep_') || id.startsWith('preset_'))) {
      return actions.handlePrepChoice(choice);
    }

    // 악마의 거래
    if (id.startsWith('devil_') && actions.hasDevilDeal) {
      return actions.handleDevilChoice(choice);
    }

    // 경로 선택 (텍스트 선택지로 던전 이동)
    if (id.startsWith('path_')) return actions.handlePathSelection(choice);

    // 엘리트 확인: 도전
    if (id == 'elite_challenge' && actions.pendingEliteNodeId != null) {
      return actions.handleEliteChallenge();
    }

    // 엘리트 확인: 회피
    if (id == 'elite_avoid' && actions.pendingEliteNodeId != null) {
      return actions.handleEliteAvoid();
    }

    // 미스터리 방 선택 (모험가의 지도)
    if (id.startsWith('mystery_choice_') && actions.hasPendingMysteryChoice) {
      return actions.handleMysteryChoice(choice);
    }

    // 상점 카드 제거 선택
    if (id.startsWith('card_removal_') && actions.hasPendingCardRemoval) {
      return actions.handleCardRemovalChoice(choice);
    }

    // 카드 전투: 카드 플레이
    if (id.startsWith('play_card_')) return actions.handlePlayCard(choice);

    // 카드 전투: 턴 종료
    if (id == 'end_turn') return actions.handleEndTurn();

    // 카드 전투: 도주
    if (id == 'flee') return actions.handleAttemptFlee();

    // 카드 전투: 카드 보상 선택 / 건너뛰기
    if (id.startsWith('card_reward_') || id == 'skip_reward') {
      return actions.handleSelectCardReward(choice);
    }

    // Default: 전투 행동 처리
    actions.handleCombatAction(choice);
  }
}
