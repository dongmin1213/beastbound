import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/environment_clue.dart';

void main() {
  group('EnvironmentClue', () {
    test('생성자 기본값 — 필드가 올바르게 설정된다', () {
      const clue = EnvironmentClue(
        id: 'ceiling_crack',
        description: '천장이 낮고 균열이 보인다',
        actionHint: '천장의 균열을 이용할 수 있을 것 같다',
      );

      expect(clue.id, 'ceiling_crack');
      expect(clue.description, '천장이 낮고 균열이 보인다');
      expect(clue.actionHint, '천장의 균열을 이용할 수 있을 것 같다');
    });

    test('Equatable 동등성 — 동일 필드 값이면 같다', () {
      const clue1 = EnvironmentClue(
        id: 'wet_floor',
        description: '바닥에 물이 고여 있다',
        actionHint: '발을 미끄러뜨릴 수 있다',
      );
      const clue2 = EnvironmentClue(
        id: 'wet_floor',
        description: '바닥에 물이 고여 있다',
        actionHint: '발을 미끄러뜨릴 수 있다',
      );

      expect(clue1, equals(clue2));
    });

    test('Equatable 비동등성 — id가 다르면 다르다', () {
      const clue1 = EnvironmentClue(
        id: 'ceiling_crack',
        description: '천장이 낮고 균열이 보인다',
        actionHint: '균열을 이용할 수 있다',
      );
      const clue2 = EnvironmentClue(
        id: 'wet_floor',
        description: '천장이 낮고 균열이 보인다',
        actionHint: '균열을 이용할 수 있다',
      );

      expect(clue1, isNot(equals(clue2)));
    });

    test('props 리스트 — id, description, actionHint 포함', () {
      const clue = EnvironmentClue(
        id: 'vine_wall',
        description: '벽면에 덩굴이 있다',
        actionHint: '덩굴을 잡아당길 수 있다',
      );

      expect(clue.props, [
        'vine_wall',
        '벽면에 덩굴이 있다',
        '덩굴을 잡아당길 수 있다',
      ]);
    });
  });
}
