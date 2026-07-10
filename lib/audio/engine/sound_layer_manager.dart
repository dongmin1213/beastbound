/// 3-layer 오디오 매니저 인터페이스.
///
/// SFX / Music / UI 3개 레이어를 독립 제어.
/// flutter_soloud 등 구체 구현체는 이 인터페이스를 구현.
abstract class SoundLayerManager {
  /// 오디오 엔진 초기화.
  Future<void> initialize();

  /// 오디오 엔진 해제.
  void dispose();

  /// SFX 1회 재생 (단발성).
  Future<void> playSfx(String assetPath, {double volume = 1.0});

  /// 배경 음악 재생 (기존 음악 정지 → 새 트랙 시작).
  Future<void> playMusic(String assetPath,
      {double volume = 1.0, bool loop = true});

  /// 음악 정지.
  void stopMusic();

  /// 음악 일시정지.
  void pauseMusic();

  /// 음악 재개.
  void resumeMusic();

  /// 모든 사운드 정지 (SFX + Music).
  void stopAll();

  /// 마스터 볼륨 설정 (0.0~1.0).
  void setMasterVolume(double volume);

  /// SFX 볼륨 설정 (0.0~1.0).
  void setSfxVolume(double volume);

  /// 음악 볼륨 설정 (0.0~1.0).
  void setMusicVolume(double volume);

  /// 초기화 완료 여부.
  bool get isInitialized;
}

/// No-op 구현 — 실제 오디오 에셋 추가 전 사용.
///
/// 모든 메서드가 무동작. 테스트에서도 안전하게 사용 가능.
class NoOpSoundLayerManager implements SoundLayerManager {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  void dispose() {
    _initialized = false;
  }

  @override
  Future<void> playSfx(String assetPath, {double volume = 1.0}) async {}

  @override
  Future<void> playMusic(String assetPath,
      {double volume = 1.0, bool loop = true}) async {}

  @override
  void stopMusic() {}

  @override
  void pauseMusic() {}

  @override
  void resumeMusic() {}

  @override
  void stopAll() {}

  @override
  void setMasterVolume(double volume) {}

  @override
  void setSfxVolume(double volume) {}

  @override
  void setMusicVolume(double volume) {}

  @override
  bool get isInitialized => _initialized;
}
