import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_modifier.dart';

/// 카드 전투용 적 데이터 — HP/ATK/DEF + 행동 패턴.
class EnemyCombatData extends Equatable {
  final String id;
  final String name;
  final int hp;
  final int atk;
  final int def;
  final int floor;
  final bool isElite;

  /// 행동 패턴 — 순환. 인덱스 = currentTurn % pattern.length.
  final List<EnemyActionType> pattern;

  /// 대체 패턴 풀 — 전투 시작 시 [pattern] 또는 이 중 하나를 랜덤 선택.
  final List<List<EnemyActionType>> alternatePatterns;

  /// 변형 수식어 (null = 변형 없음).
  final EnemyModifierType? modifier;

  const EnemyCombatData({
    required this.id,
    required this.name,
    required this.hp,
    required this.atk,
    required this.def,
    required this.floor,
    this.isElite = false,
    required this.pattern,
    this.alternatePatterns = const [],
    this.modifier,
  });

  /// 모든 패턴 후보 (기본 + 대체).
  List<List<EnemyActionType>> get allPatterns =>
      [pattern, ...alternatePatterns];

  /// 랜덤 패턴을 선택한 새 인스턴스 반환.
  EnemyCombatData withRandomPattern(Random rng) {
    final candidates = allPatterns;
    if (candidates.length <= 1) return this;
    final selected = candidates[rng.nextInt(candidates.length)];
    return copyWith(pattern: selected);
  }

  /// 현재 턴에서 적 행동 조회.
  EnemyActionType actionAt(int turn) {
    if (pattern.isEmpty) return EnemyActionType.attack;
    return pattern[turn % pattern.length];
  }

  /// 현재 턴의 공격 데미지 계산 (힘 보너스 미반영).
  int damageAt(int turn) {
    final action = actionAt(turn);
    return (atk * action.attackMultiplier).toInt();
  }

  /// 현재 턴의 블록 계산 (defend 행동일 때 def 반환).
  int blockAt(int turn) {
    final action = actionAt(turn);
    return action == EnemyActionType.defend ? def : 0;
  }

  /// 변형 수식어를 적용한 새 인스턴스 반환.
  EnemyCombatData withModifier(EnemyModifierType mod) {
    var newHp = hp;
    var newAtk = atk;
    var newDef = def;
    var newPattern = List<EnemyActionType>.from(pattern);

    switch (mod) {
      case EnemyModifierType.enhanced:
        newHp = (hp * 1.3).toInt();
        newAtk = (atk * 1.2).toInt();
      case EnemyModifierType.venomous:
        // 스탯 변경 없음 — 공격 시 독 부여는 전투 중 처리
        break;
      case EnemyModifierType.enraged:
        newAtk = (atk * 1.2).toInt();
        newDef = (def * 0.7).toInt();
      case EnemyModifierType.hardened:
        newDef = (def * 2.0).toInt();
        newHp = (hp * 1.1).toInt();
      case EnemyModifierType.swift:
        newPattern = [...pattern, EnemyActionType.attack];
    }

    return EnemyCombatData(
      id: id,
      name: '${mod.prefix} $name',
      hp: newHp,
      atk: newAtk,
      def: newDef,
      floor: floor,
      isElite: isElite,
      pattern: newPattern,
      alternatePatterns: alternatePatterns,
      modifier: mod,
    );
  }

  EnemyCombatData copyWith({
    String? id,
    String? name,
    int? hp,
    int? atk,
    int? def,
    int? floor,
    bool? isElite,
    List<EnemyActionType>? pattern,
    List<List<EnemyActionType>>? alternatePatterns,
    EnemyModifierType? modifier,
  }) {
    return EnemyCombatData(
      id: id ?? this.id,
      name: name ?? this.name,
      hp: hp ?? this.hp,
      atk: atk ?? this.atk,
      def: def ?? this.def,
      floor: floor ?? this.floor,
      isElite: isElite ?? this.isElite,
      pattern: pattern ?? this.pattern,
      alternatePatterns: alternatePatterns ?? this.alternatePatterns,
      modifier: modifier ?? this.modifier,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, hp, atk, def, floor, isElite, pattern, alternatePatterns, modifier];
}
