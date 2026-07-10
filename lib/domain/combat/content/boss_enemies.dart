import 'dart:math';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';

/// 5층 보스 15종 — 다단계 카드 전투.
class BossEnemies {
  BossEnemies._();

  // ── 1층 보스 (3종) ────────────────────────────────────────

  /// 1층 보스: 슬라임 왕 — 분열+재생.
  static const slimeKing = BossCombatData(
    id: 'boss_slime_king',
    name: '슬라임 왕',
    floor: 1,
    phases: [
      BossPhaseConfig(
        hp: 60,
        atk: 12,
        def: 4,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.defend,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
      ),
      BossPhaseConfig(
        hp: 40,
        atk: 10,
        def: 3,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.heal,
          EnemyActionType.attack,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.regen,
      ),
    ],
  );

  /// 1층 보스: 하수도 악어 — 출혈.
  static const sewerCroc = BossCombatData(
    id: 'boss_sewer_croc',
    name: '하수도 악어',
    floor: 1,
    phases: [
      BossPhaseConfig(
        hp: 65,
        atk: 13,
        def: 5,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
          EnemyActionType.defend,
        ],
        gimmick: BossGimmick.bleed,
      ),
      BossPhaseConfig(
        hp: 45,
        atk: 16,
        def: 3,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.heavy,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.bleed,
      ),
    ],
  );

  /// 1층 보스: 쥐 군주 — 부패.
  static const ratMonarch = BossCombatData(
    id: 'boss_rat_monarch',
    name: '쥐 군주',
    floor: 1,
    phases: [
      BossPhaseConfig(
        hp: 55,
        atk: 11,
        def: 3,
        pattern: [
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.defend,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.corruption,
      ),
      BossPhaseConfig(
        hp: 40,
        atk: 14,
        def: 4,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.corruption,
      ),
    ],
  );

  // ── 2층 보스 (3종) ────────────────────────────────────────

  /// 2층 보스: 거미 군주 — 거미줄+광란.
  static const spiderLord = BossCombatData(
    id: 'boss_spider_lord',
    name: '거미 군주',
    floor: 2,
    phases: [
      BossPhaseConfig(
        hp: 80,
        atk: 14,
        def: 6,
        pattern: [
          EnemyActionType.defend,
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.buff,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.web,
      ),
      BossPhaseConfig(
        hp: 50,
        atk: 18,
        def: 4,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.heavy,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.web,
      ),
    ],
  );

  /// 2층 보스: 간수장 — 속박.
  static const wardenChief = BossCombatData(
    id: 'boss_warden_chief',
    name: '간수장',
    floor: 2,
    phases: [
      BossPhaseConfig(
        hp: 85,
        atk: 15,
        def: 7,
        pattern: [
          EnemyActionType.defend,
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.shackle,
      ),
      BossPhaseConfig(
        hp: 55,
        atk: 19,
        def: 5,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.shackle,
      ),
    ],
  );

  /// 2층 보스: 원혼 사형수 — 공허.
  static const ghostConvict = BossCombatData(
    id: 'boss_ghost_convict',
    name: '원혼 사형수',
    floor: 2,
    phases: [
      BossPhaseConfig(
        hp: 75,
        atk: 16,
        def: 5,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.buff,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.voidGimmick,
      ),
      BossPhaseConfig(
        hp: 50,
        atk: 20,
        def: 3,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.heavy,
          EnemyActionType.attack,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.voidGimmick,
      ),
    ],
  );

  // ── 3층 보스 (3종) ────────────────────────────────────────

  /// 3층 보스: 오크 대장군 — 분노+폭주.
  static const orcGeneral = BossCombatData(
    id: 'boss_orc_general',
    name: '오크 대장군',
    floor: 3,
    phases: [
      BossPhaseConfig(
        hp: 100,
        atk: 16,
        def: 8,
        pattern: [
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
          EnemyActionType.defend,
        ],
      ),
      BossPhaseConfig(
        hp: 60,
        atk: 22,
        def: 5,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.rage,
      ),
    ],
  );

  /// 3층 보스: 수정 골렘 — 반사.
  static const crystalGolem = BossCombatData(
    id: 'boss_crystal_golem',
    name: '수정 골렘',
    floor: 3,
    phases: [
      BossPhaseConfig(
        hp: 110,
        atk: 14,
        def: 12,
        pattern: [
          EnemyActionType.defend,
          EnemyActionType.defend,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.reflect,
      ),
      BossPhaseConfig(
        hp: 70,
        atk: 18,
        def: 8,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.defend,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.reflect,
      ),
    ],
  );

  /// 3층 보스: 마나 폭주체 — 부패.
  static const manaOverload = BossCombatData(
    id: 'boss_mana_overload',
    name: '마나 폭주체',
    floor: 3,
    phases: [
      BossPhaseConfig(
        hp: 90,
        atk: 20,
        def: 5,
        pattern: [
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.corruption,
      ),
      BossPhaseConfig(
        hp: 65,
        atk: 26,
        def: 3,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.heavy,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.corruption,
      ),
    ],
  );

  // ── 4층 보스 (3종) ────────────────────────────────────────

  /// 4층 보스: 뱀파이어 군주 — 흡혈+변신.
  static const vampireLord = BossCombatData(
    id: 'boss_vampire_lord',
    name: '뱀파이어 군주',
    floor: 4,
    phases: [
      BossPhaseConfig(
        hp: 110,
        atk: 18,
        def: 6,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.defend,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.drain,
      ),
      BossPhaseConfig(
        hp: 60,
        atk: 24,
        def: 4,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.heavy,
          EnemyActionType.heal,
        ],
        gimmick: BossGimmick.drain,
      ),
    ],
  );

  /// 4층 보스: 대악마 — 출혈.
  static const archDemon = BossCombatData(
    id: 'boss_arch_demon',
    name: '대악마',
    floor: 4,
    phases: [
      BossPhaseConfig(
        hp: 115,
        atk: 20,
        def: 7,
        pattern: [
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.bleed,
      ),
      BossPhaseConfig(
        hp: 65,
        atk: 26,
        def: 5,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.heavy,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.bleed,
      ),
    ],
  );

  /// 4층 보스: 타락 대사제 — 속박.
  static const corruptHighPriest = BossCombatData(
    id: 'boss_corrupt_high_priest',
    name: '타락 대사제',
    floor: 4,
    phases: [
      BossPhaseConfig(
        hp: 105,
        atk: 17,
        def: 8,
        pattern: [
          EnemyActionType.buff,
          EnemyActionType.defend,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.shackle,
      ),
      BossPhaseConfig(
        hp: 60,
        atk: 22,
        def: 6,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.buff,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.shackle,
      ),
    ],
  );

  // ── 5층 보스 (3종) ────────────────────────────────────────

  /// 5층 보스: 던전 마스터 — 3페이즈 형태 변환.
  static const dungeonMaster = BossCombatData(
    id: 'boss_dungeon_master',
    name: '던전 마스터',
    floor: 5,
    phases: [
      BossPhaseConfig(
        hp: 110,
        atk: 20,
        def: 10,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.defend,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.formShift,
      ),
      BossPhaseConfig(
        hp: 90,
        atk: 26,
        def: 5,
        pattern: [
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.buff,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.formShift,
      ),
      BossPhaseConfig(
        hp: 60,
        atk: 30,
        def: 8,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
          EnemyActionType.heal,
        ],
        gimmick: BossGimmick.formShift,
      ),
    ],
  );

  /// 5층 보스: 공허의 군주 — 공허.
  static const voidSovereign = BossCombatData(
    id: 'boss_void_sovereign',
    name: '공허의 군주',
    floor: 5,
    phases: [
      BossPhaseConfig(
        hp: 120,
        atk: 22,
        def: 10,
        pattern: [
          EnemyActionType.buff,
          EnemyActionType.attack,
          EnemyActionType.defend,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.voidGimmick,
      ),
      BossPhaseConfig(
        hp: 90,
        atk: 28,
        def: 6,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
          EnemyActionType.attack,
        ],
        gimmick: BossGimmick.voidGimmick,
      ),
    ],
  );

  /// 5층 보스: 차원 붕괴자 — 반사.
  static const dimensionCollapser = BossCombatData(
    id: 'boss_dimension_collapser',
    name: '차원 붕괴자',
    floor: 5,
    phases: [
      BossPhaseConfig(
        hp: 110,
        atk: 24,
        def: 8,
        pattern: [
          EnemyActionType.defend,
          EnemyActionType.attack,
          EnemyActionType.charge,
          EnemyActionType.heavy,
          EnemyActionType.buff,
        ],
        gimmick: BossGimmick.reflect,
      ),
      BossPhaseConfig(
        hp: 110,
        atk: 30,
        def: 5,
        pattern: [
          EnemyActionType.attack,
          EnemyActionType.attack,
          EnemyActionType.heavy,
          EnemyActionType.charge,
          EnemyActionType.heavy,
        ],
        gimmick: BossGimmick.reflect,
      ),
    ],
  );

  // ── 층별 보스 풀 ──────────────────────────────────────────

  static const List<BossCombatData> floor1Bosses = [
    slimeKing,
    sewerCroc,
    ratMonarch,
  ];
  static const List<BossCombatData> floor2Bosses = [
    spiderLord,
    wardenChief,
    ghostConvict,
  ];
  static const List<BossCombatData> floor3Bosses = [
    orcGeneral,
    crystalGolem,
    manaOverload,
  ];
  static const List<BossCombatData> floor4Bosses = [
    vampireLord,
    archDemon,
    corruptHighPriest,
  ];
  static const List<BossCombatData> floor5Bosses = [
    dungeonMaster,
    voidSovereign,
    dimensionCollapser,
  ];

  /// 모든 보스 15종.
  static const List<BossCombatData> all = [
    slimeKing, sewerCroc, ratMonarch,
    spiderLord, wardenChief, ghostConvict,
    orcGeneral, crystalGolem, manaOverload,
    vampireLord, archDemon, corruptHighPriest,
    dungeonMaster, voidSovereign, dimensionCollapser,
  ];

  /// 층별 보스 조회 (기본값 — 기존 호환).
  static BossCombatData? forFloor(int floor) {
    return switch (floor) {
      1 => slimeKing,
      2 => spiderLord,
      3 => orcGeneral,
      4 => vampireLord,
      5 => dungeonMaster,
      _ => null,
    };
  }

  /// 층별 랜덤 보스 선택 (3종 풀에서).
  static BossCombatData? randomForFloor(int floor, {Random? random}) {
    final pool = switch (floor) {
      1 => floor1Bosses,
      2 => floor2Bosses,
      3 => floor3Bosses,
      4 => floor4Bosses,
      5 => floor5Bosses,
      _ => <BossCombatData>[],
    };
    if (pool.isEmpty) return null;
    final rng = random ?? Random();
    return pool[rng.nextInt(pool.length)];
  }
}
