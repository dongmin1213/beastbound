/// 미스터리 방 결과 모델 — sealed class (Dart 3 switch exhaustiveness).
/// Equatable 미사용, 수동 ==/hashCode 오버라이드 (ShopItem 패턴).
sealed class MysteryOutcome {
  final String narrativeText;

  const MysteryOutcome({required this.narrativeText});

  /// 골드 변화량 (양수=획득, 0=없음).
  int get goldChange;

  /// HP 변화량 (음수=손실, 0=없음).
  int get hpChange;
}

class TreasureOutcome extends MysteryOutcome {
  final int goldReward;

  const TreasureOutcome({
    required this.goldReward,
    required super.narrativeText,
  });

  @override
  int get goldChange => goldReward;

  @override
  int get hpChange => 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreasureOutcome &&
          goldReward == other.goldReward &&
          narrativeText == other.narrativeText;

  @override
  int get hashCode => Object.hash(goldReward, narrativeText);

  @override
  String toString() => 'TreasureOutcome(gold: $goldReward)';
}

class TrapOutcome extends MysteryOutcome {
  final int hpLoss;

  const TrapOutcome({
    required this.hpLoss,
    required super.narrativeText,
  });

  @override
  int get goldChange => 0;

  @override
  int get hpChange => -hpLoss;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrapOutcome &&
          hpLoss == other.hpLoss &&
          narrativeText == other.narrativeText;

  @override
  int get hashCode => Object.hash(hpLoss, narrativeText);

  @override
  String toString() => 'TrapOutcome(hpLoss: $hpLoss)';
}

class EncounterOutcome extends MysteryOutcome {
  final int goldReward;

  const EncounterOutcome({
    required this.goldReward,
    required super.narrativeText,
  });

  @override
  int get goldChange => goldReward;

  @override
  int get hpChange => 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncounterOutcome &&
          goldReward == other.goldReward &&
          narrativeText == other.narrativeText;

  @override
  int get hashCode => Object.hash(goldReward, narrativeText);

  @override
  String toString() => 'EncounterOutcome(gold: $goldReward)';
}

class EventOutcome extends MysteryOutcome {
  final int goldReward;

  const EventOutcome({
    required this.goldReward,
    required super.narrativeText,
  });

  @override
  int get goldChange => goldReward;

  @override
  int get hpChange => 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventOutcome &&
          goldReward == other.goldReward &&
          narrativeText == other.narrativeText;

  @override
  int get hashCode => Object.hash(goldReward, narrativeText);

  @override
  String toString() => 'EventOutcome(gold: $goldReward)';
}

class MinorOutcome extends MysteryOutcome {
  final int goldReward;

  const MinorOutcome({
    required this.goldReward,
    required super.narrativeText,
  });

  @override
  int get goldChange => goldReward;

  @override
  int get hpChange => 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinorOutcome &&
          goldReward == other.goldReward &&
          narrativeText == other.narrativeText;

  @override
  int get hashCode => Object.hash(goldReward, narrativeText);

  @override
  String toString() => 'MinorOutcome(gold: $goldReward)';
}
