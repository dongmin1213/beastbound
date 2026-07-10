import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/rest_choice_event.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_event.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_state.dart';

void main() {
  late GameEventBus gameEventBus;
  const restConfig = RestConfig(); // hpRecoveryPercent: 0.15, maxHpIncrease: 3

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('RestBloc', () {
    test('initial state is RestInitial', () {
      final bloc = RestBloc(gameEventBus: gameEventBus, restConfig: restConfig);
      expect(bloc.state, const RestInitial());
      bloc.close();
    });

    blocTest<RestBloc, RestState>(
      'EnterRest emits RestReady with calculated healAmount',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      act: (bloc) =>
          bloc.add(const EnterRest(currentHp: 60, maxHp: 100)),
      expect: () => [
        const RestReady(
          currentHp: 60,
          maxHp: 100,
          healAmount: 15,
          upgradeAmount: 3,
        ),
      ],
    );

    blocTest<RestBloc, RestState>(
      'ChooseHeal from RestReady emits RestClosed with hpRecovered',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      seed: () => const RestReady(
        currentHp: 60,
        maxHp: 100,
        healAmount: 15,
        upgradeAmount: 3,
      ),
      act: (bloc) => bloc.add(const ChooseHeal()),
      expect: () => [
        const RestClosed(hpRecovered: 15, maxHpIncreased: 0),
      ],
      verify: (_) {
        final events = gameEventBus.history
            .whereType<RestChoiceEvent>()
            .toList();
        expect(events, hasLength(1));
        expect(events.first.choiceType, 'heal');
        expect(events.first.hpChange, 15);
      },
    );

    blocTest<RestBloc, RestState>(
      'ChooseUpgrade from RestReady emits RestClosed with maxHpIncreased',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      seed: () => const RestReady(
        currentHp: 60,
        maxHp: 100,
        healAmount: 15,
        upgradeAmount: 3,
      ),
      act: (bloc) => bloc.add(const ChooseUpgrade()),
      expect: () => [
        const RestClosed(hpRecovered: 0, maxHpIncreased: 3),
      ],
      verify: (_) {
        final events = gameEventBus.history
            .whereType<RestChoiceEvent>()
            .toList();
        expect(events, hasLength(1));
        expect(events.first.choiceType, 'upgrade');
        expect(events.first.maxHpChange, 3);
      },
    );

    blocTest<RestBloc, RestState>(
      'ChooseHeal from RestInitial is ignored',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      act: (bloc) => bloc.add(const ChooseHeal()),
      expect: () => [],
    );

    blocTest<RestBloc, RestState>(
      'ChooseUpgrade from RestInitial is ignored',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      act: (bloc) => bloc.add(const ChooseUpgrade()),
      expect: () => [],
    );

    blocTest<RestBloc, RestState>(
      'ChooseHeal from RestClosed is ignored',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      seed: () => const RestClosed(hpRecovered: 15, maxHpIncreased: 0),
      act: (bloc) => bloc.add(const ChooseHeal()),
      expect: () => [],
    );

    blocTest<RestBloc, RestState>(
      'ChooseUpgrade from RestClosed is ignored',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      seed: () => const RestClosed(hpRecovered: 0, maxHpIncreased: 3),
      act: (bloc) => bloc.add(const ChooseUpgrade()),
      expect: () => [],
    );

    blocTest<RestBloc, RestState>(
      'full HP: healAmount is 0, ChooseHeal emits RestClosed(0, 0)',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      act: (bloc) {
        bloc.add(const EnterRest(currentHp: 100, maxHp: 100));
        bloc.add(const ChooseHeal());
      },
      expect: () => [
        const RestReady(
          currentHp: 100,
          maxHp: 100,
          healAmount: 0,
          upgradeAmount: 3,
        ),
        const RestClosed(hpRecovered: 0, maxHpIncreased: 0),
      ],
      verify: (_) {
        final events = gameEventBus.history
            .whereType<RestChoiceEvent>()
            .toList();
        expect(events, hasLength(1));
        expect(events.first.choiceType, 'heal');
        expect(events.first.hpChange, 0);
      },
    );

    blocTest<RestBloc, RestState>(
      'healAmount is capped to missingHp when rawHeal > missingHp',
      build: () => RestBloc(gameEventBus: gameEventBus, restConfig: restConfig),
      act: (bloc) =>
          bloc.add(const EnterRest(currentHp: 95, maxHp: 100)),
      expect: () => [
        // rawHeal = (100 * 0.15).round() = 15, missingHp = 5 → healAmount = 5
        const RestReady(
          currentHp: 95,
          maxHp: 100,
          healAmount: 5,
          upgradeAmount: 3,
        ),
      ],
    );
  });
}
