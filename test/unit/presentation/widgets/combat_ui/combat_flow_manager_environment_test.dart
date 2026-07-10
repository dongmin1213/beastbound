import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

void main() {
  const clues = [
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
  ];

  CombatEncounter makeEncounter({
    String? environmentText,
    List<EnvironmentClue> environmentClues = const [],
  }) {
    return CombatEncounter(
      enemyName: '테스트 적',
      environmentText: environmentText,
      environmentClues: environmentClues,
      introText: '적이 나타났다.',
      turns: const [
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
      defeatText: '패배...',
    );
  }

  group('CombatFlowManager 환경 서술 블록', () {
    test('toDynamicTextBlocks: environmentText 있을 때 첫 블록이 environmentNarration', () {
      final encounter = makeEncounter(
        environmentText: '낡은 석실에 들어선다.',
        environmentClues: clues,
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);

      expect(blocks.first.blockType, TextBlockType.environmentNarration);
      expect(blocks.first.text, '낡은 석실에 들어선다.');
    });

    test('toDynamicTextBlocks: environmentText null일 때 첫 블록이 introText(normal)', () {
      final encounter = makeEncounter();

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);

      expect(blocks.first.blockType, TextBlockType.normal);
      expect(blocks.first.text, '적이 나타났다.');
    });

    test('toTextBlocks: environmentText 있을 때 환경 블록 포함', () {
      final encounter = makeEncounter(
        environmentText: '어둡고 습한 공간이다.',
        environmentClues: clues,
      );

      final blocks = CombatFlowManager.toTextBlocks(encounter);

      expect(blocks.first.blockType, TextBlockType.environmentNarration);
      expect(blocks[1].blockType, TextBlockType.normal); // introText
    });

    test('환경 블록 메타데이터에 List<EnvironmentClue> 직접 포함', () {
      final encounter = makeEncounter(
        environmentText: '석실에 들어선다.',
        environmentClues: clues,
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
      final envBlock = blocks.first;

      expect(envBlock.metadata, isNotNull);
      final storedClues =
          envBlock.metadata!['environmentClues'] as List<EnvironmentClue>;
      expect(storedClues, hasLength(2));
      expect(storedClues[0].id, 'ceiling_crack');
      expect(storedClues[1].id, 'wet_floor');
    });

    test('environmentText null이고 environmentClues 있음(비정상) → 환경 블록 미생성', () {
      final encounter = makeEncounter(
        environmentText: null,
        environmentClues: clues,
      );

      final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);

      // 환경 블록 없어야 함 — environmentText가 게이트
      expect(
        blocks.where((b) => b.blockType == TextBlockType.environmentNarration),
        isEmpty,
      );
      expect(blocks.first.blockType, TextBlockType.normal);
    });
  });
}
