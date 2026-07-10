import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';

/// 5층 전체 적 35종 — 층별 일반5 + 엘리트2 + 보스(별도).
class FloorEnemies {
  FloorEnemies._();

  // ── 1층: 하수도 ────────────────────────────────────────

  /// 쥐 — HP 25, ATK 10, DEF 2. 단순 공격 반복.
  static const rat = EnemyCombatData(
    id: 'enemy_rat',
    name: '쥐',
    hp: 25,
    atk: 10,
    def: 2,
    floor: 1,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.attack],
      [EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
    ],
  );

  /// 슬라임 — HP 35, ATK 8, DEF 4. 방어 후 공격.
  static const slime = EnemyCombatData(
    id: 'enemy_slime',
    name: '슬라임',
    hp: 35,
    atk: 8,
    def: 4,
    floor: 1,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.defend,
    ],
    alternatePatterns: [
      [EnemyActionType.defend, EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.attack],
      [EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 고블린 — HP 30, ATK 12, DEF 3. 충전 후 강공격.
  static const goblin = EnemyCombatData(
    id: 'enemy_goblin',
    name: '고블린',
    hp: 30,
    atk: 12,
    def: 3,
    floor: 1,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
      [EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 고블린 족장 (엘리트) — HP 65, ATK 14, DEF 5.
  static const goblinChief = EnemyCombatData(
    id: 'enemy_goblin_chief',
    name: '고블린 족장',
    hp: 65,
    atk: 14,
    def: 5,
    floor: 1,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
      EnemyActionType.heal,
    ],
  );

  /// 독 두꺼비 — HP 28, ATK 7, DEF 3. 버프 혼합.
  static const poisonToad = EnemyCombatData(
    id: 'enemy_poison_toad',
    name: '독 두꺼비',
    hp: 28,
    atk: 7,
    def: 3,
    floor: 1,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.buff, EnemyActionType.attack],
      [EnemyActionType.attack, EnemyActionType.buff, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
    ],
  );

  /// 박쥐 떼 — HP 20, ATK 10, DEF 1. 속전속결.
  static const batSwarm = EnemyCombatData(
    id: 'enemy_bat_swarm',
    name: '박쥐 떼',
    hp: 20,
    atk: 10,
    def: 1,
    floor: 1,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.defend,
    ],
    alternatePatterns: [
      [EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.defend],
      [EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.attack],
    ],
  );

  /// 하수도 거인 (엘리트) — HP 75, ATK 12, DEF 6.
  static const sewerGiant = EnemyCombatData(
    id: 'enemy_sewer_giant',
    name: '하수도 거인',
    hp: 75,
    atk: 12,
    def: 6,
    floor: 1,
    isElite: true,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
      EnemyActionType.heal,
      EnemyActionType.attack,
    ],
  );

  static const List<EnemyCombatData> floor1Normal = [
    rat,
    slime,
    goblin,
    poisonToad,
    batSwarm,
  ];
  /// 독 두꺼비 여왕 (엘리트) — HP 70, ATK 13, DEF 4.
  static const poisonToadQueen = EnemyCombatData(
    id: 'enemy_poison_toad_queen',
    name: '독 두꺼비 여왕',
    hp: 70,
    atk: 13,
    def: 4,
    floor: 1,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.heal,
    ],
  );

  static const List<EnemyCombatData> floor1Elite = [
    goblinChief,
    sewerGiant,
    poisonToadQueen,
  ];

  // ── 2층: 지하 감옥 ──────────────────────────────────────

  /// 해골 — HP 35, ATK 10, DEF 3. 충전 후 강공격 패턴.
  static const skeleton = EnemyCombatData(
    id: 'enemy_skeleton',
    name: '해골',
    hp: 35,
    atk: 10,
    def: 3,
    floor: 2,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.attack],
      [EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
    ],
  );

  /// 유령 — HP 25, ATK 11, DEF 1. 공격 집중형.
  static const ghost = EnemyCombatData(
    id: 'enemy_ghost',
    name: '유령',
    hp: 25,
    atk: 11,
    def: 1,
    floor: 2,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.observe,
    ],
    alternatePatterns: [
      [EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
      [EnemyActionType.attack, EnemyActionType.observe, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.attack],
    ],
  );

  /// 거미 — HP 40, ATK 10, DEF 4. 방어 혼합.
  static const spider = EnemyCombatData(
    id: 'enemy_spider',
    name: '거미',
    hp: 40,
    atk: 10,
    def: 4,
    floor: 2,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.defend,
      EnemyActionType.attack,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack],
      [EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 거미 여왕 (엘리트) — HP 80, ATK 16, DEF 6.
  static const spiderQueen = EnemyCombatData(
    id: 'enemy_spider_queen',
    name: '거미 여왕',
    hp: 80,
    atk: 16,
    def: 6,
    floor: 2,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.defend,
      EnemyActionType.heal,
    ],
  );

  /// 감옥 간수 — HP 38, ATK 12, DEF 5. 버프 → 강공격.
  static const prisonGuard = EnemyCombatData(
    id: 'enemy_prison_guard',
    name: '감옥 간수',
    hp: 38,
    atk: 12,
    def: 5,
    floor: 2,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.defend, EnemyActionType.buff, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 사슬 유령 — HP 30, ATK 9, DEF 2. 공격 집중.
  static const chainGhost = EnemyCombatData(
    id: 'enemy_chain_ghost',
    name: '사슬 유령',
    hp: 30,
    atk: 9,
    def: 2,
    floor: 2,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.defend,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.defend, EnemyActionType.attack],
      [EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.observe],
    ],
  );

  /// 죄수 왕 (엘리트) — HP 85, ATK 17, DEF 7.
  static const prisonerKing = EnemyCombatData(
    id: 'enemy_prisoner_king',
    name: '죄수 왕',
    hp: 85,
    atk: 17,
    def: 7,
    floor: 2,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
      EnemyActionType.heal,
    ],
  );

  static const List<EnemyCombatData> floor2Normal = [
    skeleton,
    ghost,
    spider,
    prisonGuard,
    chainGhost,
  ];
  /// 사슬 원혼 (엘리트) — HP 85, ATK 15, DEF 5.
  static const chainWraith = EnemyCombatData(
    id: 'enemy_chain_wraith',
    name: '사슬 원혼',
    hp: 85,
    atk: 15,
    def: 5,
    floor: 2,
    isElite: true,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.defend,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
      EnemyActionType.heal,
    ],
  );

  static const List<EnemyCombatData> floor2Elite = [
    spiderQueen,
    prisonerKing,
    chainWraith,
  ];

  // ── 3층: 마나 광산 ──────────────────────────────────────

  /// 골렘 — HP 55, ATK 10, DEF 8. 방어형.
  static const golem = EnemyCombatData(
    id: 'enemy_golem',
    name: '골렘',
    hp: 55,
    atk: 10,
    def: 8,
    floor: 3,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.defend, EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
      [EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 암흑 마법사 — HP 30, ATK 16, DEF 3. 버프 후 연타.
  static const darkMage = EnemyCombatData(
    id: 'enemy_dark_mage',
    name: '암흑 마법사',
    hp: 30,
    atk: 16,
    def: 3,
    floor: 3,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.buff, EnemyActionType.buff, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 오크 — HP 50, ATK 14, DEF 5. 강공격 패턴.
  static const orc = EnemyCombatData(
    id: 'enemy_orc',
    name: '오크',
    hp: 50,
    atk: 14,
    def: 5,
    floor: 3,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack, EnemyActionType.attack],
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 미믹 (엘리트) — HP 90, ATK 18, DEF 7.
  static const mimic = EnemyCombatData(
    id: 'enemy_mimic',
    name: '미믹',
    hp: 90,
    atk: 18,
    def: 7,
    floor: 3,
    isElite: true,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.heal,
    ],
  );

  /// 수정 구체 — HP 45, ATK 12, DEF 6. 이중 방어.
  static const crystalOrb = EnemyCombatData(
    id: 'enemy_crystal_orb',
    name: '수정 구체',
    hp: 45,
    atk: 12,
    def: 6,
    floor: 3,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.defend,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.defend, EnemyActionType.buff, EnemyActionType.defend, EnemyActionType.charge, EnemyActionType.heavy],
      [EnemyActionType.defend, EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 마나 포식자 — HP 35, ATK 15, DEF 3. 버프 후 연타.
  static const manaEater = EnemyCombatData(
    id: 'enemy_mana_eater',
    name: '마나 포식자',
    hp: 35,
    atk: 15,
    def: 3,
    floor: 3,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
      [EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack],
    ],
  );

  /// 고대 수호자 (엘리트) — HP 95, ATK 16, DEF 9.
  static const ancientGuardian = EnemyCombatData(
    id: 'enemy_ancient_guardian',
    name: '고대 수호자',
    hp: 95,
    atk: 16,
    def: 9,
    floor: 3,
    isElite: true,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.heal,
      EnemyActionType.attack,
    ],
  );

  static const List<EnemyCombatData> floor3Normal = [
    golem,
    darkMage,
    orc,
    crystalOrb,
    manaEater,
  ];
  /// 암흑 대마법사 (엘리트) — HP 95, ATK 19, DEF 6.
  static const darkArchmage = EnemyCombatData(
    id: 'enemy_dark_archmage',
    name: '암흑 대마법사',
    hp: 95,
    atk: 19,
    def: 6,
    floor: 3,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
      EnemyActionType.attack,
    ],
  );

  static const List<EnemyCombatData> floor3Elite = [
    mimic,
    ancientGuardian,
    darkArchmage,
  ];

  // ── 4층: 심연 사원 ──────────────────────────────────────

  /// 악마 — HP 50, ATK 18, DEF 6. 버프+강공격.
  static const demon = EnemyCombatData(
    id: 'enemy_demon',
    name: '악마',
    hp: 50,
    atk: 18,
    def: 6,
    floor: 4,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
      [EnemyActionType.attack, EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
    ],
  );

  /// 가고일 — HP 60, ATK 14, DEF 10. 방어 중심.
  static const gargoyle = EnemyCombatData(
    id: 'enemy_gargoyle',
    name: '가고일',
    hp: 60,
    atk: 14,
    def: 10,
    floor: 4,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.attack,
      EnemyActionType.defend,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.defend, EnemyActionType.defend, EnemyActionType.buff, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
      [EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 사령 — HP 40, ATK 20, DEF 4. 버프+연타.
  static const necromancer = EnemyCombatData(
    id: 'enemy_necromancer',
    name: '사령',
    hp: 40,
    atk: 20,
    def: 4,
    floor: 4,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.buff, EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
    ],
  );

  /// 원혼 (엘리트) — HP 100, ATK 22, DEF 8.
  static const wraith = EnemyCombatData(
    id: 'enemy_wraith',
    name: '원혼',
    hp: 100,
    atk: 22,
    def: 8,
    floor: 4,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
      EnemyActionType.heal,
      EnemyActionType.attack,
    ],
  );

  /// 타락 사제 — HP 45, ATK 16, DEF 5. 버프+회복.
  static const corruptPriest = EnemyCombatData(
    id: 'enemy_corrupt_priest',
    name: '타락 사제',
    hp: 45,
    atk: 16,
    def: 5,
    floor: 4,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.heal,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.buff, EnemyActionType.heal, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.heal],
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.heal, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 그림자 마수 — HP 55, ATK 20, DEF 4. 순수 공격.
  static const shadowBeast = EnemyCombatData(
    id: 'enemy_shadow_beast',
    name: '그림자 마수',
    hp: 55,
    atk: 20,
    def: 4,
    floor: 4,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack, EnemyActionType.attack],
      [EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 심연의 눈 (엘리트) — HP 110, ATK 24, DEF 9.
  static const abyssEye = EnemyCombatData(
    id: 'enemy_abyss_eye',
    name: '심연의 눈',
    hp: 110,
    atk: 24,
    def: 9,
    floor: 4,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.defend,
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.heal,
    ],
  );

  static const List<EnemyCombatData> floor4Normal = [
    demon,
    gargoyle,
    necromancer,
    corruptPriest,
    shadowBeast,
  ];
  /// 가고일 수호신 (엘리트) — HP 105, ATK 20, DEF 11.
  static const gargoyleGuardian = EnemyCombatData(
    id: 'enemy_gargoyle_guardian',
    name: '가고일 수호신',
    hp: 105,
    atk: 20,
    def: 11,
    floor: 4,
    isElite: true,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.defend,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
      EnemyActionType.heal,
    ],
  );

  static const List<EnemyCombatData> floor4Elite = [
    wraith,
    abyssEye,
    gargoyleGuardian,
  ];

  // ── 5층: 심층 던전 ──────────────────────────────────────

  /// 암흑 기사 — HP 65, ATK 20, DEF 10. 균형형.
  static const darkKnight = EnemyCombatData(
    id: 'enemy_dark_knight',
    name: '암흑 기사',
    hp: 65,
    atk: 20,
    def: 10,
    floor: 5,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.defend,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.defend, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.defend],
      [EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.defend, EnemyActionType.buff, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 리치 — HP 50, ATK 24, DEF 5. 버프+강공격.
  static const lich = EnemyCombatData(
    id: 'enemy_lich',
    name: '리치',
    hp: 50,
    atk: 24,
    def: 5,
    floor: 5,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.attack,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.buff, EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
      [EnemyActionType.buff, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack],
    ],
  );

  /// 용족 — HP 70, ATK 22, DEF 8. 강공격 선행.
  static const dragonkin = EnemyCombatData(
    id: 'enemy_dragonkin',
    name: '용족',
    hp: 70,
    atk: 22,
    def: 8,
    floor: 5,
    pattern: [
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
      EnemyActionType.attack,
      EnemyActionType.defend,
    ],
    alternatePatterns: [
      [EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.defend, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
      [EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 공허의 보행자 (엘리트) — HP 120, ATK 26, DEF 10.
  static const voidWalker = EnemyCombatData(
    id: 'enemy_void_walker',
    name: '공허의 보행자',
    hp: 120,
    atk: 26,
    def: 10,
    floor: 5,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.defend,
      EnemyActionType.attack,
      EnemyActionType.heal,
      EnemyActionType.attack,
    ],
  );

  /// 영혼 파괴자 — HP 60, ATK 22, DEF 8. 버프 스케일링.
  static const soulDestroyer = EnemyCombatData(
    id: 'enemy_soul_destroyer',
    name: '영혼 파괴자',
    hp: 60,
    atk: 22,
    def: 8,
    floor: 5,
    pattern: [
      EnemyActionType.attack,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.attack,
    ],
    alternatePatterns: [
      [EnemyActionType.buff, EnemyActionType.attack, EnemyActionType.attack, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.attack],
      [EnemyActionType.attack, EnemyActionType.buff, EnemyActionType.buff, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 공허의 직조자 — HP 55, ATK 18, DEF 12. 최고 DEF.
  static const voidWeaver = EnemyCombatData(
    id: 'enemy_void_weaver',
    name: '공허의 직조자',
    hp: 55,
    atk: 18,
    def: 12,
    floor: 5,
    pattern: [
      EnemyActionType.defend,
      EnemyActionType.defend,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
    ],
    alternatePatterns: [
      [EnemyActionType.defend, EnemyActionType.buff, EnemyActionType.defend, EnemyActionType.charge, EnemyActionType.heavy, EnemyActionType.defend],
      [EnemyActionType.defend, EnemyActionType.defend, EnemyActionType.defend, EnemyActionType.buff, EnemyActionType.charge, EnemyActionType.heavy],
    ],
  );

  /// 차원의 균열 (엘리트) — HP 130, ATK 28, DEF 11.
  static const dimensionRift = EnemyCombatData(
    id: 'enemy_dimension_rift',
    name: '차원의 균열',
    hp: 130,
    atk: 28,
    def: 11,
    floor: 5,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.defend,
      EnemyActionType.attack,
      EnemyActionType.heal,
      EnemyActionType.attack,
    ],
  );

  static const List<EnemyCombatData> floor5Normal = [
    darkKnight,
    lich,
    dragonkin,
    soulDestroyer,
    voidWeaver,
  ];
  /// 리치 군주 (엘리트) — HP 125, ATK 27, DEF 10.
  static const lichLord = EnemyCombatData(
    id: 'enemy_lich_lord',
    name: '리치 군주',
    hp: 125,
    atk: 27,
    def: 10,
    floor: 5,
    isElite: true,
    pattern: [
      EnemyActionType.buff,
      EnemyActionType.buff,
      EnemyActionType.charge,
      EnemyActionType.heavy,
      EnemyActionType.defend,
      EnemyActionType.attack,
      EnemyActionType.heal,
      EnemyActionType.attack,
    ],
  );

  static const List<EnemyCombatData> floor5Elite = [
    voidWalker,
    dimensionRift,
    lichLord,
  ];

  // ── 전체 조회 ──────────────────────────────────────────

  /// 모든 적 40종.
  static const List<EnemyCombatData> all = [
    // Floor 1
    rat, slime, goblin, poisonToad, batSwarm,
    goblinChief, sewerGiant, poisonToadQueen,
    // Floor 2
    skeleton, ghost, spider, prisonGuard, chainGhost,
    spiderQueen, prisonerKing, chainWraith,
    // Floor 3
    golem, darkMage, orc, crystalOrb, manaEater,
    mimic, ancientGuardian, darkArchmage,
    // Floor 4
    demon, gargoyle, necromancer, corruptPriest, shadowBeast,
    wraith, abyssEye, gargoyleGuardian,
    // Floor 5
    darkKnight, lich, dragonkin, soulDestroyer, voidWeaver,
    voidWalker, dimensionRift, lichLord,
  ];

  /// 일반 적만 25종.
  static const List<EnemyCombatData> allNormal = [
    rat, slime, goblin, poisonToad, batSwarm,
    skeleton, ghost, spider, prisonGuard, chainGhost,
    golem, darkMage, orc, crystalOrb, manaEater,
    demon, gargoyle, necromancer, corruptPriest, shadowBeast,
    darkKnight, lich, dragonkin, soulDestroyer, voidWeaver,
  ];

  /// 엘리트만 15종.
  static const List<EnemyCombatData> allElite = [
    goblinChief, sewerGiant, poisonToadQueen,
    spiderQueen, prisonerKing, chainWraith,
    mimic, ancientGuardian, darkArchmage,
    wraith, abyssEye, gargoyleGuardian,
    voidWalker, dimensionRift, lichLord,
  ];
}
