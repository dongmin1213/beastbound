import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/boss_choice_event.dart';

void main() {
  test('BossChoiceEvent stores fields correctly', () {
    final event = BossChoiceEvent(
      floor: 1,
      bossId: 'boss_slime_king',
      choiceType: 'slay',
      playerJobId: 'warrior',
    );

    expect(event.floor, 1);
    expect(event.bossId, 'boss_slime_king');
    expect(event.choiceType, 'slay');
    expect(event.playerJobId, 'warrior');
    expect(event.timestamp, isNotNull);
  });

  test('BossChoiceEvent with null playerJobId', () {
    final event = BossChoiceEvent(
      floor: 3,
      bossId: 'boss_orc_general',
      choiceType: 'liberate',
    );

    expect(event.floor, 3);
    expect(event.bossId, 'boss_orc_general');
    expect(event.choiceType, 'liberate');
    expect(event.playerJobId, isNull);
  });

  test('BossChoiceEvent with coexist choice', () {
    final event = BossChoiceEvent(
      floor: 5,
      bossId: 'boss_dungeon_master',
      choiceType: 'coexist',
      playerJobId: 'sage',
    );

    expect(event.choiceType, 'coexist');
    expect(event.playerJobId, 'sage');
  });
}
