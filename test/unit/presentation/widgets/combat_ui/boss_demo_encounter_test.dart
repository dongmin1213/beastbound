import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/boss_demo_encounter.dart';

void main() {
  group('BossDemoEncounter', () {
    test('create: roomType.boss, 2 bossPhases, phase1 3턴, phase2 4턴', () {
      final encounter = BossDemoEncounter.create();

      expect(encounter.roomType, RoomType.boss);
      expect(encounter.enemyName, '심연의 수호자');
      expect(encounter.bossPhases, isNotNull);
      expect(encounter.bossPhases, hasLength(2));
      expect(encounter.bossPhases![0].turns, hasLength(3));
      expect(encounter.bossPhases![1].turns, hasLength(4));
      // turns == phase1 turns (호환)
      expect(encounter.turns, hasLength(3));
      // 퍼마데스 경고 포함
      expect(encounter.introText, contains('돌아올 수 없다'));
      // 전환 텍스트
      expect(encounter.bossPhases![0].transitionText, isNotNull);
      expect(encounter.bossPhases![1].transitionText, isNull);
    });
  });
}
