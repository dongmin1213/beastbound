import 'package:soul_dungeon/core/text/korean_particles.dart';
import 'package:soul_dungeon/domain/build/data/card_blessing_pool.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/domain/combat/logic/card_effect_resolver.dart';
import 'package:soul_dungeon/domain/combat/logic/enemy_ai.dart';
import 'package:soul_dungeon/domain/combat/logic/special_action_resolver.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/action_interaction.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_defeat_handler.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_result_calculator.dart';

/// CombatEncounter를 GameScreen이 소비할 `List<TextBlockData>`로 변환
class CombatFlowManager {
  CombatFlowManager._();

  static List<TextBlockData> toTextBlocks(CombatEncounter encounter) {
    return _buildBlocks(
      encounter,
      choicesForTurn: (turn) => turn.playerChoices,
    );
  }

  /// 동적 결과를 사용하는 전투 블록 변환.
  /// 선택지에 actionType을 자동 부여하여 ActionInteraction 기반 결과 생성을 활성화.
  /// [roomType]이 elite이면 경고 서술 블록을 introText 앞에 삽입.
  static List<TextBlockData> toDynamicTextBlocks(CombatEncounter encounter) {
    return _buildBlocks(
      encounter,
      roomType: encounter.roomType,
      choicesForTurn: (turn) => [
        ChoiceData(
          id: 't${turn.turnNumber}_attack',
          text: '${PlayerActionType.attack.prefix}공격한다',
          resultTextBlocks: const [],
          actionType: PlayerActionType.attack.name,
        ),
        ChoiceData(
          id: 't${turn.turnNumber}_defend',
          text: '${PlayerActionType.defend.prefix}방어한다',
          resultTextBlocks: const [],
          actionType: PlayerActionType.defend.name,
        ),
        ChoiceData(
          id: 't${turn.turnNumber}_observe',
          text: '${PlayerActionType.observe.prefix}관찰한다',
          resultTextBlocks: const [],
          actionType: PlayerActionType.observe.name,
        ),
      ],
    );
  }

  /// 공통 전투 블록 생성 로직.
  /// [choicesForTurn]으로 턴별 선택지 생성 방식만 분기.
  static List<TextBlockData> _buildBlocks(
    CombatEncounter encounter, {
    RoomType roomType = RoomType.combat,
    required List<ChoiceData> Function(CombatTurnData turn) choicesForTurn,
  }) {
    final blocks = <TextBlockData>[];
    var isFirstPreview = true;

    // 0. 환경 서술 (단서 포함) — GDD: "환경이 먼저, 행동이 다음"
    if (encounter.environmentText != null) {
      blocks.add(TextBlockData(
        text: encounter.environmentText!,
        blockType: TextBlockType.environmentNarration,
        metadata: {
          'environmentClues': encounter.environmentClues,
        },
      ));
    }

    // 0.5. 엘리트 경고 서술 블록 — roomType == elite 시 introText 앞에 삽입
    if (roomType == RoomType.elite) {
      blocks.add(const TextBlockData(
        text: '이곳의 공기가 무겁다. 돌아가는 것이 현명할 수도 있다... '
            '하지만 그 너머에는 대가가 기다린다. 주변을 잘 살펴야 할 것이다.',
        blockType: TextBlockType.normal,
        metadata: {'eliteWarning': true},
      ));
    }

    // 1. 적 등장 텍스트
    blocks.add(TextBlockData(text: encounter.introText));

    // 2. 턴별 반복
    for (final turn in encounter.turns) {
      // 턴 구분자
      blocks.add(TextBlockData(
        text: '═══════ ${turn.turnNumber}턴 ═══════',
        blockType: TextBlockType.turnDivider,
      ));

      // 행동 예고 (특수 스타일 블록)
      final previewMetadata = {
        'actionType': turn.enemyAction.type.name,
        'previewText': turn.enemyAction.previewText,
      };
      if (isFirstPreview) {
        previewMetadata['combatPhase'] = 'start';
        isFirstPreview = false;
      }
      blocks.add(TextBlockData(
        text: '${turn.enemyAction.type.prefix}${turn.enemyAction.previewText}',
        blockType: TextBlockType.combatPreview,
        metadata: previewMetadata,
      ));

      // 플레이어 선택지
      blocks.add(TextBlockData(
        text: '어떻게 대응할 것인가?',
        choices: choicesForTurn(turn),
      ));
    }

    // 3. 전투 결과 (placeholder — GameScreen에서 동적 교체)
    blocks.add(TextBlockData(
      text: encounter.victoryText,
      blockType: TextBlockType.combatOutcome,
      metadata: const {'combatPhase': 'end', 'combatOutcome': 'pending'},
    ));

    return blocks;
  }

