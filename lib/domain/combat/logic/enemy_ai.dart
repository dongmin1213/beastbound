import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/text/korean_particles.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';

/// 적 AI — 패턴 사이클링 + HP 기반 조건부 분기 + 의도 표시.
class EnemyAI {
  EnemyAI._();

  /// 현재 턴의 적 행동 조회 (오프셋 적용).
  static EnemyActionType getAction(
    EnemyCombatData enemy,
    int turn, {
    int patternOffset = 0,
  }) {
    return enemy.actionAt(turn + patternOffset);
  }

  /// 다음 턴의 적 행동 (의도 표시용, 오프셋 적용).
  static EnemyActionType getNextIntent(
    EnemyCombatData enemy,
    int currentTurn, {
    int patternOffset = 0,
  }) {
    return enemy.actionAt(currentTurn + 1 + patternOffset);
  }

  /// 의도 텍스트 생성 (공개 상태일 때).
  ///
  /// [enemyStrength]를 전달하면 실제 공격력(base + str)을 표시한다.
  static String intentText(
    EnemyCombatData enemy,
    int turn, {
    int enemyStrength = 0,
    int patternOffset = 0,
  }) {
    final action = getAction(enemy, turn, patternOffset: patternOffset);
    return switch (action) {
      EnemyActionType.attack =>
        '${enemy.name}${KoreanParticles.iGa(enemy.name)} 공격하려 한다 (${enemy.damageAt(turn + patternOffset) + enemyStrength})',
      EnemyActionType.heavy =>
        '${enemy.name}${KoreanParticles.iGa(enemy.name)} 강공격을 준비한다! (${enemy.damageAt(turn + patternOffset) + enemyStrength})',
      EnemyActionType.charge =>
        '${enemy.name}${KoreanParticles.iGa(enemy.name)} 힘을 모으고 있다...',
      EnemyActionType.defend =>
        '${enemy.name}${KoreanParticles.iGa(enemy.name)} 방어 태세를 취한다',
      EnemyActionType.heal =>
        '${enemy.name}${KoreanParticles.iGa(enemy.name)} 회복하려 한다',
      EnemyActionType.buff =>
        '${enemy.name}${KoreanParticles.iGa(enemy.name)} 강화하려 한다',
      EnemyActionType.observe =>
        '${enemy.name}${KoreanParticles.iGa(enemy.name)} 관찰하고 있다',
    };
  }

  /// 의도 숨김 텍스트 (엘리트/보스).
  static String hiddenIntentText(EnemyCombatData enemy) {
    return '${enemy.name}${KoreanParticles.iGa(enemy.name)} 무언가를 준비하고 있다...';
  }

  /// 적 행동 실행 결과 계산 — HP 기반 조건부 분기 포함 (하위 호환).
  ///
  /// [enemyHpRatio]를 전달하면 저체력 시 방어/회복으로 행동 오버라이드.
  /// [random]을 전달하면 조건부 분기에 확률 적용 (테스트 주입 가능).
  static EnemyActionResult resolveAction(
    EnemyCombatData enemy,
    int turn, {
    int enemyStrength = 0,
    int patternOffset = 0,
    double? enemyHpRatio,
    Random? random,
  }) {
    var action = getAction(enemy, turn, patternOffset: patternOffset);
    final effectiveTurn = turn + patternOffset;

    // ── HP 기반 조건부 행동 오버라이드 ──
    if (enemyHpRatio != null && !enemy.isElite) {
      action = _conditionalOverride(
        action, enemyHpRatio, enemy, effectiveTurn, random,
      );
    }

    return _buildResult(action, enemy, effectiveTurn, enemyStrength);
  }

  // ── Phase 3-C: 고급 적 행동 AI ─────────────────────────

