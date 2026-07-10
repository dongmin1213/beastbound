import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/room_completed_event.dart';
import 'package:soul_dungeon/core/events/room_entered_event.dart';
import 'package:soul_dungeon/domain/hsm/hsm_controller.dart';
import 'package:soul_dungeon/domain/hsm/states/game_phase.dart';

void main() {
  late GameEventBus gameEventBus;
  late HsmController controller;

  setUp(() {
    gameEventBus = GameEventBus();
    controller = HsmController(gameEventBus: gameEventBus);
  });

  tearDown(() {
    controller.dispose();
    gameEventBus.dispose();
  });

  group('RoomCompletedEvent', () {
    // ── 1. CombatPhase → ExplorationPhase ──

    test('CombatPhase에서 RoomCompletedEvent → ExplorationPhase 복귀', () async {
      controller.tryTransition(const CombatPhase());
      expect(controller.currentPhase, isA<CombatPhase>());

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_1'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    // ── 2. 각 Room Phase → ExplorationPhase 복귀 ──

    test('EventPhase에서 RoomCompletedEvent → ExplorationPhase 복귀', () async {
      controller.tryTransition(const EventPhase());
      expect(controller.currentPhase, isA<EventPhase>());

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_2'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('ShopPhase에서 RoomCompletedEvent → ExplorationPhase 복귀', () async {
      controller.tryTransition(const ShopPhase());
      expect(controller.currentPhase, isA<ShopPhase>());

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_3'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('RestPhase에서 RoomCompletedEvent → ExplorationPhase 복귀', () async {
      controller.tryTransition(const RestPhase());
      expect(controller.currentPhase, isA<RestPhase>());

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_4'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('BossPhase에서 RoomCompletedEvent → ExplorationPhase 복귀', () async {
      controller.tryTransition(const BossPhase());
      expect(controller.currentPhase, isA<BossPhase>());

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_5'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('NpcPhase에서 RoomCompletedEvent → ExplorationPhase 복귀', () async {
      controller.tryTransition(const NpcPhase());
      expect(controller.currentPhase, isA<NpcPhase>());

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_6'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('MysteryPhase에서 RoomCompletedEvent → ExplorationPhase 복귀',
        () async {
      controller.tryTransition(const MysteryPhase());
      expect(controller.currentPhase, isA<MysteryPhase>());

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_7'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    // ── 3. roomState 리셋 확인 ──

    test('RoomCompletedEvent 수신 시 roomState가 null로 리셋', () async {
      // RoomEnteredEvent로 roomState 설정
      gameEventBus
          .emit(RoomEnteredEvent(nodeId: 'node_10', roomTypeName: 'combat'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.roomState, isNotNull);
      expect(controller.roomState!.nodeId, 'node_10');

      // RoomCompletedEvent로 roomState 리셋
      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_10'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.roomState, isNull);
    });

    test('RoomCompletedEvent 후 roomState null — 각 방 타입 공통', () async {
      // EventPhase 진입
      gameEventBus
          .emit(RoomEnteredEvent(nodeId: 'node_11', roomTypeName: 'event'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.roomState, isNotNull);

      // 방 완료
      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_11'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.roomState, isNull);
      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    // ── 4. ExplorationPhase에서 RoomCompletedEvent → 에러 없이 무시 ──

    test('ExplorationPhase에서 RoomCompletedEvent → 에러 없음, Phase 유지',
        () async {
      // 초기 상태: ExplorationPhase, roomState: null
      expect(controller.currentPhase, isA<ExplorationPhase>());
      expect(controller.roomState, isNull);

      // RoomCompletedEvent 발행 — 무효 전환(Exploration→Exploration)이므로 false
      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_20'));
      await Future<void>.delayed(Duration.zero);

      // Phase 변경 없이 ExplorationPhase 유지
      expect(controller.currentPhase, isA<ExplorationPhase>());
      // roomState는 여전히 null
      expect(controller.roomState, isNull);
    });

    test('ExplorationPhase에서 RoomCompletedEvent 중복 발행 → 모두 안전 무시',
        () async {
      expect(controller.currentPhase, isA<ExplorationPhase>());

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_21'));
      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_22'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
      expect(controller.roomState, isNull);
    });

    // ── 5. 전체 사이클: RoomEnteredEvent → Phase 전환 → RoomCompletedEvent → ExplorationPhase ──

    test('전체 사이클: RoomEnteredEvent → CombatPhase → RoomCompletedEvent → ExplorationPhase',
        () async {
      // 초기 상태 확인
      expect(controller.currentPhase, isA<ExplorationPhase>());
      expect(controller.roomState, isNull);

      // 1단계: 방 진입 → CombatPhase
      gameEventBus
          .emit(RoomEnteredEvent(nodeId: 'node_30', roomTypeName: 'combat'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<CombatPhase>());
      expect(controller.roomState, isNotNull);
      expect(controller.roomState!.nodeId, 'node_30');

      // 2단계: 방 완료 → ExplorationPhase 복귀
      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_30'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
      expect(controller.roomState, isNull);
    });

    test('전체 사이클: RoomEnteredEvent → ShopPhase → RoomCompletedEvent → ExplorationPhase',
        () async {
      expect(controller.currentPhase, isA<ExplorationPhase>());

      gameEventBus
          .emit(RoomEnteredEvent(nodeId: 'node_31', roomTypeName: 'shop'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ShopPhase>());
      expect(controller.roomState, isNotNull);
      expect(controller.roomState!.nodeId, 'node_31');

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_31'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
      expect(controller.roomState, isNull);
    });

    test('연속 사이클: 방 진입 → 완료 → 다른 방 진입 → 완료', () async {
      // 첫 번째 사이클: combat
      gameEventBus
          .emit(RoomEnteredEvent(nodeId: 'node_40', roomTypeName: 'combat'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<CombatPhase>());
      expect(controller.roomState!.nodeId, 'node_40');

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_40'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
      expect(controller.roomState, isNull);

      // 두 번째 사이클: boss
      gameEventBus
          .emit(RoomEnteredEvent(nodeId: 'node_41', roomTypeName: 'boss'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<BossPhase>());
      expect(controller.roomState!.nodeId, 'node_41');

      gameEventBus.emit(RoomCompletedEvent(nodeId: 'node_41'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<ExplorationPhase>());
      expect(controller.roomState, isNull);
    });
  });
}
