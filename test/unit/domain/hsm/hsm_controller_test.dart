import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/phase_changed_event.dart';
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

  group('HsmController', () {
    test('초기 상태: ExplorationPhase', () {
      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('Exploration → CombatPhase 유효 전환', () {
      final result = controller.tryTransition(const CombatPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<CombatPhase>());
    });

    test('Exploration → EventPhase 유효 전환', () {
      final result = controller.tryTransition(const EventPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<EventPhase>());
    });

    test('Exploration → ShopPhase 유효 전환', () {
      final result = controller.tryTransition(const ShopPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<ShopPhase>());
    });

    test('Exploration → RestPhase 유효 전환', () {
      final result = controller.tryTransition(const RestPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<RestPhase>());
    });

    test('Exploration → BossPhase 유효 전환', () {
      final result = controller.tryTransition(const BossPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<BossPhase>());
    });

    test('Exploration → NpcPhase 유효 전환', () {
      final result = controller.tryTransition(const NpcPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<NpcPhase>());
    });

    test('Exploration → MysteryPhase 유효 전환', () {
      final result = controller.tryTransition(const MysteryPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<MysteryPhase>());
    });

    test('CombatPhase → Exploration 유효 복귀', () {
      controller.tryTransition(const CombatPhase());
      final result = controller.tryTransition(const ExplorationPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('BossPhase → Exploration 유효 복귀', () {
      controller.tryTransition(const BossPhase());
      final result = controller.tryTransition(const ExplorationPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('RestPhase → Exploration 유효 복귀', () {
      controller.tryTransition(const RestPhase());
      final result = controller.tryTransition(const ExplorationPhase());
      expect(result, isTrue);
      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('Exploration → Exploration 무효 전환 → false', () {
      final result = controller.tryTransition(const ExplorationPhase());
      expect(result, isFalse);
      expect(controller.currentPhase, isA<ExplorationPhase>());
    });

    test('CombatPhase → ShopPhase 무효 전환 → false', () {
      controller.tryTransition(const CombatPhase());
      final result = controller.tryTransition(const ShopPhase());
      expect(result, isFalse);
      expect(controller.currentPhase, isA<CombatPhase>());
    });

    test('EventPhase → CombatPhase 무효 전환 → false', () {
      controller.tryTransition(const EventPhase());
      final result = controller.tryTransition(const CombatPhase());
      expect(result, isFalse);
      expect(controller.currentPhase, isA<EventPhase>());
    });

    test('PhaseChangedEvent 발행 확인', () async {
      final events = <GameEvent>[];
      final subscription =
          gameEventBus.on<PhaseChangedEvent>().listen(events.add);

      controller.tryTransition(const CombatPhase());
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      final event = events.first as PhaseChangedEvent;
      expect(event.fromPhase, 'ExplorationPhase');
      expect(event.toPhase, 'CombatPhase');

      await subscription.cancel();
    });

    test('RoomEnteredEvent 구독 → 자동 Phase 전환', () async {
      final events = <GameEvent>[];
      final subscription =
          gameEventBus.on<PhaseChangedEvent>().listen(events.add);

      gameEventBus
          .emit(RoomEnteredEvent(nodeId: 'node_1', roomTypeName: 'combat'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPhase, isA<CombatPhase>());
      expect(events, hasLength(1));

      await subscription.cancel();
    });
  });
}
