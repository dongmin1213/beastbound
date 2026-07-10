import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';

void main() {
  group('CardPool 캐싱 최적화', () {
    test('allCards는 동일 참조 반환 (late final 캐싱)', () {
      final first = CardPool.allCards;
      final second = CardPool.allCards;
      expect(identical(first, second), isTrue);
    });

    test('findById → 존재하는 카드 반환', () {
      final card = CardPool.findById('starter_strike_1');
      expect(card, isNotNull);
      expect(card!.id, 'starter_strike_1');
    });

    test('findById → 존재하지 않는 카드 null', () {
      final card = CardPool.findById('nonexistent_card_xyz');
      expect(card, isNull);
    });

    test('allCards 내 모든 카드 ID가 유일함', () {
      final allCards = CardPool.allCards;
      final uniqueIds = allCards.map((c) => c.id).toSet();
      expect(uniqueIds.length, allCards.length);
    });

    test('findById는 allCards 목록과 일관적 결과 반환', () {
      for (final card in CardPool.allCards) {
        final found = CardPool.findById(card.id);
        expect(found, isNotNull, reason: '카드 ${card.id}를 findById로 찾을 수 없음');
        expect(identical(found, card), isTrue,
            reason: '카드 ${card.id} findById 결과가 allCards와 다른 인스턴스');
      }
    });
  });

  group('GameEventBus history 캐싱 최적화', () {
    late GameEventBus bus;

    setUp(() {
      bus = GameEventBus();
    });

    tearDown(() {
      bus.dispose();
    });

    test('이벤트 없을 때 history는 동일 참조', () {
      final h1 = bus.history;
      final h2 = bus.history;
      expect(identical(h1, h2), isTrue);
    });

    test('emit 후 history 캐시 무효화', () {
      final h1 = bus.history;
      bus.emit(GoldGainedEvent(amount: 10, totalGold: 10));
      final h2 = bus.history;
      expect(identical(h1, h2), isFalse);
    });

    test('emit 없이 연속 호출은 캐시 유지', () {
      bus.emit(FloorCompletedEvent(floorNumber: 1));
      final h1 = bus.history;
      final h2 = bus.history;
      final h3 = bus.history;
      expect(identical(h1, h2), isTrue);
      expect(identical(h2, h3), isTrue);
    });

    test('emit 후 새 history에 이벤트 포함', () {
      bus.emit(GoldGainedEvent(amount: 5, totalGold: 5));
      final history = bus.history;
      expect(history.length, 1);
      expect(history.first, isA<GoldGainedEvent>());
    });

    test('history 크기 상한 50 적용', () {
      for (var i = 0; i < 60; i++) {
        bus.emit(GoldGainedEvent(amount: i, totalGold: i));
      }
      final history = bus.history;
      expect(history.length, 50);
      // 가장 오래된 10개가 제거되어 첫 항목은 amount=10
      final first = history.first as GoldGainedEvent;
      expect(first.amount, 10);
    });

    test('각 emit마다 캐시 무효화 발생', () {
      bus.emit(GoldGainedEvent(amount: 1, totalGold: 1));
      final h1 = bus.history;

      bus.emit(FloorCompletedEvent(floorNumber: 2));
      final h2 = bus.history;

      expect(identical(h1, h2), isFalse);
      expect(h2.length, 2);
    });
  });

}
