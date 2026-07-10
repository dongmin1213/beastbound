import 'package:soul_dungeon/core/models/card_blessing_data.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/card_relic_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/domain/combat/models/enemy_battle_state.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/core/models/enemy_modifier.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';

/// CardCombatActive ↔ `Map<String, dynamic>` 직렬화/역직렬화.
///
/// core/save는 domain 의존 불가이므로 domain 레이어에 배치.
/// RunSaveData.cardCombatStateRaw에 raw JSON 형태로 저장.
class CombatStateSerializer {
  CombatStateSerializer._();

  // ══════════════════════════════════════════════════════════
  // Serialize: CardCombatActive → Map<String, dynamic>
  // ══════════════════════════════════════════════════════════

  static Map<String, dynamic> toJson(CardCombatActive state) {
    return {
      // 적 상태
      'enemies': state.enemies.map(_enemyBattleStateToJson).toList(),
      'selectedTargetIndex': state.selectedTargetIndex,

      // 플레이어
      'playerHp': state.playerHp,
      'playerMaxHp': state.playerMaxHp,
      'playerBlock': state.playerBlock,
      'deckState': _deckStateToJson(state.deckState),
      'actionPoints': state.actionPoints,
      'maxActionPoints': state.maxActionPoints,
      'playerStatuses': state.playerStatuses.map(_statusEffectToJson).toList(),
      'currentTurn': state.currentTurn,
      'roomType': state.roomType.name,

      // 턴 플래그 + Power 효과
      'turnFlags': _turnFlagsToJson(state.turnFlags),
      'powerEffects': _powerEffectsToJson(state.powerEffects),
      'lastPlayedAttackId': state.lastPlayedAttack?.id,

      // 보스
      if (state.bossData != null)
        'bossData': _bossCombatDataToJson(state.bossData!),
      'currentBossPhase': state.currentBossPhase,

      // 환경 카드
      'environmentCardId': state.environmentCard?.id,
      'environmentCardObservedId': state.environmentCardObserved?.id,
      'environmentGranted': state.environmentGranted,

      // 의도 표시
      'intentRevealed': state.intentRevealed,
      'intentRevealTurns': state.intentRevealTurns,
      'regenBlockedThisTurn': state.regenBlockedThisTurn,

      // 도주
      'fleeGuaranteed': state.fleeGuaranteed,
      'fleeFailed': state.fleeFailed,

      // 축복/유물 (ID만 저장)
      'activeBlessingIds': state.activeBlessings.map((b) => b.id).toList(),
      'activeRelicIds': state.activeRelics.map((r) => r.id).toList(),
      'perfectFormDisabledTurns': state.perfectFormDisabledTurns,

      // 기세
      'lastMomentumTier': state.lastMomentumTier,
      'momentumHighBonusDamage': state.momentumHighBonusDamage,
      'initialMomentumBonus': state.initialMomentumBonus,

      // Phase 3-B
      'nextSkillApDiscount': state.nextSkillApDiscount,
      'immuneNextHitsRemaining': state.immuneNextHitsRemaining,
      'nextHitDamageReductionPercent': state.nextHitDamageReductionPercent,
      'cooldownCards': state.cooldownCards,

      // 보상
      'rewardJobOverride': state.rewardJobOverride,
    };
  }

  // ══════════════════════════════════════════════════════════
  // Deserialize: Map<String, dynamic> → CardCombatActive
  // ══════════════════════════════════════════════════════════

