import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/run/run_bloc.dart';
import 'package:soul_dungeon/domain/run/run_state.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';

void main() {
  late GameRunController controller;
  late RunBloc runBloc;
  late GameEventBus gameEventBus;

  setUp(() {
    gameEventBus = GameEventBus();
    runBloc = RunBloc(initialPlayerState: PlayerRunState.initial(maxHp: 100), gameEventBus: gameEventBus);
    controller = GameRunController(
      initialState: PlayerRunState.initial(maxHp: 100),
      runBloc: runBloc,
      gameEventBus: gameEventBus,
      onStateChanged: () {},
      isScrolledUp: () => false,
      scrollToBottom: () {},
    );
  });

  tearDown(() {
    controller.dispose();
    runBloc.close();
  });

  group('GameRunController 힌트 상태', () {
    test('onRoomEntered — roomsSinceLastHint 카운터 증가', () {
      final initial = controller.roomsSinceLastHint;
      controller.onRoomEntered();
      expect(controller.roomsSinceLastHint, initial + 1);
      controller.onRoomEntered();
      expect(controller.roomsSinceLastHint, initial + 2);
    });

    test('onHintShown — 카운터 리셋 + 인덱스 증가', () {
      expect(controller.hintIndex, 0);
      controller.onHintShown();
      expect(controller.roomsSinceLastHint, 0);
      expect(controller.hintIndex, 1);
      controller.onHintShown();
      expect(controller.roomsSinceLastHint, 0);
      expect(controller.hintIndex, 2);
    });

    test('resetRun — 힌트 상태 초기화', () {
      controller.onRoomEntered();
      controller.onRoomEntered();
      controller.onHintShown();
      controller.onRoomEntered();

      controller.resetRun(100);

      expect(controller.roomsSinceLastHint, 99);
      expect(controller.hintIndex, 0);
    });
  });

  group('GameRunController — advanceFloor', () {
    test('advanceFloor — currentFloor 증가 + completedFloors 기록', () {
      expect(controller.playerRunState.currentFloor, 1);
      expect(controller.playerRunState.completedFloors, isEmpty);

      controller.advanceFloor();

      expect(controller.playerRunState.currentFloor, 2);
      expect(controller.playerRunState.completedFloors, {1});
    });

    test('advanceFloor — 연속 호출 1→2→3', () {
      controller.advanceFloor();
      controller.advanceFloor();

      expect(controller.playerRunState.currentFloor, 3);
      expect(controller.playerRunState.completedFloors, {1, 2});
    });

    test('advanceFloor — 힌트 카운터 리셋', () {
      controller.onRoomEntered();
      controller.onRoomEntered();
      controller.onHintShown();
      controller.onRoomEntered();

      controller.advanceFloor();

      expect(controller.roomsSinceLastHint, 99);
      expect(controller.hintIndex, 0);
    });

    test('advanceFloor — RunBloc AdvanceFloor 이벤트 발행', () async {
      controller.advanceFloor();

      // RunBloc의 비동기 처리 대기
      await runBloc.stream.first;

      final state = runBloc.state as RunActive;
      expect(state.playerRunState.currentFloor, 2);
      expect(state.playerRunState.completedFloors, {1});
    });

    test('advanceFloor — GameEventBus FloorCompletedEvent 발행', () async {
      final eventBusWithBloc = GameEventBus();
      final blocWithBus = RunBloc(
        initialPlayerState: PlayerRunState.initial(maxHp: 100),
        gameEventBus: eventBusWithBloc,
      );
      final ctrl = GameRunController(
        initialState: PlayerRunState.initial(maxHp: 100),
        runBloc: blocWithBus,
        gameEventBus: eventBusWithBloc,
        onStateChanged: () {},
        isScrolledUp: () => false,
        scrollToBottom: () {},
      );
      addTearDown(() {
        ctrl.dispose();
        blocWithBus.close();
        eventBusWithBloc.dispose();
      });

      ctrl.advanceFloor();
      await blocWithBus.stream.first;

      final events = eventBusWithBloc.history
          .whereType<FloorCompletedEvent>()
          .toList();
      expect(events.length, 1);
      expect(events.first.floorNumber, 1);
    });

    test('resetRun 후 floor 1로 복귀', () {
      controller.advanceFloor();
      controller.advanceFloor();
      expect(controller.playerRunState.currentFloor, 3);

      controller.resetRun(100);
      expect(controller.playerRunState.currentFloor, 1);
      expect(controller.playerRunState.completedFloors, isEmpty);
      expect(controller.playerRunState.bossChoices, isEmpty);
    });
  });
}