  /// 고급 적 행동 실행 결과 계산 — 플레이어 상태 반응 포함.
  ///
  /// 일반/엘리트/보스 모두 지원. 플레이어 블록/턴 수 기반 반응형 오버라이드.
  /// [lastOverrideAction]: 직전 턴 오버라이드 (같은 오버라이드 연속 방지).
  /// [enragedTurns]: 격노 남은 턴 (ATK×1.5).
  static EnemyActionResult resolveActionAdvanced(
    EnemyCombatData enemy,
    int turn, {
    int enemyStrength = 0,
    int patternOffset = 0,
    double? enemyHpRatio,
    int playerBlock = 0,
    int currentTurnNumber = 0,
    bool isBoss = false,
    EnemyActionType? lastOverrideAction,
    int enragedTurns = 0,
    Random? random,
  }) {
    var action = getAction(enemy, turn, patternOffset: patternOffset);
    final effectiveTurn = turn + patternOffset;
    final rng = random ?? Random();

    // ── charge→heavy 콤보 보호: 절대 오버라이드 금지 ──
    if (action == EnemyActionType.heavy || action == EnemyActionType.charge) {
      return _buildResult(
        action, enemy, effectiveTurn, enemyStrength,
        enragedTurns: enragedTurns,
      );
    }

    // ── 반응형 오버라이드 시스템 (최대 1회/턴, 연속 불가) ──
    EnemyActionType? overrideAction;

    // 1. 엘리트 HP ≤ 25%: 격노(buff) — 40% (엘리트 전용)
    if (enemy.isElite &&
        !isBoss &&
        enemyHpRatio != null &&
        enemyHpRatio <= 0.25) {
      if (rng.nextDouble() < 0.4 &&
          lastOverrideAction != EnemyActionType.buff) {
        overrideAction = EnemyActionType.buff;
      }
    }

    // 2. 적 HP ≤ 50%: 공격 → 방어/회복 — 30% (일반 + 엘리트)
    if (overrideAction == null &&
        !isBoss &&
        enemyHpRatio != null &&
        enemyHpRatio <= 0.5 &&
        action.isAttack) {
      if (rng.nextDouble() < 0.3) {
        final candidate =
            rng.nextBool() ? EnemyActionType.defend : EnemyActionType.heal;
        if (lastOverrideAction != candidate) {
          overrideAction = candidate;
        }
      }
    }

    // 3. 플레이어 블록 ≥ 15: 공격 → 버프 — 30% (전체)
    if (overrideAction == null &&
        playerBlock >= 15 &&
        action == EnemyActionType.attack) {
      if (rng.nextDouble() < 0.3 &&
          lastOverrideAction != EnemyActionType.buff) {
        overrideAction = EnemyActionType.buff;
      }
    }

    // 4. 플레이어 블록 = 0: 방어 → 공격 — 40% (전체)
    if (overrideAction == null &&
        playerBlock == 0 &&
        action == EnemyActionType.defend) {
      if (rng.nextDouble() < 0.4 &&
          lastOverrideAction != EnemyActionType.attack) {
        overrideAction = EnemyActionType.attack;
      }
    }

    // 오버라이드 적용
    final finalAction = overrideAction ?? action;

    // ── 전투 10턴 초과: 엘리트/보스 힘 +1/턴 (100%) ──
    var bonusStrength = 0;
    if (currentTurnNumber > 10 && (enemy.isElite || isBoss)) {
      bonusStrength = 1;
    }

    final result = _buildResult(
      finalAction,
      enemy,
      effectiveTurn,
      enemyStrength + bonusStrength,
      enragedTurns: enragedTurns,
    );

    return EnemyActionResult(
      type: result.type,
      damage: result.damage,
      block: result.block,
      healAmount: result.healAmount,
      buffStrength: result.buffStrength,
      isEnrage: overrideAction == EnemyActionType.buff &&
          enemy.isElite &&
          !isBoss &&
          enemyHpRatio != null &&
          enemyHpRatio <= 0.25,
      overrideApplied: overrideAction,
      longCombatStrengthBonus: bonusStrength,
    );
  }

  /// HP 기반 조건부 행동 오버라이드 (레거시 — resolveAction용).
  /// - HP ≤ 30%: 공격 행동을 50% 확률로 방어/회복으로 교체
  /// - 충전 직후(heavy)는 오버라이드 금지 (콤보 보장)
  static EnemyActionType _conditionalOverride(
    EnemyActionType action,
    double hpRatio,
    EnemyCombatData enemy,
    int effectiveTurn,
    Random? random,
  ) {
    final rng = random ?? Random();

    // 충전 직후 heavy는 무조건 실행 (콤보 깨면 안 됨)
    if (action == EnemyActionType.heavy) return action;
    // charge도 보존 (다음 턴 heavy 연결)
    if (action == EnemyActionType.charge) return action;

    // HP 30% 이하: 공격 → 50% 확률로 방어/회복
    if (hpRatio <= 0.3 && action.isAttack) {
      if (rng.nextDouble() < 0.5) {
        return rng.nextBool()
            ? EnemyActionType.defend
            : EnemyActionType.heal;
      }
    }

    // HP 50% 이하: 관찰(observe) → 방어로 교체 (관찰보다 유용)
    if (hpRatio <= 0.5 && action == EnemyActionType.observe) {
      return EnemyActionType.defend;
    }

    return action;
  }