  /// 전투 결과에 따른 outcome 블록 생성.
  static TextBlockData buildOutcomeBlock(
    CombatEncounter encounter,
    CombatResultScore result,
  ) {
    final isVictory = result.outcome == CombatOutcome.victory;
    final summary = _buildResultSummary(result);
    return TextBlockData(
      text: isVictory
          ? '✦ 승리 — ${encounter.victoryText}\n$summary'
          : '✧ 패배 — ${encounter.defeatText}\n$summary',
      blockType: TextBlockType.combatOutcome,
      metadata: {
        'combatPhase': 'end',
        'combatOutcome': isVictory ? 'victory' : 'defeat',
        'resultScore': result.score,
        'turnResults': result.turnResults,
      },
    );
  }

  /// 턴 결과 요약 텍스트 생성.
  static String _buildResultSummary(CombatResultScore result) {
    final total = result.turnResults.length;
    final effective =
        result.turnResults.where((r) => r == 'effective').length;
    final ineffective =
        result.turnResults.where((r) => r == 'ineffective').length;
    final neutral = total - effective - ineffective;

    final parts = <String>[];
    if (effective > 0) parts.add('유효 $effective회');
    if (neutral > 0) parts.add('중립 $neutral회');
    if (ineffective > 0) parts.add('빗나감 $ineffective회');

    return '[$total턴: ${parts.join(' / ')}]';
  }

  /// 직업 특수 행동 선택지 생성.
  /// [specialActionType]: JobPath.specialActionType
  static ChoiceData buildSpecialActionChoice(String specialActionType) {
    final displayName = SpecialActionResolver.getDisplayName(specialActionType);
    final prefix = SpecialActionResolver.getPrefix(specialActionType);
    return ChoiceData(
      id: 'special_$specialActionType',
      text: '$prefix$displayName',
      resultTextBlocks: const [],
      actionType: ActionType.special.name,
    );
  }

  /// 환경 단서로부터 환경 활용 선택지를 생성한다.
  static List<ChoiceData> buildEnvironmentChoices(
    List<EnvironmentClue> discoveredClues,
  ) {
    return discoveredClues
        .map((clue) => ChoiceData(
              id: 'env_${clue.id}',
              text: '${ActionType.environment.prefix}${clue.actionHint}',
              resultTextBlocks: const [],
              actionType: ActionType.environment.name,
            ))
        .toList();
  }

  /// 패배 시 HP 손실 서술 블록 생성. 티어별 접두사 적용.
  static TextBlockData buildDefeatHpBlock({
    required int hpLost,
    required int remainingHp,
    required int maxHp,
    required HpNarrationTier tier,
  }) {
    final text = switch (tier) {
      HpNarrationTier.healthy =>
        '체력이 $hpLost 감소했다. ($remainingHp/$maxHp)',
      HpNarrationTier.wounded =>
        '숨이 거칠어진다. 체력이 $hpLost 감소했다. ($remainingHp/$maxHp)',
      HpNarrationTier.critical =>
        '몸이 비틀거린다. 체력이 $hpLost 감소했다. ($remainingHp/$maxHp)',
      HpNarrationTier.danger =>
        '시야가 흐려진다. 체력이 $hpLost 감소했다. ($remainingHp/$maxHp)',
      HpNarrationTier.dead => '마지막 체력이 소진되었다.',
    };

    return TextBlockData(
      text: text,
      blockType: TextBlockType.normal,
      metadata: {
        'hpLoss': true,
        'hpLost': hpLost,
        'remainingHp': remainingHp,
      },
    );
  }

  /// 퍼마데스 서술 블록 생성.
  static TextBlockData buildPermadeathBlock() {
    return const TextBlockData(
      text: '어둠이 밀려온다. 마지막 힘이 빠져나가고... 의식이 흐려진다.',
      blockType: TextBlockType.normal,
      metadata: {'permadeath': true},
    );
  }

