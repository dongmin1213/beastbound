/// 픽셀 아트 에셋 경로 매핑 — enemy ID / job ID → PNG 경로.
class PixelArtAssets {
  PixelArtAssets._();

  static const _base = 'assets/pixel_art';

  // ── 적 스프라이트 ──

  static const _enemySprites = <String, String>{
    // Floor 1
    'enemy_rat': 'monsters/floor1/rat.png',
    'enemy_slime': 'monsters/floor1/slime.png',
    'enemy_goblin': 'monsters/floor1/goblin.png',
    'enemy_goblin_chief': 'monsters/floor1/goblin_chief.png',
    'enemy_poison_toad': 'monsters/floor1/toad.png',
    'enemy_bat_swarm': 'monsters/floor1/bats.png',
    'enemy_sewer_giant': 'monsters/floor1/sewer_giant.png',
    'enemy_poison_toad_queen': 'monsters/floor1/toad_queen.png',
    // Floor 2
    'enemy_skeleton': 'monsters/floor2/skeleton.png',
    'enemy_ghost': 'monsters/floor2/ghost.png',
    'enemy_spider': 'monsters/floor2/spider.png',
    'enemy_spider_queen': 'monsters/floor2/spider_queen.png',
    'enemy_prison_guard': 'monsters/floor2/jailer.png',
    'enemy_chain_ghost': 'monsters/floor2/chain_ghost.png',
    'enemy_prisoner_king': 'monsters/floor2/prisoner_king.png',
    'enemy_chain_wraith': 'monsters/floor2/chain_wraith.png',
    // Floor 3
    'enemy_golem': 'monsters/floor3/golem.png',
    'enemy_dark_mage': 'monsters/floor3/dark_mage.png',
    'enemy_orc': 'monsters/floor3/orc.png',
    'enemy_mimic': 'monsters/floor3/mimic.png',
    'enemy_crystal_orb': 'monsters/floor3/crystal_orb.png',
    'enemy_mana_eater': 'monsters/floor3/mana_eater.png',
    'enemy_ancient_guardian': 'monsters/floor3/ancient_guardian.png',
    'enemy_dark_archmage': 'monsters/floor3/dark_archmage.png',
    // Floor 4
    'enemy_demon': 'monsters/floor4/demon.png',
    'enemy_gargoyle': 'monsters/floor4/gargoyle.png',
    'enemy_necromancer': 'monsters/floor4/necromancer.png',
    'enemy_wraith': 'monsters/floor4/wraith.png',
    'enemy_corrupt_priest': 'monsters/floor4/corrupt_priest.png',
    'enemy_shadow_beast': 'monsters/floor4/shadow_beast.png',
    'enemy_abyss_eye': 'monsters/floor4/abyss_eye.png',
    'enemy_gargoyle_guardian': 'monsters/floor4/gargoyle_guardian.png',
    // Floor 5
    'enemy_dark_knight': 'monsters/floor5/dark_knight.png',
    'enemy_lich': 'monsters/floor5/lich.png',
    'enemy_dragonkin': 'monsters/floor5/dragonkin.png',
    'enemy_void_walker': 'monsters/floor5/void_walker.png',
    'enemy_soul_destroyer': 'monsters/floor5/soul_destroyer.png',
    'enemy_void_weaver': 'monsters/floor5/void_weaver.png',
    'enemy_dimension_rift': 'monsters/floor5/dimensional_rift.png',
    'enemy_lich_lord': 'monsters/floor5/lich_lord.png',
  };

  // ── 보스 스프라이트 ──

  static const _bossSprites = <String, String>{
    // Floor 1
    'boss_slime_king': 'bosses/slime_king.png',
    'boss_sewer_croc': 'bosses/sewer_croc.png',
    'boss_rat_monarch': 'bosses/rat_monarch.png',
    // Floor 2
    'boss_spider_lord': 'bosses/spider_lord.png',
    'boss_warden_chief': 'bosses/warden_chief.png',
    'boss_ghost_convict': 'bosses/ghost_convict.png',
    // Floor 3
    'boss_orc_general': 'bosses/orc_general.png',
    'boss_crystal_golem': 'bosses/crystal_golem.png',
    'boss_mana_overload': 'bosses/mana_overload.png',
    // Floor 4
    'boss_vampire_lord': 'bosses/vampire_lord.png',
    'boss_arch_demon': 'bosses/arch_demon.png',
    'boss_corrupt_high_priest': 'bosses/corrupt_high_priest.png',
    // Floor 5
    'boss_dungeon_master': 'bosses/dungeon_master.png',
    'boss_void_sovereign': 'bosses/void_sovereign.png',
    'boss_dimension_collapser': 'bosses/dimension_collapser.png',
    // Legacy keys (without boss_ prefix)
    'slime_king': 'bosses/slime_king.png',
    'spider_lord': 'bosses/spider_lord.png',
    'orc_general': 'bosses/orc_general.png',
    'vampire_lord': 'bosses/vampire_lord.png',
    'dungeon_master': 'bosses/dungeon_master.png',
  };

  // ── 직업 초상화 ──

  static const _jobSprites = <String, String>{
    'warrior': 'jobs/warrior.png',
    'sage': 'jobs/sage.png',
    'assassin': 'jobs/assassin.png',
    'saint': 'jobs/saint.png',
    'guardian': 'jobs/guardian.png',
    'wanderer': 'jobs/wanderer.png',
    'reaper': 'jobs/reaper.png',
    'illusionist': 'jobs/illusionist.png',
    'harmonist': 'jobs/harmonist.png',
  };

  /// 적 ID → 스프라이트 경로. 없으면 null.
  static String? enemySprite(String enemyId) {
    final path = _enemySprites[enemyId];
    return path != null ? '$_base/$path' : null;
  }

  /// 보스 ID → 스프라이트 경로. 없으면 null.
  static String? bossSprite(String bossId) {
    final path = _bossSprites[bossId];
    return path != null ? '$_base/$path' : null;
  }

  /// 직업 ID → 초상화 경로. 없으면 null.
  static String? jobSprite(String jobId) {
    final path = _jobSprites[jobId];
    return path != null ? '$_base/$path' : null;
  }

  // ── UI 아이콘 ──

  static const String hpIcon = '$_base/ui/hp.png';
  static const String goldIcon = '$_base/ui/gold.png';
  static const String soulIcon = '$_base/ui/soul.png';
  static const String blockIcon = '$_base/ui/block.png';
  static const String apIcon = '$_base/ui/ap.png';
  static const String keyIcon = '$_base/ui/key.png';

  // ── 카드 타입 아이콘 ──

  static const String attackCardIcon = '$_base/cards/attack.png';
  static const String skillCardIcon = '$_base/cards/skill.png';
  static const String powerCardIcon = '$_base/cards/power.png';

  // ── 타이틀 ──

  static const String logo = '$_base/title/soul_dungeon_logo.png';
}
