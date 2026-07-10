import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/input/game_input_mapper.dart';
import 'package:soul_dungeon/core/input/input_context.dart';

void main() {
  late GameInputMapper mapper;

  setUp(() {
    mapper = GameInputMapper();
  });

  group('GameInputMapper - textInteraction', () {
    test('tap during animation returns SkipText', () {
      mapper.isTextAnimating = true;
      final action = mapper.mapGesture(GameGesture.tap);
      expect(action, isA<SkipText>());
    });

    test('tap after animation returns AdvanceText', () {
      mapper.isTextAnimating = false;
      final action = mapper.mapGesture(GameGesture.tap);
      expect(action, isA<AdvanceText>());
    });

    test('longPress returns NoAction', () {
      final action = mapper.mapGesture(GameGesture.longPress);
      expect(action, isA<NoAction>());
    });
  });

  group('GameInputMapper - other contexts return NoAction', () {
    test('combat tap returns NoAction', () {
      mapper.currentContext = InputContext.combat;
      final action = mapper.mapGesture(GameGesture.tap);
      expect(action, isA<NoAction>());
    });

    test('exploration tap returns NoAction', () {
      mapper.currentContext = InputContext.exploration;
      final action = mapper.mapGesture(GameGesture.tap);
      expect(action, isA<NoAction>());
    });
  });
}
