import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soul_dungeon/audio/engine/sfx_registry.dart';
import 'package:soul_dungeon/audio/engine/sound_layer_manager.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';

/// SoLoud 기반 [SoundLayerManager] 구현.
///
/// SFX는 fire-and-forget (중첩 가능), Music은 단일 트랙 루프.
/// 모든 SoLoud 호출은 try-catch — 오디오 실패로 앱 크래시 절대 없음.
class SoLoudSoundLayerManager implements SoundLayerManager {
  /// SoLoud 인스턴스 — initialize() 시점에 초기화 (lazy).
  /// 생성자에서 SoLoud.instance 접근 시 native DLL 로딩 발생 → 테스트 실패.
  late final SoLoud _soloud;

  bool _initialized = false;

  /// preload된 SFX 소스 캐시 (asset path → AudioSource).
  final Map<String, AudioSource> _sfxSources = {};

  /// 현재 재생 중인 Music 핸들 + 소스.
  SoundHandle? _musicHandle;
  AudioSource? _musicSource;

  /// 레이어별 볼륨 (0.0~1.0). per-handle 볼륨 계산에 사용.
  double _masterVolume = 1.0;
  double _sfxVolume = 1.0;
  double _musicVolume = 1.0;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _soloud = SoLoud.instance;
      await _soloud.init();
      _initialized = true;

      // SFX 19종 전부 preload
      for (final id in SfxRegistry.allIds) {
        final path = SfxRegistry.pathFor(id);
        if (path == null) continue;
        try {
          final source = await _soloud.loadAsset(path);
          _sfxSources[path] = source;
        } catch (e) {
          GameLogger.warning(
            LogSystem.audio,
            'SFX preload failed: $path — $e',
          );
        }
      }

      GameLogger.info(
        LogSystem.audio,
        'SoLoud initialized, ${_sfxSources.length} SFX preloaded',
      );
    } catch (e) {
      GameLogger.error(LogSystem.audio, 'SoLoud init failed', e);
    }
  }

  @override
  void dispose() {
    if (!_initialized) return;
    try {
      _soloud.deinit();
    } catch (e) {
      GameLogger.warning(LogSystem.audio, 'SoLoud deinit error: $e');
    }
    _sfxSources.clear();
    _musicHandle = null;
    _musicSource = null;
    _initialized = false;
  }

  // ─── SFX ──────────────────────────────────────────────

  @override
  Future<void> playSfx(String assetPath, {double volume = 1.0}) async {
    if (!_initialized) return;
    try {
      var source = _sfxSources[assetPath];
      if (source == null) {
        // 미리 로드되지 않은 경우 lazy load
        source = await _soloud.loadAsset(assetPath);
        _sfxSources[assetPath] = source;
      }
      // fire-and-forget: handle 저장 안 함, 자동 소멸
      await _soloud.play(
        source,
        volume: _sfxVolume * volume,
      );
    } catch (e) {
      GameLogger.warning(LogSystem.audio, 'playSfx failed: $assetPath — $e');
    }
  }

  // ─── Music ────────────────────────────────────────────

  @override
  Future<void> playMusic(
    String assetPath, {
    double volume = 1.0,
    bool loop = true,
  }) async {
    if (!_initialized) return;
    try {
      // 이전 트랙이 있으면 페이드아웃 후 정지
      if (_musicHandle != null) {
        final oldHandle = _musicHandle!;
        final oldSource = _musicSource;
        _musicHandle = null;
        _musicSource = null;
        _soloud.fadeVolume(oldHandle, 0.0, const Duration(milliseconds: 300));
        // 페이드아웃 완료 대기 후 정리
        Future.delayed(const Duration(milliseconds: 320), () {
          try {
            _soloud.stop(oldHandle);
            if (oldSource != null) _soloud.disposeSource(oldSource);
          } catch (_) {}
        });
        // 잠시 대기 후 새 트랙 시작 (겹침 방지)
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }

      final source = await _soloud.loadAsset(assetPath);
      _musicSource = source;
      // 볼륨 0에서 시작 → 페이드인
      _musicHandle = await _soloud.play(
        source,
        volume: 0.0,
        looping: loop,
      );
      _soloud.fadeVolume(
        _musicHandle!,
        _musicVolume * volume,
        const Duration(milliseconds: 500),
      );
    } catch (e) {
      GameLogger.warning(
        LogSystem.audio,
        'playMusic failed: $assetPath — $e',
      );
    }
  }

  @override
  void stopMusic() {
    if (!_initialized) return;
    try {
      _stopMusicInternal();
    } catch (e) {
      GameLogger.warning(LogSystem.audio, 'stopMusic error: $e');
    }
  }

  void _stopMusicInternal() {
    if (_musicHandle != null) {
      _soloud.stop(_musicHandle!);
      _musicHandle = null;
    }
    if (_musicSource != null) {
      _soloud.disposeSource(_musicSource!);
      _musicSource = null;
    }
  }

  @override
  void pauseMusic() {
    if (!_initialized) return;
    try {
      if (_musicHandle != null) {
        _soloud.setPause(_musicHandle!, true);
      }
    } catch (e) {
      GameLogger.warning(LogSystem.audio, 'pauseMusic error: $e');
    }
  }

  @override
  void resumeMusic() {
    if (!_initialized) return;
    try {
      if (_musicHandle != null) {
        _soloud.setPause(_musicHandle!, false);
      }
    } catch (e) {
      GameLogger.warning(LogSystem.audio, 'resumeMusic error: $e');
    }
  }

  // ─── Stop All ─────────────────────────────────────────

  @override
  void stopAll() {
    if (!_initialized) return;
    try {
      _stopMusicInternal();
      // SFX는 fire-and-forget이므로 disposeAllSources로 전부 정지
      // 단, preload 캐시를 유지하기 위해 개별 소스는 보존.
      // SoLoud의 disposeAllSources는 너무 과하므로 deinit/init 없이
      // 현재 재생 중인 SFX는 자연 소멸에 맡김.
    } catch (e) {
      GameLogger.warning(LogSystem.audio, 'stopAll error: $e');
    }
  }

  // ─── Volume ───────────────────────────────────────────

  @override
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    if (!_initialized) return;
    try {
      // 글로벌 볼륨은 SoLoud 전체에 적용
      _soloud.setGlobalVolume(_masterVolume);
    } catch (e) {
      GameLogger.warning(LogSystem.audio, 'setMasterVolume error: $e');
    }
  }

  @override
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    // SFX는 fire-and-forget이라 기존 핸들 볼륨 변경 불가.
    // 다음 playSfx()부터 적용됨.
  }

  @override
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    if (!_initialized) return;
    try {
      if (_musicHandle != null) {
        _soloud.setVolume(_musicHandle!, _musicVolume);
      }
    } catch (e) {
      GameLogger.warning(LogSystem.audio, 'setMusicVolume error: $e');
    }
  }

}
