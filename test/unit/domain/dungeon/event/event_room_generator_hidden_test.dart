import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_generator.dart';

void main() {
  const config = EventConfig();

  group('EventRoomGenerator hidden events', () {
    // Test: floor 1, no memory, no curses → only 15 base events possible
    // (기존 12 + 갈림길의 석상/독 웅덩이/잠든 야수)
    test('floor 1 has no hidden events', () {
      final titles = <String>{};
      for (var seed = 0; seed < 100; seed++) {
        final event = EventRoomGenerator.generate(
          floor: 1,
          eventConfig: config,
          seed: seed,
        );
        titles.add(event.title);
      }
      // 기존 hidden events
      expect(titles.contains('차원의 균열'), isFalse);
      expect(titles.contains('잊혀진 제단'), isFalse);
      expect(titles.contains('시간의 방'), isFalse);
      expect(titles.contains('야성의 거울'), isFalse);
      expect(titles.contains('사신의 문'), isFalse);
      expect(titles.contains('환영의 미궁'), isFalse);
      // 신규 hidden events (2층+ 조건)
      expect(titles.contains('기억의 우물'), isFalse);
      expect(titles.contains('피의 계약서'), isFalse);
      expect(titles.contains('전이의 회랑'), isFalse);
      expect(titles.contains('속삭이는 벽'), isFalse);
    });

    // Test: floor 3, memoryCount 3 → 차원의 균열 can appear + 시간의 방 + 사신의 문 + 환영의 미궁
    test('floor 3 with memory 3 includes hidden events', () {
      final titles = <String>{};
      for (var seed = 0; seed < 200; seed++) {
        final event = EventRoomGenerator.generate(
          floor: 3,
          eventConfig: config,
          seed: seed,
          unlockedMemoryCount: 3,
        );
        titles.add(event.title);
      }
      // These should be possible now
      expect(titles.length, greaterThan(15)); // More than base pool
    });

    // Test: hasCurses → 잊혀진 제단 can appear
    test('hasCurses enables 잊혀진 제단', () {
      final titles = <String>{};
      for (var seed = 0; seed < 200; seed++) {
        final event = EventRoomGenerator.generate(
          floor: 1,
          eventConfig: config,
          seed: seed,
          hasCurses: true,
        );
        titles.add(event.title);
      }
      expect(titles.contains('잊혀진 제단'), isTrue);
    });

    // Test: floor 4 enables 야성의 거울
    test('floor 4 enables 야성의 거울', () {
      final titles = <String>{};
      for (var seed = 0; seed < 200; seed++) {
        final event = EventRoomGenerator.generate(
          floor: 4,
          eventConfig: config,
          seed: seed,
          unlockedMemoryCount: 5,
        );
        titles.add(event.title);
      }
      expect(titles.contains('야성의 거울'), isTrue);
    });

    // Test: floor 3 WITHOUT enough memory → no 차원의 균열
    test('memory < 3 prevents 차원의 균열', () {
      final titles = <String>{};
      for (var seed = 0; seed < 200; seed++) {
        final event = EventRoomGenerator.generate(
          floor: 3,
          eventConfig: config,
          seed: seed,
          unlockedMemoryCount: 2, // < 3
        );
        titles.add(event.title);
      }
      expect(titles.contains('차원의 균열'), isFalse);
    });

    // Test: each hidden event has correct choice count (2 each)
    // Find a seed that generates each hidden event
    test('hidden events have 2 choices each', () {
      // Try to find seeds for each hidden event at floor 4 with all conditions
      final hiddenTitles = [
        '차원의 균열',
        '잊혀진 제단',
        '시간의 방',
        '야성의 거울',
        '사신의 문',
        '환영의 미궁'
      ];

      for (var seed = 0; seed < 500; seed++) {
        final event = EventRoomGenerator.generate(
          floor: 4,
          eventConfig: config,
          seed: seed,
          unlockedMemoryCount: 5,
          hasCurses: true,
        );
        if (hiddenTitles.contains(event.title)) {
          expect(
            event.choices.length,
            greaterThanOrEqualTo(2),
            reason: '${event.title} should have at least 2 choices',
          );
        }
      }
    });

    // Test: default params (backward compatible) → same as before
    test('default params backward compatible', () {
      final event1 = EventRoomGenerator.generate(
        floor: 1,
        eventConfig: config,
        seed: 42,
      );
      final event2 = EventRoomGenerator.generate(
        floor: 1,
        eventConfig: config,
        seed: 42,
        unlockedMemoryCount: 0,
        hasCurses: false,
      );
      expect(event1.title, event2.title);
    });
  });
}
