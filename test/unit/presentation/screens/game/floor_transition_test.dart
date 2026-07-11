import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/run_completed_event.dart';
import 'package:soul_dungeon/domain/run/run_bloc.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/domain/run/run_state.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  group('층 전환 흐름 (E5-4)', () {
    late GameEventBus eventBus;
    late RunBloc runBloc;

    setUp(() {
      eventBus = GameEventBus();
      runBloc = RunBloc(
        initialPlayerState: PlayerRunState.initial(maxHp: 100),
        gameEventBus: eventBus,
      );
    });

    tearDown(() {
      runBloc.close();
      eventBus.dispose();
    });

    test('1층→5층 순차 진행 (중간 진행 검증)', () async {
      // 1→2
      runBloc.add(const AdvanceFloor());
      await runBloc.stream.first;
      expect((runBloc.state as RunActive).playerRunState.currentFloor, 2);
      expect((runBloc.state as RunActive).playerRunState.completedFloors, {1});

      // 2→3
      runBloc.add(const AdvanceFloor());
      await runBloc.stream.first;
      expect((runBloc.state as RunActive).playerRunState.currentFloor, 3);

      // 3→4
      runBloc.add(const AdvanceFloor());
      await runBloc.stream.first;
      expect((runBloc.state as RunActive).playerRunState.currentFloor, 4);

      // 4→5
      runBloc.add(const AdvanceFloor());
      await runBloc.stream.first;
      expect((runBloc.state as RunActive).playerRunState.currentFloor, 5);
      expect(
        (runBloc.state as RunActive).playerRunState.completedFloors,
        {1, 2, 3, 4},
      );
    });

    test('10층 AdvanceFloor → RunCompletedEvent + floor 유지', () async {
      // 9층까지 진행
      for (var i = 0; i < 9; i++) {
        runBloc.add(const AdvanceFloor());
        await runBloc.stream.first;
      }
      expect((runBloc.state as RunActive).playerRunState.currentFloor, 10);

      // 10층(최종) AdvanceFloor
      runBloc.add(const AdvanceFloor());
      await runBloc.stream.first;

      // floor 유지 (11이 아님)
      expect((runBloc.state as RunActive).playerRunState.currentFloor, 10);
      expect(
        (runBloc.state as RunActive).playerRunState.completedFloors,
        {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
      );

      // RunCompletedEvent 발행 확인
      final runEvents = eventBus.history.whereType<RunCompletedEvent>().toList();
      expect(runEvents.length, 1);
      expect(runEvents.first.totalFloors, 10);
    });

    test('FloorCompletedEvent 매 층마다 발행', () async {
      for (var i = 0; i < 3; i++) {
        runBloc.add(const AdvanceFloor());
        await runBloc.stream.first;
      }

      final events = eventBus.history.whereType<FloorCompletedEvent>().toList();
      expect(events.length, 3);
      expect(events[0].floorNumber, 1);
      expect(events[1].floorNumber, 2);
      expect(events[2].floorNumber, 3);
    });

    test('ResetRun 후 floor=1로 복귀 + 재진행 가능', () async {
      // 3층까지 진행
      for (var i = 0; i < 2; i++) {
        runBloc.add(const AdvanceFloor());
        await runBloc.stream.first;
      }
      expect((runBloc.state as RunActive).playerRunState.currentFloor, 3);

      // 리셋
      runBloc.add(const ResetRun(maxHp: 100));
      await runBloc.stream.first;

      final prs = (runBloc.state as RunActive).playerRunState;
      expect(prs.currentFloor, 1);
      expect(prs.completedFloors, isEmpty);

      // 다시 진행 가능
      runBloc.add(const AdvanceFloor());
      await runBloc.stream.first;
      expect((runBloc.state as RunActive).playerRunState.currentFloor, 2);
    });

    test('HP/gold 보존 — 층 전환 시', () async {
      // HP/골드 설정
      runBloc.add(SetPlayerRunState(
        PlayerRunState.initial(maxHp: 100).copyWith(
          currentHp: 60,
          gold: 150,
        ),
      ));
      await runBloc.stream.first;

      // 층 전환
      runBloc.add(const AdvanceFloor());
      await runBloc.stream.first;

      final prs = (runBloc.state as RunActive).playerRunState;
      expect(prs.currentFloor, 2);
      expect(prs.currentHp, 60);
      expect(prs.gold, 150);
    });
  });
}
