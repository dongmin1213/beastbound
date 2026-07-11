import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';

void main() {
  group('EventRoomData', () {
    test('creation and ==/hashCode with DeepCollectionEquality', () {
      const choice1 = EventChoice(
        label: '도움을 준다',
        outcomeText: '감사합니다.',
        goldChange: 10,
        hpChange: 0,
      );
      const choice2 = EventChoice(
        label: '무시한다',
        outcomeText: '지나간다.',
        goldChange: 0,
        hpChange: 0,
      );

      final data1 = EventRoomData(
        title: '길을 잃은 여행자',
        narrativeText: '어두운 통로에 여행자가 있다.',
        choices: [choice1, choice2],
      );
      final data2 = EventRoomData(
        title: '길을 잃은 여행자',
        narrativeText: '어두운 통로에 여행자가 있다.',
        choices: [choice1, choice2],
      );
      final dataDifferent = EventRoomData(
        title: '깨진 제단',
        narrativeText: '고대 제단의 잔해.',
        choices: [choice1],
      );

      // == 동등성 검증
      expect(data1, equals(data2));
      expect(data1, isNot(equals(dataDifferent)));

      // hashCode 일관성 검증
      expect(data1.hashCode, equals(data2.hashCode));
      expect(data1.hashCode, isNot(equals(dataDifferent.hashCode)));

      // EventChoice == 검증
      expect(choice1, equals(const EventChoice(
        label: '도움을 준다',
        outcomeText: '감사합니다.',
        goldChange: 10,
        hpChange: 0,
      )));
      expect(choice1, isNot(equals(choice2)));

      // toString 검증
      expect(data1.toString(), contains('길을 잃은 여행자'));
      expect(choice1.toString(), contains('도움을 준다'));
    });

    test('EventChoice equality includes gold/hp/card fields', () {
      const a = EventChoice(
        label: '도움',
        outcomeText: '감사',
        goldChange: 10,
        hpChange: 0,
      );
      const b = EventChoice(
        label: '도움',
        outcomeText: '감사',
        goldChange: 10,
        hpChange: 0,
      );
      const c = EventChoice(
        label: '도움',
        outcomeText: '감사',
        goldChange: 20,
        hpChange: 0,
      );

      expect(a, b);
      expect(a, isNot(c));
      expect(a.hashCode, b.hashCode);
    });
  });
}