  /// 런 종합 요약 블록 생성 (사망/클리어 공용).
  static TextBlockData buildRunSummaryBlock({
    required PlayerRunState runState,
    required int soulGained,
    bool isVictory = false,
    bool showSoulHint = false,
  }) {
    final buf = StringBuffer();
    buf.writeln('══════ 여정의 기록 ══════');
    buf.writeln();

    // 직업
    final jobName = _resolveJobName(runState.currentJobId);
    buf.writeln('직업: $jobName');

    // 도달 층수
    if (isVictory) {
      buf.writeln('도달: 던전 클리어!');
    } else {
      buf.writeln('도달: ${runState.currentFloor}층');
    }
    buf.writeln();

    // 덱 정보
    final deckSize = runState.masterDeck.length;
    final removed = runState.removedCardIds.length;
    if (removed > 0) {
      buf.writeln('덱: $deckSize장 (제거 $removed장)');
    } else {
      buf.writeln('덱: $deckSize장');
    }

    // 축복/유물/저주 (상점 저주 아이템은 축복에서 제외)
    final cursedInBlessings = runState.ownedBlessingIds
        .where((id) => CardBlessingPool.cursedIds.contains(id))
        .length;
    final blessings = runState.ownedBlessingIds.length - cursedInBlessings;
    final relics = runState.ownedRelicIds.length;
    final curses = runState.activeCurseIds.length + cursedInBlessings;
    buf.writeln('축복: $blessings개  유물: $relics개  저주: $curses개');

    // 소지 골드
    buf.writeln('골드: ${runState.gold}');
    buf.writeln();

    // 보스 선택 기록
    if (runState.bossChoices.isNotEmpty) {
      buf.write('보스 선택: ');
      final choiceTexts = runState.bossChoices
          .map((c) => '${c.floor}층 ${c.choiceType.displayName}')
          .join(', ');
      buf.writeln(choiceTexts);
      buf.writeln();
    }

    // 획득 소울
    if (soulGained > 0) {
      buf.writeln('획득 소울: $soulGained');
      if (showSoulHint) {
        buf.writeln('  → 소울은 소울 상점에서 영구 강화에 사용된다.');
      }
    }

    buf.write('════════════════════════');

    return TextBlockData(
      text: buf.toString(),
      blockType: TextBlockType.normal,
      metadata: {
        'runSummary': true,
        'isVictory': isVictory,
        'floor': runState.currentFloor,
      },
    );
  }

  /// jobId → 표시 이름 변환.
  static String _resolveJobName(String? jobId) {
    if (jobId == null) return '무직';
    final job = JobPath.values.where((j) => j.id == jobId).firstOrNull;
    return job?.displayName ?? jobId;
  }

  /// 플레이어 행동 + 적 행동 조합으로 결과 TextBlockData 생성.
  static TextBlockData resolveActionResult({
    required PlayerActionType playerAction,
    required EnemyActionType enemyAction,
  }) {
    final result = ActionInteraction.getResult(playerAction, enemyAction);
    final resultText = ActionInteraction.getResultText(playerAction, enemyAction);
    final prefix = ActionInteraction.getResultPrefix(result);

    return TextBlockData(
      text: '$prefix$resultText',
      blockType: TextBlockType.combatResult,
      metadata: {
        'actionResult': result.name,
        'playerAction': playerAction.name,
        'enemyAction': enemyAction.name,
      },
    );
  }

  // ── 카드 전투 ──────────────────────────────────────

  /// 카드 손패 → ChoiceData 변환 (카드만, 턴 종료/도주 제외).
  ///
  /// AP 부족 카드는 enabled=false + apCost 전달.
  static List<ChoiceData> buildCardHandChoices({
    required List<CardData> hand,
    required int actionPoints,
    int playerStrength = 0,
    int playerDexterity = 0,
    bool isPlayerWeakened = false,
    bool isEnemyVulnerable = false,
  }) {
    return [
      for (int i = 0; i < hand.length; i++)
        ChoiceData(
          id: 'play_card_${hand[i].id}_$i',
          text: _formatCardChoiceText(
            hand[i],
            playerStrength: playerStrength,
            playerDexterity: playerDexterity,
            isPlayerWeakened: isPlayerWeakened,
            isEnemyVulnerable: isEnemyVulnerable,
          ),
          resultTextBlocks: const [],
          enabled: hand[i].apCost <= actionPoints,
          apCost: hand[i].apCost,
          cardType: hand[i].type,
          sourceCard: hand[i],
        ),
    ];
  }

