import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/elite_demo_encounter.dart';

void main() {
  group('EliteDemoEncounter', () {
    test('creates encounter with RoomType.elite and 5 turns', () {
      final encounter = EliteDemoEncounter.create();

      expect(encounter.roomType, RoomType.elite);
      expect(encounter.turns.length, 5);
      expect(encounter.enemyName, isNotEmpty);
      expect(encounter.introText, isNotEmpty);
      expect(encounter.victoryText, isNotEmpty);
      expect(encounter.defeatText, isNotEmpty);
      expect(encounter.environmentClues.length, 2);
    });

    test('enemy action distribution: attack 60%, defend 20%, observe 20%', () {
      final encounter = EliteDemoEncounter.create();

      final actionCounts = <EnemyActionType, int>{};
      for (final turn in encounter.turns) {
        actionCounts[turn.enemyAction.type] =
            (actionCounts[turn.enemyAction.type] ?? 0) + 1;
      }

      // 5턴: 3 attack (60%), 1 defend (20%), 1 observe (20%)
      expect(actionCounts[EnemyActionType.attack], 3);
      expect(actionCounts[EnemyActionType.defend], 1);
      expect(actionCounts[EnemyActionType.observe], 1);
    });
  });
}
