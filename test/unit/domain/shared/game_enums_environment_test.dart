import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('ActionType.environment', () {
    test('environment displayName은 "환경활용"이다', () {
      expect(ActionType.environment.displayName, '환경활용');
    });

    test('ActionType.values는 5개이다 (attack, defend, observe, environment, special)', () {
      expect(ActionType.values.length, 5);
      expect(ActionType.values, contains(ActionType.attack));
      expect(ActionType.values, contains(ActionType.defend));
      expect(ActionType.values, contains(ActionType.observe));
      expect(ActionType.values, contains(ActionType.environment));
      expect(ActionType.values, contains(ActionType.special));
    });

    test('environment name으로 firstWhere 역변환 가능', () {
      final env = ActionType.values.firstWhere((e) => e.name == 'environment');
      expect(env, ActionType.environment);
    });
  });
}