  /// 전투 액션 버튼 데이터 (턴 종료 / 도주).
  static List<ChoiceData> buildCombatActionButtons({
    required bool isBoss,
    int fleeApCost = 1,
  }) {
    return [
      const ChoiceData(
        id: 'end_turn',
        text: '턴 종료',
        resultTextBlocks: [],
      ),
      if (!isBoss)
        ChoiceData(
          id: 'flee',
          text: '도주 (${fleeApCost}AP)',
          resultTextBlocks: const [],
        ),
    ];
  }

  /// 카드 선택지 텍스트 포맷.
  ///
  /// 형식: `{카드이름} — {효과}` (AP 비용은 위젯 뱃지로 표시)
  static String _formatCardChoiceText(
    CardData card, {
    int playerStrength = 0,
    int playerDexterity = 0,
    bool isPlayerWeakened = false,
    bool isEnemyVulnerable = false,
  }) {
    final effectParts = <String>[];
    if (card.damage != null) {
      var dmg = card.damage! + playerStrength;
      if (dmg < 0) dmg = 0;
      if (isPlayerWeakened) dmg = (dmg * 0.75).toInt();
      if (isEnemyVulnerable) dmg = (dmg * 1.5).toInt();
      effectParts.add('$dmg 데미지');
    }
    if (card.block != null) {
      var blk = card.block! + playerDexterity;
      if (blk < 0) blk = 0;
      effectParts.add('$blk 방어');
    }
    if (effectParts.isNotEmpty) {
      return '${card.name} \u2014 ${effectParts.join(' / ')}';
    }
    // damage/block 없는 카드 → description 폴백으로 높이 통일
    return '${card.name} \u2014 ${card.description}';
  }

  /// CardPlayResult → 서술 텍스트.
  ///
  /// [comboCount] 이번 턴 공격 카드 연속 횟수. 3+에서 콤보 텍스트 추가.
  /// [chainBonusDamage] 연쇄 보너스로 추가된 데미지 (0이면 표시 안 함).
  static String describeCardPlayResult(
    CardPlayResult result, {
    int comboCount = 0,
    int chainBonusDamage = 0,
  }) {
    final parts = <String>[];
    final synergy = detectSynergy(result, comboCount: comboCount);

    if (result.damageResult != null) {
      final dmg = result.damageResult!;
      final totalDamage = dmg.finalDamage + chainBonusDamage;
      final chainSuffix = chainBonusDamage > 0 ? ' (연쇄 +$chainBonusDamage)' : '';
      final dmgText = dmg.blockAbsorbed > 0
          ? '$totalDamage 데미지!$chainSuffix (${dmg.blockAbsorbed} 블록 흡수)'
          : '$totalDamage 데미지!$chainSuffix';

      if (synergy.isBigDamage) {
        parts.add(
            '★ ${result.card.name}${KoreanParticles.euro(result.card.name)} $dmgText ★');
      } else {
        parts.add(
            '${result.card.name}${KoreanParticles.euro(result.card.name)} $dmgText');
      }

      if (dmg.strengthBonus >= 5) {
        parts.add('【힘+${dmg.strengthBonus}】');
      }
    }
    if (result.blockGained > 0) {
      parts.add('${result.blockGained} 블록 획득.');
    }
    if (result.selfDamage > 0) {
      parts.add('반동으로 ${result.selfDamage} 데미지를 받았다.');
    }
    if (result.healAmount > 0) {
      parts.add('${result.healAmount} HP 회복.');
    }
    if (result.drawCount > 0) {
      parts.add('카드 ${result.drawCount}장 드로우.');
    }
    for (final s in result.newEnemyStatuses) {
      parts.add('적에게 ${s.type.displayName} ${s.stacks} 부여.');
    }
    for (final s in result.newPlayerStatuses) {
      parts.add('${s.type.displayName} ${s.stacks} 획득.');
    }
    if (parts.isEmpty) {
      parts.add('${result.card.name}${KoreanParticles.eulReul(result.card.name)} 사용했다.');
    }

    if (synergy.isCombo) {
      parts.add('$comboCount연속 공격!');
    }

    return parts.join(' ');
  }

