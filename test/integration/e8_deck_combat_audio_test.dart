import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/audio/engine/sfx_registry.dart';
import 'package:soul_dungeon/core/events/card_drawn_event.dart';
import 'package:soul_dungeon/core/events/card_exhausted_event.dart';
import 'package:soul_dungeon/core/events/combat_milestone_event.dart';
import 'package:soul_dungeon/core/events/deck_shuffled_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';

void main() {
  group('E8 덱/전투 사운드 통합', () {
    late GameEventBus bus;

    setUp(() {
      bus = GameEventBus();
    });

    tearDown(() {
      bus.dispose();
    });

    test('덱 셔플 이벤트 → SFX 매핑', () {
      final event = DeckShuffledEvent();
      bus.emit(event);

      expect(SfxRegistry.pathFor('deck_shuffle'), isNotNull);
      expect(bus.history, contains(event));
    });

    test('카드 드로우 이벤트 → SFX 매핑', () {
      final event = CardDrawnEvent(count: 5);
      bus.emit(event);

      expect(event.count, 5);
      expect(SfxRegistry.pathFor('card_draw'), isNotNull);
    });

    test('카드 소진 이벤트 → SFX 매핑', () {
      final event = CardExhaustedEvent(
        cardId: 'test_card',
        cardName: '테스트 카드',
      );
      bus.emit(event);

      expect(event.cardId, 'test_card');
      expect(SfxRegistry.pathFor('card_exhaust'), isNotNull);
    });

    test('전투 마일스톤 4종 → SFX 매핑', () {
      for (final type in CombatMilestoneType.values) {
        final sfxId = SfxRegistry.sfxForCombatMilestone(type.name);
        expect(SfxRegistry.pathFor(sfxId), isNotNull,
            reason: '${type.name} SFX should be registered');
      }
    });

    test('전투 승리/패배 이벤트 브로드캐스트', () {
      bus.emit(CombatMilestoneEvent(type: CombatMilestoneType.victory));
      bus.emit(CombatMilestoneEvent(type: CombatMilestoneType.defeat));

      final milestones = bus.history
          .whereType<CombatMilestoneEvent>()
          .toList();
      expect(milestones, hasLength(2));
      expect(milestones[0].type, CombatMilestoneType.victory);
      expect(milestones[1].type, CombatMilestoneType.defeat);
    });

    test('SfxRegistry 카드타입 매핑', () {
      expect(SfxRegistry.sfxForCardType('attack'), 'card_attack');
      expect(SfxRegistry.sfxForCardType('skill'), 'card_skill');
      expect(SfxRegistry.sfxForCardType('power'), 'card_power');
      expect(SfxRegistry.sfxForCardType('unknown'), 'card_skill');
    });
  });
}
