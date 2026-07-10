/// 기세 변동 사유
enum MomentumChangeReason {
  actionSwitch,
  sameAction,
  sameActionStreak,
  environmentAction,
  specialAction,
  cardTypeSwitch,
  none,
}

/// 기세 단계 (임계값 기반)
enum MomentumTier {
  low,
  medium,
  high;

  String get displayName => switch (this) {
        MomentumTier.low => '저',
        MomentumTier.medium => '중',
        MomentumTier.high => '고',
      };
}

/// 기세 변동 결과 데이터
class MomentumDelta {
  final int value;
  final MomentumChangeReason reason;

  const MomentumDelta({
    required this.value,
    required this.reason,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MomentumDelta &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(value, reason);

  @override
  String toString() => 'MomentumDelta(value: $value, reason: $reason)';
}
