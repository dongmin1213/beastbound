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

    // === Story 4-1: dispositionChanges 필드 ===

    test('dispositionChanges field carries String-keyed disposition data', () {
      final event = EventChoiceEvent(
        choiceLabel: '도움을 준다',
        goldChange: 10,
        hpChange: 0,
        dispositionChanges: {'mercy': 3, 'wisdom': 1},
      );

      expect(event.dispositionChanges['mercy'], 3);
      expect(event.dispositionChanges['wisdom'], 1);
      expect(event.dispositionChanges.length, 2);
    });

    test('dispositionChanges defaults to empty Map for backward compatibility', () {
      final event = EventChoiceEvent(
        choiceLabel: '무시한다',
        goldChange: 0,
        hpChange: 0,
      );

      expect(event.dispositionChanges, isEmpty);
    });
  });
}
