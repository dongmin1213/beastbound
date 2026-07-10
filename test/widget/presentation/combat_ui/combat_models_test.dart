import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

void main() {
  group('EnemyActionType', () {
    test('has exactly 7 values', () {
      expect(EnemyActionType.values, hasLength(7));
    });

    test('contains attack, defend, observe, heavy, charge, heal, buff', () {
      expect(EnemyActionType.values, containsAll([
        EnemyActionType.attack,
        EnemyActionType.defend,
        EnemyActionType.observe,
        EnemyActionType.heavy,
        EnemyActionType.charge,
        EnemyActionType.heal,
        EnemyActionType.buff,
      ]));
    });
  });

  group('EnemyAction', () {
    test('creates with required fields', () {
      const action = EnemyAction(
        type: EnemyActionType.attack,
        previewText: '적이 강하게 내려치려 한다',
      );

      expect(action.type, EnemyActionType.attack);
      expect(action.previewText, '적이 강하게 내려치려 한다');
      expect(action.threatLevel, 1); // default
    });

    test('creates with custom threatLevel', () {
      const action = EnemyAction(
        type: EnemyActionType.defend,
        previewText: '적이 방어 자세를 취한다',
        threatLevel: 3,
      );

      expect(action.threatLevel, 3);
    });

    test('each action type is distinguishable', () {
      const attack = EnemyAction(
        type: EnemyActionType.attack,
        previewText: '공격',
      );
      const defend = EnemyAction(
        type: EnemyActionType.defend,
        previewText: '방어',
      );
      const observe = EnemyAction(
        type: EnemyActionType.observe,
        previewText: '관찰',
      );

      expect(attack.type, isNot(defend.type));
      expect(defend.type, isNot(observe.type));
      expect(attack.type, isNot(observe.type));
    });
  });

  group('CombatTurnData', () {
    test('creates with required fields', () {
      const turn = CombatTurnData(
        turnNumber: 1,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '적이 공격한다',
        ),
        playerChoices: [
          ChoiceData(
            id: 'attack',
            text: '공격한다',
            resultTextBlocks: ['강한 일격!'],
          ),
          ChoiceData(
            id: 'defend',
            text: '방어한다',
            resultTextBlocks: ['방어 성공!'],
          ),
        ],
      );

      expect(turn.turnNumber, 1);
      expect(turn.enemyAction.type, EnemyActionType.attack);
      expect(turn.playerChoices, hasLength(2));
    });

    test('supports 3 player choices', () {
      const turn = CombatTurnData(
        turnNumber: 2,
        enemyAction: EnemyAction(
          type: EnemyActionType.observe,
          previewText: '적이 관찰한다',
        ),
        playerChoices: [
          ChoiceData(id: 'a', text: '공격', resultTextBlocks: []),
          ChoiceData(id: 'b', text: '방어', resultTextBlocks: []),
          ChoiceData(id: 'c', text: '관찰', resultTextBlocks: []),
        ],
      );

      expect(turn.playerChoices, hasLength(3));
    });
  });

  group('CombatEncounter', () {
    test('creates with all required fields', () {
      const encounter = CombatEncounter(
        enemyName: '어둠의 수호자',
        introText: '어둠 속에서 거대한 그림자가 다가온다.',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '적이 내려친다',
            ),
            playerChoices: [
              ChoiceData(id: 'a', text: '공격', resultTextBlocks: ['일격!']),
            ],
          ),
        ],
        victoryText: '적이 쓰러진다.',
        defeatText: '패배했다.',
      );

      expect(encounter.enemyName, '어둠의 수호자');
      expect(encounter.introText, '어둠 속에서 거대한 그림자가 다가온다.');
      expect(encounter.turns, hasLength(1));
      expect(encounter.victoryText, '적이 쓰러진다.');
    });

    test('supports empty turns (0-turn combat)', () {
      const encounter = CombatEncounter(
        enemyName: '허깨비',
        introText: '허깨비가 나타났다!',
        turns: [],
        victoryText: '허깨비가 사라진다.',
        defeatText: '패배했다.',
      );

      expect(encounter.turns, isEmpty);
    });

    test('environmentClues 기본값은 빈 리스트', () {
      const encounter = CombatEncounter(
        enemyName: '테스트 적',
        introText: '적 등장',
        turns: [],
        victoryText: '승리',
        defeatText: '패배',
      );

      expect(encounter.environmentText, isNull);
      expect(encounter.environmentClues, isEmpty);
    });

    test('environmentText와 environmentClues 포함 생성', () {
      const encounter = CombatEncounter(
        enemyName: '테스트 적',
        environmentText: '낡은 석실에 발을 들인다.',
        environmentClues: [
          EnvironmentClue(
            id: 'ceiling_crack',
            description: '천장에 균열이 보인다',
            actionHint: '균열을 이용할 수 있다',
          ),
          EnvironmentClue(
            id: 'wet_floor',
            description: '바닥에 물이 고여 있다',
            actionHint: '발을 미끄러뜨릴 수 있다',
          ),
        ],
        introText: '적 등장',
        turns: [],
        victoryText: '승리',
        defeatText: '패배',
      );

      expect(encounter.environmentText, '낡은 석실에 발을 들인다.');
      expect(encounter.environmentClues, hasLength(2));
      expect(encounter.environmentClues[0].id, 'ceiling_crack');
      expect(encounter.environmentClues[1].id, 'wet_floor');
    });

    test('roomType defaults to RoomType.combat', () {
      const encounter = CombatEncounter(
        enemyName: '일반 적',
        introText: '적 등장',
        turns: [],
        victoryText: '승리',
        defeatText: '패배',
      );

      expect(encounter.roomType, RoomType.combat);
    });

    test('roomType can be set to RoomType.elite', () {
      const encounter = CombatEncounter(
        roomType: RoomType.elite,
        enemyName: '엘리트 적',
        introText: '적 등장',
        turns: [],
        victoryText: '승리',
        defeatText: '패배',
      );

      expect(encounter.roomType, RoomType.elite);
    });

    test('roomType can be set to RoomType.boss', () {
      const encounter = CombatEncounter(
        roomType: RoomType.boss,
        enemyName: '보스',
        introText: '보스 등장',
        turns: [],
        victoryText: '승리',
        defeatText: '패배',
      );

      expect(encounter.roomType, RoomType.boss);
    });

    test('supports multi-turn combat', () {
      const encounter = CombatEncounter(
        enemyName: '테스트 적',
        introText: '적 등장',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '1턴 공격',
            ),
            playerChoices: [
              ChoiceData(id: 't1a', text: '공격', resultTextBlocks: ['결과1']),
            ],
          ),
          CombatTurnData(
            turnNumber: 2,
            enemyAction: EnemyAction(
              type: EnemyActionType.defend,
              previewText: '2턴 방어',
            ),
            playerChoices: [
              ChoiceData(id: 't2a', text: '공격', resultTextBlocks: ['결과2']),
            ],
          ),
          CombatTurnData(
            turnNumber: 3,
            enemyAction: EnemyAction(
              type: EnemyActionType.observe,
              previewText: '3턴 관찰',
            ),
            playerChoices: [
              ChoiceData(id: 't3a', text: '공격', resultTextBlocks: ['결과3']),
            ],
          ),
        ],
        victoryText: '승리!',
        defeatText: '패배했다.',
      );

      expect(encounter.turns, hasLength(3));
      expect(encounter.turns[0].enemyAction.type, EnemyActionType.attack);
      expect(encounter.turns[1].enemyAction.type, EnemyActionType.defend);
      expect(encounter.turns[2].enemyAction.type, EnemyActionType.observe);
    });
  });
}
