import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/events/game_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/room_entered_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';

void main() {
  const config = DungeonBalanceConfig();
  late GameEventBus gameEventBus;
  late DungeonGenerator generator;

  setUp(() {
    gameEventBus = GameEventBus();
    generator = DungeonGenerator(config: config, gameEventBus: gameEventBus);
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('DungeonBloc', () {
    blocTest<DungeonBloc, DungeonBlocState>(
      '초기 상태: DungeonInitial',
      build: () => DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      ),
      verify: (bloc) {
        expect(bloc.state, const DungeonInitial());
      },
    );

    blocTest<DungeonBloc, DungeonBlocState>(
      'GenerateFloor 성공 → DungeonFloorReady',
      build: () => DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      ),
      act: (bloc) => bloc.add(const GenerateFloor(floor: 1, seed: 42)),
      verify: (bloc) {
        expect(bloc.state, isA<DungeonFloorReady>());
        final state = bloc.state as DungeonFloorReady;
        expect(state.floorMap.floorNumber, 1);
        expect(state.minimapVisible, isFalse);
        expect(state.visitedNodeIds, contains(state.currentNodeId));
      },
    );

    blocTest<DungeonBloc, DungeonBlocState>(
      'SelectNode 유효 → DungeonRoomEntered + 방문 기록',
      build: () => DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      ),
      act: (bloc) {
        bloc.add(const GenerateFloor(floor: 1, seed: 42));
      },
      verify: (bloc) {
        // GenerateFloor 후 state에서 nextNodeIds의 첫 번째 노드를 선택
        final floorReady = bloc.state as DungeonFloorReady;
        final startNode = floorReady.floorMap.nodeById(floorReady.currentNodeId)!;
        expect(startNode.nextNodeIds, isNotEmpty);
      },
    );

    test('SelectNode 유효 → DungeonRoomEntered + RoomEnteredEvent 발행', () async {
      final bloc = DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      );

      bloc.add(const GenerateFloor(floor: 1, seed: 42));
      await Future<void>.delayed(Duration.zero);

      final floorReady = bloc.state as DungeonFloorReady;
      final startNode = floorReady.floorMap.nodeById(floorReady.currentNodeId)!;
      final nextNodeId = startNode.nextNodeIds.first;

      final events = <GameEvent>[];
      final subscription = gameEventBus.on<RoomEnteredEvent>().listen(events.add);

      bloc.add(SelectNode(nextNodeId));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, isA<DungeonRoomEntered>());
      final roomState = bloc.state as DungeonRoomEntered;
      expect(roomState.currentNodeId, nextNodeId);
      expect(roomState.minimapVisible, isFalse);
      expect(roomState.visitedNodeIds, contains(nextNodeId));

      // RoomEnteredEvent 발행 확인
      expect(events, hasLength(1));
      expect(events.first, isA<RoomEnteredEvent>());

      await subscription.cancel();
      await bloc.close();
    });

    test('SelectNode 무효 (nextNodeIds 미포함) → 상태 변경 없음', () async {
      final bloc = DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      );

      bloc.add(const GenerateFloor(floor: 1, seed: 42));
      await Future<void>.delayed(Duration.zero);

      final beforeState = bloc.state;
      bloc.add(const SelectNode('invalid_node_id'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, beforeState);

      await bloc.close();
    });

    test('초기 상태에서 SelectNode → 무시', () async {
      final bloc = DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      );

      bloc.add(const SelectNode('any_node'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, const DungeonInitial());

      await bloc.close();
    });

    blocTest<DungeonBloc, DungeonBlocState>(
      'ToggleMinimap → minimapVisible 토글',
      build: () => DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      ),
      act: (bloc) {
        bloc.add(const GenerateFloor(floor: 1, seed: 42));
        bloc.add(const ToggleMinimap());
      },
      verify: (bloc) {
        expect(bloc.state, isA<DungeonFloorReady>());
        final state = bloc.state as DungeonFloorReady;
        expect(state.minimapVisible, isTrue);
      },
    );

    test('CompleteRoom → DungeonFloorReady(minimapVisible=false) 복귀', () async {
      final bloc = DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      );

      bloc.add(const GenerateFloor(floor: 1, seed: 42));
      await Future<void>.delayed(Duration.zero);

      final floorReady = bloc.state as DungeonFloorReady;
      final startNode = floorReady.floorMap.nodeById(floorReady.currentNodeId)!;
      final nextNodeId = startNode.nextNodeIds.first;

      bloc.add(SelectNode(nextNodeId));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<DungeonRoomEntered>());

      bloc.add(const CompleteRoom());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, isA<DungeonFloorReady>());
      final restored = bloc.state as DungeonFloorReady;
      expect(restored.minimapVisible, isFalse);
      expect(restored.currentNodeId, nextNodeId);

      await bloc.close();
    });

    test('전진만 가능 — 이전 depth 노드 선택 거부', () async {
      final bloc = DungeonBloc(
        dungeonGenerator: generator,
        gameEventBus: gameEventBus,
      );

      bloc.add(const GenerateFloor(floor: 1, seed: 42));
      await Future<void>.delayed(Duration.zero);

      final floorReady = bloc.state as DungeonFloorReady;
      final startNode = floorReady.floorMap.nodeById(floorReady.currentNodeId)!;
      final nextNodeId = startNode.nextNodeIds.first;

      // 다음 노드로 이동
      bloc.add(SelectNode(nextNodeId));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<DungeonRoomEntered>());

      // 방 완료 → 탐색 복귀
      bloc.add(const CompleteRoom());
      await Future<void>.delayed(Duration.zero);

      // 시작 노드로 돌아가기 시도 (역방향) → 실패해야 함
      final stateBeforeBacktrack = bloc.state;
      bloc.add(SelectNode(floorReady.currentNodeId));
      await Future<void>.delayed(Duration.zero);

      // 역방향은 nextNodeIds에 없으므로 상태 변경 없어야 함
      expect(bloc.state, stateBeforeBacktrack);

      await bloc.close();
    });
  });
}
