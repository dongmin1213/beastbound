import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

/// 일반 전투 데모 조우 팩토리.
/// JSON 에셋(assets/content/demo_encounters.json)에서 로드. 실패 시 기본값 폴백.
class CombatDemoEncounter {
  CombatDemoEncounter._();

  static CombatEncounter _encounter = _default;

  /// JSON 에셋에서 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/demo_encounters.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final combat = json['combat'] as Map<String, dynamic>;
      _encounter = _parseEncounter(combat);
      GameLogger.info(LogSystem.core, 'CombatDemoEncounter loaded');
    } catch (e) {
      GameLogger.error(
          LogSystem.core, 'Failed to load demo_encounters.json (combat), using defaults', e);
      _encounter = _default;
    }
  }

  static CombatEncounter _parseEncounter(Map<String, dynamic> json) {
    final clues = (json['environment_clues'] as List?)
            ?.map((e) => EnvironmentClue(
                  id: (e as Map<String, dynamic>)['id'] as String,
                  description: e['description'] as String,
                  actionHint: e['action_hint'] as String,
                ))
            .toList() ??
        const [];

    final turns = (json['turns'] as List).map((t) {
      final map = t as Map<String, dynamic>;
      final turn = map['turn'] as int;
      return CombatTurnData(
        turnNumber: turn,
        enemyAction: EnemyAction(
          type: EnemyActionType.values.byName(map['action_type'] as String),
          previewText: map['preview_text'] as String,
          threatLevel: map['threat_level'] as int? ?? 1,
        ),
        playerChoices: [
          ChoiceData(id: 't${turn}a', text: '공격', resultTextBlocks: const []),
        ],
      );
    }).toList();

    return CombatEncounter(
      roomType: RoomType.combat,
      enemyName: json['enemy_name'] as String,
      environmentText: json['environment_text'] as String?,
      environmentClues: clues,
      introText: json['intro_text'] as String,
      turns: turns,
      victoryText: json['victory_text'] as String,
      defeatText: json['defeat_text'] as String,
    );
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _default = CombatEncounter(
    roomType: RoomType.combat,
    enemyName: '떠도는 망령',
    environmentText: '좁은 통로에 금이 간 돌벽이 이어진다. '
        '벽 틈 사이로 차가운 바람이 새어 나온다.',
    environmentClues: [
      EnvironmentClue(
        id: 'cracked_wall',
        description: '금이 간 돌벽이 위태롭게 서 있다',
        actionHint: '벽을 무너뜨려 적의 움직임을 방해할 수 있다',
      ),
    ],
    introText: '어둠 속에서 희미한 형체가 다가온다. 떠도는 망령이다.',
    turns: [
      CombatTurnData(
        turnNumber: 1,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '망령이 차가운 손을 뻗어 덮친다',
          threatLevel: 2,
        ),
        playerChoices: [
          ChoiceData(id: 't1a', text: '공격', resultTextBlocks: []),
        ],
      ),
      CombatTurnData(
        turnNumber: 2,
        enemyAction: EnemyAction(
          type: EnemyActionType.defend,
          previewText: '망령이 형체를 흐트러뜨리며 몸을 사린다',
          threatLevel: 1,
        ),
        playerChoices: [
          ChoiceData(id: 't2a', text: '공격', resultTextBlocks: []),
        ],
      ),
      CombatTurnData(
        turnNumber: 3,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '망령이 차가운 기운을 모아 돌진한다',
          threatLevel: 2,
        ),
        playerChoices: [
          ChoiceData(id: 't3a', text: '공격', resultTextBlocks: []),
        ],
      ),
    ],
    victoryText: '망령이 흩어진다. 남겨진 잔재 속에서 무언가가 빛난다.',
    defeatText: '차가운 기운에 휩싸여 쓰러진다. '
        '하지만 아직 숨이 붙어 있다...',
  );

  /// 일반 전투 데모 생성.
  /// [combatConfig]의 normalTurnCount와 턴 수 일치를 debug assert로 검증.
  static CombatEncounter create({
    CombatBalanceConfig combatConfig = const CombatBalanceConfig(),
  }) {
    assert(
      _encounter.turns.length == combatConfig.normalTurnCount,
      'CombatDemoEncounter turns (${_encounter.turns.length}) must match '
      'combatConfig.normalTurnCount (${combatConfig.normalTurnCount})',
    );
    return _encounter;
  }
}
