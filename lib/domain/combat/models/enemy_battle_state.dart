import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';

/// 전투 중 적 개체별 가변 상태 — 멀티몹 전투 지원.
class EnemyBattleState extends Equatable {
  final EnemyCombatData data;
  final int currentHp;
  final int maxHp;
  final int block;
  final int strength;
  final List<StatusEffect> statuses;
  final int healBlockedTurns;
  final int stunnedTurns;
  final int drainBlockedTurns;

  /// 패턴 오프셋 — 멀티몹 시 같은 종류 개체별 행동 분산.
  final int patternOffset;

  // ── Phase 3-C: 적 AI 개선 필드 ──

  /// 엘리트 HP 50% 이하 시 공격적 패턴으로 전환 완료 여부.
  final bool phaseShifted;

  /// 일반 몹 HP 50% 이하 시 대체 패턴으로 전환 완료 여부.
  final bool patternSwitched;

  /// 직전 턴에 적용된 오버라이드 행동 (같은 오버라이드 연속 방지).
  final EnemyActionType? lastOverrideAction;

  /// 격노(enrage) 남은 턴 수 — ATK×1.5 적용 중.
  final int enragedTurns;

  /// 보스 rage 기믹: 연속 피격 턴 카운터.
  final int consecutiveHitTurns;

  const EnemyBattleState({
    required this.data,
    required this.currentHp,
    required this.maxHp,
    this.block = 0,
    this.strength = 0,
    this.statuses = const [],
    this.healBlockedTurns = 0,
    this.stunnedTurns = 0,
    this.drainBlockedTurns = 0,
    this.patternOffset = 0,
    this.phaseShifted = false,
    this.patternSwitched = false,
    this.lastOverrideAction,
    this.enragedTurns = 0,
    this.consecutiveHitTurns = 0,
  });

  /// EnemyCombatData에서 초기 전투 상태 생성.
  factory EnemyBattleState.fromData(
    EnemyCombatData data, {
    int strengthBonus = 0,
    int patternOffset = 0,
  }) {
    return EnemyBattleState(
      data: data,
      currentHp: data.hp,
      maxHp: data.hp,
      strength: strengthBonus,
      patternOffset: patternOffset,
    );
  }

  /// 오프셋 적용된 턴 번호.
  int effectiveTurn(int turn) => turn + patternOffset;

  bool get isDead => currentHp <= 0;

  /// HP 비율 (0.0 ~ 1.0).
  double get hpRatio => maxHp > 0 ? currentHp / maxHp : 0.0;

  EnemyBattleState copyWith({
    EnemyCombatData? data,
    int? currentHp,
    int? maxHp,
    int? block,
    int? strength,
    List<StatusEffect>? statuses,
    int? healBlockedTurns,
    int? stunnedTurns,
    int? drainBlockedTurns,
    int? patternOffset,
    bool? phaseShifted,
    bool? patternSwitched,
    EnemyActionType? lastOverrideAction,
    bool clearLastOverrideAction = false,
    int? enragedTurns,
    int? consecutiveHitTurns,
  }) {
    return EnemyBattleState(
      data: data ?? this.data,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      block: block ?? this.block,
      strength: strength ?? this.strength,
      statuses: statuses ?? this.statuses,
      healBlockedTurns: healBlockedTurns ?? this.healBlockedTurns,
      stunnedTurns: stunnedTurns ?? this.stunnedTurns,
      drainBlockedTurns: drainBlockedTurns ?? this.drainBlockedTurns,
      patternOffset: patternOffset ?? this.patternOffset,
      phaseShifted: phaseShifted ?? this.phaseShifted,
      patternSwitched: patternSwitched ?? this.patternSwitched,
      lastOverrideAction: clearLastOverrideAction
          ? null
          : (lastOverrideAction ?? this.lastOverrideAction),
      enragedTurns: enragedTurns ?? this.enragedTurns,
      consecutiveHitTurns: consecutiveHitTurns ?? this.consecutiveHitTurns,
    );
  }

  @override
  List<Object?> get props => [
        data,
        currentHp,
        maxHp,
        block,
        strength,
        statuses,
        healBlockedTurns,
        stunnedTurns,
        drainBlockedTurns,
        patternOffset,
        phaseShifted,
        patternSwitched,
        lastOverrideAction,
        enragedTurns,
        consecutiveHitTurns,
      ];
}
