import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 직업별 특수 행동 결과 판정 유틸리티.
///
/// 각 직업의 specialActionType에 따라 적 행동과의 상호작용 결과를 결정한다.
/// 특수 행동은 기본 행동(공격/방어/관찰)보다 전반적으로 유리하지만,
/// 직업별로 고유한 약점이 존재한다.
class SpecialActionResolver {
  SpecialActionResolver._();

  /// 특수 행동 결과 판정.
  ///
  /// [specialActionType]: JobPath.specialActionType (e.g. 'powerStrike')
  /// [enemyAction]: 현재 턴 적 행동
  /// 미등록 specialActionType → neutral 폴백.
  static ActionResult getResult(
    String specialActionType,
    EnemyActionType enemyAction,
  ) {
    return switch (specialActionType) {
      'powerStrike' => _powerStrike(enemyAction),
      'divineHeal' => _divineHeal(enemyAction),
      'insight' => _insight(enemyAction),
      'shadowStrike' => _shadowStrike(enemyAction),
      'ironWall' => _ironWall(enemyAction),
      'adapt' => _adapt(enemyAction),
      _ => ActionResult.neutral,
    };
  }

  /// 특수 행동 결과 텍스트.
  static String getResultText(
    String specialActionType,
    EnemyActionType enemyAction,
  ) {
    final result = getResult(specialActionType, enemyAction);
    return switch (specialActionType) {
      'powerStrike' => switch (result) {
          ActionResult.effective => '압도적인 힘으로 적을 강타했다!',
          ActionResult.neutral => '강타가 적의 방어에 부딪혔지만 밀어냈다.',
          ActionResult.ineffective => '강타가 빗나갔다.',
        },
      'divineHeal' => switch (result) {
          ActionResult.effective => '신성한 빛이 적의 공격을 막아내며 상처를 치유한다!',
          ActionResult.neutral => '치유의 빛이 빛나지만 효과가 미미하다.',
          ActionResult.ineffective => '치유의 빛이 흩어졌다.',
        },
      'insight' => switch (result) {
          ActionResult.effective => '깊은 통찰로 적의 약점을 꿰뚫었다!',
          ActionResult.neutral => '적의 의도를 읽었지만 대응할 틈이 없다.',
          ActionResult.ineffective => '통찰이 빗나갔다.',
        },
      'shadowStrike' => switch (result) {
          ActionResult.effective => '그림자 속에서 치명적 일격을 날렸다!',
          ActionResult.neutral => '그림자 일격이 빗나갔지만 혼란을 줬다.',
          ActionResult.ineffective => '적이 그림자의 움직임을 감지했다!',
        },
      'ironWall' => switch (result) {
          ActionResult.effective => '철벽 방어로 적의 공세를 완벽히 막았다!',
          ActionResult.neutral => '철벽을 세웠지만 적도 움직이지 않는다.',
          ActionResult.ineffective => '철벽 방어가 효과가 없었다.',
        },
      'adapt' => switch (result) {
          ActionResult.effective => '적의 움직임에 완벽히 적응하여 역이용했다!',
          ActionResult.neutral => '적응했지만 결정적 기회는 아니다.',
          ActionResult.ineffective => '적응이 실패했다.',
        },
      _ => '특수 행동을 사용했다.',
    };
  }

  /// 특수 행동 표시 이름.
  static String getDisplayName(String specialActionType) {
    return switch (specialActionType) {
      'powerStrike' => '강타',
      'divineHeal' => '신성한 치유',
      'insight' => '통찰',
      'shadowStrike' => '그림자 일격',
      'ironWall' => '철벽',
      'adapt' => '적응',
      // 히든 직업
      'deathReap' => '사신의 낫',
      'mirrorImage' => '환영',
      'attune' => '동조',
      // 2차 전직 — 상위직
      'swordAura' => '검기',
      'divineLight' => '천상의 빛',
      'arcaneWill' => '마법의 의지',
      'shadowDomain' => '그림자 영역',
      'absoluteDefense' => '절대 방어',
      'fateSpin' => '운명의 바퀴',
      'netherCommand' => '명계의 명령',
      'dimensionRift' => '차원의 틈',
      'transcend' => '초월',
      // 2차 전직 — 조합직
      'arcaneSlash' => '마력 참격',
      'holyStrike' => '성스러운 일격',
      'curseWave' => '저주의 파동',
      'darkCounter' => '암흑 반격',
      'divineJudgment' => '신성 심판',
      _ => '특수',
    };
  }

