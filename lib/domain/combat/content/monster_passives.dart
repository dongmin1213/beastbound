/// 몬스터 패시브 — 장착(로스터)한 몬스터가 주는 매 턴 지속 효과.
///
/// 성향(disposition) 시스템을 대체한다. "이 몬스터를 데려가면 이 플레이가
/// 강해진다" — 테이밍 게임의 핵심 재미. 기존 PowerEffects 기계장치(턴마다
/// 블록/독/힘/회복/드로우)에 주입되어 별도 전투 계산 없이 작동한다.
///
/// 레이어링: 여기서는 순수 수치만 정의하고, PowerEffects 조립은 CombatBloc이 한다.
class MonsterPassive {
  /// 표시 라벨 (예: "매 턴 힘 +1").
  final String label;

  final int blockPerTurn; // 매 턴 방어
  final int poisonPerTurn; // 매 턴 적에게 독
  final int healPerTurn; // 매 턴 HP 회복
  final int strengthPerTurn; // 매 턴 힘 +
  final int drawPerTurn; // 매 턴 추가 드로우

  const MonsterPassive({
    this.label = '',
    this.blockPerTurn = 0,
    this.poisonPerTurn = 0,
    this.healPerTurn = 0,
    this.strengthPerTurn = 0,
    this.drawPerTurn = 0,
  });

  /// 효과 없음.
  static const none = MonsterPassive();

  // ── 아키타입 프리셋 ──
  static const _strength =
      MonsterPassive(label: '매 턴 힘 +1', strengthPerTurn: 1);
  static const _block = MonsterPassive(label: '매 턴 방어 +3', blockPerTurn: 3);
  static const _poison =
      MonsterPassive(label: '매 턴 적 독 +2', poisonPerTurn: 2);
  static const _heal = MonsterPassive(label: '매 턴 회복 +2', healPerTurn: 2);
  static const _draw = MonsterPassive(label: '매 턴 드로우 +1', drawPerTurn: 1);

  bool get isNone =>
      blockPerTurn == 0 &&
      poisonPerTurn == 0 &&
      healPerTurn == 0 &&
      strengthPerTurn == 0 &&
      drawPerTurn == 0;
}

/// 몬스터 id → 패시브 매핑 + 로스터 합산.
class MonsterPassives {
  MonsterPassives._();

  /// 몬스터 id → 패시브 (아키타입별). 무브풀 테마와 일치.
  static const Map<String, MonsterPassive> _passives = {
    // 1층
    'enemy_rat': MonsterPassive._draw,
    'enemy_slime': MonsterPassive._block,
    'enemy_goblin': MonsterPassive._strength,
    'enemy_goblin_chief': MonsterPassive._strength,
    'enemy_poison_toad': MonsterPassive._poison,
    'enemy_bat_swarm': MonsterPassive._draw,
    'enemy_sewer_giant': MonsterPassive._block,
    'enemy_poison_toad_queen': MonsterPassive._poison,
    // 2층
    'enemy_skeleton': MonsterPassive._strength,
    'enemy_ghost': MonsterPassive._heal,
    'enemy_spider': MonsterPassive._poison,
    'enemy_spider_queen': MonsterPassive._poison,
    'enemy_prison_guard': MonsterPassive._block,
    'enemy_chain_ghost': MonsterPassive._heal,
    'enemy_prisoner_king': MonsterPassive._strength,
    'enemy_chain_wraith': MonsterPassive._heal,
    // 3층
    'enemy_golem': MonsterPassive._block,
    'enemy_dark_mage': MonsterPassive._draw,
    'enemy_orc': MonsterPassive._strength,
    'enemy_mimic': MonsterPassive._draw,
    'enemy_crystal_orb': MonsterPassive._block,
    'enemy_mana_eater': MonsterPassive._draw,
    'enemy_ancient_guardian': MonsterPassive._block,
    'enemy_dark_archmage': MonsterPassive._draw,
    // 4층
    'enemy_demon': MonsterPassive._strength,
    'enemy_gargoyle': MonsterPassive._block,
    'enemy_necromancer': MonsterPassive._heal,
    'enemy_wraith': MonsterPassive._heal,
    'enemy_corrupt_priest': MonsterPassive._heal,
    'enemy_shadow_beast': MonsterPassive._poison,
    'enemy_abyss_eye': MonsterPassive._draw,
    'enemy_gargoyle_guardian': MonsterPassive._block,
    // 5층
    'enemy_dark_knight': MonsterPassive._strength,
    'enemy_lich': MonsterPassive._heal,
    'enemy_dragonkin': MonsterPassive._strength,
    'enemy_void_walker': MonsterPassive._draw,
    'enemy_soul_destroyer': MonsterPassive._heal,
    'enemy_void_weaver': MonsterPassive._draw,
    'enemy_dimension_rift': MonsterPassive._draw,
    'enemy_lich_lord': MonsterPassive._heal,
  };

  /// 몬스터 id → 패시브 (없으면 none).
  static MonsterPassive forMonster(String id) =>
      _passives[id] ?? MonsterPassive.none;

  /// 로스터 몬스터들의 패시브 합산.
  static MonsterPassive aggregate(List<String> monsterIds) {
    var block = 0, poison = 0, heal = 0, strength = 0, draw = 0;
    for (final id in monsterIds) {
      final p = forMonster(id);
      block += p.blockPerTurn;
      poison += p.poisonPerTurn;
      heal += p.healPerTurn;
      strength += p.strengthPerTurn;
      draw += p.drawPerTurn;
    }
    return MonsterPassive(
      blockPerTurn: block,
      poisonPerTurn: poison,
      healPerTurn: heal,
      strengthPerTurn: strength,
      drawPerTurn: draw,
    );
  }
}
