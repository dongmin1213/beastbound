import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/run_completed_event.dart';

void main() {
  group('FloorCompletedEvent', () {
    test('GameEvent 상속 + 필드 확인', () {
      final event = FloorCompletedEvent(floorNumber: 3);
      expect(event, isA<GameEvent>());
      expect(event.floorNumber, 3);
      expect(event.timestamp, isNotNull);
    });

    test('GameEventBus 발행/수신', () async {
      final bus = GameEventBus();
      addTearDown(bus.dispose);

      final future = bus.on<FloorCompletedEvent>().first;
      bus.emit(FloorCompletedEvent(floorNumber: 2));
      final received = await future;
      expect(received.floorNumber, 2);
    });
  });

  group('RunCompletedEvent', () {
    test('GameEvent 상속 + 필드 확인', () {
      final event = RunCompletedEvent(totalFloors: 5);
      expect(event, isA<GameEvent>());
      expect(event.totalFloors, 5);
      expect(event.timestamp, isNotNull);
    });

    test('GameEventBus 발행/수신', () async {
      final bus = GameEventBus();
      addTearDown(bus.dispose);

      final future = bus.on<RunCompletedEvent>().first;
      bus.emit(RunCompletedEvent(totalFloors: 5));
      final received = await future;
      expect(received.totalFloors, 5);
    });

    test('히스토리에 저장', () {
      final bus = GameEventBus();
      addTearDown(bus.dispose);

      bus.emit(FloorCompletedEvent(floorNumber: 1));
      bus.emit(FloorCompletedEvent(floorNumber: 2));
      bus.emit(RunCompletedEvent(totalFloors: 5));

      final floorEvents = bus.history.whereType<FloorCompletedEvent>().toList();
      final runEvents = bus.history.whereType<RunCompletedEvent>().toList();

      expect(floorEvents.length, 2);
      expect(runEvents.length, 1);
    });
  });
}
