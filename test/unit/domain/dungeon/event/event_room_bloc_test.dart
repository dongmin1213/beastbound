import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/event_choice_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_event.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_state.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

void main() {
  late GameEventBus gameEventBus;

  const testChoice1 = EventChoice(
    label: '도움을 준다',
    outcomeText: '감사합니다.',
    goldChange: 10,
    hpChange: 0,
  );
  const testChoice2 = EventChoice(
    label: '무시한다',
    outcomeText: '지나간다.',
    goldChange: 0,
    hpChange: 0,
  );
  final testData = EventRoomData(
    title: '길을 잃은 여행자',
    narrativeText: '어두운 통로에 여행자가 있다.',
    choices: [testChoice1, testChoice2],
  );

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('EventRoomBloc', () {
    blocTest<EventRoomBloc, EventRoomState>(
      'OpenEventRoom emits EventRoomReady',
      build: () => EventRoomBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(OpenEventRoom(testData)),
      expect: () => [EventRoomReady(testData)],
    );

    blocTest<EventRoomBloc, EventRoomState>(
      'SelectEventChoice emits EventRoomCompleted and GameEventBus emit',
      build: () => EventRoomBloc(gameEventBus: gameEventBus),
      act: (bloc) {
        bloc.add(OpenEventRoom(testData));
        bloc.add(const SelectEventChoice(0));
      },
      expect: () => [
        EventRoomReady(testData),
        const EventRoomCompleted(testChoice1),
      ],
      verify: (_) async {
        // GameEventBus emit 검증은 별도 test에서 수행
      },
    );

    blocTest<EventRoomBloc, EventRoomState>(
      'SelectEventChoice on EventRoomInitial is ignored (guard)',
      build: () => EventRoomBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const SelectEventChoice(0)),
      expect: () => <EventRoomState>[],
    );

    blocTest<EventRoomBloc, EventRoomState>(
      'SelectEventChoice with out-of-range index is ignored (guard)',
      build: () => EventRoomBloc(gameEventBus: gameEventBus),
      act: (bloc) {
        bloc.add(OpenEventRoom(testData));
        bloc.add(const SelectEventChoice(5)); // 범위 초과
        bloc.add(const SelectEventChoice(-1)); // 음수
      },
      expect: () => [
        EventRoomReady(testData),
        // SelectEventChoice(5)과 SelectEventChoice(-1)은 무시됨
      ],
    );

    test('SelectEventChoice emits EventChoiceEvent on GameEventBus', () async {
      final bloc = EventRoomBloc(gameEventBus: gameEventBus);
      final events = <EventChoiceEvent>[];
      final sub = gameEventBus.on<EventChoiceEvent>().listen(events.add);

      bloc.add(OpenEventRoom(testData));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const SelectEventChoice(0));
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.choiceLabel, '도움을 준다');
      expect(events.first.goldChange, 10);
      expect(events.first.hpChange, 0);

      await sub.cancel();
      await bloc.close();
    });

    // === Story 4-1: dispositionChanges 전달 ===

    test('SelectEventChoice includes dispositionChanges in EventChoiceEvent', () async {
      const choiceWithDisposition = EventChoice(
        label: '도움을 준다',
        outcomeText: '감사합니다.',
        goldChange: 10,
        hpChange: 0,
        dispositionRewards: {DispositionAxis.mercy: 3},
      );
      final dataWithDisposition = EventRoomData(
        title: '테스트 이벤트',
        narrativeText: '테스트.',
        choices: [choiceWithDisposition],
      );

      final bloc = EventRoomBloc(gameEventBus: gameEventBus);
      final events = <EventChoiceEvent>[];
      final sub = gameEventBus.on<EventChoiceEvent>().listen(events.add);

      bloc.add(OpenEventRoom(dataWithDisposition));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const SelectEventChoice(0));
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.dispositionChanges, {'mercy': 3});

      await sub.cancel();
      await bloc.close();
    });

    test('SelectEventChoice passes empty dispositionChanges when no rewards', () async {
      final bloc = EventRoomBloc(gameEventBus: gameEventBus);
      final events = <EventChoiceEvent>[];
      final sub = gameEventBus.on<EventChoiceEvent>().listen(events.add);

      bloc.add(OpenEventRoom(testData));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const SelectEventChoice(1)); // "무시한다" — no dispositionRewards
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.dispositionChanges, isEmpty);

      await sub.cancel();
      await bloc.close();
    });
  });
}
