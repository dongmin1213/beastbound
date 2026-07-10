import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';

/// 몬스터 무브풀 — 몬스터 id → 길들이면 드래프트 가능한 카드 id 목록.
///
/// "네가 싸운 적이, 네 덱이 된다"의 **데이터 백본**.
/// 몬스터를 길들이면 이 무브풀에서 카드를 뽑아 덱에 넣는다(장착 풀).
/// 콘텐츠 교체는 원칙적으로 이 파일 하나만 수정한다(에셋 swap 구조와 동일 철학).
///
/// 현재는 원작의 기존 카드(직업/무색)를 테마별로 재활용. 신규 카드 도입 시
/// 여기 매핑만 갈아끼우면 된다.
class MonsterCards {
  MonsterCards._();

  /// 몬스터 id → 무브풀 카드 id. (1층 8종 — 테마별)
  static const Map<String, List<String>> _movepool = {
    // 쥐 — 빠른 연타.
    'enemy_rat': [
      'colorless_focused_strike',
      'colorless_double_strike',
      'colorless_sprint',
      'warrior_charge',
      'colorless_critical_strike',
    ],
    // 슬라임 — 방어/점착.
    'enemy_slime': [
      'guardian_iron_guard',
      'guardian_shield_bash',
      'colorless_endurance',
      'guardian_thorn_armor',
      'colorless_patience',
    ],
    // 고블린 — 기본 근접 공격.
    'enemy_goblin': [
      'warrior_heavy_strike',
      'warrior_crush',
      'warrior_charge',
      'colorless_focused_strike',
      'warrior_spin_slash',
    ],
    // 고블린 두목 — 근접 + 버프.
    'enemy_goblin_chief': [
      'warrior_war_cry',
      'warrior_onslaught',
      'warrior_rage_shout',
      'warrior_heavy_strike',
      'colorless_expose_weakness',
    ],
    // 독두꺼비 — 독/도트.
    'enemy_poison_toad': [
      'assassin_poison_blade',
      'assassin_poison_cloud',
      'colorless_poison_jar',
      'assassin_poison_burst',
      'assassin_ambush',
    ],
    // 박쥐 떼 — 다단히트/속공.
    'enemy_bat_swarm': [
      'assassin_chain_strike',
      'colorless_double_strike',
      'colorless_sprint',
      'assassin_shadow_step',
      'whirlwind',
    ],
    // 하수구 거인 — 강타/중량.
    'enemy_sewer_giant': [
      'warrior_execute',
      'warrior_crush',
      'guardian_wall_charge',
      'warrior_berserker',
      'colorless_last_stand',
    ],
    // 독두꺼비 여왕 — 독 강화.
    'enemy_poison_toad_queen': [
      'assassin_poison_burst',
      'assassin_poison_cloud',
      'colorless_poison_jar',
      'assassin_assassination',
      'assassin_poison_blade',
    ],

    // ── 2층: 지하 감옥 (언데드/거미/구속) ──
    'enemy_skeleton': [
      'warrior_heavy_strike', 'reaper_scythe', 'warrior_crush',
      'colorless_focused_strike', 'reaper_grim',
    ],
    'enemy_ghost': [
      'illusionist_phantom_strike', 'colorless_smoke_screen',
      'reaper_life_drain', 'illusionist_clone', 'colorless_observe',
    ],
    'enemy_spider': [
      'assassin_poison_blade', 'assassin_poison_cloud', 'colorless_poison_jar',
      'assassin_chain_strike', 'guardian_thorn_armor',
    ],
    'enemy_spider_queen': [
      'assassin_poison_burst', 'assassin_poison_cloud',
      'illusionist_phantom_army', 'colorless_poison_jar',
      'assassin_assassination',
    ],
    'enemy_prison_guard': [
      'guardian_iron_guard', 'guardian_taunt', 'guardian_shield_bash',
      'guardian_chains', 'warrior_crush',
    ],
    'enemy_chain_ghost': [
      'reaper_life_drain', 'guardian_chains', 'illusionist_phantom_strike',
      'reaper_soul_split', 'colorless_smoke_screen',
    ],
    'enemy_prisoner_king': [
      'warrior_war_cry', 'warrior_onslaught', 'guardian_chains',
      'warrior_execute', 'warrior_rage_shout',
    ],
    'enemy_chain_wraith': [
      'reaper_soul_harvest', 'reaper_life_drain', 'guardian_chains',
      'reaper_death_mark', 'reaper_grim',
    ],

    // ── 3층: 마나 광산 (골렘/마법/마나) ──
    'enemy_golem': [
      'guardian_iron_guard', 'guardian_fortress', 'guardian_wall_charge',
      'guardian_unyielding', 'warrior_crush',
    ],
    'enemy_dark_mage': [
      'sage_magic_bolt', 'sage_magic_explosion', 'sage_chain_lightning',
      'sage_mana_charge', 'reaper_death_touch',
    ],
    'enemy_orc': [
      'warrior_heavy_strike', 'warrior_berserker', 'warrior_crush',
      'warrior_onslaught', 'warrior_execute',
    ],
    'enemy_mimic': [
      'wanderer_mimic', 'colorless_bold_gamble', 'wanderer_conjure',
      'colorless_collector', 'wanderer_improvise_strike',
    ],
    'enemy_crystal_orb': [
      'sage_mana_barrier', 'sage_mana_cycle', 'guardian_thorn_armor',
      'sage_magic_bolt', 'sage_analysis',
    ],
    'enemy_mana_eater': [
      'sage_mana_cycle', 'sage_mana_charge', 'reaper_life_drain',
      'sage_chain_lightning', 'harmonist_absorb',
    ],
    'enemy_ancient_guardian': [
      'guardian_fortress', 'guardian_unyielding', 'guardian_iron_guard',
      'guardian_counter_stance', 'warrior_crush',
    ],
    'enemy_dark_archmage': [
      'sage_magic_explosion', 'sage_chain_lightning', 'sage_time_distortion',
      'sage_mana_charge', 'reaper_death_sentence',
    ],

    // ── 4층: 심연 사원 (악마/언데드/타락) ──
    'enemy_demon': [
      'warrior_berserker', 'sage_magic_explosion', 'reaper_death_touch',
      'warrior_execute', 'saint_retribution',
    ],
    'enemy_gargoyle': [
      'guardian_iron_guard', 'guardian_thorn_armor', 'guardian_fortress',
      'warrior_crush', 'guardian_counter_stance',
    ],
    'enemy_necromancer': [
      'reaper_soul_harvest', 'illusionist_phantom_army', 'reaper_death_mark',
      'reaper_nether_gate', 'sage_magic_bolt',
    ],
    'enemy_wraith': [
      'reaper_life_drain', 'reaper_soul_split', 'reaper_grim',
      'illusionist_phantom_strike', 'reaper_death_touch',
    ],
    'enemy_corrupt_priest': [
      'saint_divine_strike', 'saint_retribution', 'saint_judgment',
      'reaper_death_mark', 'saint_purify',
    ],
    'enemy_shadow_beast': [
      'assassin_shadow_step', 'illusionist_phantom_strike', 'assassin_ambush',
      'assassin_chain_strike', 'colorless_smoke_screen',
    ],
    'enemy_abyss_eye': [
      'sage_analysis', 'colorless_expose_weakness', 'sage_magic_explosion',
      'reaper_death_sentence', 'sage_time_distortion',
    ],
    'enemy_gargoyle_guardian': [
      'guardian_fortress', 'guardian_unyielding', 'guardian_wall_charge',
      'guardian_counter_stance', 'guardian_iron_guard',
    ],

    // ── 5층: 심층 던전 (공허/용/리치) ──
    'enemy_dark_knight': [
      'warrior_heavy_strike', 'reaper_death_touch', 'warrior_execute',
      'warrior_blood_strike', 'guardian_iron_guard',
    ],
    'enemy_lich': [
      'reaper_soul_harvest', 'sage_magic_explosion', 'reaper_death_sentence',
      'reaper_nether_gate', 'reaper_immortal_will',
    ],
    'enemy_dragonkin': [
      'warrior_berserker', 'sage_magic_explosion', 'warrior_crush',
      'warrior_onslaught', 'warrior_execute',
    ],
    'enemy_void_walker': [
      'illusionist_dimension_shift', 'sage_time_distortion',
      'assassin_shadow_step', 'illusionist_phantom_strike',
      'colorless_time_rewind',
    ],
    'enemy_soul_destroyer': [
      'reaper_soul_harvest', 'reaper_death_sentence', 'reaper_soul_split',
      'reaper_life_drain', 'reaper_death_mark',
    ],
    'enemy_void_weaver': [
      'sage_time_distortion', 'illusionist_dimension_shift',
      'sage_chain_lightning', 'illusionist_phantom_army',
      'colorless_time_rewind',
    ],
    'enemy_dimension_rift': [
      'illusionist_dimension_shift', 'sage_time_distortion',
      'illusionist_perfect_copy', 'colorless_time_rewind',
      'sage_magic_explosion',
    ],
    'enemy_lich_lord': [
      'reaper_immortal_will', 'reaper_soul_harvest', 'reaper_nether_gate',
      'reaper_death_sentence', 'sage_magic_explosion',
    ],
  };

  /// 몬스터 id → 무브풀 카드 id 목록 (없으면 빈 리스트).
  static List<String> movepoolIds(String monsterId) =>
      _movepool[monsterId] ?? const [];

  /// 몬스터 id → 실제 CardData 목록 (레지스트리에 없는 id는 자동 스킵).
  static List<CardData> movepool(String monsterId) => movepoolIds(monsterId)
      .map(CardPool.findById)
      .whereType<CardData>()
      .toList();

  /// 무브풀 정의 여부.
  static bool hasMovepool(String monsterId) =>
      _movepool.containsKey(monsterId);
}
