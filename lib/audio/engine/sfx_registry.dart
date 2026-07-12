/// SFX ID -> asset path mapping.
/// 33종 SFX: 카드 3 + 전투 6 + 덱 3 + 상태 4 + 게임 플로우 10 + 기세 2 + UI 2 + 서술자 3.
class SfxRegistry {
  SfxRegistry._();

  static const Map<String, String> _registry = {
    // Card type sounds
    'card_attack': 'assets/audio/sfx/card_attack.ogg',
    'card_skill': 'assets/audio/sfx/card_skill.ogg',
    'card_power': 'assets/audio/sfx/card_power.ogg',
    // Deck manipulation sounds
    'deck_shuffle': 'assets/audio/sfx/deck_shuffle.ogg',
    'card_draw': 'assets/audio/sfx/card_draw.ogg',
    'card_exhaust': 'assets/audio/sfx/card_exhaust.ogg',
    // Status effect sounds
    'status_poison': 'assets/audio/sfx/status_poison.ogg',
    'status_burn': 'assets/audio/sfx/status_burn.ogg',
    'status_buff': 'assets/audio/sfx/status_buff.ogg',
    'status_debuff': 'assets/audio/sfx/status_debuff.ogg',
    // Combat event sounds
    'combat_hit': 'assets/audio/sfx/combat_hit.ogg',
    'combat_block': 'assets/audio/sfx/combat_block.ogg',
    'combat_victory': 'assets/audio/sfx/combat_victory.ogg',
    'combat_defeat': 'assets/audio/sfx/combat_defeat.ogg',
    'player_hurt': 'assets/audio/sfx/player_hurt.ogg',
    'chain_combo': 'assets/audio/sfx/chain_combo.ogg',
    // Game flow sounds
    'heal': 'assets/audio/sfx/heal.ogg',
    'rest_heal': 'assets/audio/sfx/rest_heal.ogg',
    'gold_gain': 'assets/audio/sfx/gold_gain.ogg',
    'shop_purchase': 'assets/audio/sfx/shop_purchase.ogg',
    'event_choice': 'assets/audio/sfx/event_choice.ogg',
    'room_enter': 'assets/audio/sfx/room_enter.ogg',
    'boss_appear': 'assets/audio/sfx/boss_appear.ogg',
    'turn_start': 'assets/audio/sfx/turn_start.ogg',
    // Momentum tier change sounds
    'momentum_up': 'assets/audio/sfx/momentum_up.ogg',
    'momentum_down': 'assets/audio/sfx/momentum_down.ogg',
    // UI sounds
    'ui_select': 'assets/audio/sfx/ui_select.ogg',
    'ui_confirm': 'assets/audio/sfx/ui_confirm.ogg',
    // Narrator sounds
    'narrator_distortion': 'assets/audio/sfx/narrator_distortion.ogg',
    'narrator_truth_reveal': 'assets/audio/sfx/narrator_truth_reveal.ogg',
    'narrator_silence': 'assets/audio/sfx/narrator_silence.ogg',
  };

  /// SFX ID -> asset path. Returns null if not registered.
  static String? pathFor(String sfxId) => _registry[sfxId];

  /// All registered SFX IDs.
  static List<String> get allIds => _registry.keys.toList();

  /// Total registered count.
  static int get count => _registry.length;

  /// CardType name -> SFX ID.
  static String sfxForCardType(String cardType) => switch (cardType) {
        'attack' => 'card_attack',
        'skill' => 'card_skill',
        'power' => 'card_power',
        _ => 'card_skill',
      };

  /// CombatMilestoneType name -> SFX ID.
  static String sfxForCombatMilestone(String type) => switch (type) {
        'hit' => 'combat_hit',
        'block' => 'combat_block',
        'victory' => 'combat_victory',
        'defeat' => 'combat_defeat',
        _ => 'combat_hit',
      };

  /// Narrator event type -> SFX ID.
  static String sfxForNarratorEvent(String eventType) => switch (eventType) {
        'distortion' => 'narrator_distortion',
        'truth_reveal' => 'narrator_truth_reveal',
        'silence' => 'narrator_silence',
        _ => 'narrator_distortion',
      };

  /// StatusEffectType name -> SFX ID.
  static String sfxForStatusEffect(String effectType) {
    switch (effectType) {
      case 'poison':
      case 'burn':
        return 'status_$effectType';
      case 'weak':
      case 'vulnerable':
        return 'status_debuff';
      case 'strength':
      case 'dexterity':
      case 'thorn':
      case 'regenerate':
        return 'status_buff';
      default:
        return 'status_debuff';
    }
  }
}
