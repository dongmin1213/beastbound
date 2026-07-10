import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

/// 보스 데모 전투 조우 팩토리.
/// JSON 에셋(assets/content/demo_encounters.json)에서 로드. 실패 시 기본값 폴백.
class BossDemoEncounter {
  BossDemoEncounter._();

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
      final boss = json['boss'] as Map<String, dynamic>;
      _encounter = _parseEncounter(boss);
      GameLogger.info(LogSystem.core, 'BossDemoEncounter loaded');
    } catch (e) {
      GameLogger.error(
          LogSystem.core, 'Failed to load demo_encounters.json (boss), using defaults', e);
      _encounter = _default;
    }
  }

  static List<CombatTurnData> _parseTurns(List jsonTurns, String prefix) {
    return jsonTurns.map((t) {
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
          ChoiceData(id: '${prefix}t${turn}a', text: '공격', resultTextBlocks: const []),
        ],
      );
    }).toList();
  }

  static CombatEncounter _parseEncounter(Map<String, dynamic> json) {
    final phase1Turns = _parseTurns(json['phase1_turns'] as List, 'b1');
    final phase2Turns = _parseTurns(json['phase2_turns'] as List, 'b2');

    return CombatEncounter(
      roomType: RoomType.boss,
      enemyName: json['enemy_name'] as String,
      introText: json['intro_text'] as String,
      turns: phase1Turns,
      victoryText: json['victory_text'] as String,
      defeatText: json['defeat_text'] as String,
      bossPhases: [
        BossPhasePresentation(
          introText: '',
          turns: phase1Turns,
          transitionText: json['transition_text'] as String?,
        ),
        BossPhasePresentation(
          introText: json['phase2_intro_text'] as String? ?? '',
          turns: phase2Turns,
        ),
      ],
    );
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _phase1Turns = [
    CombatTurnData(
      turnNumber: 1,
      enemyAction: EnemyAction(
        type: EnemyActionType.attack,
        previewText: '수호자가 거대한 팔을 휘두르려 한다',
        threatLevel: 3,
      ),
      playerChoices: [
        ChoiceData(id: 'b1t1a', text: '공격', resultTextBlocks: []),
      ],
    ),
    CombatTurnData(
      turnNumber: 2,
      enemyAction: EnemyAction(
        type: EnemyActionType.defend,
        previewText: '수호자가 어둠의 장벽을 펼친다',
        threatLevel: 2,
      ),
      playerChoices: [
        ChoiceData(id: 'b1t2a', text: '공격', resultTextBlocks: []),
      ],
    ),
    CombatTurnData(
      turnNumber: 3,
      enemyAction: EnemyAction(
        type: EnemyActionType.attack,
        previewText: '수호자가 어둠을 응축하여 내려친다',
        threatLevel: 3,
      ),
      playerChoices: [
        ChoiceData(id: 'b1t3a', text: '공격', resultTextBlocks: []),
      ],
    ),
  ];

  static const _phase2Turns = [
    CombatTurnData(
      turnNumber: 1,
      enemyAction: EnemyAction(
        type: EnemyActionType.attack,
        previewText: '수호자가 붉은 빛과 함께 돌진한다',
        threatLevel: 4,
      ),
      playerChoices: [
        ChoiceData(id: 'b2t1a', text: '공격', resultTextBlocks: []),
      ],
    ),
    CombatTurnData(
      turnNumber: 2,
      enemyAction: EnemyAction(
        type: EnemyActionType.attack,
        previewText: '수호자가 연속으로 강타한다',
        threatLevel: 3,
      ),
      playerChoices: [
        ChoiceData(id: 'b2t2a', text: '공격', resultTextBlocks: []),
      ],
    ),
    CombatTurnData(
      turnNumber: 3,
      enemyAction: EnemyAction(
        type: EnemyActionType.observe,
        previewText: '수호자가 잠시 숨을 고르며 빈틈을 노린다',
        threatLevel: 1,
      ),
      playerChoices: [
        ChoiceData(id: 'b2t3a', text: '공격', resultTextBlocks: []),
      ],
    ),
    CombatTurnData(
      turnNumber: 4,
      enemyAction: EnemyAction(
        type: EnemyActionType.attack,
        previewText: '수호자가 최후의 일격을 준비한다',
        threatLevel: 4,
      ),
      playerChoices: [
        ChoiceData(id: 'b2t4a', text: '공격', resultTextBlocks: []),
      ],
    ),
  ];

  static const _default = CombatEncounter(
    roomType: RoomType.boss,
    enemyName: '심연의 수호자',
    introText: '어둠 속에서 거대한 그림자가 일어선다. 이 층의 지배자다.\n\n'
        '여기서 쓰러지면... 돌아올 수 없다.',
    turns: _phase1Turns,
    victoryText: '심연의 수호자가 쓰러진다. '
        '어둠이 걷히며 저 너머로 길이 열린다.',
    defeatText: '심연의 수호자의 압도적인 힘에 쓰러진다. '
        '의식이 어두워진다...',
    bossPhases: [
      BossPhasePresentation(
        introText: '',
        turns: _phase1Turns,
        transitionText: '심연의 수호자가 포효한다! '
            '어둠이 짙어지며 새로운 형태가 드러난다...',
      ),
      BossPhasePresentation(
        introText: '수호자의 눈에서 붉은 빛이 타오른다. 진짜 전투가 시작된다.',
        turns: _phase2Turns,
      ),
    ],
  );

  /// 보스 데모 전투 생성.
  /// [combatConfig]의 bossTurnCountPhase1/Phase2와 턴 수 일치를 assert.
  static CombatEncounter create({
    CombatBalanceConfig combatConfig = const CombatBalanceConfig(),
  }) {
    assert(
      _encounter.bossPhases![0].turns.length == combatConfig.bossTurnCountPhase1,
      'BossDemoEncounter phase1 turns (${_encounter.bossPhases![0].turns.length}) '
      'must match combatConfig.bossTurnCountPhase1 (${combatConfig.bossTurnCountPhase1})',
    );
    assert(
      _encounter.bossPhases![1].turns.length == combatConfig.bossTurnCountPhase2,
      'BossDemoEncounter phase2 turns (${_encounter.bossPhases![1].turns.length}) '
      'must match combatConfig.bossTurnCountPhase2 (${combatConfig.bossTurnCountPhase2})',
    );
    return _encounter;
  }
}
