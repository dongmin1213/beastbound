abstract class GameClock {
  DateTime now();
  Duration elapsed(DateTime from);
}

class SystemClock implements GameClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  Duration elapsed(DateTime from) => now().difference(from);
}
