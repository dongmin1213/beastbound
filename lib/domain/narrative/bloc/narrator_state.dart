import 'package:equatable/equatable.dart';

/// 서술자 신뢰도 상태 -- sealed class hierarchy.
sealed class NarratorState extends Equatable {
  final int currentFloor;

  const NarratorState({this.currentFloor = 1});
}

/// 1층: 신뢰할 수 있는 서술자. 왜곡 없음.
final class NarratorReliable extends NarratorState {
  const NarratorReliable({super.currentFloor});

  @override
  List<Object?> get props => [currentFloor];
}

/// 2층+: 왜곡된 서술자. 층별 점진적 왜곡.
///
/// 2층: 미세 징조 (glitch 0.05, HP 오프셋 없음)
/// 3층: 본격 왜곡 (jamo level 1, HP ±3)
/// 4층: 심한 왜곡 (jamo level 2, HP ±5)
/// 5층: 완전 왜곡 + 침묵 (jamo level 2, HP ±5, silent)
final class NarratorDistorted extends NarratorState {
  final int hpLieOffset;
  final bool silent;

  /// 카드 왜곡 수준: 0=글리치만(2층), 1=숫자왜곡(3층), 2=전체왜곡(4~5층).
  final int cardDistortionLevel;

  /// 미세 글리치 확률 (0.0~1.0). 2층 전용 미세 징조.
  final double microGlitchProbability;

  /// 관찰/분석 사용 후 진실 표시 잔여 턴 수.
  final int truthRevealTurnsRemaining;

  const NarratorDistorted({
    super.currentFloor,
    required this.hpLieOffset,
    this.silent = false,
    this.cardDistortionLevel = 1,
    this.microGlitchProbability = 0.0,
    this.truthRevealTurnsRemaining = 0,
  });

  /// 현재 왜곡이 활성 상태인지 (truthReveal로 일시 해제 가능).
  bool get isCardDistortionActive =>
      (cardDistortionLevel > 0 || microGlitchProbability > 0) &&
      truthRevealTurnsRemaining <= 0;

  NarratorDistorted copyWith({
    int? currentFloor,
    int? hpLieOffset,
    bool? silent,
    int? cardDistortionLevel,
    double? microGlitchProbability,
    int? truthRevealTurnsRemaining,
  }) {
    return NarratorDistorted(
      currentFloor: currentFloor ?? this.currentFloor,
      hpLieOffset: hpLieOffset ?? this.hpLieOffset,
      silent: silent ?? this.silent,
      cardDistortionLevel: cardDistortionLevel ?? this.cardDistortionLevel,
      microGlitchProbability:
          microGlitchProbability ?? this.microGlitchProbability,
      truthRevealTurnsRemaining:
          truthRevealTurnsRemaining ?? this.truthRevealTurnsRemaining,
    );
  }

  @override
  List<Object?> get props => [
        currentFloor,
        hpLieOffset,
        silent,
        cardDistortionLevel,
        microGlitchProbability,
        truthRevealTurnsRemaining,
      ];
}