  /// 행동 결과 빌드.
  ///
  /// [enragedTurns] > 0이면 ATK×1.5 적용.
  static EnemyActionResult _buildResult(
    EnemyActionType action,
    EnemyCombatData enemy,
    int effectiveTurn,
    int enemyStrength, {
    int enragedTurns = 0,
  }) {
    // 격노 시 공격력 1.5배
    final enrageMultiplier = enragedTurns > 0 ? 1.5 : 1.0;

    // 오버라이드 시 패턴의 attackMultiplier(0)가 아닌 action의 multiplier 사용
    final atkDamage = (enemy.atk * action.attackMultiplier).toInt();

    return switch (action) {
      EnemyActionType.attack => EnemyActionResult(
          type: action,
          damage: ((atkDamage + enemyStrength) * enrageMultiplier).toInt(),
          block: 0,
          healAmount: 0,
          buffStrength: 0,
        ),
      EnemyActionType.heavy => EnemyActionResult(
          type: action,
          damage: ((atkDamage + enemyStrength) * enrageMultiplier).toInt(),
          block: 0,
          healAmount: 0,
          buffStrength: 0,
        ),
      EnemyActionType.defend => EnemyActionResult(
          type: action,
          damage: 0,
          block: enemy.blockAt(effectiveTurn),
          healAmount: 0,
          buffStrength: 0,
        ),
      EnemyActionType.charge => EnemyActionResult(
          type: action,
          damage: 0,
          block: 0,
          healAmount: 0,
          buffStrength: 0,
        ),
      EnemyActionType.heal => EnemyActionResult(
          type: action,
          damage: 0,
          block: 0,
          healAmount: (enemy.hp * 0.2).toInt(),
          buffStrength: 0,
        ),
      EnemyActionType.buff => EnemyActionResult(
          type: action,
          damage: 0,
          block: 0,
          healAmount: 0,
          buffStrength: enemy.isElite ? 4 : 3,
        ),
      EnemyActionType.observe => EnemyActionResult(
          type: action,
          damage: 0,
          block: 0,
          healAmount: 0,
          buffStrength: 0,
        ),
    };
  }

  // ── 의도 표시 ─────────────────────────────────────────

  /// 적 의도를 표시할지 결정.
  ///
  /// - 일반: 항상 공개
  /// - 엘리트: 첫 2턴 "???" → 이후 공개. [intentRevealed]로 즉시 해제
  /// - 보스: 항상 공개 (StS 스타일 — 의도 기반 전략이 핵심)
  static bool shouldShowIntent({
    required bool isElite,
    required bool isBoss,
    required int currentTurn,
    required bool intentRevealed,
  }) {
    if (isBoss) return true;
    if (isElite) return currentTurn >= 2 || intentRevealed;
    return true; // 일반
  }

  // ── 보스 기믹 ─────────────────────────────────────────

  /// 보스 기믹 턴 시작 효과 계산 (하위 호환).
  static BossGimmickResult resolveGimmick(
    BossGimmick gimmick,
    int enemyMaxHp,
  ) {
    return switch (gimmick) {
      BossGimmick.none => const BossGimmickResult(),
      BossGimmick.regen => BossGimmickResult(
          healAmount: ((enemyMaxHp * 0.05).toInt()).clamp(1, 999),
        ),
      BossGimmick.web => const BossGimmickResult(playerDrawPenalty: 1),
      BossGimmick.rage => const BossGimmickResult(strengthOnHit: 2),
      BossGimmick.drain => const BossGimmickResult(drainPercent: 30),
      BossGimmick.formShift => const BossGimmickResult(),
      BossGimmick.bleed => const BossGimmickResult(bleedBurnStacks: 2),
      BossGimmick.shackle => const BossGimmickResult(playerApPenalty: 1),
      BossGimmick.reflect => const BossGimmickResult(reflectPercent: 15),
      BossGimmick.corruption => const BossGimmickResult(applyRandomDebuff: true),
      BossGimmick.voidGimmick => const BossGimmickResult(
          playerDrawPenalty: 1,
        ),
    };
  }

