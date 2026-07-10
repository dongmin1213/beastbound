/// 카드 ID → game-icons.net SVG 아이콘 매핑.
/// 아이콘 출처: https://game-icons.net (CC BY 3.0)
/// 작성자: Lorc, Delapouite 등 — 크레딧 표기 필요.
class CardIconMapper {
  CardIconMapper._();

  static const _base = 'assets/game_icons';

  /// 카드 ID('+' 접미사 제거)에 대응하는 아이콘 경로 반환.
  /// 매핑 없으면 null.
  static String? iconPath(String cardId) {
    // play_card_ / card_reward_ 접두사 제거
    var stripped = cardId;
    if (cardId.startsWith('play_card_')) {
      stripped = cardId.substring('play_card_'.length);
    } else if (cardId.startsWith('card_reward_')) {
      stripped = cardId.substring('card_reward_'.length);
    }
    // '+' 접미사 제거 (업그레이드 카드)
    final baseId = stripped.endsWith('+')
        ? stripped.substring(0, stripped.length - 1)
        : stripped;
    final file = _map[baseId];
    if (file != null) return '$_base/$file';

    // play_card_{id}_{index} 형태의 인덱스 접미사 제거 시도
    final lastUnderscore = baseId.lastIndexOf('_');
    if (lastUnderscore > 0) {
      final withoutSuffix = baseId.substring(0, lastUnderscore);
      final cleaned = withoutSuffix.endsWith('+')
          ? withoutSuffix.substring(0, withoutSuffix.length - 1)
          : withoutSuffix;
      final fallback = _map[cleaned];
      if (fallback != null) return '$_base/$fallback';
    }

    return null;
  }

