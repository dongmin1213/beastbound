import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';

void main() {
  group('CombatFlowManager.buildEnvironmentChoices', () {
    test('2개 단서 → 2개 선택지 생성', () {
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

      final choices = CombatFlowManager.buildEnvironmentChoices(clues);

      expect(choices, hasLength(2));
    });

    test('빈 단서 → 빈 리스트', () {
      final choices =
          CombatFlowManager.buildEnvironmentChoices(const []);

      expect(choices, isEmpty);
    });

    test('선택지 id/text/actionType 형식 검증', () {
      const clues = [
        EnvironmentClue(
          id: 'ceiling_crack',
          description: '천장에 균열이 보인다',
          actionHint: '균열을 이용할 수 있다',
        ),
      ];

      final choices = CombatFlowManager.buildEnvironmentChoices(clues);

      expect(choices.first.id, 'env_ceiling_crack');
      expect(choices.first.text, '🌿 균열을 이용할 수 있다');
      expect(choices.first.actionType, ActionType.environment.name);
      expect(choices.first.resultTextBlocks, isEmpty);
    });
  });
}
