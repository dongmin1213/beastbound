import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('ActionType', () {
    test('values 5개 확인 (attack, defend, observe, environment, special)', () {
      expect(ActionType.values.length, 5);
      expect(ActionType.values, contains(ActionType.attack));
      expect(ActionType.values, contains(ActionType.defend));
      expect(ActionType.values, contains(ActionType.observe));
      expect(ActionType.values, contains(ActionType.environment));
      expect(ActionType.values, contains(ActionType.special));
    });

    test('각 displayName 정확성', () {
      expect(ActionType.attack.displayName, '공격');
      expect(ActionType.defend.displayName, '방어');
      expect(ActionType.observe.displayName, '관찰');
      expect(ActionType.environment.displayName, '환경활용');
    });

    test('name getter 문자열 확인', () {
      expect(ActionType.attack.name, 'attack');
      expect(ActionType.defend.name, 'defend');
      expect(ActionType.observe.name, 'observe');
    });

    test('values.firstWhere로 name 역변환 확인', () {
      final attack = ActionType.values.firstWhere((e) => e.name == 'attack');
      expect(attack, ActionType.attack);

      final defend = ActionType.values.firstWhere((e) => e.name == 'defend');
      expect(defend, ActionType.defend);

      final observe = ActionType.values.firstWhere((e) => e.name == 'observe');
      expect(observe, ActionType.observe);
    });
  });
}
