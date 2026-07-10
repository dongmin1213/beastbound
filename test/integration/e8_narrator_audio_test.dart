import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/audio/engine/sfx_registry.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/truth_reveal_event.dart';

void main() {
  group('E8 서술자 오디오 통합', () {
    late GameEventBus bus;

    setUp(() {
      bus = GameEventBus();
    });

    tearDown(() {
      bus.dispose();
    });

    test('서술자 왜곡 SFX 3종 등록 확인', () {
      expect(SfxRegistry.pathFor('narrator_distortion'), isNotNull);
      expect(SfxRegistry.pathFor('narrator_truth_reveal'), isNotNull);
      expect(SfxRegistry.pathFor('narrator_silence'), isNotNull);
    });

    test('sfxForNarratorEvent 매핑', () {
      expect(SfxRegistry.sfxForNarratorEvent('distortion'),
          'narrator_distortion');
      expect(SfxRegistry.sfxForNarratorEvent('truth_reveal'),
          'narrator_truth_reveal');
      expect(SfxRegistry.sfxForNarratorEvent('silence'), 'narrator_silence');
      expect(SfxRegistry.sfxForNarratorEvent('unknown'),
          'narrator_distortion'); // default
    });

    test('TruthRevealEvent 브로드캐스트', () {
      bus.emit(TruthRevealEvent(turns: 3));

      final events = bus.history.whereType<TruthRevealEvent>().toList();
      expect(events, hasLength(1));
    });

    test('SFX 카운트 포함 narrator 3종', () {
      final allIds = SfxRegistry.allIds;
      expect(allIds, contains('narrator_distortion'));
      expect(allIds, contains('narrator_truth_reveal'));
      expect(allIds, contains('narrator_silence'));
    });

    test('상태 효과 SFX 매핑 통합', () {
      expect(SfxRegistry.sfxForStatusEffect('poison'), 'status_poison');
      expect(SfxRegistry.sfxForStatusEffect('burn'), 'status_burn');
      expect(SfxRegistry.sfxForStatusEffect('weak'), 'status_debuff');
      expect(SfxRegistry.sfxForStatusEffect('strength'), 'status_buff');
    });
  });
}