  static const _map = <String, String>{
    // ── Starter ──
    'starter_strike_1': 'strike.svg',
    'starter_strike_2': 'strike.svg',
    'starter_strike_3': 'strike.svg',
    'starter_defend_1': 'defend.svg',
    'starter_defend_2': 'defend.svg',
    'starter_vigilance': 'defend.svg',
    'starter_brace': 'focus.svg',

    // ── Warrior ──
    'warrior_heavy_strike': 'heavy_strike.svg',
    'warrior_war_cry': 'war_cry.svg',
    'warrior_charge': 'charge.svg',
    'warrior_onslaught': 'onslaught.svg',
    'warrior_crush': 'crush.svg',
    'warrior_berserker': 'berserker.svg',
    'warrior_blood_oath': 'blood_oath.svg',
    'warrior_spin_slash': 'spin_slash.svg',
    'warrior_awakening': 'berserker.svg',
    'warrior_battle_pulse': 'onslaught.svg',
    'warrior_blood_strike': 'blood_oath.svg',
    'warrior_execute': 'crush.svg',
    'warrior_iron_will': 'unyielding.svg',
    'warrior_rage_shout': 'war_cry.svg',
    'warrior_war_pulse': 'onslaught.svg',

    // ── Sage ──
    'sage_magic_bolt': 'magic_bolt.svg',
    'sage_analysis': 'analysis.svg',
    'sage_focus': 'focus.svg',
    'sage_mana_cycle': 'mana_cycle.svg',
    'sage_magic_explosion': 'magic_explosion.svg',
    'sage_chain_lightning': 'chain_lightning.svg',
    'sage_time_distortion': 'time_distortion.svg',
    'sage_mana_charge': 'mana_charge.svg',
    'sage_dimension_cut': 'dimension_shift.svg',
    'sage_mana_barrier': 'mana_crystal.svg',
    'sage_mana_overload': 'magic_explosion.svg',
    'sage_mana_reflux': 'mana_cycle.svg',
    'sage_mind_focus': 'focus.svg',
    'sage_tower_of_knowledge': 'wisdom.svg',
    'sage_mana_absorb': 'mana_crystal.svg',
    'sage_mana_shield': 'mana_crystal.svg',

    // ── Assassin ──
    'assassin_ambush': 'ambush.svg',
    'assassin_poison_blade': 'poison_blade.svg',
    'assassin_stealth': 'stealth.svg',
    'assassin_shadow': 'shadow.svg',
    'assassin_chain_strike': 'chain_strike.svg',
    'assassin_poison_cloud': 'poison_cloud.svg',
    'assassin_assassination': 'assassination.svg',
    'assassin_shadow_clone': 'shadow_clone.svg',
    'assassin_blade_rain': 'chain_strike.svg',
    'assassin_dark_cloak': 'stealth.svg',
    'assassin_poison_burst': 'poison_cloud.svg',
    'assassin_poison_fig': 'poison_blade.svg',
    'assassin_shadow_step': 'shadow.svg',
    'assassin_vital_strike': 'assassination.svg',
    'assassin_toxic_guard': 'poison_cloud.svg',
    'assassin_shadow_leap': 'shadow.svg',

    // ── Saint ──
    'saint_divine_strike': 'divine_strike.svg',
    'saint_heal': 'heal.svg',
    'saint_prayer': 'prayer.svg',
    'saint_holy_wall': 'holy_wall.svg',
    'saint_divine_shield': 'divine_shield.svg',
    'saint_purify': 'purify.svg',
    'saint_retribution': 'retribution.svg',
    'saint_light_of_regeneration': 'light_of_regeneration.svg',
    'saint_blessed_armor': 'divine_shield.svg',
    'saint_devotion': 'prayer.svg',
    'saint_divine_barrier': 'holy_wall.svg',
    'saint_divine_punishment': 'retribution.svg',
    'saint_holy_light': 'light_of_regeneration.svg',
    'saint_judgment': 'divine_strike.svg',

    // ── Guardian ──
    'guardian_shield_bash': 'shield_bash.svg',
    'guardian_iron_guard': 'iron_guard.svg',
    'guardian_thorn_armor': 'thorn_armor.svg',
    'guardian_taunt': 'taunt.svg',
    'guardian_counter_stance': 'counter_stance.svg',
    'guardian_fortress': 'fortress.svg',
    'guardian_thorn_burst': 'thorn_burst.svg',
    'guardian_unyielding': 'unyielding.svg',
    'guardian_chains': 'chain_bind.svg',
    'guardian_fortify': 'fortress.svg',
    'guardian_grand_counter': 'counter_stance.svg',
    'guardian_oath_of_protection': 'shield_bash.svg',
    'guardian_steel_will': 'iron_guard.svg',
    'guardian_wall_charge': 'thorn_burst.svg',
    'guardian_iron_will': 'unyielding.svg',

    // ── Wanderer ──
    'wanderer_improvise_strike': 'improvise_strike.svg',
    'wanderer_adapt': 'adapt.svg',
    'wanderer_lucky_coin': 'lucky_coin.svg',
    'wanderer_wisdom': 'wisdom.svg',
    'wanderer_mimic': 'mimic.svg',
    'wanderer_conjure': 'conjure.svg',
    'wanderer_chain_adapt': 'chain_adapt.svg',
    'wanderer_chaos': 'chaos.svg',
    'wanderer_lucky_dice': 'lucky_coin.svg',
    'wanderer_rewind': 'time_distortion.svg',
    'wanderer_seize_moment': 'preemptive.svg',
    'wanderer_survival_instinct': 'last_stand.svg',
    'wanderer_veteran_strike': 'improvise_strike.svg',
    'wanderer_vision': 'observe.svg',
    'wanderer_instinct': 'last_stand.svg',

    // ── Reaper ──
    'reaper_scythe': 'scythe.svg',
    'reaper_soul_harvest': 'soul_harvest.svg',
    'reaper_death_sentence': 'death_sentence.svg',
    'reaper_death_touch': 'death_touch.svg',
    'reaper_immortal_will': 'immortal_will.svg',
    'reaper_nether_gate': 'nether_gate.svg',
    'reaper_grim': 'grim.svg',
    'reaper_soul_split': 'soul_split.svg',
    'reaper_blood_armor': 'thorn_armor.svg',
    'reaper_death_dance': 'death_touch.svg',
    'reaper_death_mark': 'death_sentence.svg',
    'reaper_life_drain': 'soul_harvest.svg',
    'reaper_nether_grace': 'nether_gate.svg',
    'reaper_soul_storm': 'soul_split.svg',

    // ── Illusionist ──
    'illusionist_phantom_strike': 'phantom_strike.svg',
    'illusionist_mirror_shield': 'mirror_shield.svg',
    'illusionist_clone': 'clone.svg',
    'illusionist_hallucination': 'hallucination.svg',
    'illusionist_magic_card': 'magic_card.svg',
    'illusionist_dimension_shift': 'dimension_shift.svg',
    'illusionist_perfect_copy': 'perfect_copy.svg',
    'illusionist_phantom_army': 'phantom_army.svg',
    'illusionist_hallucination_storm': 'hallucination.svg',
    'illusionist_infinite_mirror': 'mirror_shield.svg',
    'illusionist_mirror_maze': 'magic_card.svg',
    'illusionist_multi_clone': 'clone.svg',
    'illusionist_phantom_wall': 'phantom_strike.svg',
    'illusionist_reality_warp': 'dimension_shift.svg',
    'illusionist_phantom': 'phantom_strike.svg',

    // ── Harmonist ──
    'harmonist_balanced_strike': 'balanced_strike.svg',
    'harmonist_attune': 'attune.svg',
    'harmonist_resonance': 'resonance.svg',
    'harmonist_adaptive_strike': 'adaptive_strike.svg',
    'harmonist_absorb': 'absorb.svg',
    'harmonist_perfect_harmony': 'perfect_harmony.svg',
    'harmonist_equilibrium': 'equilibrium.svg',
    'harmonist_oneness': 'oneness.svg',
    'harmonist_all_as_one': 'oneness.svg',
    'harmonist_flow_shift': 'equilibrium.svg',
    'harmonist_inner_harmony': 'perfect_harmony.svg',
    'harmonist_perfect_defense': 'absorb.svg',
    'harmonist_resonance_wave': 'resonance.svg',
    'harmonist_tuning_wave': 'attune.svg',

    // ── Colorless ──
    'colorless_fresh_start': 'fresh_start.svg',
    'colorless_threaten': 'threaten.svg',
    'colorless_preemptive': 'preemptive.svg',
    'colorless_flee_prepare': 'flee_prepare.svg',
    'colorless_observe': 'observe.svg',
    'colorless_expose_weakness': 'expose_weakness.svg',
    'colorless_focused_strike': 'focused_strike.svg',
    'colorless_sprint': 'sprint.svg',
    'colorless_insight': 'insight.svg',
    'colorless_smoke_screen': 'smoke_screen.svg',
    'colorless_critical_strike': 'critical_strike.svg',
    'colorless_momentum_charge': 'momentum_charge.svg',
    'colorless_environment_explosion': 'environment_explosion.svg',
    'colorless_poison_jar': 'poison_jar.svg',
    'colorless_absorb': 'absorb_colorless.svg',
    'colorless_threatening_shot': 'threatening_shot.svg',
    'colorless_double_strike': 'double_strike.svg',
    'colorless_patience': 'patience.svg',
    'colorless_trickery': 'trickery.svg',
    'colorless_last_stand': 'last_stand.svg',
    'colorless_bold_gamble': 'lucky_coin.svg',
    'colorless_collector': 'insight.svg',
    'colorless_endurance': 'patience.svg',
    'colorless_final_battle': 'last_stand.svg',
    'colorless_improvise': 'adapt.svg',
    'colorless_thrift': 'momentum_charge.svg',
    'colorless_time_rewind': 'time_distortion.svg',
    'colorless_wrath_of_weak': 'threaten.svg',

    // ── Sword Saint (검성) ──
    'sword_saint_sword_aura': 'heavy_strike.svg',
    'sword_saint_fatal_slash': 'crush.svg',
    'sword_saint_sword_focus': 'focus.svg',
    'sword_saint_thousand_blades': 'spin_slash.svg',
    'sword_saint_way_of_sword': 'berserker.svg',

    // ── High Priest (대사제) ──
    'high_priest_grand_purify': 'purify.svg',
    'high_priest_celestial_light': 'light_of_regeneration.svg',
    'high_priest_sacred_protection': 'divine_shield.svg',
    'high_priest_divine_punishment': 'retribution.svg',
    'high_priest_blessing_aura': 'prayer.svg',

    // ── Archmage (대현자) ──
    'archmage_dimension_sever': 'dimension_shift.svg',
    'archmage_spacetime_warp': 'time_distortion.svg',
    'archmage_mana_amplify': 'mana_charge.svg',
    'archmage_absolute_zero': 'magic_explosion.svg',
    'archmage_grand_magic_circle': 'mana_crystal.svg',

    // ── Shadow Lord (그림자군주) ──
    'shadow_lord_shadow_storm': 'poison_cloud.svg',
    'shadow_lord_perfect_stealth': 'stealth.svg',
    'shadow_lord_poison_dominion': 'poison_blade.svg',
    'shadow_lord_assassination': 'assassination.svg',
    'shadow_lord_shadow_throne': 'shadow.svg',

    // ── Iron Fortress (철벽성주) ──
    'iron_fortress_absolute_barrier': 'fortress.svg',
    'iron_fortress_reflect_wall': 'counter_stance.svg',
    'iron_fortress_fortress_charge': 'shield_bash.svg',
    'iron_fortress_thorn_fortress': 'thorn_armor.svg',
    'iron_fortress_guardian_oath': 'unyielding.svg',

    // ── Fate Traveler (운명의 여행자) ──
    'fate_traveler_fate_strike': 'lucky_coin.svg',
    'fate_traveler_chaos_card': 'chaos.svg',
    'fate_traveler_time_reverse': 'time_distortion.svg',
    'fate_traveler_lucky_explosion': 'magic_explosion.svg',
    'fate_traveler_fate_tuning': 'adapt.svg',

    // ── Nether King (명계왕) ──
    'nether_king_death_scythe': 'scythe.svg',
    'nether_king_soul_exploit': 'soul_harvest.svg',
    'nether_king_nether_dominion': 'nether_gate.svg',
    'nether_king_nether_judgment': 'death_sentence.svg',
    'nether_king_immortal': 'immortal_will.svg',

    // ── Dimension Mage (차원술사) ──
    'dimension_mage_dimension_storm': 'dimension_shift.svg',
    'dimension_mage_perfect_clone': 'perfect_copy.svg',
    'dimension_mage_phantom_legion': 'phantom_army.svg',
    'dimension_mage_dimension_barrier': 'mirror_shield.svg',
    'dimension_mage_reality_collapse': 'hallucination.svg',

    // ── One With All (만물일체) ──
    'one_with_all_perfect_strike': 'balanced_strike.svg',
    'one_with_all_harmony_of_all': 'perfect_harmony.svg',
    'one_with_all_resonance_explosion': 'resonance.svg',
    'one_with_all_absolute_balance': 'equilibrium.svg',
    'one_with_all_transcendence': 'oneness.svg',

    // ── Spell Blade (마검사) ──
    'spell_blade_arcane_slash': 'heavy_strike.svg',
    'spell_blade_magic_enhance': 'mana_charge.svg',
    'spell_blade_chain_arcane': 'chain_lightning.svg',
    'spell_blade_mana_shield': 'mana_crystal.svg',
    'spell_blade_arcane_awakening': 'magic_explosion.svg',

    // ── Holy Knight (성기사) ──
    'holy_knight_holy_sword': 'divine_strike.svg',
    'holy_knight_guardian_prayer': 'prayer.svg',
    'holy_knight_judgment_strike': 'retribution.svg',
    'holy_knight_blessed_armor': 'divine_shield.svg',
    'holy_knight_crusader_oath': 'heal.svg',

    // ── Dark Mage (흑마법사) ──
    'dark_mage_curse_bolt': 'magic_bolt.svg',
    'dark_mage_dark_barrier': 'shadow.svg',
    'dark_mage_dark_amplify': 'mana_charge.svg',
    'dark_mage_mind_control': 'hallucination.svg',
    'dark_mage_dark_power': 'poison_blade.svg',

    // ── Dark Knight (암흑기사) ──
    'dark_knight_shadow_slash': 'ambush.svg',
    'dark_knight_dark_shield': 'iron_guard.svg',
    'dark_knight_counter_slash': 'counter_stance.svg',
    'dark_knight_dark_armor': 'stealth.svg',
    'dark_knight_dark_knight_oath': 'unyielding.svg',

    // ── Arbiter (심판자) ──
    'arbiter_justice_judgment': 'divine_strike.svg',
    'arbiter_purify_wave': 'purify.svg',
    'arbiter_poison_absorb_light': 'light_of_regeneration.svg',
    'arbiter_arbiter_eye': 'observe.svg',
    'arbiter_absolute_justice': 'retribution.svg',

    // ── Soul Unlock ──
    'whirlwind': 'spin_slash.svg',
    'meditation': 'focus.svg',

    // ── Curse ──
    'curse_weakness': 'weakness.svg',
    'curse_decay': 'decay.svg',

    // ── Environment ──
    'env_ceiling_collapse': 'ceiling_collapse.svg',
    'env_swamp_miasma': 'swamp_miasma.svg',
    'env_chain_bind': 'chain_bind.svg',
    'env_mana_crystal': 'mana_crystal.svg',
    'env_altar_flame': 'altar_flame.svg',
    'env_abyssal_rift': 'abyssal_rift.svg',
    'env_acid_pool': 'acid_pool.svg',
    'env_web_reversal': 'web_reversal.svg',
    'env_trap_trigger': 'trap_trigger.svg',
    'env_holy_water': 'holy_water.svg',
    'env_primordial_light': 'primordial_light.svg',
  };
}
