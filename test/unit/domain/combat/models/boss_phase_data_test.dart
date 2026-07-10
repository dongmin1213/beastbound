import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/models/boss_phase_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_encounter_data.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';

void main() {
  group('BossPhaseData', () {
    test('생성 및 Equatable props 검증', () {
      const phase = BossPhaseData(
        phaseName: 'phase1',
        turns: [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
          CombatTurnInfo(turnNumber: 2, enemyAction: EnemyActionType.defend),
        ],
      );

      expect(phase.phaseName, 'phase1');
      expect(phase.turns, hasLength(2));

      const same = BossPhaseData(
        phaseName: 'phase1',
        turns: [
          CombatTurnInfo(turnNumber: 1, enemyAction: EnemyActionType.attack),
          CombatTurnInfo(turnNumber: 2, enemyAction: EnemyActionType.defend),
        ],
      );

      expect(phase, equals(same));
    });
  });
}
