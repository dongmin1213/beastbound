import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_generator.dart';

void main() {
  group('EventRoomGenerator extended pool', () {
    const eventConfig = EventConfig();

    /// 모든 시드(0~999)를 돌려 유니크 이벤트 타이틀 수집.
    List<EventRoomData> collectAllUniqueEvents() {
      final seen = <String>{};
      final unique = <EventRoomData>[];
      for (int seed = 0; seed < 1000; seed++) {
        final event = EventRoomGenerator.generate(
          floor: 1,
          eventConfig: eventConfig,
          seed: seed,
        );
        if (seen.add(event.title)) {
          unique.add(event);
        }
      }
      return unique;
    }

    test('event pool contains 19 unique events', () {
      final unique = collectAllUniqueEvents();
      expect(unique.length, 19);
    });

    test('card reward events exist (cardRewardId != null)', () {
      final unique = collectAllUniqueEvents();
      final cardRewardEvents = unique.where((e) =>
          e.choices.any((c) => c.cardRewardId != null));
      expect(cardRewardEvents, isNotEmpty,
          reason: 'At least one event should offer a card reward');
    });

    test('card remove events exist (removeRandomCard == true)', () {
      final unique = collectAllUniqueEvents();
      final removeEvents = unique.where((e) =>
          e.choices.any((c) => c.removeRandomCard));
      expect(removeEvents, isNotEmpty,
          reason: 'At least one event should remove a random card');
    });

    test('card upgrade events exist (upgradeRandomCard == true)', () {
      final unique = collectAllUniqueEvents();
      final upgradeEvents = unique.where((e) =>
          e.choices.any((c) => c.upgradeRandomCard));
      expect(upgradeEvents, isNotEmpty,
          reason: 'At least one event should upgrade a random card');
    });

    test('same seed produces same event (deterministic)', () {
      final event1 = EventRoomGenerator.generate(
        floor: 1,
        eventConfig: eventConfig,
        seed: 777,
      );
      final event2 = EventRoomGenerator.generate(
        floor: 1,
        eventConfig: eventConfig,
        seed: 777,
      );

      expect(event1, equals(event2));
      expect(event1.title, equals(event2.title));
      expect(event1.choices.length, equals(event2.choices.length));
    });

    test('all events have at least 2 choices', () {
      final unique = collectAllUniqueEvents();
      for (final event in unique) {
        expect(event.choices.length, greaterThanOrEqualTo(2),
            reason: '${event.title} should have >= 2 choices');
      }
    });

    test('original 3 events are preserved unchanged', () {
      final unique = collectAllUniqueEvents();
      final titles = unique.map((e) => e.title).toSet();
      expect(titles, contains('길을 잃은 여행자'));
      expect(titles, contains('깨진 제단'));
      expect(titles, contains('수상한 상인'));
    });

    test('new events 4~12 are present', () {
      final unique = collectAllUniqueEvents();
      final titles = unique.map((e) => e.title).toSet();
      expect(titles, contains('고대 무기고'));
      expect(titles, contains('저주받은 카드'));
      expect(titles, contains('은둔 스승'));
      expect(titles, contains('잊혀진 보물상자'));
      expect(titles, contains('생명의 샘'));
      expect(titles, contains('전사의 유령'));
      expect(titles, contains('붕괴하는 길'));
      expect(titles, contains('이상한 거래'));
      expect(titles, contains('수정 동굴'));
    });

    test('고대 무기고 — upgradeRandomCard choice', () {
      final unique = collectAllUniqueEvents();
      final event = unique.firstWhere((e) => e.title == '고대 무기고');
      final upgradeChoice = event.choices
          .firstWhere((c) => c.upgradeRandomCard);
      expect(upgradeChoice.label, '무기를 수련한다');
    });

    test('저주받은 카드 — removeRandomCard + cardRewardId choices', () {
      final unique = collectAllUniqueEvents();
      final event = unique.firstWhere((e) => e.title == '저주받은 카드');

      final removeChoice = event.choices
          .firstWhere((c) => c.removeRandomCard);
      expect(removeChoice.label, '카드를 버린다');

      final rewardChoice = event.choices
          .firstWhere((c) => c.cardRewardId != null);
      expect(rewardChoice.hpChange, -10);
      expect(rewardChoice.cardRewardId, 'colorless_random');
    });

    test('이상한 거래 — removeRandomCard + cardRewardId combined', () {
      final unique = collectAllUniqueEvents();
      final event = unique.firstWhere((e) => e.title == '이상한 거래');

      final exchangeChoice = event.choices
          .firstWhere((c) => c.removeRandomCard && c.cardRewardId != null);
      expect(exchangeChoice.label, '카드를 교환한다');
      expect(exchangeChoice.cardRewardId, 'colorless_random');
    });
  });
}
