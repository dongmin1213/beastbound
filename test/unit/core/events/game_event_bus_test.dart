import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';

final class TestEvent extends GameEvent {}

final class OtherEvent extends GameEvent {}

void main() {
  late GameEventBus bus;

  setUp(() {
    bus = GameEventBus();
  });

  tearDown(() {
    bus.dispose();
  });

  group('GameEventBus', () {
    test('emits events to subscribers', () async {
      final events = <GameEvent>[];
      bus.on<TestEvent>().listen(events.add);

      bus.emit(TestEvent());
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first, isA<TestEvent>());
    });

    test('filters events by type', () async {
      final testEvents = <GameEvent>[];
      bus.on<TestEvent>().listen(testEvents.add);

      bus.emit(TestEvent());
      bus.emit(OtherEvent());
      await Future<void>.delayed(Duration.zero);

      expect(testEvents, hasLength(1));
    });

    test('maintains history up to 50 events', () {
      for (int i = 0; i < 60; i++) {
        bus.emit(TestEvent());
      }
      expect(bus.history, hasLength(50));
    });
  });
}