  /// 특수 행동 접두사 이모지.
  static String getPrefix(String specialActionType) {
    return switch (specialActionType) {
      'powerStrike' => '⚡ ',
      'divineHeal' => '✨ ',
      'insight' => '🔮 ',
      'shadowStrike' => '🗡 ',
      'ironWall' => '🛡 ',
      'adapt' => '🔄 ',
      // 히든 직업
      'deathReap' => '💀 ',
      'mirrorImage' => '🪞 ',
      'attune' => '🎵 ',
      // 2차 전직 — 상위직
      'swordAura' => '⚔ ',
      'divineLight' => '🌟 ',
      'arcaneWill' => '🔮 ',
      'shadowDomain' => '🌑 ',
      'absoluteDefense' => '🏰 ',
      'fateSpin' => '🎰 ',
      'netherCommand' => '👑 ',
      'dimensionRift' => '🌀 ',
      'transcend' => '🌌 ',
      // 2차 전직 — 조합직
      'arcaneSlash' => '⚡ ',
      'holyStrike' => '✨ ',
      'curseWave' => '🌊 ',
      'darkCounter' => '🗡 ',
      'divineJudgment' => '⚖ ',
      _ => '★ ',
    };
  }

  // --- 직업별 상호작용 ---

  /// 전사 — 강타: 공격 강화. 방어에도 밀어붙임.
  static ActionResult _powerStrike(EnemyActionType enemy) {
    return switch (enemy) {
      EnemyActionType.attack || EnemyActionType.heavy => ActionResult.effective,
      EnemyActionType.defend => ActionResult.neutral,
      EnemyActionType.observe => ActionResult.effective,
      EnemyActionType.charge ||
      EnemyActionType.heal ||
      EnemyActionType.buff =>
        ActionResult.effective,
    };
  }

  /// 성자 — 신성한 치유: 공격에 신성 방어, 관찰에 치유.
  static ActionResult _divineHeal(EnemyActionType enemy) {
    return switch (enemy) {
      EnemyActionType.attack || EnemyActionType.heavy => ActionResult.effective,
      EnemyActionType.defend => ActionResult.neutral,
      EnemyActionType.observe => ActionResult.effective,
      EnemyActionType.charge ||
      EnemyActionType.heal ||
      EnemyActionType.buff =>
        ActionResult.neutral,
    };
  }

  /// 현자 — 통찰: 방어 읽기, 관찰 시너지.
  static ActionResult _insight(EnemyActionType enemy) {
    return switch (enemy) {
      EnemyActionType.attack || EnemyActionType.heavy => ActionResult.neutral,
      EnemyActionType.defend => ActionResult.effective,
      EnemyActionType.observe => ActionResult.effective,
      EnemyActionType.charge ||
      EnemyActionType.heal ||
      EnemyActionType.buff =>
        ActionResult.effective,
    };
  }

  /// 암살자 — 그림자 일격: 기습. 관찰에 약함.
  static ActionResult _shadowStrike(EnemyActionType enemy) {
    return switch (enemy) {
      EnemyActionType.attack || EnemyActionType.heavy => ActionResult.effective,
      EnemyActionType.defend => ActionResult.effective,
      EnemyActionType.observe => ActionResult.ineffective,
      EnemyActionType.charge ||
      EnemyActionType.heal ||
      EnemyActionType.buff =>
        ActionResult.effective,
    };
  }

  /// 수호자 — 철벽: 완벽 방어. 관찰에 중립.
  static ActionResult _ironWall(EnemyActionType enemy) {
    return switch (enemy) {
      EnemyActionType.attack || EnemyActionType.heavy => ActionResult.effective,
      EnemyActionType.defend => ActionResult.effective,
      EnemyActionType.observe => ActionResult.neutral,
      EnemyActionType.charge ||
      EnemyActionType.heal ||
      EnemyActionType.buff =>
        ActionResult.neutral,
    };
  }

  /// 방랑자 — 적응: 공격/관찰에 유리, 방어에 중립.
  static ActionResult _adapt(EnemyActionType enemy) {
    return switch (enemy) {
      EnemyActionType.attack || EnemyActionType.heavy => ActionResult.effective,
      EnemyActionType.defend => ActionResult.neutral,
      EnemyActionType.observe => ActionResult.effective,
      EnemyActionType.charge ||
      EnemyActionType.heal ||
      EnemyActionType.buff =>
        ActionResult.effective,
    };
  }
}
