import 'package:flutter/foundation.dart';
import 'package:soul_dungeon/core/clock/clock.dart';

abstract class GameEvent {
  static GameClock _clock = const SystemClock();

  @visibleForTesting
  static void overrideClock(GameClock clock) => _clock = clock;

  @visibleForTesting
  static void resetClock() => _clock = const SystemClock();

  final DateTime timestamp;

  GameEvent() : timestamp = _clock.now();
}
