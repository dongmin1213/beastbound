import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_generator.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

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

    test('demo events have dispositionRewards', () {
      const config = EventConfig();
      const dConfig = DispositionConfig();

      final allEvents = <EventRoomData>[];
      for (int seed = 0; seed < 100; seed++) {
        allEvents.add(EventRoomGenerator.generate(
          floor: 1,
          eventConfig: config,
          dispositionConfig: dConfig,
          seed: seed,
        ));
      }

      // "길을 잃은 여행자" — 도움: mercy=4 (eventMajorReward 기본값)
      final traveler = allEvents.firstWhere((e) => e.title == '길을 잃은 여행자');
      expect(traveler.choices[0].dispositionRewards[DispositionAxis.mercy], 4);
      // 무시: shadow=1
      expect(traveler.choices[1].dispositionRewards[DispositionAxis.shadow], 1);
      // 약탈: shadow=4, struggle=1
      expect(traveler.choices[2].dispositionRewards[DispositionAxis.shadow], 4);
      expect(traveler.choices[2].dispositionRewards[DispositionAxis.struggle], 1);

      // "깨진 제단" — 기도: mercy=2, wisdom=1
      final altar = allEvents.firstWhere((e) => e.title == '깨진 제단');
      expect(altar.choices[0].dispositionRewards[DispositionAxis.mercy], 2);
      expect(altar.choices[0].dispositionRewards[DispositionAxis.wisdom], 1);
      // 지나감: will=1
      expect(altar.choices[1].dispositionRewards[DispositionAxis.will], 1);

      // "수상한 상인" — 거래: shadow=2
      final merchant = allEvents.firstWhere((e) => e.title == '수상한 상인');
      expect(merchant.choices[0].dispositionRewards[DispositionAxis.shadow], 2);
      // 거절: will=2
      expect(merchant.choices[1].dispositionRewards[DispositionAxis.will], 2);
    });

    test('dispositionRewards use DispositionConfig values', () {
      const config = EventConfig();
      const customDConfig = DispositionConfig(
        eventMajorReward: 5,
        eventMinorReward: 2,
        eventMediumReward: 4,
      );

      final allEvents = <EventRoomData>[];
      for (int seed = 0; seed < 100; seed++) {
        allEvents.add(EventRoomGenerator.generate(
          floor: 1,
          eventConfig: config,
          dispositionConfig: customDConfig,
          seed: seed,
        ));
      }

      // "길을 잃은 여행자" — 도움: mercy = eventMajorReward (5)
      final traveler = allEvents.firstWhere((e) => e.title == '길을 잃은 여행자');
      expect(traveler.choices[0].dispositionRewards[DispositionAxis.mercy], 5);
      // 무시: shadow = eventMinorReward (2)
      expect(traveler.choices[1].dispositionRewards[DispositionAxis.shadow], 2);

      // "깨진 제단" — 기도: mercy = eventMediumReward (4)
      final altar = allEvents.firstWhere((e) => e.title == '깨진 제단');
      expect(altar.choices[0].dispositionRewards[DispositionAxis.mercy], 4);
    });
  });
}