  // ── Phase 3-C: 고급 보스 기믹 ──────────────────────────

  /// 보스 기믹 — 플레이어 상태 반응형 강화 포함.
  ///
  /// 기본 기믹 효과에 플레이어 상태에 따른 반응형 보너스를 추가.
  /// 각 보스별 고유 반응 조건은 COMBAT_OVERHAUL.md 참조.
  static BossGimmickResult resolveGimmickAdvanced(
    BossGimmick gimmick,
    int enemyMaxHp, {
    String bossId = '',
    int playerBlock = 0,
    int playerHp = 0,
    int playerMaxHp = 0,
    int playerPoisonStacks = 0,
    int playerBurnStacks = 0,
    int playerStrength = 0,
    int exhaustPileSize = 0,
    int attacksPlayedThisTurn = 0,
    int chainCount = 0,
    int cardsPlayedThisTurn = 0,
    int turnNumber = 0,
    int playerDebuffCount = 0,
    int consecutiveHitTurns = 0,
    bool playerUsedPowerThisTurn = false,
    bool playerUsedSkillThisTurn = false,
  }) {
    // 기본 기믹 결과 가져오기
    final base = resolveGimmick(gimmick, enemyMaxHp);

    // ── 보스별 반응형 강화 ──
    switch (gimmick) {
      case BossGimmick.regen:
        // slime_king: 플레이어에게 독/화상 있으면 재생×2
        if (playerPoisonStacks > 0 || playerBurnStacks > 0) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: regen doubled (player has status)');
          return base.copyWith(
            healAmount: base.healAmount * 2,
            doubleRegen: true,
          );
        }
        return base;

      case BossGimmick.web:
        // spider_lord: 플레이어가 0AP 카드 사용 → 추가 드로우 -1 (1턴)
        // (cardsPlayedThisTurn > attacksPlayedThisTurn은
        //  0코스트 카드 사용의 근사치)
        if (cardsPlayedThisTurn > 0 && attacksPlayedThisTurn == 0) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: web extra draw penalty');
          return base.copyWith(
            playerDrawPenalty: base.playerDrawPenalty + 1,
            extraDrawPenalty: 1,
          );
        }
        return base;

      case BossGimmick.rage:
        // orc_general: 3턴 연속 피격 → 광폭화 (ATK×2, 1턴)
        if (consecutiveHitTurns >= 3) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: rage berserk triggered');
          return base.copyWith(berserk: true);
        }
        return base;

      case BossGimmick.drain:
        // vampire_lord: 플레이어 HP < 50% → 흡혈 50% (기본 30%)
        if (playerMaxHp > 0 && playerHp < playerMaxHp * 0.5) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: drain enhanced 30->50%');
          return base.copyWith(
            drainPercent: 50,
            enhancedDrainPercent: 50,
          );
        }
        return base;

      case BossGimmick.formShift:
        // dungeon_master: 플레이어 최고 스탯 감지 후 디버프
        // (formShift는 기본 효과 없음 — CombatBloc에서 별도 처리)
        return base;

      case BossGimmick.bleed:
        // sewer_croc: 플레이어 블록 = 0 → 화상 4 (기본 2)
        // arch_demon: 화상 5+ → 모든 화상 즉발 데미지
        if (playerBlock == 0) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: bleed enhanced (no block)');
          return base.copyWith(bleedBurnStacks: 4);
        }
        if (playerBurnStacks >= 5) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: burn burst triggered');
          return base.copyWith(burnBurst: true);
        }
        return base;

      case BossGimmick.corruption:
        // rat_monarch: 디버프 3개 이상 → 추가 공격
        // mana_overload: Power 카드 사용 → 디버프 면역 1턴
        if (playerDebuffCount >= 3) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: corruption extra attack');
          return base.copyWith(extraAttack: true);
        }
        if (playerUsedPowerThisTurn) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: debuff immunity (Power used)');
          return base.copyWith(debuffImmunity: true);
        }
        return base;

      case BossGimmick.shackle:
        // warden_chief: 1장만 사용 → AP 패널티 해제
        // corrupt_high_priest: Skill 사용 → 50% 확률 AP 패널티 해제
        if (cardsPlayedThisTurn == 1) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: shackle AP penalty removed');
          return base.copyWith(apPenaltyRemoved: true);
        }
        if (playerUsedSkillThisTurn) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: shackle half AP penalty removed');
          return base.copyWith(halfApPenaltyRemoved: true);
        }
        return base;

      case BossGimmick.voidGimmick:
        // ghost_convict: 소진 더미 5+ → 소진 카드당 2 데미지
        // void_sovereign: 소진 더미 비어있으면 HP -5
        if (exhaustPileSize >= 5) {
          if (kDebugMode) {
            GameLogger.debug(LogSystem.combat,
              'Boss reactive: void exhaust damage ($exhaustPileSize cards)',
            );
          }
          return base.copyWith(exhaustDamage: exhaustPileSize * 2);
        }
        if (exhaustPileSize == 0) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: void direct HP damage');
          return base.copyWith(directHpDamage: 5);
        }
        return base;

      case BossGimmick.reflect:
        // crystal_golem: 플레이어 힘 ≥ 5 → 반사 25% (기본 15%)
        // dimension_collapser: 연쇄 3+ → 반사 데미지 2배
        if (playerStrength >= 5) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: reflect enhanced 15->25%');
          return base.copyWith(
            reflectPercent: 25,
            enhancedReflectPercent: 25,
          );
        }
        if (chainCount >= 3) {
          if (kDebugMode) GameLogger.debug(LogSystem.combat,'Boss reactive: reflect doubled (chain 3+)');
          return base.copyWith(doubleReflectDamage: true);
        }
        return base;

      case BossGimmick.none:
        return base;
    }
  }
}

