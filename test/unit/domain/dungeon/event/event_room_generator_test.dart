import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_generator.dart';

void main() {
  group('EventRoomGenerator', () {
    test('same seed produces same deterministic event', () {
      const config = EventConfig();
      final result1 = EventRoomGenerator.generate(
        floor: 1,
        eventConfig: config,
        seed: 42,
      );
      final result2 = EventRoomGenerator.generate(
        floor: 1,
        eventConfig: config,
        seed: 42,
      );

      expect(result1, equals(result2));
      expect(result1.title, equals(result2.title));
      expect(result1.choices.length, equals(result2.choices.length));
    });

    test('EventConfig values are reflected in generated events', () {
      const customConfig = EventConfig(
        goldReward: 20,
        hpReward: 15,
        hpPenalty: 8,
      );

      // 모든 시드(0~2)에 대해 생성하여 EventConfig 값 반영 확인
      final allEvents = <EventRoomData>[];
      for (int seed = 0; seed < 100; seed++) {
        allEvents.add(EventRoomGenerator.generate(
          floor: 1,
          eventConfig: customConfig,
          seed: seed,
        ));
      }

      // "길을 잃은 여행자" 이벤트 찾기 — 도움 선택지의 goldChange가 customConfig.goldReward
      final travelerEvents = allEvents.where(
        (e) => e.title == '길을 잃은 여행자',
      );
      expect(travelerEvents, isNotEmpty);
      final traveler = travelerEvents.first;

      // 도움: +goldReward
      expect(traveler.choices[0].goldChange, 20);
      // 약탈: +(goldReward*1.5).round()
      expect(traveler.choices[2].goldChange, 30);
      // 약탈: -hpPenalty
      expect(traveler.choices[2].hpChange, -8);

      // "깨진 제단" 이벤트 찾기
      final altarEvents = allEvents.where(
        (e) => e.title == '깨진 제단',
      );
      expect(altarEvents, isNotEmpty);
      final altar = altarEvents.first;

      // 기도: +hpReward, -(goldReward/2).round()
      expect(altar.choices[0].hpChange, 15);
      expect(altar.choices[0].goldChange, -10);
    });

    // === Story 4-1: dispositionRewards 검증 ===

  });
}
