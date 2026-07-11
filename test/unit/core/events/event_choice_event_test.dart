import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/event_choice_event.dart';

void main() {
  group('EventChoiceEvent', () {
    test('creation and field verification', () {
      final event = EventChoiceEvent(
        choiceLabel: '도움을 준다',
        goldChange: 10,
        hpChange: -5,
      );

      expect(event.choiceLabel, '도움을 준다');
      expect(event.goldChange, 10);
      expect(event.hpChange, -5);
    });
  });
}