/// 보스 기믹 효과 결과.
class BossGimmickResult {
  /// 턴 시작 시 적 HP 회복량.
  final int healAmount;

  /// 플레이어 AP 감소량.
  final int playerApPenalty;

  /// 피격 시 힘 증가량 (rage).
  final int strengthOnHit;

  /// 공격 데미지의 흡혈 비율 (drain, %).
  final int drainPercent;

  /// 플레이어 드로우 감소량 (web/voidGimmick).
  final int playerDrawPenalty;

  /// 공격 시 화상 스택 (bleed).
  final int bleedBurnStacks;

  /// 받은 데미지 반사 비율 (reflect, %).
  final int reflectPercent;

  /// 랜덤 디버프 부여 여부 (corruption).
  final bool applyRandomDebuff;

  /// 랜덤 카드 소진 여부 (voidGimmick).
  final bool exhaustRandomCard;

  // ── Phase 3-C: 반응형 보스 기믹 필드 ──

  /// slime_king: 재생 2배 활성화.
  final bool doubleRegen;

  /// spider_lord: 추가 드로우 패널티.
  final int extraDrawPenalty;

  /// orc_general: 광폭화 (ATK×2, 1턴).
  final bool berserk;

  /// vampire_lord: 강화된 흡혈 비율 (50%).
  final int enhancedDrainPercent;

  /// rat_monarch: 추가 공격.
  final bool extraAttack;

  /// warden_chief: AP 패널티 완전 해제.
  final bool apPenaltyRemoved;

  /// ghost_convict: 소진 카드 기반 데미지.
  final int exhaustDamage;

  /// crystal_golem: 강화된 반사 비율.
  final int enhancedReflectPercent;

  /// mana_overload: 디버프 면역 1턴.
  final bool debuffImmunity;

  /// arch_demon: 화상 즉발 폭발.
  final bool burnBurst;

  /// corrupt_high_priest: AP 패널티 절반 해제.
  final bool halfApPenaltyRemoved;

  /// void_sovereign: 직접 HP 데미지.
  final int directHpDamage;

  /// dimension_collapser: 반사 데미지 2배.
  final bool doubleReflectDamage;

  const BossGimmickResult({
    this.healAmount = 0,
    this.playerApPenalty = 0,
    this.strengthOnHit = 0,
    this.drainPercent = 0,
    this.playerDrawPenalty = 0,
    this.bleedBurnStacks = 0,
    this.reflectPercent = 0,
    this.applyRandomDebuff = false,
    this.exhaustRandomCard = false,
    // Phase 3-C reactive fields
    this.doubleRegen = false,
    this.extraDrawPenalty = 0,
    this.berserk = false,
    this.enhancedDrainPercent = 0,
    this.extraAttack = false,
    this.apPenaltyRemoved = false,
    this.exhaustDamage = 0,
    this.enhancedReflectPercent = 0,
    this.debuffImmunity = false,
    this.burnBurst = false,
    this.halfApPenaltyRemoved = false,
    this.directHpDamage = 0,
    this.doubleReflectDamage = false,
  });