  /// [cardResolver] 카드 ID → CardData (null = 알 수 없는 카드).
  /// [blessingResolver] 축복 ID 리스트 → CardBlessingData 리스트.
  /// [relicResolver] 유물 ID 리스트 → CardRelicData 리스트.
  /// [playerRunState] 현재 런 상태 (별도 복원됨).
  static CardCombatActive? fromJson(
    Map<String, dynamic>? json, {
    required CardData? Function(String id) cardResolver,
    required List<CardBlessingData> Function(List<String> ids) blessingResolver,
    required List<CardRelicData> Function(List<String> ids) relicResolver,
    required PlayerRunState playerRunState,
  }) {
    if (json == null) return null;

    try {
      return CardCombatActive(
        // 적 상태
        enemies: _parseEnemyBattleStates(json['enemies']),
        selectedTargetIndex: (json['selectedTargetIndex'] as int?) ?? 0,

        // 플레이어
        playerHp: json['playerHp'] as int,
        playerMaxHp: json['playerMaxHp'] as int,
        playerBlock: (json['playerBlock'] as int?) ?? 0,
        deckState: _parseDeckState(json['deckState'], cardResolver),
        actionPoints: json['actionPoints'] as int,
        maxActionPoints: json['maxActionPoints'] as int,
        playerStatuses: _parseStatusEffects(json['playerStatuses']),
        currentTurn: (json['currentTurn'] as int?) ?? 0,
        playerRunState: playerRunState,
        roomType: _parseRoomType(json['roomType']),

        // 턴 플래그 + Power 효과
        turnFlags: _parseTurnFlags(json['turnFlags']),
        powerEffects: _parsePowerEffects(json['powerEffects']),
        lastPlayedAttack: _resolveCardNullable(
          json['lastPlayedAttackId'] as String?,
          cardResolver,
        ),

        // 보스
        bossData: _parseBossCombatData(json['bossData']),
        currentBossPhase: (json['currentBossPhase'] as int?) ?? 0,

        // 환경 카드
        environmentCard: _resolveCardNullable(
          json['environmentCardId'] as String?,
          cardResolver,
        ),
        environmentCardObserved: _resolveCardNullable(
          json['environmentCardObservedId'] as String?,
          cardResolver,
        ),
        environmentGranted: (json['environmentGranted'] as bool?) ?? false,

        // 의도 표시
        intentRevealed: (json['intentRevealed'] as bool?) ?? false,
        intentRevealTurns: (json['intentRevealTurns'] as int?) ?? 0,
        regenBlockedThisTurn:
            (json['regenBlockedThisTurn'] as bool?) ?? false,

        // 도주
        fleeGuaranteed: (json['fleeGuaranteed'] as bool?) ?? false,
        fleeFailed: (json['fleeFailed'] as bool?) ?? false,

        // 축복/유물
        activeBlessings: blessingResolver(_parseStringList(json['activeBlessingIds'])),
        activeRelics: relicResolver(_parseStringList(json['activeRelicIds'])),
        perfectFormDisabledTurns:
            (json['perfectFormDisabledTurns'] as int?) ?? 0,

        // 기세
        lastMomentumTier: (json['lastMomentumTier'] as int?) ?? 1,
        momentumHighBonusDamage:
            (json['momentumHighBonusDamage'] as int?) ?? 0,
        initialMomentumBonus: (json['initialMomentumBonus'] as int?) ?? 0,

        // Phase 3-B
        nextSkillApDiscount: (json['nextSkillApDiscount'] as int?) ?? 0,
        immuneNextHitsRemaining:
            (json['immuneNextHitsRemaining'] as int?) ?? 0,
        nextHitDamageReductionPercent:
            (json['nextHitDamageReductionPercent'] as int?) ?? 0,
        cooldownCards: _parseIntMap(json['cooldownCards']),

        // 보상
        rewardJobOverride: json['rewardJobOverride'] as String?,
      );
    } catch (_) {
      // 파싱 실패 → null (전투 직전 안전 지점으로 폴백).
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // EnemyBattleState 직렬화
  // ══════════════════════════════════════════════════════════

  static Map<String, dynamic> _enemyBattleStateToJson(EnemyBattleState e) {
    return {
      'data': _enemyCombatDataToJson(e.data),
      'currentHp': e.currentHp,
      'maxHp': e.maxHp,
      'block': e.block,
      'strength': e.strength,
      'statuses': e.statuses.map(_statusEffectToJson).toList(),
      'healBlockedTurns': e.healBlockedTurns,
      'stunnedTurns': e.stunnedTurns,
      'drainBlockedTurns': e.drainBlockedTurns,
      'patternOffset': e.patternOffset,
      'phaseShifted': e.phaseShifted,
      'patternSwitched': e.patternSwitched,
      'lastOverrideAction': e.lastOverrideAction?.name,
      'enragedTurns': e.enragedTurns,
      'consecutiveHitTurns': e.consecutiveHitTurns,
    };
  }

  static EnemyBattleState _enemyBattleStateFromJson(Map<String, dynamic> json) {
    return EnemyBattleState(
      data: _enemyCombatDataFromJson(json['data'] as Map<String, dynamic>),
      currentHp: json['currentHp'] as int,
      maxHp: json['maxHp'] as int,
      block: (json['block'] as int?) ?? 0,
      strength: (json['strength'] as int?) ?? 0,
      statuses: _parseStatusEffects(json['statuses']),
      healBlockedTurns: (json['healBlockedTurns'] as int?) ?? 0,
      stunnedTurns: (json['stunnedTurns'] as int?) ?? 0,
      drainBlockedTurns: (json['drainBlockedTurns'] as int?) ?? 0,
      patternOffset: (json['patternOffset'] as int?) ?? 0,
      phaseShifted: (json['phaseShifted'] as bool?) ?? false,
      patternSwitched: (json['patternSwitched'] as bool?) ?? false,
      lastOverrideAction: _parseEnemyActionType(json['lastOverrideAction']),
      enragedTurns: (json['enragedTurns'] as int?) ?? 0,
      consecutiveHitTurns: (json['consecutiveHitTurns'] as int?) ?? 0,
    );
  }

  // ══════════════════════════════════════════════════════════
  // EnemyCombatData 직렬화 (변형 적용 후 상태 저장)
  // ══════════════════════════════════════════════════════════

  static Map<String, dynamic> _enemyCombatDataToJson(EnemyCombatData e) {
    return {
      'id': e.id,
      'name': e.name,
      'hp': e.hp,
      'atk': e.atk,
      'def': e.def,
      'floor': e.floor,
      'isElite': e.isElite,
      'pattern': e.pattern.map((a) => a.name).toList(),
      'alternatePatterns': e.alternatePatterns
          .map((p) => p.map((a) => a.name).toList())
          .toList(),
      'modifier': e.modifier?.name,
    };
  }

  static EnemyCombatData _enemyCombatDataFromJson(Map<String, dynamic> json) {
    return EnemyCombatData(
      id: json['id'] as String,
      name: json['name'] as String,
      hp: json['hp'] as int,
      atk: json['atk'] as int,
      def: json['def'] as int,
      floor: json['floor'] as int,
      isElite: (json['isElite'] as bool?) ?? false,
      pattern: _parseEnemyActionTypes(json['pattern']),
      alternatePatterns: (json['alternatePatterns'] as List<dynamic>?)
              ?.map((p) => _parseEnemyActionTypes(p))
              .toList() ??
          const [],
      modifier: _parseEnemyModifier(json['modifier']),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BossCombatData 직렬화
  // ══════════════════════════════════════════════════════════

  static Map<String, dynamic> _bossCombatDataToJson(BossCombatData b) {
    return {
      'id': b.id,
      'name': b.name,
      'floor': b.floor,
      'phases': b.phases.map((p) => {
        'hp': p.hp,
        'atk': p.atk,
        'def': p.def,
        'pattern': p.pattern.map((a) => a.name).toList(),
        'gimmick': p.gimmick.name,
      }).toList(),
    };
  }

  static BossCombatData? _parseBossCombatData(dynamic raw) {
    if (raw == null || raw is! Map<String, dynamic>) return null;
    return BossCombatData(
      id: raw['id'] as String,
      name: raw['name'] as String,
      floor: raw['floor'] as int,
      phases: (raw['phases'] as List<dynamic>).map((p) {
        final m = p as Map<String, dynamic>;
        return BossPhaseConfig(
          hp: m['hp'] as int,
          atk: m['atk'] as int,
          def: m['def'] as int,
          pattern: _parseEnemyActionTypes(m['pattern']),
          gimmick: BossGimmick.values.firstWhere(
            (g) => g.name == m['gimmick'],
            orElse: () => BossGimmick.none,
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DeckState 직렬화 (카드 ID 리스트)
  // ══════════════════════════════════════════════════════════

  static Map<String, dynamic> _deckStateToJson(DeckState ds) {
    return {
      'drawPileIds': ds.drawPile.map((c) => c.id).toList(),
      'handIds': ds.hand.map((c) => c.id).toList(),
      'discardPileIds': ds.discardPile.map((c) => c.id).toList(),
      'exhaustPileIds': ds.exhaustPile.map((c) => c.id).toList(),
    };
  }

  static DeckState _parseDeckState(
    dynamic raw,
    CardData? Function(String id) cardResolver,
  ) {
    if (raw == null || raw is! Map<String, dynamic>) return const DeckState();
    return DeckState(
      drawPile: _resolveCardIds(raw['drawPileIds'], cardResolver),
      hand: _resolveCardIds(raw['handIds'], cardResolver),
      discardPile: _resolveCardIds(raw['discardPileIds'], cardResolver),
      exhaustPile: _resolveCardIds(raw['exhaustPileIds'], cardResolver),
    );
  }

  // ══════════════════════════════════════════════════════════
  // StatusEffect 직렬화
  // ══════════════════════════════════════════════════════════

  static Map<String, dynamic> _statusEffectToJson(StatusEffect s) {
    return {
      'type': s.type.name,
      'stacks': s.stacks,
      'turnsRemaining': s.turnsRemaining,
    };
  }

  static List<StatusEffect> _parseStatusEffects(dynamic raw) {
    if (raw == null || raw is! List) return const [];
    return raw.where((e) {
      final m = e as Map<String, dynamic>;
      return StatusEffectType.values.any((t) => t.name == m['type']);
    }).map((e) {
      final m = e as Map<String, dynamic>;
      return StatusEffect(
        type: StatusEffectType.values.firstWhere(
          (t) => t.name == m['type'],
        ),
        stacks: (m['stacks'] as num?)?.toInt() ?? 1,
        turnsRemaining: (m['turnsRemaining'] as num?)?.toInt(),
      );
    }).toList();
  }

  // ══════════════════════════════════════════════════════════
  // TurnFlags 직렬화
  // ══════════════════════════════════════════════════════════

  static Map<String, dynamic> _turnFlagsToJson(TurnFlags tf) {
    return {
      'immuneThisTurn': tf.immuneThisTurn,
      'doubleNextAttack': tf.doubleNextAttack,
      'exhaustHandAtTurnEnd': tf.exhaustHandAtTurnEnd,
      'attacksPlayedThisTurn': tf.attacksPlayedThisTurn,
      'cardsPlayedThisTurn': tf.cardsPlayedThisTurn,
      'apModifierNextTurn': tf.apModifierNextTurn,
      'blockRetainPercent': tf.blockRetainPercent,
      'typesPlayedThisTurn':
          tf.typesPlayedThisTurn.map((t) => t.name).toList(),
      'remainingApBlockValue': tf.remainingApBlockValue,
      'skillsPlayedThisTurn': tf.skillsPlayedThisTurn,
      'lastPlayedCardType': tf.lastPlayedCardType?.name,
      'chainCount': tf.chainCount,
    };
  }

  static TurnFlags _parseTurnFlags(dynamic raw) {
    if (raw == null || raw is! Map<String, dynamic>) return const TurnFlags();
    return TurnFlags(
      immuneThisTurn: (raw['immuneThisTurn'] as bool?) ?? false,
      doubleNextAttack: (raw['doubleNextAttack'] as bool?) ?? false,
      exhaustHandAtTurnEnd: (raw['exhaustHandAtTurnEnd'] as bool?) ?? false,
      attacksPlayedThisTurn: (raw['attacksPlayedThisTurn'] as int?) ?? 0,
      cardsPlayedThisTurn: (raw['cardsPlayedThisTurn'] as int?) ?? 0,
      apModifierNextTurn: (raw['apModifierNextTurn'] as int?) ?? 0,
      blockRetainPercent: (raw['blockRetainPercent'] as int?) ?? 0,
      typesPlayedThisTurn: _parseCardTypeSet(raw['typesPlayedThisTurn']),
      remainingApBlockValue: (raw['remainingApBlockValue'] as int?) ?? 0,
      skillsPlayedThisTurn: (raw['skillsPlayedThisTurn'] as int?) ?? 0,
      lastPlayedCardType: _parseCardType(raw['lastPlayedCardType']),
      chainCount: (raw['chainCount'] as int?) ?? 0,
    );
  }

  // ══════════════════════════════════════════════════════════
  // PowerEffects 직렬화
  // ══════════════════════════════════════════════════════════

  static Map<String, dynamic> _powerEffectsToJson(PowerEffects pe) {
    return {
      'poisonPerTurnStart': pe.poisonPerTurnStart,
      'blockPerTurnStart': pe.blockPerTurnStart,
      'conditionalBlockPerTurnStart': pe.conditionalBlockPerTurnStart,
      'retrievePerTurn': pe.retrievePerTurn,
      'selfDamagePerTurn': pe.selfDamagePerTurn,
      'strengthPerTurn': pe.strengthPerTurn,
      'generateAttackPerTurn': pe.generateAttackPerTurn,
      'transformHand': pe.transformHand,
      'allTypesApBonus': pe.allTypesApBonus,
      'boostLowestStatPerTurn': pe.boostLowestStatPerTurn,
      'dodgeChancePercent': pe.dodgeChancePercent,
      'lostHpToBlockPerTurnPercent': pe.lostHpToBlockPerTurnPercent,
      'healPerTurn': pe.healPerTurn,
      'drawPerTurn': pe.drawPerTurn,
      'reflectDamageChancePercent': pe.reflectDamageChancePercent,
      'lifestealOnAllAttacksPercent': pe.lifestealOnAllAttacksPercent,
      'healPerTurnConditional': pe.healPerTurnConditional,
      'healPerTurnCondition': pe.healPerTurnCondition,
      'overflowToBlockPercent': pe.overflowToBlockPercent,
      'momentumGainOnDodge': pe.momentumGainOnDodge,
      'poisonDamageReduction': pe.poisonDamageReduction,
      'poisonDamageReductionCap': pe.poisonDamageReductionCap,
      'damageReductionWhenBlock': pe.damageReductionWhenBlock,
      'damageReductionWhenBlockThreshold':
          pe.damageReductionWhenBlockThreshold,
      'healOnDamageTaken': pe.healOnDamageTaken,
      'healOnReflect': pe.healOnReflect,
      'allAttackPiercing': pe.allAttackPiercing,
      'allSkillApDiscount': pe.allSkillApDiscount,
    };
  }

  static PowerEffects _parsePowerEffects(dynamic raw) {
    if (raw == null || raw is! Map<String, dynamic>) {
      return const PowerEffects();
    }
    return PowerEffects(
      poisonPerTurnStart: (raw['poisonPerTurnStart'] as int?) ?? 0,
      blockPerTurnStart: (raw['blockPerTurnStart'] as int?) ?? 0,
      conditionalBlockPerTurnStart:
          (raw['conditionalBlockPerTurnStart'] as int?) ?? 0,
      retrievePerTurn: (raw['retrievePerTurn'] as int?) ?? 0,
      selfDamagePerTurn: (raw['selfDamagePerTurn'] as int?) ?? 0,
      strengthPerTurn: (raw['strengthPerTurn'] as int?) ?? 0,
      generateAttackPerTurn: (raw['generateAttackPerTurn'] as int?) ?? 0,
      transformHand: (raw['transformHand'] as bool?) ?? false,
      allTypesApBonus: (raw['allTypesApBonus'] as bool?) ?? false,
      boostLowestStatPerTurn: (raw['boostLowestStatPerTurn'] as int?) ?? 0,
      dodgeChancePercent: (raw['dodgeChancePercent'] as int?) ?? 0,
      lostHpToBlockPerTurnPercent:
          (raw['lostHpToBlockPerTurnPercent'] as int?) ?? 0,
      healPerTurn: (raw['healPerTurn'] as int?) ?? 0,
      drawPerTurn: (raw['drawPerTurn'] as int?) ?? 0,
      reflectDamageChancePercent:
          (raw['reflectDamageChancePercent'] as int?) ?? 0,
      lifestealOnAllAttacksPercent:
          (raw['lifestealOnAllAttacksPercent'] as int?) ?? 0,
      healPerTurnConditional: (raw['healPerTurnConditional'] as int?) ?? 0,
      healPerTurnCondition: raw['healPerTurnCondition'] as String?,
      overflowToBlockPercent: (raw['overflowToBlockPercent'] as int?) ?? 0,
      momentumGainOnDodge: (raw['momentumGainOnDodge'] as int?) ?? 0,
      poisonDamageReduction: (raw['poisonDamageReduction'] as int?) ?? 0,
      poisonDamageReductionCap:
          (raw['poisonDamageReductionCap'] as int?) ?? 0,
      damageReductionWhenBlock:
          (raw['damageReductionWhenBlock'] as int?) ?? 0,
      damageReductionWhenBlockThreshold:
          (raw['damageReductionWhenBlockThreshold'] as int?) ?? 0,
      healOnDamageTaken: (raw['healOnDamageTaken'] as int?) ?? 0,
      healOnReflect: (raw['healOnReflect'] as int?) ?? 0,
      allAttackPiercing: (raw['allAttackPiercing'] as bool?) ?? false,
      allSkillApDiscount: (raw['allSkillApDiscount'] as int?) ?? 0,
    );
  }

  // ══════════════════════════════════════════════════════════
  // Private helpers
  // ══════════════════════════════════════════════════════════

  static List<EnemyBattleState> _parseEnemyBattleStates(dynamic raw) {
    if (raw == null || raw is! List) return const [];
    return raw
        .map((e) =>
            _enemyBattleStateFromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<EnemyActionType> _parseEnemyActionTypes(dynamic raw) {
    if (raw == null || raw is! List) return const [];
    return raw.map((e) {
      return EnemyActionType.values.firstWhere(
        (t) => t.name == (e as String),
        orElse: () => EnemyActionType.attack,
      );
    }).toList();
  }

  static EnemyActionType? _parseEnemyActionType(dynamic raw) {
    if (raw == null || raw is! String) return null;
    return EnemyActionType.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => EnemyActionType.attack,
    );
  }

  static EnemyModifierType? _parseEnemyModifier(dynamic raw) {
    if (raw == null || raw is! String) return null;
    try {
      return EnemyModifierType.values.firstWhere((t) => t.name == raw);
    } catch (_) {
      return null;
    }
  }

  static RoomType _parseRoomType(dynamic raw) {
    if (raw == null || raw is! String) return RoomType.combat;
    return RoomType.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => RoomType.combat,
    );
  }

  static CardType? _parseCardType(dynamic raw) {
    if (raw == null || raw is! String) return null;
    return CardType.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => CardType.attack,
    );
  }

  static Set<CardType> _parseCardTypeSet(dynamic raw) {
    if (raw == null || raw is! List) return const {};
    return raw
        .map((e) => CardType.values.firstWhere(
              (t) => t.name == (e as String),
              orElse: () => CardType.attack,
            ))
        .toSet();
  }

  static List<CardData> _resolveCardIds(
    dynamic raw,
    CardData? Function(String id) cardResolver,
  ) {
    if (raw == null || raw is! List) return const [];
    return raw
        .map((e) => cardResolver(e as String))
        .whereType<CardData>()
        .toList();
  }

  static CardData? _resolveCardNullable(
    String? id,
    CardData? Function(String id) cardResolver,
  ) {
    if (id == null) return null;
    return cardResolver(id);
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null || raw is! List) return const [];
    return raw.map((e) => e as String).toList();
  }

  static Map<String, int> _parseIntMap(dynamic raw) {
    if (raw == null || raw is! Map) return const {};
    return Map<String, dynamic>.from(raw)
        .map((k, v) => MapEntry(k, (v as num).toInt()));
  }
}
