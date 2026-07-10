import 'package:soul_dungeon/core/input/input_context.dart';

class GameInputMapper {
  InputContext currentContext = InputContext.textInteraction;
  bool isTextAnimating = false;

  InputAction mapGesture(GameGesture gesture) {
    return switch ((currentContext, gesture)) {
      (InputContext.textInteraction, GameGesture.tap) =>
        isTextAnimating ? const SkipText() : const AdvanceText(),
      (InputContext.textInteraction, GameGesture.longPress) =>
        const NoAction(),
      (InputContext.combat, _) => const NoAction(),
      (InputContext.exploration, _) => const NoAction(),
    };
  }
}
