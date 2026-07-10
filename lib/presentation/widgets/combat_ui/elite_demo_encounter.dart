import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

/// 엘리트 데모 전투 조우 팩토리.
/// JSON 에셋(assets/content/demo_encounters.json)에서 로드. 실패 시 기본값 폴백.
class EliteDemoEncounter {
  EliteDemoEncounter._();

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
      final elite = json['elite'] as Map<String, dynamic>;
      _encounter = _parseEncounter(elite);
      GameLogger.info(LogSystem.core, 'EliteDemoEncounter loaded');
    } catch (e) {
      GameLogger.error(
          LogSystem.core, 'Failed to load demo_encounters.json (elite), using defaults', e);
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
      roomType: RoomType.elite,
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
    roomType: RoomType.elite,
    enemyName: '심연의 파수꾼',
    environmentText: '무너진 제단 위에 금이 간 석상이 서 있다. '
        '바닥에는 오래된 마법진의 흔적이 희미하게 빛난다.',
    environmentClues: [
      EnvironmentClue(
        id: 'cracked_statue',
        description: '금이 간 석상이 불안정하게 서 있다',
        actionHint: '석상을 무너뜨려 적을 방해할 수 있다',
      ),
      EnvironmentClue(
        id: 'magic_circle',
        description: '바닥의 마법진이 희미하게 빛나고 있다',
        actionHint: '마법진의 힘을 빌려 공격할 수 있다',
      ),
    ],
    introText: '심연의 파수꾼이 어둠 속에서 모습을 드러낸다. '
        '평범한 적이 아니다.',
    turns: [
      CombatTurnData(
        turnNumber: 1,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '파수꾼이 거대한 창을 휘두르려 한다',
          threatLevel: 3,
        ),
        playerChoices: [
          ChoiceData(id: 't1a', text: '공격', resultTextBlocks: []),
        ],
      ),
      CombatTurnData(
        turnNumber: 2,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '파수꾼이 돌진하며 내려찍으려 한다',
          threatLevel: 3,
        ),
        playerChoices: [
          ChoiceData(id: 't2a', text: '공격', resultTextBlocks: []),
        ],
      ),
      CombatTurnData(
        turnNumber: 3,
        enemyAction: EnemyAction(
          type: EnemyActionType.defend,
          previewText: '파수꾼이 창을 세워 방어 태세를 취한다',
          threatLevel: 2,
        ),
        playerChoices: [
          ChoiceData(id: 't3a', text: '공격', resultTextBlocks: []),
        ],
      ),
      CombatTurnData(
        turnNumber: 4,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '파수꾼이 어둠의 기운을 모아 강타한다',
          threatLevel: 4,
        ),
        playerChoices: [
          ChoiceData(id: 't4a', text: '공격', resultTextBlocks: []),
        ],
      ),
      CombatTurnData(
        turnNumber: 5,
        enemyAction: EnemyAction(
          type: EnemyActionType.observe,
          previewText: '파수꾼이 잠시 물러서며 빈틈을 노린다',
          threatLevel: 1,
        ),
        playerChoices: [
          ChoiceData(id: 't5a', text: '공격', resultTextBlocks: []),
        ],
      ),
    ],
    victoryText: '강적이 무릎을 꿇는다. '
        '그 잔해 속에서 빛나는 무언가가 눈에 들어온다...',
    defeatText: '압도적인 힘 앞에 쓰러진다. '
        '하지만 이 경험이 무의미하지는 않을 것이다...',
  );

  /// 엘리트 데모 전투 생성.
  /// [combatConfig]의 eliteTurnCount와 턴 수 일치를 debug assert로 검증.
  static CombatEncounter create({
    CombatBalanceConfig combatConfig = const CombatBalanceConfig(),
  }) {
    assert(
      _encounter.turns.length == combatConfig.eliteTurnCount,
      'EliteDemoEncounter turns (${_encounter.turns.length}) must match '
      'combatConfig.eliteTurnCount (${combatConfig.eliteTurnCount})',
    );
    return _encounter;
  }
}
