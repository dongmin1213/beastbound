import 'package:equatable/equatable.dart';

/// AudioBloc 이벤트 (sealed class -- switch exhaustiveness 보장)
sealed class AudioEvent extends Equatable {
  const AudioEvent();
}

/// 오디오 엔진 초기화 요청.
final class InitializeAudio extends AudioEvent {
  const InitializeAudio();

  @override
  List<Object?> get props => [];
}

/// SFX 1회 재생 요청.
final class PlaySfx extends AudioEvent {
  final String sfxId;

  const PlaySfx(this.sfxId);

  @override
  List<Object?> get props => [sfxId];
}

/// 배경 음악 재생 요청.
final class PlayBgm extends AudioEvent {
  final String bgmId;

  const PlayBgm(this.bgmId);

  @override
  List<Object?> get props => [bgmId];
}

/// 배경 음악 정지 요청.
final class StopBgm extends AudioEvent {
  const StopBgm();

  @override
  List<Object?> get props => [];
}

/// 배경 음악 일시정지 요청 (앱 백그라운드 전환 등).
final class PauseBgm extends AudioEvent {
  const PauseBgm();

  @override
  List<Object?> get props => [];
}

/// 배경 음악 재개 요청 (앱 포그라운드 복귀 등).
final class ResumeBgm extends AudioEvent {
  const ResumeBgm();

  @override
  List<Object?> get props => [];
}

/// 마스터 볼륨 변경.
final class SetMasterVolume extends AudioEvent {
  final double volume;

  const SetMasterVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// SFX 볼륨 변경.
final class SetSfxVolume extends AudioEvent {
  final double volume;

  const SetSfxVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// 음악 볼륨 변경.
final class SetMusicVolume extends AudioEvent {
  final double volume;

  const SetMusicVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// 전체 뮤트 토글 (SFX + Music 동시).
final class ToggleMute extends AudioEvent {
  const ToggleMute();

  @override
  List<Object?> get props => [];
}

/// SFX 레이어 뮤트 토글.
final class ToggleSfxMute extends AudioEvent {
  const ToggleSfxMute();

  @override
  List<Object?> get props => [];
}

/// 음악 레이어 뮤트 토글.
final class ToggleMusicMute extends AudioEvent {
  const ToggleMusicMute();

  @override
  List<Object?> get props => [];
}