  /// 시너지 판정.
  static SynergyInfo detectSynergy(
    CardPlayResult result, {
    int comboCount = 0,
  }) {
    final dmg = result.damageResult;
    final isBigDamage = dmg != null && dmg.finalDamage >= 20;
    final isStrengthBurst = dmg != null && dmg.strengthBonus >= 5;
    final isCombo = comboCount >= 3;
    return SynergyInfo(
      isBigDamage: isBigDamage,
      isStrengthBurst: isStrengthBurst,
      isCombo: isCombo,
      hasSynergy: isCombo,
    );
  }

  /// 적이 독/화상/가시 등 상태이상으로 사망했을 때 피니시 텍스트.
  static String describeStatusFinish(String enemyName) {
    return '★ 피니시! $enemyName${KoreanParticles.eulReul(enemyName)} 상태이상이 쓰러뜨렸다!';
  }

  /// 적 기절(스턴) 시 서술 텍스트.
  static String describeEnemyStunned(String enemyName) {
    return '$enemyName${KoreanParticles.eunNeun(enemyName)} 기절하여 행동하지 못했다!';
  }

  /// EnemyActionResult → 서술 텍스트.
  static String describeEnemyAction(
    String enemyName,
    EnemyActionResult action,
  ) {
    return switch (action.type) {
      EnemyActionType.attack => action.damage > 0
          ? '$enemyName${KoreanParticles.iGa(enemyName)} 공격했다! ${action.damage} 데미지.'
          : '$enemyName${KoreanParticles.iGa(enemyName)} 공격했지만 블록으로 막았다!',
      EnemyActionType.heavy => action.damage > 0
          ? '$enemyName${KoreanParticles.iGa(enemyName)} 강타를 날렸다! ${action.damage} 데미지!'
          : '$enemyName${KoreanParticles.iGa(enemyName)} 강타를 날렸지만 블록으로 막았다!',
      EnemyActionType.defend =>
        '$enemyName${KoreanParticles.iGa(enemyName)} 방어 태세를 취했다. ${action.block} 블록.',
      EnemyActionType.heal =>
        '$enemyName${KoreanParticles.iGa(enemyName)} 회복했다. +${action.healAmount} HP.',
      EnemyActionType.buff =>
        '$enemyName${KoreanParticles.iGa(enemyName)} 강화했다. 힘 +${action.buffStrength}.',
      EnemyActionType.charge =>
        '$enemyName${KoreanParticles.iGa(enemyName)} 힘을 모으고 있다...',
      EnemyActionType.observe =>
        '$enemyName${KoreanParticles.iGa(enemyName)} 주시하고 있다.',
    };
  }

  /// 적 의도 표시 텍스트.
  ///
  /// [showIntent]가 true이면 구체적 의도 텍스트, false이면 "???" 표시.
  static String describeEnemyIntent({
    required String enemyName,
    required bool showIntent,
    required String intentText,
  }) {
    if (showIntent) return intentText;
    return '$enemyName${KoreanParticles.iGa(enemyName)} 무언가를 준비하고 있다...';
  }

  /// 카드 전투 상태 요약 텍스트 (멀티몹 지원).
  static String describeCardCombatStatus({
    required int playerHp,
    required int playerMaxHp,
    required int playerBlock,
    required int actionPoints,
    required int maxActionPoints,
    required String enemyName,
    required int enemyHp,
    required int enemyMaxHp,
    required int currentTurn,
    List<({String name, int hp, int maxHp})>? allEnemies,
  }) {
    final clampedAp = actionPoints.clamp(0, maxActionPoints);
    final apBar = '■' * clampedAp + '□' * (maxActionPoints - clampedAp);
    final blockText = playerBlock > 0 ? '  블록: $playerBlock' : '';
    final buf = StringBuffer();
    buf.write('[$currentTurn턴] HP: $playerHp/$playerMaxHp$blockText  '
        'AP: $apBar ($actionPoints/$maxActionPoints)');

    if (allEnemies != null && allEnemies.length > 1) {
      for (final e in allEnemies) {
        buf.write('  ${e.name}: ${e.hp}/${e.maxHp}');
      }
    } else {
      buf.write('  $enemyName: $enemyHp/$enemyMaxHp');
    }
    return buf.toString();
  }
}
