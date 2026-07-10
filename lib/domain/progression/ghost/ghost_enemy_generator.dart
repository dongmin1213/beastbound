import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';

/// 유령 NPC → 전투용 EnemyCombatData 변환.
///
/// 유령 PvP: 과거 런의 사망 데이터를 기반으로 적 생성.
/// jobId → 전투 원형(archetype) → 스탯 + 행동 패턴.
/// deathFloor → 층별 스탯 스케일링.
class GhostEnemyGenerator {
  GhostEnemyGenerator._();

  /// 유령 NPC 데이터 → 전투용 적 데이터 변환.
  static EnemyCombatData generate(GhostNpcData ghost) {
    final archetype = _archetypeFor(ghost.jobId);
    final base = _baseStats[archetype]!;
    final multiplier = _floorMultiplier(ghost.deathFloor);
    final jobName = _jobDisplayNames[ghost.jobId] ?? ghost.jobId;

    return EnemyCombatData(
      id: 'ghost_${ghost.jobId}_f${ghost.deathFloor}',
      name: '$jobName의 유령',
      hp: (base.hp * multiplier).toInt(),
      atk: (base.atk * multiplier).toInt(),
      def: (base.def * multiplier).toInt(),
      floor: ghost.deathFloor,
      isElite: true,
      pattern: _patterns[archetype]!,
      alternatePatterns: _alternatePatterns[archetype] ?? const [],
    );
  }

  /// 직업 ID → 전투 원형 매핑.
  /// 25종 직업을 6가지 원형으로 분류.
  static _Archetype _archetypeFor(String jobId) => switch (jobId) {
        // 1차 전직
        'warrior' => _Archetype.attacker,
        'saint' => _Archetype.healer,
        'sage' => _Archetype.caster,
        'assassin' => _Archetype.assassin,
        'guardian' => _Archetype.tank,
        'wanderer' => _Archetype.balanced,
        // 히든 1차
        'reaper' => _Archetype.attacker,
        'illusionist' => _Archetype.assassin,
        'harmonist' => _Archetype.balanced,
        // 2차 상위직
        'swordSaint' => _Archetype.attacker,
        'highPriest' => _Archetype.healer,
        'archmage' => _Archetype.caster,
        'shadowLord' => _Archetype.assassin,
        'ironFortress' => _Archetype.tank,
        'fateTraveler' => _Archetype.balanced,
        'netherKing' => _Archetype.attacker,
        'dimensionMage' => _Archetype.caster,
        'oneWithAll' => _Archetype.balanced,
        // 2차 조합직
        'spellBlade' => _Archetype.attacker,
        'holyKnight' => _Archetype.attacker,
        'darkMage' => _Archetype.caster,
        'darkKnight' => _Archetype.tank,
        'arbiter' => _Archetype.healer,
        // 알 수 없는 직업 → balanced
        _ => _Archetype.balanced,
      };

  /// 원형별 기본 스탯 (floor 1 기준).
  /// 일반 적과 엘리트 중간 수준.
  static const _baseStats = <_Archetype, ({int hp, int atk, int def})>{
    _Archetype.attacker: (hp: 50, atk: 13, def: 4),
    _Archetype.healer: (hp: 55, atk: 10, def: 5),
    _Archetype.caster: (hp: 40, atk: 14, def: 3),
    _Archetype.assassin: (hp: 35, atk: 15, def: 2),
    _Archetype.tank: (hp: 60, atk: 9, def: 7),
    _Archetype.balanced: (hp: 45, atk: 11, def: 5),
  };

  /// 층별 스탯 배율.
  static double _floorMultiplier(int floor) => switch (floor) {
        1 => 1.0,
        2 => 1.3,
        3 => 1.6,
        4 => 1.85,
        5 => 2.1,
        _ => (floor <= 0) ? 1.0 : 2.1,
      };

  /// 원형별 기본 행동 패턴.
  static const _patterns = <_Archetype, List<EnemyActionType>>{
    _Archetype.attacker: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    _Archetype.healer: [
      EnemyActionType.heal,
      EnemyActionType.attack,
      EnemyActionType.defend,
      EnemyActionType.attack,
    ],
    _Archetype.caster: [
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
    ],
    _Archetype.assassin: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    _Archetype.tank: [
      EnemyActionType.defend,
      EnemyActionType.defend,
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    _Archetype.balanced: [
      EnemyActionType.attack,
      EnemyActionType.defend,
      EnemyActionType.buff,
      EnemyActionType.attack,
    ],
  };

  /// 원형별 대체 패턴 — 전투마다 랜덤 선택.
  static const _alternatePatterns =
      <_Archetype, List<List<EnemyActionType>>>{
    _Archetype.attacker: [
      [
        EnemyActionType.charge,
        EnemyActionType.heavy,
        EnemyActionType.attack,
        EnemyActionType.attack,
        EnemyActionType.attack,
      ],
      [
        EnemyActionType.buff,
        EnemyActionType.attack,
        EnemyActionType.attack,
        EnemyActionType.charge,
        EnemyActionType.heavy,
      ],
    ],
    _Archetype.healer: [
      [
        EnemyActionType.defend,
        EnemyActionType.heal,
        EnemyActionType.attack,
        EnemyActionType.attack,
        EnemyActionType.heal,
      ],
    ],
    _Archetype.caster: [
      [
        EnemyActionType.buff,
        EnemyActionType.buff,
        EnemyActionType.charge,
        EnemyActionType.heavy,
        EnemyActionType.attack,
      ],
    ],
    _Archetype.assassin: [
      [
        EnemyActionType.attack,
        EnemyActionType.charge,
        EnemyActionType.heavy,
        EnemyActionType.attack,
        EnemyActionType.attack,
      ],
    ],
    _Archetype.tank: [
      [
        EnemyActionType.defend,
        EnemyActionType.attack,
        EnemyActionType.defend,
        EnemyActionType.charge,
        EnemyActionType.heavy,
      ],
    ],
    _Archetype.balanced: [
      [
        EnemyActionType.attack,
        EnemyActionType.buff,
        EnemyActionType.charge,
        EnemyActionType.heavy,
        EnemyActionType.defend,
      ],
    ],
  };

  static const _jobDisplayNames = <String, String>{
    'warrior': '전사',
    'saint': '성자',
    'sage': '현자',
    'assassin': '암살자',
    'guardian': '수호자',
    'wanderer': '방랑자',
    'reaper': '사신',
    'illusionist': '환술사',
    'harmonist': '조율사',
    'swordSaint': '검성',
    'highPriest': '대사제',
    'archmage': '대현자',
    'shadowLord': '그림자군주',
    'ironFortress': '철벽성주',
    'fateTraveler': '운명의 여행자',
    'netherKing': '명계왕',
    'dimensionMage': '차원술사',
    'oneWithAll': '만물일체',
    'spellBlade': '마검사',
    'holyKnight': '성기사',
    'darkMage': '흑마법사',
    'darkKnight': '암흑기사',
    'arbiter': '심판자',
  };
}

/// 전투 원형 — 6가지 전투 스타일.
enum _Archetype {
  attacker,
  healer,
  caster,
  assassin,
  tank,
  balanced,
}
