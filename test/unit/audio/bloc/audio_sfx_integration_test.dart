import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/audio/bloc/audio_bloc.dart';
import 'package:soul_dungeon/audio/engine/sound_layer_manager.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/card_played_event.dart';
import 'package:soul_dungeon/core/events/deck_shuffled_event.dart';
import 'package:soul_dungeon/core/events/card_drawn_event.dart';
import 'package:soul_dungeon/core/events/card_exhausted_event.dart';
import 'package:soul_dungeon/core/events/combat_milestone_event.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/status_effect_applied_event.dart';
import 'package:soul_dungeon/core/events/truth_reveal_event.dart';

class MockSoundLayerManager extends NoOpSoundLayerManager {
  final List<String> playedSfxPaths = [];

  @override
  Future<void> playSfx(String assetPath, {double volume = 1.0}) async {
    playedSfxPaths.add(assetPath);
  }
}

void main() {
  const config = AudioConfig();
  late GameEventBus gameEventBus;
  late MockSoundLayerManager soundManager;
  late AudioBloc bloc;

  setUp(() {
    gameEventBus = GameEventBus();
    soundManager = MockSoundLayerManager();
    bloc = AudioBloc(
      soundManager: soundManager,
      eventBus: gameEventBus,
      config: config,
    );
  });

  tearDown(() async {
    await bloc.close();
    gameEventBus.dispose();
  });

  group('AudioBloc SFX Integration', () {
    test('CardPlayedEvent -> playSfx called with correct path', () async {
      // Initialize audio
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<AudioReady>());

      // Emit card played event
      gameEventBus.emit(CardPlayedEvent(
        cardType: 'attack',
        cardId: 'test_card_1',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/card_attack.ogg',
      ));
    });

    test('CardPlayedEvent skill type -> card_skill SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(CardPlayedEvent(
        cardType: 'skill',
        cardId: 'test_card_2',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/card_skill.ogg',
      ));
    });

    test('CardPlayedEvent power type -> card_power SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(CardPlayedEvent(
        cardType: 'power',
        cardId: 'test_card_3',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/card_power.ogg',
      ));
    });

    test('muted state -> CardPlayedEvent does not trigger playSfx', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      // Mute
      bloc.add(const ToggleMute());
      await Future<void>.delayed(Duration.zero);
      expect((bloc.state as AudioReady).muted, isTrue);

      // Emit card played event
      gameEventBus.emit(CardPlayedEvent(
        cardType: 'attack',
        cardId: 'test_card_4',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, isEmpty);
    });

    test('StatusEffectAppliedEvent poison -> status_poison SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(StatusEffectAppliedEvent(
        effectType: 'poison',
        target: 'enemy',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/status_poison.ogg',
      ));
    });

    test('StatusEffectAppliedEvent strength -> status_buff SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(StatusEffectAppliedEvent(
        effectType: 'strength',
        target: 'player',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/status_buff.ogg',
      ));
    });

    test('StatusEffectAppliedEvent weak -> status_debuff SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(StatusEffectAppliedEvent(
        effectType: 'weak',
        target: 'player',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/status_debuff.ogg',
      ));
    });

    test('muted state -> StatusEffectAppliedEvent does not trigger playSfx',
        () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const ToggleMute());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(StatusEffectAppliedEvent(
        effectType: 'poison',
        target: 'enemy',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, isEmpty);
    });

    test('uninitialized -> CardPlayedEvent ignored', () async {
      // Do NOT initialize audio
      expect(bloc.state, isA<AudioUninitialized>());

      gameEventBus.emit(CardPlayedEvent(
        cardType: 'attack',
        cardId: 'test_card_5',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, isEmpty);
    });

    test('uninitialized -> StatusEffectAppliedEvent ignored', () async {
      expect(bloc.state, isA<AudioUninitialized>());

      gameEventBus.emit(StatusEffectAppliedEvent(
        effectType: 'burn',
        target: 'enemy',
      ));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, isEmpty);
    });

    // P1: 덱 조작 SFX 테스트
    test('DeckShuffledEvent triggers deck_shuffle SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<AudioReady>());

      gameEventBus.emit(DeckShuffledEvent());
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/deck_shuffle.ogg',
      ));
    });

    test('CardDrawnEvent triggers card_draw SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(CardDrawnEvent(count: 5));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/card_draw.ogg',
      ));
    });

    test('CardExhaustedEvent triggers card_exhaust SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(CardExhaustedEvent(cardId: 'test', cardName: '테스트'));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/card_exhaust.ogg',
      ));
    });

    test('CombatMilestoneEvent victory triggers combat_victory SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(CombatMilestoneEvent(type: CombatMilestoneType.victory));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/combat_victory.ogg',
      ));
    });

    // P2: 서술자 왜곡 SFX 테스트
    test('TruthRevealEvent triggers narrator_truth_reveal SFX', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(TruthRevealEvent(turns: 2));
      await Future<void>.delayed(Duration.zero);

      expect(soundManager.playedSfxPaths, contains(
        'assets/audio/sfx/narrator_truth_reveal.ogg',
      ));
    });

    test('FloorCompletedEvent for floor 2 triggers BGM change', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(FloorCompletedEvent(floorNumber: 2));
      await Future<void>.delayed(Duration.zero);

      // FloorCompletedEvent는 탐색 BGM 전환만 담당 (narrator SFX는 별도 시스템)
      expect(soundManager.playedSfxPaths, isNot(contains(
        'assets/audio/sfx/narrator_distortion.ogg',
      )));
    });

    test('FloorCompletedEvent for floor 4 triggers BGM change', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(FloorCompletedEvent(floorNumber: 4));
      await Future<void>.delayed(Duration.zero);

      // BGM 전환만 — narrator SFX는 별도
      expect(soundManager.playedSfxPaths, isNot(contains(
        'assets/audio/sfx/narrator_silence.ogg',
      )));
    });

    test('FloorCompletedEvent for floor 5 triggers BGM change', () async {
      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);

      gameEventBus.emit(FloorCompletedEvent(floorNumber: 5));
      await Future<void>.delayed(Duration.zero);

      // BGM 전환만 — narrator SFX는 별도
      expect(soundManager.playedSfxPaths, isNot(contains(
        'assets/audio/sfx/narrator_silence.ogg',
      )));
    });
  });
}
