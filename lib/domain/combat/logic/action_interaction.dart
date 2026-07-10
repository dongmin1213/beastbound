import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 행동 상호작용 판정 유틸리티
class ActionInteraction {
  ActionInteraction._();

  /// 플레이어 행동 vs 적 행동 → 결과 등급
  static ActionResult getResult(
    ActionType player,
    EnemyActionType enemy,
  ) {
    return switch ((player, enemy)) {
      (ActionType.attack, EnemyActionType.attack) => ActionResult.neutral,
      (ActionType.attack, EnemyActionType.defend) => ActionResult.ineffective,
      (ActionType.attack, EnemyActionType.observe) => ActionResult.effective,
      (ActionType.attack, EnemyActionType.heavy) => ActionResult.neutral,
      (ActionType.attack, EnemyActionType.charge) => ActionResult.effective,
      (ActionType.attack, EnemyActionType.heal) => ActionResult.effective,
      (ActionType.attack, EnemyActionType.buff) => ActionResult.effective,
      (ActionType.defend, EnemyActionType.attack) => ActionResult.effective,
      (ActionType.defend, EnemyActionType.defend) => ActionResult.neutral,
      (ActionType.defend, EnemyActionType.observe) => ActionResult.ineffective,
      (ActionType.defend, EnemyActionType.heavy) => ActionResult.effective,
      (ActionType.defend, EnemyActionType.charge) => ActionResult.neutral,
      (ActionType.defend, EnemyActionType.heal) => ActionResult.neutral,
      (ActionType.defend, EnemyActionType.buff) => ActionResult.neutral,
      (ActionType.observe, EnemyActionType.attack) => ActionResult.ineffective,
      (ActionType.observe, EnemyActionType.defend) => ActionResult.neutral,
      (ActionType.observe, EnemyActionType.observe) => ActionResult.effective,
      (ActionType.observe, EnemyActionType.heavy) => ActionResult.ineffective,
      (ActionType.observe, EnemyActionType.charge) => ActionResult.neutral,
      (ActionType.observe, EnemyActionType.heal) => ActionResult.neutral,
      (ActionType.observe, EnemyActionType.buff) => ActionResult.neutral,
      // 환경 활용은 관찰 투자에 대한 보상 — 항상 effective
      (ActionType.environment, _) => ActionResult.effective,
      // 특수 행동은 SpecialActionResolver 경유 — 여기선 폴백 effective
      (ActionType.special, _) => ActionResult.effective,
    };
  }

  /// 결과 등급 + 행동 조합에 따른 결과 텍스트
  static String getResultText(
    ActionType player,
    EnemyActionType enemy,
  ) {
    return switch ((player, enemy)) {
      (ActionType.attack, EnemyActionType.attack) => '양쪽의 공격이 맞부딪힌다!',
      (ActionType.attack, EnemyActionType.defend) => '적의 방어에 공격이 막힌다.',
      (ActionType.attack, EnemyActionType.observe) =>
        '무방비 상태의 적에게 강한 일격을 날렸다!',
      (ActionType.attack, EnemyActionType.heavy) => '양쪽의 공격이 맞부딪힌다!',
      (ActionType.attack, EnemyActionType.charge) =>
        '적이 힘을 모으는 틈을 노려 공격했다!',
      (ActionType.attack, EnemyActionType.heal) =>
        '적이 회복하는 틈을 노려 공격했다!',
      (ActionType.attack, EnemyActionType.buff) =>
        '적이 강화하는 틈을 노려 공격했다!',
      (ActionType.defend, EnemyActionType.attack) => '적의 공격을 견고히 막아냈다!',
      (ActionType.defend, EnemyActionType.defend) => '양쪽 모두 방어 자세로 대치한다.',
      (ActionType.defend, EnemyActionType.observe) =>
        '적이 관찰하는데 방어만 하고 있다...',
      (ActionType.defend, EnemyActionType.heavy) => '적의 강타를 견고히 막아냈다!',
      (ActionType.defend, EnemyActionType.charge) =>
        '양쪽 모두 방어 자세로 대치한다.',
      (ActionType.defend, EnemyActionType.heal) =>
        '양쪽 모두 방어 자세로 대치한다.',
      (ActionType.defend, EnemyActionType.buff) =>
        '양쪽 모두 방어 자세로 대치한다.',
      (ActionType.observe, EnemyActionType.attack) =>
        '적의 공격에 맞으며 관찰한다... 아프다.',
      (ActionType.observe, EnemyActionType.defend) => '방어 중인 적을 안전하게 관찰한다.',
      (ActionType.observe, EnemyActionType.observe) =>
        '서로 관찰하며 깊은 통찰을 얻었다!',
      (ActionType.observe, EnemyActionType.heavy) =>
        '적의 강타에 맞으며 관찰한다... 아프다.',
      (ActionType.observe, EnemyActionType.charge) =>
        '적이 힘을 모으는 동안 안전하게 관찰한다.',
      (ActionType.observe, EnemyActionType.heal) =>
        '적이 회복하는 동안 안전하게 관찰한다.',
      (ActionType.observe, EnemyActionType.buff) =>
        '적이 강화하는 동안 안전하게 관찰한다.',
      // 환경 활용: actionHint 기반 텍스트는 GameScreen에서 생성. 폴백 텍스트.
      (ActionType.environment, _) => '환경을 활용했다!',
      // 특수 행동: SpecialActionResolver.getResultText 경유. 폴백 텍스트.
      (ActionType.special, _) => '특수 행동을 사용했다!',
    };
  }

  /// 결과 등급에 따른 접두사
  static String getResultPrefix(ActionResult result) {
    return switch (result) {
      ActionResult.effective => '✦ ',
      ActionResult.neutral => '- ',
      ActionResult.ineffective => '✧ ',
    };
  }
}
