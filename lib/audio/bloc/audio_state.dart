/// AudioBloc 상태 (sealed class -- switch exhaustiveness 보장)
sealed class AudioState {
  const AudioState();
}

/// 오디오 엔진 미초기화 상태.
final class AudioUninitialized extends AudioState {
  const AudioUninitialized();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AudioUninitialized;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// 오디오 준비 완료 — 재생 가능 상태.
final class AudioReady extends AudioState {
  final double masterVolume;
  final double sfxVolume;
  final double musicVolume;
  final bool sfxMuted;
  final bool musicMuted;

  const AudioReady({
    required this.masterVolume,
    required this.sfxVolume,
    required this.musicVolume,
    this.sfxMuted = false,
    this.musicMuted = false,
  });

  /// 하위호환: 전체 레이어 뮤트 시 true.
  bool get muted => sfxMuted && musicMuted;

  AudioReady copyWith({
    double? masterVolume,
    double? sfxVolume,
    double? musicVolume,
    bool? sfxMuted,
    bool? musicMuted,
  }) {
    return AudioReady(
      masterVolume: masterVolume ?? this.masterVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxMuted: sfxMuted ?? this.sfxMuted,
      musicMuted: musicMuted ?? this.musicMuted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioReady &&
          runtimeType == other.runtimeType &&
          masterVolume == other.masterVolume &&
          sfxVolume == other.sfxVolume &&
          musicVolume == other.musicVolume &&
          sfxMuted == other.sfxMuted &&
          musicMuted == other.musicMuted;

  @override
  int get hashCode => Object.hash(
        masterVolume,
        sfxVolume,
        musicVolume,
        sfxMuted,
        musicMuted,
      );

  @override
  String toString() =>
      'AudioReady(master: $masterVolume, sfx: $sfxVolume, '
      'music: $musicVolume, '
      'sfxMuted: $sfxMuted, musicMuted: $musicMuted)';
}

/// 오디오 초기화 실패.
final class AudioError extends AudioState {
  final String message;

  const AudioError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'AudioError($message)';
}
