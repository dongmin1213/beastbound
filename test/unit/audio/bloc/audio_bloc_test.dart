import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/audio/bloc/audio_bloc.dart';
import 'package:soul_dungeon/audio/engine/sound_layer_manager.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';

void main() {
  const config = AudioConfig();
  late GameEventBus gameEventBus;
  late NoOpSoundLayerManager soundManager;

  setUp(() {
    gameEventBus = GameEventBus();
    soundManager = NoOpSoundLayerManager();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('AudioBloc', () {
    blocTest<AudioBloc, AudioState>(
      '초기 상태: AudioUninitialized',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      verify: (bloc) {
        expect(bloc.state, isA<AudioUninitialized>());
      },
    );

    blocTest<AudioBloc, AudioState>(
      'InitializeAudio -> AudioReady (config 기본 볼륨)',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      act: (bloc) => bloc.add(const InitializeAudio()),
      expect: () => [
        const AudioReady(
          masterVolume: 0.8,
          sfxVolume: 1.0,
          musicVolume: 0.7,

        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'InitializeAudio with custom config -> AudioReady with custom volumes',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: const AudioConfig(
          masterVolume: 0.5,
          sfxVolume: 0.6,
          musicVolume: 0.4,

        ),
      ),
      act: (bloc) => bloc.add(const InitializeAudio()),
      expect: () => [
        const AudioReady(
          masterVolume: 0.5,
          sfxVolume: 0.6,
          musicVolume: 0.4,

        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'PlaySfx -> AudioReady 상태 유지 (상태 변경 없음)',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

      ),
      act: (bloc) => bloc.add(const PlaySfx('sword_hit')),
      expect: () => [],
    );

    blocTest<AudioBloc, AudioState>(
      'SetMasterVolume -> AudioReady.masterVolume 업데이트',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

      ),
      act: (bloc) => bloc.add(const SetMasterVolume(0.5)),
      expect: () => [
        const AudioReady(
          masterVolume: 0.5,
          sfxVolume: 1.0,
          musicVolume: 0.7,

        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'SetSfxVolume -> AudioReady.sfxVolume 업데이트',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

      ),
      act: (bloc) => bloc.add(const SetSfxVolume(0.3)),
      expect: () => [
        const AudioReady(
          masterVolume: 0.8,
          sfxVolume: 0.3,
          musicVolume: 0.7,

        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'SetMusicVolume -> AudioReady.musicVolume 업데이트',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

      ),
      act: (bloc) => bloc.add(const SetMusicVolume(0.9)),
      expect: () => [
        const AudioReady(
          masterVolume: 0.8,
          sfxVolume: 1.0,
          musicVolume: 0.9,

        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'ToggleMute -> muted true',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

      ),
      act: (bloc) => bloc.add(const ToggleMute()),
      expect: () => [
        const AudioReady(
          masterVolume: 0.8,
          sfxVolume: 1.0,
          musicVolume: 0.7,

          sfxMuted: true,
          musicMuted: true,

        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'ToggleMute 2회 -> muted false (토글)',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

      ),
      act: (bloc) {
        bloc.add(const ToggleMute());
        bloc.add(const ToggleMute());
      },
      expect: () => [
        const AudioReady(
          masterVolume: 0.8,
          sfxVolume: 1.0,
          musicVolume: 0.7,

          sfxMuted: true,
          musicMuted: true,

        ),
        const AudioReady(
          masterVolume: 0.8,
          sfxVolume: 1.0,
          musicVolume: 0.7,

          sfxMuted: false,
          musicMuted: false,

        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      '초기화 전 PlaySfx -> 무시 (AudioUninitialized 상태)',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      act: (bloc) => bloc.add(const PlaySfx('sword_hit')),
      expect: () => [],
    );

    blocTest<AudioBloc, AudioState>(
      '초기화 전 SetMasterVolume -> 무시 (AudioUninitialized 상태)',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      act: (bloc) => bloc.add(const SetMasterVolume(0.5)),
      expect: () => [],
    );

    blocTest<AudioBloc, AudioState>(
      '초기화 전 ToggleMute -> 무시 (AudioUninitialized 상태)',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      act: (bloc) => bloc.add(const ToggleMute()),
      expect: () => [],
    );

    blocTest<AudioBloc, AudioState>(
      'muted 상태에서 PlaySfx -> 재생 안 함 (상태 변경 없음)',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

        sfxMuted: true,
        musicMuted: true,

      ),
      act: (bloc) => bloc.add(const PlaySfx('sword_hit')),
      expect: () => [],
    );

    blocTest<AudioBloc, AudioState>(
      '볼륨 클램핑: SetMasterVolume(1.5) -> 1.0 으로 클램핑',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

      ),
      act: (bloc) => bloc.add(const SetMasterVolume(1.5)),
      expect: () => [
        const AudioReady(
          masterVolume: 1.0,
          sfxVolume: 1.0,
          musicVolume: 0.7,

        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      '볼륨 클램핑: SetSfxVolume(-0.5) -> 0.0 으로 클램핑',
      build: () => AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      ),
      seed: () => const AudioReady(
        masterVolume: 0.8,
        sfxVolume: 1.0,
        musicVolume: 0.7,

      ),
      act: (bloc) => bloc.add(const SetSfxVolume(-0.5)),
      expect: () => [
        const AudioReady(
          masterVolume: 0.8,
          sfxVolume: 0.0,
          musicVolume: 0.7,

        ),
      ],
    );

    test('close() -> soundManager.dispose() 호출', () async {
      final bloc = AudioBloc(
        soundManager: soundManager,
        eventBus: gameEventBus,
        config: config,
      );

      bloc.add(const InitializeAudio());
      await Future<void>.delayed(Duration.zero);
      expect(soundManager.isInitialized, isTrue);

      await bloc.close();
      expect(soundManager.isInitialized, isFalse);
    });
  });
}
