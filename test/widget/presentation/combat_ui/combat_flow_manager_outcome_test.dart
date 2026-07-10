import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_result_calculator.dart';

void main() {
  const encounter = CombatEncounter(
    enemyName: '적',
    introText: '적 등장',
    turns: [],
    victoryText: '적이 쓰러졌다!',
    defeatText: '당신이 쓰러졌다...',
  );

  group('CombatFlowManager.buildOutcomeBlock', () {
    test('victory: 텍스트에 "✦ 승리" 접두사 + victoryText 포함', () {
      final result = CombatResultScore(
        score: 2,
        outcome: CombatOutcome.victory,
        turnResults: const ['effective', 'effective'],
      );

      final block = CombatFlowManager.buildOutcomeBlock(encounter, result);

      expect(block.text, contains('✦ 승리 — 적이 쓰러졌다!'));
      expect(block.text, contains('[2턴: 유효 2회]'));
      expect(block.blockType, TextBlockType.combatOutcome);
    });

    test('defeat: 텍스트에 "✧ 패배" 접두사 + defeatText 포함', () {
      final result = CombatResultScore(
        score: -2,
        outcome: CombatOutcome.defeat,
        turnResults: const ['ineffective', 'ineffective'],
      );

      final block = CombatFlowManager.buildOutcomeBlock(encounter, result);

      expect(block.text, contains('✧ 패배 — 당신이 쓰러졌다...'));
      expect(block.text, contains('[2턴: 빗나감 2회]'));
      expect(block.blockType, TextBlockType.combatOutcome);
    });

    test('victory metadata: combatPhase=end, combatOutcome=victory, resultScore', () {
      final result = CombatResultScore(
        score: 1,
        outcome: CombatOutcome.victory,
        turnResults: const ['effective', 'neutral'],
      );

      final block = CombatFlowManager.buildOutcomeBlock(encounter, result);

      expect(block.metadata?['combatPhase'], 'end');
      expect(block.metadata?['combatOutcome'], 'victory');
      expect(block.metadata?['resultScore'], 1);
      expect(block.metadata?['turnResults'], ['effective', 'neutral']);
    });

    test('defeat metadata: combatPhase=end, combatOutcome=defeat, resultScore', () {
      final result = CombatResultScore(
        score: -1,
        outcome: CombatOutcome.defeat,
        turnResults: const ['ineffective'],
      );

      final block = CombatFlowManager.buildOutcomeBlock(encounter, result);

      expect(block.metadata?['combatPhase'], 'end');
      expect(block.metadata?['combatOutcome'], 'defeat');
      expect(block.metadata?['resultScore'], -1);
      expect(block.metadata?['turnResults'], ['ineffective']);
    });
  });

  group('CombatFlowManager._buildBlocks combatOutcome', () {
    test('마지막 블록이 combatOutcome blockType', () {
      final blocks = CombatFlowManager.toTextBlocks(encounter);
      expect(blocks.last.blockType, TextBlockType.combatOutcome);
    });

    test('마지막 블록 metadata에 combatOutcome: pending', () {
      final blocks = CombatFlowManager.toTextBlocks(encounter);
      expect(blocks.last.metadata?['combatOutcome'], 'pending');
      expect(blocks.last.metadata?['combatPhase'], 'end');
    });

    test('toDynamicTextBlocks도 마지막 블록이 combatOutcome', () {
      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      expect(blocks.last.blockType, TextBlockType.combatOutcome);
      expect(blocks.last.metadata?['combatOutcome'], 'pending');
    });
  });
}
