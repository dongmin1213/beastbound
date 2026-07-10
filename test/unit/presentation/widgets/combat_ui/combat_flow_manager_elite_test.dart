import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

CombatEncounter _makeEncounter({RoomType roomType = RoomType.combat}) {
  return CombatEncounter(
    roomType: roomType,
    enemyName: '테스트 적',
    introText: '적이 나타났다.',
    turns: [
      const CombatTurnData(
        turnNumber: 1,
        enemyAction: EnemyAction(
          type: EnemyActionType.attack,
          previewText: '적이 공격한다',
        ),
        playerChoices: [
          ChoiceData(id: 'a', text: '공격', resultTextBlocks: []),
        ],
      ),
    ],
    victoryText: '승리!',
    defeatText: '패배!',
  );
}

void main() {
  group('CombatFlowManager elite support', () {
    test('elite encounter inserts eliteWarning block before intro', () {
      final blocks = CombatFlowManager.toDynamicTextBlocks(
        _makeEncounter(roomType: RoomType.elite),
      );

      // 첫 번째 블록이 eliteWarning 메타데이터를 가져야 함
      expect(blocks.isNotEmpty, isTrue);
      final warningBlock = blocks.first;
      expect(warningBlock.blockType, TextBlockType.normal);
      expect(warningBlock.metadata?['eliteWarning'], isTrue);
    });

    test('elite warning block appears before intro text', () {
      final blocks = CombatFlowManager.toDynamicTextBlocks(
        _makeEncounter(roomType: RoomType.elite),
      );

      // warning → intro 순서 확인
      final warningIndex = blocks.indexWhere(
        (b) => b.metadata?['eliteWarning'] == true,
      );
      final introIndex = blocks.indexWhere(
        (b) => b.text == '적이 나타났다.',
      );

      expect(warningIndex, lessThan(introIndex));
    });

    test('normal combat does not include eliteWarning block', () {
      final blocks = CombatFlowManager.toDynamicTextBlocks(
        _makeEncounter(roomType: RoomType.combat),
      );

      final hasWarning = blocks.any(
        (b) => b.metadata?['eliteWarning'] == true,
      );
      expect(hasWarning, isFalse);
    });

    test('elite warning text contains narrative content', () {
      final blocks = CombatFlowManager.toDynamicTextBlocks(
        _makeEncounter(roomType: RoomType.elite),
      );

      final warningBlock = blocks.firstWhere(
        (b) => b.metadata?['eliteWarning'] == true,
      );
      expect(warningBlock.text.isNotEmpty, isTrue);
    });
  });
}
