import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

/// 층별 보스 전투 조우 팩토리.
/// GAME_DESIGN.md 5보스: 재(灰)/무(無)/경(鏡)/안(安)/근(根).
/// JSON 에셋(assets/content/boss_encounters.json)에서 로드. 실패 시 기본값 폴백.
class BossEncounterFactory {
  BossEncounterFactory._();

  static Map<int, _BossData>? _loadedBossData;
  static _BossData? _loadedFallback;

  /// JSON 에셋에서 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/boss_encounters.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final bosses = json['bosses'] as List;
      final loaded = <int, _BossData>{};
      for (final entry in bosses) {
        final map = entry as Map<String, dynamic>;
        final floor = map['floor'] as int;
        loaded[floor] = _parseBossData(map);
      }
      _loadedBossData = loaded;
      if (json['generic_fallback'] != null) {
        _loadedFallback = _parseBossData(json['generic_fallback'] as Map<String, dynamic>);
      }
      GameLogger.info(LogSystem.core, 'BossEncounterFactory loaded: ${loaded.length} bosses');
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load boss_encounters.json, using defaults', e);
    }
  }

  static _BossData _parseBossData(Map<String, dynamic> map) {
    return _BossData(
      id: map['id'] as String? ?? 'boss_unknown',
      name: map['name'] as String,
      introText: map['intro_text'] as String,
      transitionText: map['transition_text'] as String,
      phase2IntroText: map['phase2_intro_text'] as String,
      victoryText: map['victory_text'] as String,
      defeatText: map['defeat_text'] as String,
      phase1Turns: _parseTurns(map['phase1_turns'] as List, 'boss'),
      phase2Turns: _parseTurns(map['phase2_turns'] as List, 'boss'),
    );
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
        playerChoices: [ChoiceData(id: '${prefix}_t${turn}a', text: '공격', resultTextBlocks: const [])],
      );
    }).toList();
  }

  /// 층별 보스 CombatEncounter 생성.
  static CombatEncounter create({
    required int floor,
    CombatBalanceConfig combatConfig = const CombatBalanceConfig(),
  }) {
    final bossData = _loadedBossData ?? _defaultBossData;
    final data = bossData[floor];
    if (data == null) {
      final fallback = _loadedFallback;
      if (fallback != null) {
        return _buildEncounter(
          bossName: fallback.name,
          introText: fallback.introText,
          phase1Turns: fallback.phase1Turns,
          phase2Turns: fallback.phase2Turns,
          transitionText: fallback.transitionText,
          phase2IntroText: fallback.phase2IntroText,
          victoryText: fallback.victoryText,
          defeatText: fallback.defeatText,
          combatConfig: combatConfig,
        );
      }
      return _buildEncounter(
        bossName: '미지의 존재',
        introText: '알 수 없는 존재가 앞을 가로막는다.',
        phase1Turns: _genericPhase1Turns('unknown'),
        phase2Turns: _genericPhase2Turns('unknown'),
        transitionText: '존재의 형태가 변한다...',
        phase2IntroText: '진짜 모습을 드러낸다.',
        victoryText: '존재가 사라진다.',
        defeatText: '존재의 힘에 쓰러진다...',
        combatConfig: combatConfig,
      );
    }

    return _buildEncounter(
      bossName: data.name,
      introText: data.introText,
      phase1Turns: data.phase1Turns,
      phase2Turns: data.phase2Turns,
      transitionText: data.transitionText,
      phase2IntroText: data.phase2IntroText,
      victoryText: data.victoryText,
      defeatText: data.defeatText,
      combatConfig: combatConfig,
    );
  }

  /// 보스 ID (저장/조회용).
  static String bossId(int floor) {
    final bossData = _loadedBossData ?? _defaultBossData;
    return bossData[floor]?.id ?? 'boss_unknown';
  }

  static CombatEncounter _buildEncounter({
    required String bossName,
    required String introText,
    required List<CombatTurnData> phase1Turns,
    required List<CombatTurnData> phase2Turns,
    required String transitionText,
    required String phase2IntroText,
    required String victoryText,
    required String defeatText,
    required CombatBalanceConfig combatConfig,
  }) {
    assert(
      phase1Turns.length == combatConfig.bossTurnCountPhase1,
      'Phase 1 turns (${phase1Turns.length}) must match '
      'combatConfig.bossTurnCountPhase1 (${combatConfig.bossTurnCountPhase1})',
    );
    assert(
      phase2Turns.length == combatConfig.bossTurnCountPhase2,
      'Phase 2 turns (${phase2Turns.length}) must match '
      'combatConfig.bossTurnCountPhase2 (${combatConfig.bossTurnCountPhase2})',
    );

    return CombatEncounter(
      roomType: RoomType.boss,
      enemyName: bossName,
      introText: introText,
      turns: phase1Turns,
      victoryText: victoryText,
      defeatText: defeatText,
      bossPhases: [
        BossPhasePresentation(
          introText: '',
          turns: phase1Turns,
          transitionText: transitionText,
        ),
        BossPhasePresentation(
          introText: phase2IntroText,
          turns: phase2Turns,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // 기본값 (JSON 로드 실패 시 폴백)
  // ════════════════════════════════════════════════════════════════════════

  static final Map<int, _BossData> _defaultBossData = {
    1: _BossData(id: 'boss_ash', name: '재(灰)의 수호자', introText: '재로 뒤덮인 형상이 천천히 일어선다...\n한때 이 던전을 구하려 했던 자의 잔재다.\n\n여기서 쓰러지면... 돌아올 수 없다.', transitionText: '재의 수호자가 흩어지더니... 더 짙은 형태로 뭉친다!', phase2IntroText: '흔들리는 목소리가 들린다. "너도... 나처럼..."', victoryText: '재의 수호자가 바람에 흩어진다. 그 자리에 희미한 빛이 남는다.', defeatText: '재의 수호자의 마지막 일격에 의식이 사라진다...', phase1Turns: _floor1Phase1Turns, phase2Turns: _floor1Phase2Turns),
    2: _BossData(id: 'boss_void', name: '무(無)의 수호자', introText: '텅 빈 공간에서... 아무것도 아닌 것이 형태를 갖는다...\n잊혀진 자의 메아리가 울린다.\n\n여기서 쓰러지면... 돌아올 수 없다.', transitionText: '무의 수호자가 사라졌다... 사라졌다... 아직 여기 있다!', phase2IntroText: '"기억해... 기억해... 아무도 기억하지 않아..."', victoryText: '무의 수호자가 조용히 소멸한다. 침묵만이 남는다.', defeatText: '무의 수호자에게 삼켜져 존재가 희미해진다...', phase1Turns: _floor2Phase1Turns, phase2Turns: _floor2Phase2Turns),
    3: _BossData(id: 'boss_mirror', name: '경(鏡)의 수호자', introText: '거울처럼 매끄러운 벽에서... 자신의 모습이 걸어 나온다.\n진행 중인 구원자. 바로 당신의 그림자.\n\n여기서 쓰러지면... 돌아올 수 없다.', transitionText: '경의 수호자가 당신의 움직임을 완벽히 따라한다... 그리고 앞서간다!', phase2IntroText: '"네가 하는 것을 나도 할 수 있어. 아니, 더 잘 할 수 있어."', victoryText: '경의 수호자가 산산이 부서진다. 거울 속에 진짜 자신이 비친다.', defeatText: '경의 수호자가 당신을 대체한다. 진짜가 누구인지 알 수 없게 된다...', phase1Turns: _floor3Phase1Turns, phase2Turns: _floor3Phase2Turns),
    4: _BossData(id: 'boss_peace', name: '안(安)의 수호자', introText: '따뜻한 빛이 감싸 안는다. 평화로운 목소리가 속삭인다.\n"여기서 쉬어도 돼. 더 이상 싸울 필요 없어."\n\n여기서 쓰러지면... 돌아올 수 없다.', transitionText: '안의 수호자의 미소가 일그러진다. "그래도... 멈추지 않겠다는 거야?"', phase2IntroText: '"내가 줄 수 있는 건 안식뿐... 원한다면 영원히."', victoryText: '안의 수호자가 눈을 감는다. 평화로운 표정 그대로.', defeatText: '안의 수호자의 포옹 속에서 의식이 녹아내린다...', phase1Turns: _floor4Phase1Turns, phase2Turns: _floor4Phase2Turns),
    5: _BossData(id: 'boss_root', name: '근(根)의 수호자', introText: '던전 자체가 움직인다. 벽이, 바닥이, 천장이 하나의 의지로 뭉친다.\n최초의 구원자. 이 던전 그 자체.\n\n여기서 쓰러지면... 돌아올 수 없다.', transitionText: '근의 수호자가 형태를 바꾼다! 던전 전체가 맥동한다!', phase2IntroText: '"나를 꺾으면 이 모든 것이 끝난다. 그래도 괜찮겠느냐?"', victoryText: '근의 수호자가 무너진다. 던전이 조용히 떨린다.', defeatText: '근의 수호자가 당신을 던전의 일부로 흡수한다...', phase1Turns: _floor5Phase1Turns, phase2Turns: _floor5Phase2Turns),
  };

  static const _floor1Phase1Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '재의 수호자가 떨리는 팔을 휘두르려 한다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f1b1t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.defend, previewText: '재의 수호자가 재로 된 장벽을 펼친다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f1b1t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '재의 수호자가 불씨를 응축하여 내려친다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f1b1t3a', text: '공격', resultTextBlocks: [])])];
  static const _floor1Phase2Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '재의 수호자가 불꽃과 함께 돌진한다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f1b2t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '재의 수호자가 연속으로 강타한다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f1b2t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.observe, previewText: '재의 수호자가 잠시 숨을 고르며 빈틈을 노린다', threatLevel: 1), playerChoices: [ChoiceData(id: 'f1b2t3a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 4, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '재의 수호자가 최후의 일격을 준비한다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f1b2t4a', text: '공격', resultTextBlocks: [])])];
  static const _floor2Phase1Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.observe, previewText: '무의 수호자가 형태 없이 흔들린다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f2b1t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '공허한 손이 뻗어온다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f2b1t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '무의 수호자가 존재를 부정하는 파동을 일으킨다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f2b1t3a', text: '공격', resultTextBlocks: [])])];
  static const _floor2Phase2Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '무의 수호자가 공간 자체를 지운다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f2b2t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.defend, previewText: '무의 수호자가 허무의 벽을 세운다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f2b2t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '무의 수호자가 기억을 삼킨다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f2b2t3a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 4, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '무의 수호자가 소멸의 일격을 가한다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f2b2t4a', text: '공격', resultTextBlocks: [])])];
  static const _floor3Phase1Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '경의 수호자가 당신과 똑같은 자세로 공격한다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f3b1t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.defend, previewText: '경의 수호자가 거울 장벽을 세운다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f3b1t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '경의 수호자가 반사된 힘으로 내려친다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f3b1t3a', text: '공격', resultTextBlocks: [])])];
  static const _floor3Phase2Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '경의 수호자가 당신보다 빠르게 움직인다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f3b2t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.observe, previewText: '경의 수호자가 당신의 다음 행동을 읽는다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f3b2t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '경의 수호자가 왜곡된 반사로 공격한다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f3b2t3a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 4, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '경의 수호자가 완벽한 모방으로 최후의 일격을 가한다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f3b2t4a', text: '공격', resultTextBlocks: [])])];
  static const _floor4Phase1Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.defend, previewText: '안의 수호자가 평화의 장벽으로 감싼다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f4b1t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '안의 수호자가 부드러운 빛으로 타격한다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f4b1t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.observe, previewText: '안의 수호자가 설득의 속삭임을 보낸다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f4b1t3a', text: '공격', resultTextBlocks: [])])];
  static const _floor4Phase2Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '안의 수호자가 절망의 파도를 일으킨다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f4b2t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '안의 수호자가 안식의 사슬을 던진다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f4b2t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.defend, previewText: '안의 수호자가 달콤한 꿈의 방패를 펼친다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f4b2t3a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 4, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '안의 수호자가 영원한 안식을 강제한다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f4b2t4a', text: '공격', resultTextBlocks: [])])];
  static const _floor5Phase1Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '근의 수호자가 던전의 벽을 무기로 삼아 내려친다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f5b1t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.defend, previewText: '근의 수호자가 던전 자체를 갑옷으로 두른다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f5b1t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '근의 수호자가 대지의 맥동으로 공격한다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f5b1t3a', text: '공격', resultTextBlocks: [])])];
  static const _floor5Phase2Turns = [CombatTurnData(turnNumber: 1, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '근의 수호자가 공간 자체를 찌그러뜨린다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f5b2t1a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 2, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '근의 수호자가 뿌리를 뻗어 얽어맨다', threatLevel: 3), playerChoices: [ChoiceData(id: 'f5b2t2a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 3, enemyAction: EnemyAction(type: EnemyActionType.observe, previewText: '근의 수호자가 당신의 의지를 시험한다', threatLevel: 2), playerChoices: [ChoiceData(id: 'f5b2t3a', text: '공격', resultTextBlocks: [])]), CombatTurnData(turnNumber: 4, enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '근의 수호자가 던전의 모든 힘을 모아 최종 일격을 가한다', threatLevel: 4), playerChoices: [ChoiceData(id: 'f5b2t4a', text: '공격', resultTextBlocks: [])])];

  static List<CombatTurnData> _genericPhase1Turns(String prefix) => [
    CombatTurnData(turnNumber: 1, enemyAction: const EnemyAction(type: EnemyActionType.attack, previewText: '적이 공격한다', threatLevel: 3), playerChoices: [ChoiceData(id: '${prefix}_p1t1', text: '공격', resultTextBlocks: const [])]),
    CombatTurnData(turnNumber: 2, enemyAction: const EnemyAction(type: EnemyActionType.defend, previewText: '적이 방어한다', threatLevel: 2), playerChoices: [ChoiceData(id: '${prefix}_p1t2', text: '공격', resultTextBlocks: const [])]),
    CombatTurnData(turnNumber: 3, enemyAction: const EnemyAction(type: EnemyActionType.attack, previewText: '적이 강하게 공격한다', threatLevel: 3), playerChoices: [ChoiceData(id: '${prefix}_p1t3', text: '공격', resultTextBlocks: const [])]),
  ];

  static List<CombatTurnData> _genericPhase2Turns(String prefix) => [
    CombatTurnData(turnNumber: 1, enemyAction: const EnemyAction(type: EnemyActionType.attack, previewText: '적이 돌진한다', threatLevel: 4), playerChoices: [ChoiceData(id: '${prefix}_p2t1', text: '공격', resultTextBlocks: const [])]),
    CombatTurnData(turnNumber: 2, enemyAction: const EnemyAction(type: EnemyActionType.attack, previewText: '적이 연속 공격한다', threatLevel: 3), playerChoices: [ChoiceData(id: '${prefix}_p2t2', text: '공격', resultTextBlocks: const [])]),
    CombatTurnData(turnNumber: 3, enemyAction: const EnemyAction(type: EnemyActionType.observe, previewText: '적이 숨을 고른다', threatLevel: 1), playerChoices: [ChoiceData(id: '${prefix}_p2t3', text: '공격', resultTextBlocks: const [])]),
    CombatTurnData(turnNumber: 4, enemyAction: const EnemyAction(type: EnemyActionType.attack, previewText: '적이 최후의 일격을 준비한다', threatLevel: 4), playerChoices: [ChoiceData(id: '${prefix}_p2t4', text: '공격', resultTextBlocks: const [])]),
  ];
}

class _BossData {
  final String id;
  final String name;
  final String introText;
  final String transitionText;
  final String phase2IntroText;
  final String victoryText;
  final String defeatText;
  final List<CombatTurnData> phase1Turns;
  final List<CombatTurnData> phase2Turns;

  const _BossData({
    required this.id,
    required this.name,
    required this.introText,
    required this.transitionText,
    required this.phase2IntroText,
    required this.victoryText,
    required this.defeatText,
    required this.phase1Turns,
    required this.phase2Turns,
  });
}