  /// 반응형 효과가 하나라도 활성화되었는지.
  bool get hasReactiveEffect =>
      doubleRegen ||
      extraDrawPenalty > 0 ||
      berserk ||
      enhancedDrainPercent > 0 ||
      extraAttack ||
      apPenaltyRemoved ||
      exhaustDamage > 0 ||
      enhancedReflectPercent > 0 ||
      debuffImmunity ||
      burnBurst ||
      halfApPenaltyRemoved ||
      directHpDamage > 0 ||
      doubleReflectDamage;

  BossGimmickResult copyWith({
    int? healAmount,
    int? playerApPenalty,
    int? strengthOnHit,
    int? drainPercent,
    int? playerDrawPenalty,
    int? bleedBurnStacks,
    int? reflectPercent,
    bool? applyRandomDebuff,
    bool? exhaustRandomCard,
    bool? doubleRegen,
    int? extraDrawPenalty,
    bool? berserk,
    int? enhancedDrainPercent,
    bool? extraAttack,
    bool? apPenaltyRemoved,
    int? exhaustDamage,
    int? enhancedReflectPercent,
    bool? debuffImmunity,
    bool? burnBurst,
    bool? halfApPenaltyRemoved,
    int? directHpDamage,
    bool? doubleReflectDamage,
  }) {
    return BossGimmickResult(
      healAmount: healAmount ?? this.healAmount,
      playerApPenalty: playerApPenalty ?? this.playerApPenalty,
      strengthOnHit: strengthOnHit ?? this.strengthOnHit,
      drainPercent: drainPercent ?? this.drainPercent,
      playerDrawPenalty: playerDrawPenalty ?? this.playerDrawPenalty,
      bleedBurnStacks: bleedBurnStacks ?? this.bleedBurnStacks,
      reflectPercent: reflectPercent ?? this.reflectPercent,
      applyRandomDebuff: applyRandomDebuff ?? this.applyRandomDebuff,
      exhaustRandomCard: exhaustRandomCard ?? this.exhaustRandomCard,
      doubleRegen: doubleRegen ?? this.doubleRegen,
      extraDrawPenalty: extraDrawPenalty ?? this.extraDrawPenalty,
      berserk: berserk ?? this.berserk,
      enhancedDrainPercent: enhancedDrainPercent ?? this.enhancedDrainPercent,
      extraAttack: extraAttack ?? this.extraAttack,
      apPenaltyRemoved: apPenaltyRemoved ?? this.apPenaltyRemoved,
      exhaustDamage: exhaustDamage ?? this.exhaustDamage,
      enhancedReflectPercent:
          enhancedReflectPercent ?? this.enhancedReflectPercent,
      debuffImmunity: debuffImmunity ?? this.debuffImmunity,
      burnBurst: burnBurst ?? this.burnBurst,
      halfApPenaltyRemoved: halfApPenaltyRemoved ?? this.halfApPenaltyRemoved,
      directHpDamage: directHpDamage ?? this.directHpDamage,
      doubleReflectDamage: doubleReflectDamage ?? this.doubleReflectDamage,
    );
  }
}

/// 적 행동 실행 결과.
class EnemyActionResult {
  final EnemyActionType type;
  final int damage;
  final int block;
  final int healAmount;
  final int buffStrength;

  // ── Phase 3-C: 추가 메타데이터 ──

  /// 격노 오버라이드 여부 (엘리트 HP ≤ 25% → ATK×1.5, 2턴).
  final bool isEnrage;

  /// 적용된 오버라이드 행동 (null = 오버라이드 없음).
  final EnemyActionType? overrideApplied;

  /// 장기전 보너스 힘 (10턴 초과 시 +1/턴).
  final int longCombatStrengthBonus;

  const EnemyActionResult({
    required this.type,
    required this.damage,
    required this.block,
    required this.healAmount,
    required this.buffStrength,
    this.isEnrage = false,
    this.overrideApplied,
    this.longCombatStrengthBonus = 0,
  });
}
