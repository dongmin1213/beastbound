import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';

void main() {
  group('CombatFlowManager.toTextBlocks', () {
    test('generates intro text as first block', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '적이 나타났다!',
        turns: [],
        victoryText: '승리!',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);
      expect(blocks.first.text, '적이 나타났다!');
      expect(blocks.first.blockType, TextBlockType.normal);
    });

    test('generates victory text as last block', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '적이 나타났다!',
        turns: [],
        victoryText: '승리!',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);
      expect(blocks.last.text, '승리!');
      expect(blocks.last.blockType, TextBlockType.combatOutcome);
    });

    test('0-turn combat: intro + victory only', () {
      const encounter = CombatEncounter(
        enemyName: '허깨비',
        introText: '허깨비가 나타났다!',
        turns: [],
        victoryText: '허깨비가 사라졌다.',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);
      expect(blocks, hasLength(2));
      expect(blocks[0].text, '허깨비가 나타났다!');
      expect(blocks[1].text, '허깨비가 사라졌다.');
    });

    test('1-turn combat: intro + divider + preview + choices + victory', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '적 등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '적이 공격한다',
            ),
            playerChoices: [
              ChoiceData(id: 'a', text: '공격', resultTextBlocks: ['일격!']),
            ],
          ),
        ],
        victoryText: '승리!',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);

      // intro(1) + divider(1) + preview(1) + choices(1) + victory(1) = 5
      expect(blocks, hasLength(5));

      // Block 0: intro
      expect(blocks[0].text, '적 등장');
      expect(blocks[0].blockType, TextBlockType.normal);

      // Block 1: turn divider
      expect(blocks[1].text, '═══════ 1턴 ═══════');
      expect(blocks[1].blockType, TextBlockType.turnDivider);

      // Block 2: action preview
      expect(blocks[2].text, contains('적이 공격한다'));
      expect(blocks[2].text, contains('⚔'));
      expect(blocks[2].blockType, TextBlockType.combatPreview);
      expect(blocks[2].metadata?['actionType'], 'attack');

      // Block 3: choices
      expect(blocks[3].hasChoices, isTrue);
      expect(blocks[3].text, '어떻게 대응할 것인가?');

      // Block 4: victory
      expect(blocks[4].text, '승리!');
    });

    test('3-turn combat generates correct block count', () {
      const encounter = CombatEncounter(
        enemyName: '테스트',
        introText: '등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '공격',
            ),
            playerChoices: [
              ChoiceData(id: 't1', text: '행동', resultTextBlocks: ['결과1']),
            ],
          ),
          CombatTurnData(
            turnNumber: 2,
            enemyAction: EnemyAction(
              type: EnemyActionType.defend,
              previewText: '방어',
            ),
            playerChoices: [
              ChoiceData(id: 't2', text: '행동', resultTextBlocks: ['결과2']),
            ],
          ),
          CombatTurnData(
            turnNumber: 3,
            enemyAction: EnemyAction(
              type: EnemyActionType.observe,
              previewText: '관찰',
            ),
            playerChoices: [
              ChoiceData(id: 't3', text: '행동', resultTextBlocks: ['결과3']),
            ],
          ),
        ],
        victoryText: '승리!',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);

      // intro(1) + 3 turns x (divider + preview + choices) + victory(1) = 1 + 9 + 1 = 11
      expect(blocks, hasLength(11));
    });

    test('turn dividers show correct turn numbers', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '공격',
            ),
            playerChoices: [
              ChoiceData(id: 't1', text: '행동', resultTextBlocks: []),
            ],
          ),
          CombatTurnData(
            turnNumber: 2,
            enemyAction: EnemyAction(
              type: EnemyActionType.defend,
              previewText: '방어',
            ),
            playerChoices: [
              ChoiceData(id: 't2', text: '행동', resultTextBlocks: []),
            ],
          ),
        ],
        victoryText: '승리',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);
      final dividers =
          blocks.where((b) => b.blockType == TextBlockType.turnDivider).toList();

      expect(dividers, hasLength(2));
      expect(dividers[0].text, '═══════ 1턴 ═══════');
      expect(dividers[1].text, '═══════ 2턴 ═══════');
    });

    test('preview blocks contain correct action type metadata', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '공격',
            ),
            playerChoices: [
              ChoiceData(id: 't1', text: '행동', resultTextBlocks: []),
            ],
          ),
          CombatTurnData(
            turnNumber: 2,
            enemyAction: EnemyAction(
              type: EnemyActionType.defend,
              previewText: '방어',
            ),
            playerChoices: [
              ChoiceData(id: 't2', text: '행동', resultTextBlocks: []),
            ],
          ),
        ],
        victoryText: '승리',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);
      final previews = blocks
          .where((b) => b.blockType == TextBlockType.combatPreview)
          .toList();

      expect(previews, hasLength(2));
      expect(previews[0].metadata?['actionType'], 'attack');
      expect(previews[1].metadata?['actionType'], 'defend');
    });

    test('action prefixes match type', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '공격 텍스트',
            ),
            playerChoices: [
              ChoiceData(id: 't1', text: '행동', resultTextBlocks: []),
            ],
          ),
          CombatTurnData(
            turnNumber: 2,
            enemyAction: EnemyAction(
              type: EnemyActionType.defend,
              previewText: '방어 텍스트',
            ),
            playerChoices: [
              ChoiceData(id: 't2', text: '행동', resultTextBlocks: []),
            ],
          ),
          CombatTurnData(
            turnNumber: 3,
            enemyAction: EnemyAction(
              type: EnemyActionType.observe,
              previewText: '관찰 텍스트',
            ),
            playerChoices: [
              ChoiceData(id: 't3', text: '행동', resultTextBlocks: []),
            ],
          ),
        ],
        victoryText: '승리',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);
      final previews = blocks
          .where((b) => b.blockType == TextBlockType.combatPreview)
          .toList();

      expect(previews[0].text, contains('⚔'));
      expect(previews[1].text, contains('🛡'));
      expect(previews[2].text, contains('👁'));
    });
  });

  group('CombatFlowManager.toDynamicTextBlocks', () {
    test('generates same structure as toTextBlocks', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '적 등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '적이 공격한다',
            ),
            playerChoices: [],
          ),
        ],
        victoryText: '승리!',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);

      // intro(1) + divider(1) + preview(1) + choices(1) + victory(1) = 5
      expect(blocks, hasLength(5));
      expect(blocks[0].text, '적 등장');
      expect(blocks[1].blockType, TextBlockType.turnDivider);
      expect(blocks[2].blockType, TextBlockType.combatPreview);
      expect(blocks[3].hasChoices, isTrue);
      expect(blocks[4].text, '승리!');
    });

    test('generates 3 action choices per turn with actionType', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '공격',
            ),
            playerChoices: [],
          ),
        ],
        victoryText: '승리',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      final choiceBlock = blocks.firstWhere((b) => b.hasChoices);
      final choices = choiceBlock.choices!;

      expect(choices, hasLength(3));
      expect(choices[0].actionType, 'attack');
      expect(choices[1].actionType, 'defend');
      expect(choices[2].actionType, 'observe');
    });

    test('choice texts include action type prefix', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '공격',
            ),
            playerChoices: [],
          ),
        ],
        victoryText: '승리',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      final choices = blocks.firstWhere((b) => b.hasChoices).choices!;

      expect(choices[0].text, contains('⚔'));
      expect(choices[1].text, contains('🛡'));
      expect(choices[2].text, contains('👁'));
    });

    test('dynamic choices have empty resultTextBlocks', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '공격',
            ),
            playerChoices: [],
          ),
        ],
        victoryText: '승리',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      final choices = blocks.firstWhere((b) => b.hasChoices).choices!;

      for (final choice in choices) {
        expect(choice.resultTextBlocks, isEmpty);
      }
    });

    test('3-turn dynamic combat generates correct block count', () {
      const encounter = CombatEncounter(
        enemyName: '적',
        introText: '등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(type: EnemyActionType.attack, previewText: '공격'),
            playerChoices: [],
          ),
          CombatTurnData(
            turnNumber: 2,
            enemyAction: EnemyAction(type: EnemyActionType.defend, previewText: '방어'),
            playerChoices: [],
          ),
          CombatTurnData(
            turnNumber: 3,
            enemyAction: EnemyAction(type: EnemyActionType.observe, previewText: '관찰'),
            playerChoices: [],
          ),
        ],
        victoryText: '승리',
        defeatText: '패배했다.',
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      // intro(1) + 3 x (divider + preview + choices) + victory(1) = 11
      expect(blocks, hasLength(11));
    });
  });

  group('CombatFlowManager.resolveActionResult', () {
    test('returns combatResult block type', () {
      final result = CombatFlowManager.resolveActionResult(
        playerAction: PlayerActionType.attack,
        enemyAction: EnemyActionType.attack,
      );

      expect(result.blockType, TextBlockType.combatResult);
    });

    test('metadata contains actionResult, playerAction, enemyAction', () {
      final result = CombatFlowManager.resolveActionResult(
        playerAction: PlayerActionType.defend,
        enemyAction: EnemyActionType.attack,
      );

      expect(result.metadata?['actionResult'], 'effective');
      expect(result.metadata?['playerAction'], 'defend');
      expect(result.metadata?['enemyAction'], 'attack');
    });

    test('effective result contains ✦ prefix', () {
      final result = CombatFlowManager.resolveActionResult(
        playerAction: PlayerActionType.attack,
        enemyAction: EnemyActionType.observe,
      );

      expect(result.text, startsWith('✦ '));
      expect(result.metadata?['actionResult'], 'effective');
    });

    test('neutral result contains - prefix', () {
      final result = CombatFlowManager.resolveActionResult(
        playerAction: PlayerActionType.attack,
        enemyAction: EnemyActionType.attack,
      );

      expect(result.text, startsWith('- '));
      expect(result.metadata?['actionResult'], 'neutral');
    });

    test('ineffective result contains ✧ prefix', () {
      final result = CombatFlowManager.resolveActionResult(
        playerAction: PlayerActionType.attack,
        enemyAction: EnemyActionType.defend,
      );

      expect(result.text, startsWith('✧ '));
      expect(result.metadata?['actionResult'], 'ineffective');
    });

    test('all 9 combinations produce non-empty text', () {
      for (final player in PlayerActionType.values) {
        for (final enemy in EnemyActionType.values) {
          final result = CombatFlowManager.resolveActionResult(
            playerAction: player,
            enemyAction: enemy,
          );
          expect(result.text, isNotEmpty,
              reason: '${player.name} vs ${enemy.name}');
        }
      }
    });

    test('결과 텍스트에 상호작용 내용 포함', () {
      final result = CombatFlowManager.resolveActionResult(
        playerAction: PlayerActionType.defend,
        enemyAction: EnemyActionType.attack,
      );

      // ActionInteraction.getResultText 결과가 포함되어야 함
      expect(result.text, contains('적의 공격을 견고히 막아냈다!'));
    });
  });

  group('CombatFlowManager.describeCardCombatStatus', () {
    test('기본 상태 텍스트 포맷', () {
      final text = CombatFlowManager.describeCardCombatStatus(
        playerHp: 72,
        playerMaxHp: 80,
        playerBlock: 0,
        actionPoints: 3,
        maxActionPoints: 3,
        enemyName: '고블린',
        enemyHp: 15,
        enemyMaxHp: 20,
        currentTurn: 1,
      );
      expect(text, contains('[1턴]'));
      expect(text, contains('HP: 72/80'));
      expect(text, contains('AP: ■■■ (3/3)'));
      expect(text, contains('고블린: 15/20'));
      // 블록 0이면 블록 표시 없음
      expect(text, isNot(contains('블록')));
    });

    test('블록이 있으면 블록 표시', () {
      final text = CombatFlowManager.describeCardCombatStatus(
        playerHp: 50,
        playerMaxHp: 80,
        playerBlock: 5,
        actionPoints: 2,
        maxActionPoints: 3,
        enemyName: '쥐',
        enemyHp: 8,
        enemyMaxHp: 10,
        currentTurn: 2,
      );
      expect(text, contains('블록: 5'));
      expect(text, contains('AP: ■■□ (2/3)'));
    });
  });
}
