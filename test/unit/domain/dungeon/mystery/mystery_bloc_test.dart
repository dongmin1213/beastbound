import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/mystery_reward_event.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_event.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_state.dart';

void main() {
  late GameEventBus gameEventBus;

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('MysteryBloc', () {
    test('initial state is MysteryInitial', () {
      final bloc = MysteryBloc(gameEventBus: gameEventBus);
      expect(bloc.state, const MysteryInitial());
      bloc.close();
    });

    blocTest<MysteryBloc, MysteryState>(
      'RevealMystery with TreasureOutcome emits MysteryRevealed',
      build: () => MysteryBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const RevealMystery(
        TreasureOutcome(goldReward: 20, narrativeText: '보물!'),
      )),
      expect: () => [
        const MysteryRevealed(
          TreasureOutcome(goldReward: 20, narrativeText: '보물!'),
        ),
      ],
    );

    blocTest<MysteryBloc, MysteryState>(
      'RevealMystery with TrapOutcome emits MysteryRevealed',
      build: () => MysteryBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const RevealMystery(
        TrapOutcome(hpLoss: 15, narrativeText: '함정!'),
      )),
      expect: () => [
        const MysteryRevealed(
          TrapOutcome(hpLoss: 15, narrativeText: '함정!'),
        ),
      ],
    );

    blocTest<MysteryBloc, MysteryState>(
      'RevealMystery with EncounterOutcome emits MysteryRevealed',
      build: () => MysteryBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const RevealMystery(
        EncounterOutcome(goldReward: 15, narrativeText: '전투!'),
      )),
      expect: () => [
        const MysteryRevealed(
          EncounterOutcome(goldReward: 15, narrativeText: '전투!'),
        ),
      ],
    );

    blocTest<MysteryBloc, MysteryState>(
      'RevealMystery with EventOutcome emits MysteryRevealed',
      build: () => MysteryBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const RevealMystery(
        EventOutcome(goldReward: 5, narrativeText: '이벤트!'),
      )),
      expect: () => [
        const MysteryRevealed(
          EventOutcome(goldReward: 5, narrativeText: '이벤트!'),
        ),
      ],
    );

    blocTest<MysteryBloc, MysteryState>(
      'RevealMystery with MinorOutcome emits MysteryRevealed',
      build: () => MysteryBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const RevealMystery(
        MinorOutcome(goldReward: 3, narrativeText: '잔돈!'),
      )),
      expect: () => [
        const MysteryRevealed(
          MinorOutcome(goldReward: 3, narrativeText: '잔돈!'),
        ),
      ],
    );

    blocTest<MysteryBloc, MysteryState>(
      'AcceptResult from MysteryRevealed emits MysteryCompleted',
      build: () => MysteryBloc(gameEventBus: gameEventBus),
      act: (bloc) {
        bloc.add(const RevealMystery(
          TreasureOutcome(goldReward: 20, narrativeText: '보물!'),
        ));
        bloc.add(const AcceptResult());
      },
      expect: () => [
        const MysteryRevealed(
          TreasureOutcome(goldReward: 20, narrativeText: '보물!'),
        ),
        const MysteryCompleted(
          TreasureOutcome(goldReward: 20, narrativeText: '보물!'),
        ),
      ],
    );

    blocTest<MysteryBloc, MysteryState>(
      'AcceptResult from MysteryInitial is ignored (no state change)',
      build: () => MysteryBloc(gameEventBus: gameEventBus),
      act: (bloc) => bloc.add(const AcceptResult()),
      expect: () => <MysteryState>[],
    );

    test('AcceptResult emits MysteryRewardEvent on GameEventBus', () async {
      final bloc = MysteryBloc(gameEventBus: gameEventBus);
      final events = <MysteryRewardEvent>[];
      final sub = gameEventBus.on<MysteryRewardEvent>().listen(events.add);

      bloc.add(const RevealMystery(
        TreasureOutcome(goldReward: 20, narrativeText: '보물!'),
      ));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const AcceptResult());
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.outcomeType, 'treasure');
      expect(events.first.goldChange, 20);
      expect(events.first.hpChange, 0);

      await sub.cancel();
      await bloc.close();
    });
  });
}
