import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/rest_choice_event.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/core/events/momentum_changed_event.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  const config = MomentumConfig(initialValue: 0);
  late GameEventBus gameEventBus;

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('MomentumBloc', () {
    blocTest<MomentumBloc, MomentumState>(
      '초기 상태: MomentumInitial',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      verify: (bloc) {
        expect(bloc.state, const MomentumInitial());
      },
    );

    blocTest<MomentumBloc, MomentumState>(
      '첫 턴 ActionPerformed(attack) → MomentumUpdated(0, low, delta(0, none), attack)',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) => bloc.add(const ActionPerformed(ActionType.attack)),
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      '행동 전환 attack → defend → MomentumUpdated(12, low, delta(+12, actionSwitch), defend)',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.defend));
      },
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
        const MomentumUpdated(
          value: 12,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.actionSwitch),
          lastActionType: ActionType.defend,
          consecutiveSameAction: 0,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      '연속 전환 attack → defend → attack → MomentumUpdated(24, ...)',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.defend));
        bloc.add(const ActionPerformed(ActionType.attack));
      },
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
        const MomentumUpdated(
          value: 12,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.actionSwitch),
          lastActionType: ActionType.defend,
          consecutiveSameAction: 0,
        ),
        const MomentumUpdated(
          value: 24,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.actionSwitch),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      '같은 행동 2연속 attack → attack → MomentumUpdated(value: -15→0, sameAction)',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.attack));
      },
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: -15, reason: MomentumChangeReason.sameAction),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 1,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      'MomentumReset → MomentumInitial',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      seed: () => const MomentumUpdated(
        value: 30,
        tier: MomentumTier.low,
        lastDelta:
            MomentumDelta(value: 12, reason: MomentumChangeReason.actionSwitch),
        lastActionType: ActionType.defend,
      ),
      act: (bloc) => bloc.add(const MomentumReset()),
      expect: () => [const MomentumInitial()],
    );

    blocTest<MomentumBloc, MomentumState>(
      'MomentumReset 후 ActionPerformed → 첫 턴 처리 (lastActionType null)',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.defend));
        bloc.add(const MomentumReset());
        bloc.add(const ActionPerformed(ActionType.observe));
      },
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
        const MomentumUpdated(
          value: 12,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.actionSwitch),
          lastActionType: ActionType.defend,
          consecutiveSameAction: 0,
        ),
        const MomentumInitial(),
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.observe,
          consecutiveSameAction: 0,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      '클램핑: 기세 0에서 같은 행동 → 0 유지',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      seed: () => const MomentumUpdated(
        value: 0,
        tier: MomentumTier.low,
        lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
        lastActionType: ActionType.attack,
      ),
      act: (bloc) => bloc.add(const ActionPerformed(ActionType.attack)),
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: -15, reason: MomentumChangeReason.sameAction),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 1,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      '클램핑: 기세 100 근처에서 전환 → 100 상한',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      seed: () => const MomentumUpdated(
        value: 95,
        tier: MomentumTier.high,
        lastDelta:
            MomentumDelta(value: 12, reason: MomentumChangeReason.actionSwitch),
        lastActionType: ActionType.attack,
      ),
      act: (bloc) => bloc.add(const ActionPerformed(ActionType.defend)),
      expect: () => [
        const MomentumUpdated(
          value: 100,
          tier: MomentumTier.high,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.actionSwitch),
          lastActionType: ActionType.defend,
          consecutiveSameAction: 0,
        ),
      ],
    );

    test('GameEventBus에 MomentumChangedEvent 발행 확인', () async {
      final bloc = MomentumBloc(gameEventBus: gameEventBus, config: config);
      final events = <GameEvent>[];
      final subscription = gameEventBus.on<MomentumChangedEvent>().listen(events.add);

      bloc.add(const ActionPerformed(ActionType.attack));
      bloc.add(const ActionPerformed(ActionType.defend));

      // Bloc 이벤트 처리 대기
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(events.length, 2);
      expect(events[0], isA<MomentumChangedEvent>());
      expect((events[0] as MomentumChangedEvent).value, 0);
      expect((events[0] as MomentumChangedEvent).tier, MomentumTier.low);
      expect(events[1], isA<MomentumChangedEvent>());
      expect((events[1] as MomentumChangedEvent).value, 12);
      expect((events[1] as MomentumChangedEvent).tier, MomentumTier.low);

      await subscription.cancel();
      await bloc.close();
    });

    // === Story 2-2: consecutiveSameAction 시퀀스 검증 (Task 1.4) ===

    blocTest<MomentumBloc, MomentumState>(
      'consecutiveSameAction 시퀀스: attack(0)→attack(1)→attack(2)→defend(0)',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.defend));
      },
      expect: () => [
        // attack(첫 행동): consecutiveSameAction=0
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
        // attack(2연속): delta 계산 시 count=0 → sameAction, 이후 increment → 1
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: -15, reason: MomentumChangeReason.sameAction),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 1,
        ),
        // attack(3연속): count=2 → sameActionStreak, consecutive=2
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: -25, reason: MomentumChangeReason.sameActionStreak),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 2,
        ),
        // defend(행동 전환): consecutiveSameAction=0
        const MomentumUpdated(
          value: 12,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.actionSwitch),
          lastActionType: ActionType.defend,
          consecutiveSameAction: 0,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      'sameActionStreak 발동: 4연속 같은 행동 시 count=2 → sameActionStreak(-25)',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.attack));
      },
      expect: () => [
        // 1st attack: none, consecutive=0
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
        // 2nd attack: count=0 → sameAction, consecutive=1
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: -15, reason: MomentumChangeReason.sameAction),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 1,
        ),
        // 3rd attack: count=2 → sameActionStreak(-25), consecutive=2
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: -25, reason: MomentumChangeReason.sameActionStreak),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 2,
        ),
        // 4th attack: count=3 → sameActionStreak(-25), consecutive=3
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(
              value: -25, reason: MomentumChangeReason.sameActionStreak),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 3,
        ),
      ],
    );

    // === Story 2-2: MomentumReset 후 consecutiveSameAction 초기화 (Task 1.6) ===

    blocTest<MomentumBloc, MomentumState>(
      'MomentumReset 후 consecutiveSameAction 초기화: attack→attack(1)→Reset→attack(0)',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const ActionPerformed(ActionType.attack));
        bloc.add(const MomentumReset());
        bloc.add(const ActionPerformed(ActionType.attack));
      },
      expect: () => [
        // attack(첫 행동): consecutiveSameAction=0
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
        // attack(2연속): consecutiveSameAction=1
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: -15, reason: MomentumChangeReason.sameAction),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 1,
        ),
        // Reset
        const MomentumInitial(),
        // attack(Reset 후 첫 행동): consecutiveSameAction=0
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastActionType: ActionType.attack,
          consecutiveSameAction: 0,
        ),
      ],
    );

    // === Story 3-7: RestChoiceEvent 기세 리셋 ===

    test('GameEventBus RestChoiceEvent(heal) 수신 → MomentumInitial', () async {
      final bloc = MomentumBloc(gameEventBus: gameEventBus, config: config);

      // 기세를 올린 상태로 만듦
      bloc.add(const ActionPerformed(ActionType.attack));
      bloc.add(const ActionPerformed(ActionType.defend));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<MomentumUpdated>());
      expect((bloc.state as MomentumUpdated).value, 12);

      // RestChoiceEvent 발행 → MomentumReset 트리거
      gameEventBus.emit(RestChoiceEvent(choiceType: 'heal', hpChange: 30));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, const MomentumInitial());
      await bloc.close();
    });

    test('GameEventBus RestChoiceEvent(upgrade) 수신 → MomentumInitial', () async {
      final bloc = MomentumBloc(gameEventBus: gameEventBus, config: config);

      bloc.add(const ActionPerformed(ActionType.attack));
      bloc.add(const ActionPerformed(ActionType.defend));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<MomentumUpdated>());

      gameEventBus.emit(RestChoiceEvent(choiceType: 'upgrade', maxHpChange: 10));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, const MomentumInitial());
      await bloc.close();
    });

    test('MomentumReset 시 MomentumChangedEvent(value: 0) 발행', () async {
      final bloc = MomentumBloc(gameEventBus: gameEventBus, config: config);
      final events = <MomentumChangedEvent>[];
      final subscription =
          gameEventBus.on<MomentumChangedEvent>().listen(events.add);

      // 기세 축적
      bloc.add(const ActionPerformed(ActionType.attack));
      bloc.add(const ActionPerformed(ActionType.defend));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      events.clear(); // ActionPerformed의 이벤트 무시

      // MomentumReset
      bloc.add(const MomentumReset());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events[0].value, 0);
      expect(events[0].tier, MomentumTier.low);

      await subscription.cancel();
      await bloc.close();
    });

    test('close() 후 RestChoiceEvent → 무시 (구독 해제 확인)', () async {
      final bloc = MomentumBloc(gameEventBus: gameEventBus, config: config);

      bloc.add(const ActionPerformed(ActionType.attack));
      bloc.add(const ActionPerformed(ActionType.defend));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final stateBeforeClose = bloc.state;
      expect(stateBeforeClose, isA<MomentumUpdated>());

      await bloc.close();

      // close() 후 RestChoiceEvent 발행 — 에러 없이 무시되어야 함
      gameEventBus.emit(RestChoiceEvent(choiceType: 'heal', hpChange: 30));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // bloc이 닫혔으므로 상태 변화 없음 (isClosed = true)
      expect(bloc.state, stateBeforeClose);
      expect(bloc.isClosed, isTrue);
    });

    // === CardPlayed 이벤트 (카드 전투 기세) ===

    blocTest<MomentumBloc, MomentumState>(
      'CardPlayed(attack) 첫 턴 → MomentumUpdated(0, low, delta(0, none))',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) => bloc.add(const CardPlayed(CardType.attack)),
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastCardType: CardType.attack,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      'CardPlayed(attack) → CardPlayed(skill) → value 12, tier low',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const CardPlayed(CardType.attack));
        bloc.add(const CardPlayed(CardType.skill));
      },
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastCardType: CardType.attack,
        ),
        const MomentumUpdated(
          value: 12,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.cardTypeSwitch),
          lastCardType: CardType.skill,
        ),
      ],
    );

    blocTest<MomentumBloc, MomentumState>(
      'CardPlayed(attack) → CardPlayed(skill) → CardPlayed(attack) → value 24, tier low',
      build: () => MomentumBloc(gameEventBus: gameEventBus, config: config),
      act: (bloc) {
        bloc.add(const CardPlayed(CardType.attack));
        bloc.add(const CardPlayed(CardType.skill));
        bloc.add(const CardPlayed(CardType.attack));
      },
      expect: () => [
        const MomentumUpdated(
          value: 0,
          tier: MomentumTier.low,
          lastDelta: MomentumDelta(value: 0, reason: MomentumChangeReason.none),
          lastCardType: CardType.attack,
        ),
        const MomentumUpdated(
          value: 12,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.cardTypeSwitch),
          lastCardType: CardType.skill,
        ),
        const MomentumUpdated(
          value: 24,
          tier: MomentumTier.low,
          lastDelta:
              MomentumDelta(value: 12, reason: MomentumChangeReason.cardTypeSwitch),
          lastCardType: CardType.attack,
        ),
      ],
    );
  });
}
