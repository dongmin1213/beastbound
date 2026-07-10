import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_bloc.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_event.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_state.dart';

void main() {
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
  });

  group('NarratorBloc', () {
    test('초기 상태 — NarratorReliable, floor 1', () {
      final bloc = NarratorBloc(gameEventBus: eventBus);
      expect(bloc.state, isA<NarratorReliable>());
      expect(bloc.state.currentFloor, 1);
      bloc.close();
    });

    test('1층 → NarratorReliable', () async {
      final bloc = NarratorBloc(gameEventBus: eventBus);

      bloc.add(const NarratorFloorChanged(1));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorReliable>());
      expect(bloc.state.currentFloor, 1);

      bloc.close();
    });

    test('2층 → NarratorDistorted 미세 징조 (glitch, HP 오프셋 없음)', () async {
      final bloc = NarratorBloc(gameEventBus: eventBus);

      bloc.add(const NarratorFloorChanged(2));
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<NarratorDistorted>());
      final distorted = bloc.state as NarratorDistorted;
      expect(distorted.currentFloor, 2);
      expect(distorted.hpLieOffset, 0);
      expect(distorted.cardDistortionLevel, 0);
      expect(distorted.microGlitchProbability, 0.05);
      expect(distorted.silent, isFalse);

      bloc.close();
    });

    test('3층 → NarratorDistorted 본격 왜곡 (jamo level 1, HP ±3)', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );

      bloc.add(const NarratorFloorChanged(3));
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<NarratorDistorted>());
      final distorted = bloc.state as NarratorDistorted;
      expect(distorted.currentFloor, 3);
      expect(distorted.hpLieOffset, isNot(0));
      expect(distorted.hpLieOffset.abs(), lessThanOrEqualTo(3));
      expect(distorted.cardDistortionLevel, 1);
      expect(distorted.silent, isFalse);

      bloc.close();
    });

    test('4층 → NarratorDistorted 심한 왜곡 (jamo level 2, HP ±5)', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );

      bloc.add(const NarratorFloorChanged(4));
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<NarratorDistorted>());
      final distorted = bloc.state as NarratorDistorted;
      expect(distorted.currentFloor, 4);
      expect(distorted.hpLieOffset, isNot(0));
      expect(distorted.silent, isFalse);
      expect(distorted.cardDistortionLevel, 2);

      bloc.close();
    });

    test('5층 → NarratorDistorted + silent', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );

      bloc.add(const NarratorFloorChanged(5));
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<NarratorDistorted>());
      final distorted = bloc.state as NarratorDistorted;
      expect(distorted.currentFloor, 5);
      expect(distorted.silent, isTrue);
      expect(distorted.hpLieOffset, isNot(0));
      expect(distorted.cardDistortionLevel, 2);

      bloc.close();
    });

    test('hpLieOffset 범위 — 4층: [-5, +5], 0 아님', () async {
      for (int seed = 0; seed < 20; seed++) {
        final bloc = NarratorBloc(
          gameEventBus: eventBus,
          random: Random(seed),
        );
        bloc.add(const NarratorFloorChanged(4));
        await Future.delayed(Duration.zero);

        final distorted = bloc.state as NarratorDistorted;
        final offset = distorted.hpLieOffset;
        expect(offset, isNot(0), reason: 'seed $seed offset should not be 0');
        expect(offset.abs(), lessThanOrEqualTo(5),
            reason: 'seed $seed offset $offset out of range');

        bloc.close();
      }
    });

    test('hpLieOffset 범위 — 3층: [-3, +3], 0 아님', () async {
      for (int seed = 0; seed < 20; seed++) {
        final bloc = NarratorBloc(
          gameEventBus: eventBus,
          random: Random(seed),
        );
        bloc.add(const NarratorFloorChanged(3));
        await Future.delayed(Duration.zero);

        final distorted = bloc.state as NarratorDistorted;
        final offset = distorted.hpLieOffset;
        expect(offset, isNot(0), reason: 'seed $seed offset should not be 0');
        expect(offset.abs(), lessThanOrEqualTo(3),
            reason: 'seed $seed offset $offset out of range');

        bloc.close();
      }
    });

    test('FloorCompletedEvent 구독 — nextFloor 전환', () async {
      final bloc = NarratorBloc(gameEventBus: eventBus);

      // FloorCompletedEvent(floorNumber: 2) → NarratorFloorChanged(2) → micro
      eventBus.emit(FloorCompletedEvent(floorNumber: 2));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.currentFloor, 2);
      expect(bloc.state, isA<NarratorDistorted>());

      bloc.close();
    });

    test('ResetNarrator → 초기 상태 복귀', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );

      bloc.add(const NarratorFloorChanged(4));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorDistorted>());

      bloc.add(const ResetNarrator());
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorReliable>());
      expect(bloc.state.currentFloor, 1);

      bloc.close();
    });

    test('층 순서대로 진행 — 1→2→3→4→5', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );

      for (int floor = 1; floor <= 5; floor++) {
        bloc.add(NarratorFloorChanged(floor));
        await Future.delayed(Duration.zero);
        expect(bloc.state.currentFloor, floor);
      }

      // 1층 NarratorReliable
      bloc.add(const NarratorFloorChanged(1));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorReliable>());

      // 2층 NarratorDistorted micro
      bloc.add(const NarratorFloorChanged(2));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorDistorted>());
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 0);

      // 3층 NarratorDistorted level 1
      bloc.add(const NarratorFloorChanged(3));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorDistorted>());
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 1);

      // 4층 NarratorDistorted level 2
      bloc.add(const NarratorFloorChanged(4));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorDistorted>());
      expect((bloc.state as NarratorDistorted).silent, isFalse);
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 2);

      // 5층 NarratorDistorted level 2 + silent
      bloc.add(const NarratorFloorChanged(5));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorDistorted>());
      expect((bloc.state as NarratorDistorted).silent, isTrue);

      bloc.close();
    });

    test('커스텀 microFloor/unreliableFloor/heavyFloor/silentFloor', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
        microFloor: 3,
        unreliableFloor: 4,
        heavyFloor: 5,
        silentFloor: 6,
      );

      bloc.add(const NarratorFloorChanged(2));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorReliable>());

      bloc.add(const NarratorFloorChanged(3));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorDistorted>());
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 0);

      bloc.add(const NarratorFloorChanged(4));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorDistorted>());
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 1);

      bloc.add(const NarratorFloorChanged(5));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorDistorted>());
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 2);
      expect((bloc.state as NarratorDistorted).silent, isFalse);

      bloc.add(const NarratorFloorChanged(6));
      await Future.delayed(Duration.zero);
      expect((bloc.state as NarratorDistorted).silent, isTrue);

      bloc.close();
    });

    test('close 후 EventBus 구독 해제', () async {
      final bloc = NarratorBloc(gameEventBus: eventBus);
      await bloc.close();

      // 이후 이벤트는 무시 (에러 발생하면 안 됨)
      eventBus.emit(FloorCompletedEvent(floorNumber: 3));
      await Future.delayed(const Duration(milliseconds: 10));
    });
  });

  group('NarratorBloc — 카드 왜곡', () {
    test('2층 → cardDistortionLevel 0 + microGlitch', () async {
      final bloc = NarratorBloc(gameEventBus: eventBus);
      bloc.add(const NarratorFloorChanged(2));
      await Future.delayed(Duration.zero);
      final distorted = bloc.state as NarratorDistorted;
      expect(distorted.cardDistortionLevel, 0);
      expect(distorted.microGlitchProbability, 0.05);
      bloc.close();
    });

    test('3층 → cardDistortionLevel 1', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );
      bloc.add(const NarratorFloorChanged(3));
      await Future.delayed(Duration.zero);
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 1);
      bloc.close();
    });

    test('4층 → cardDistortionLevel 2', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );
      bloc.add(const NarratorFloorChanged(4));
      await Future.delayed(Duration.zero);
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 2);
      bloc.close();
    });

    test('5층 → cardDistortionLevel 2', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );
      bloc.add(const NarratorFloorChanged(5));
      await Future.delayed(Duration.zero);
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 2);
      bloc.close();
    });

    test('1층 → NarratorReliable (왜곡 없음)', () async {
      final bloc = NarratorBloc(gameEventBus: eventBus);
      bloc.add(const NarratorFloorChanged(1));
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorReliable>());
      bloc.close();
    });

    test('RevealTruth → truthRevealTurnsRemaining 설정', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );
      bloc.add(const NarratorFloorChanged(3));
      await Future.delayed(Duration.zero);
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 1);

      bloc.add(const RevealTruth(2));
      await Future.delayed(Duration.zero);
      final distorted = bloc.state as NarratorDistorted;
      expect(distorted.truthRevealTurnsRemaining, 2);
      expect(distorted.isCardDistortionActive, isFalse);
      bloc.close();
    });

    test('RevealTruth on floor 1 → 무시', () async {
      final bloc = NarratorBloc(gameEventBus: eventBus);
      bloc.add(const RevealTruth(3));
      await Future.delayed(Duration.zero);
      // NarratorReliable 상태 유지 — RevealTruth 무시됨
      expect(bloc.state, isA<NarratorReliable>());
      bloc.close();
    });

    test('TickTruthReveal → 카운트다운', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );
      bloc.add(const NarratorFloorChanged(3));
      await Future.delayed(Duration.zero);
      bloc.add(const RevealTruth(2));
      await Future.delayed(Duration.zero);
      expect(
          (bloc.state as NarratorDistorted).truthRevealTurnsRemaining, 2);

      bloc.add(const TickTruthReveal());
      await Future.delayed(Duration.zero);
      var distorted = bloc.state as NarratorDistorted;
      expect(distorted.truthRevealTurnsRemaining, 1);
      expect(distorted.isCardDistortionActive, isFalse);

      bloc.add(const TickTruthReveal());
      await Future.delayed(Duration.zero);
      distorted = bloc.state as NarratorDistorted;
      expect(distorted.truthRevealTurnsRemaining, 0);
      expect(distorted.isCardDistortionActive, isTrue);
      bloc.close();
    });

    test('TickTruthReveal 0일 때 → 무시', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );
      bloc.add(const NarratorFloorChanged(3));
      await Future.delayed(Duration.zero);

      bloc.add(const TickTruthReveal());
      await Future.delayed(Duration.zero);
      expect(
          (bloc.state as NarratorDistorted).truthRevealTurnsRemaining, 0);
      bloc.close();
    });

    test('ResetNarrator → NarratorReliable 초기화', () async {
      final bloc = NarratorBloc(
        gameEventBus: eventBus,
        random: Random(42),
      );
      bloc.add(const NarratorFloorChanged(5));
      await Future.delayed(Duration.zero);
      expect((bloc.state as NarratorDistorted).cardDistortionLevel, 2);

      bloc.add(const ResetNarrator());
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<NarratorReliable>());
      bloc.close();
    });
  });

  group('NarratorState sealed hierarchy', () {
    test('NarratorReliable 기본 생성자', () {
      const state = NarratorReliable();
      expect(state.currentFloor, 1);
      expect(state, isA<NarratorReliable>());
    });

    test('NarratorDistorted copyWith', () {
      const state = NarratorDistorted(
        currentFloor: 4,
        hpLieOffset: 3,
      );
      final updated = state.copyWith(hpLieOffset: 5, silent: true);
      expect(updated.hpLieOffset, 5);
      expect(updated.silent, isTrue);
      expect(updated.currentFloor, 4); // 변경 안 함
    });

    test('NarratorDistorted copyWith — microGlitchProbability', () {
      const state = NarratorDistorted(
        currentFloor: 2,
        hpLieOffset: 0,
        microGlitchProbability: 0.05,
      );
      final updated = state.copyWith(microGlitchProbability: 0.1);
      expect(updated.microGlitchProbability, 0.1);
      expect(updated.hpLieOffset, 0);
    });

    test('Equatable — NarratorReliable 같은 값 동등', () {
      const a = NarratorReliable(currentFloor: 2);
      const b = NarratorReliable(currentFloor: 2);
      expect(a, equals(b));
    });

    test('Equatable — NarratorReliable 다른 값 부동', () {
      const a = NarratorReliable(currentFloor: 2);
      const b = NarratorReliable(currentFloor: 3);
      expect(a, isNot(equals(b)));
    });

    test('Equatable — NarratorDistorted 같은 값 동등', () {
      const a = NarratorDistorted(
          currentFloor: 4, hpLieOffset: 2);
      const b = NarratorDistorted(
          currentFloor: 4, hpLieOffset: 2);
      expect(a, equals(b));
    });

    test('Equatable — NarratorDistorted 다른 값 부동', () {
      const a = NarratorDistorted(
          currentFloor: 4, hpLieOffset: 2);
      const b = NarratorDistorted(
          currentFloor: 4, hpLieOffset: 3);
      expect(a, isNot(equals(b)));
    });

    test('NarratorReliable != NarratorDistorted', () {
      const a = NarratorReliable(currentFloor: 4);
      const b = NarratorDistorted(
          currentFloor: 4, hpLieOffset: 0);
      expect(a, isNot(equals(b)));
    });

    test('isCardDistortionActive — truthReveal 활성 시 false', () {
      const state = NarratorDistorted(
        currentFloor: 3,
        hpLieOffset: 3,
        cardDistortionLevel: 1,
        truthRevealTurnsRemaining: 2,
      );
      expect(state.isCardDistortionActive, isFalse);
    });

    test('isCardDistortionActive — truthReveal 만료 시 true', () {
      const state = NarratorDistorted(
        currentFloor: 3,
        hpLieOffset: 3,
        cardDistortionLevel: 1,
        truthRevealTurnsRemaining: 0,
      );
      expect(state.isCardDistortionActive, isTrue);
    });

    test('isCardDistortionActive — microGlitch만 있어도 true', () {
      const state = NarratorDistorted(
        currentFloor: 2,
        hpLieOffset: 0,
        cardDistortionLevel: 0,
        microGlitchProbability: 0.05,
        truthRevealTurnsRemaining: 0,
      );
      expect(state.isCardDistortionActive, isTrue);
    });
  });
}
