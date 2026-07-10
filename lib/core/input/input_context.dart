enum InputContext {
  textInteraction,
  combat,
  exploration,
}

enum GameGesture {
  tap,
  longPress,
}

sealed class InputAction {
  const InputAction();
}

final class SkipText extends InputAction {
  const SkipText();
}

final class AdvanceText extends InputAction {
  const AdvanceText();
}

final class NoAction extends InputAction {
  const NoAction();
}
