import 'package:collection/collection.dart';

/// 이벤트 방 선택지 모델.
/// 수동 ==/hashCode 오버라이드 (MysteryOutcome 패턴).
class EventChoice {
  final String label;
  final String outcomeText;
  final int goldChange;
  final int hpChange;

  /// 보상으로 받는 카드 ID (null=없음).
  final String? cardRewardId;

  /// 랜덤 카드 제거 여부.
  final bool removeRandomCard;

  /// 랜덤 카드 업그레이드 여부.
  final bool upgradeRandomCard;

  const EventChoice({
    required this.label,
    required this.outcomeText,
    required this.goldChange,
    required this.hpChange,
    this.cardRewardId,
    this.removeRandomCard = false,
    this.upgradeRandomCard = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventChoice &&
          label == other.label &&
          outcomeText == other.outcomeText &&
          goldChange == other.goldChange &&
          hpChange == other.hpChange &&
          cardRewardId == other.cardRewardId &&
          removeRandomCard == other.removeRandomCard &&
          upgradeRandomCard == other.upgradeRandomCard;

  @override
  int get hashCode => Object.hash(
      label,
      outcomeText,
      goldChange,
      hpChange,
      cardRewardId,
      removeRandomCard,
      upgradeRandomCard);

  @override
  String toString() =>
      'EventChoice(label: $label, gold: $goldChange, hp: $hpChange, '
      'cardRewardId: $cardRewardId, '
      'removeRandomCard: $removeRandomCard, upgradeRandomCard: $upgradeRandomCard)';
}

/// 이벤트 방 데이터 모델.
/// choices 리스트는 List.unmodifiable로 불변 보장.
class EventRoomData {
  final String title;
  final String narrativeText;
  final List<EventChoice> choices;

  EventRoomData({
    required this.title,
    required this.narrativeText,
    required List<EventChoice> choices,
  }) : choices = List.unmodifiable(choices);

  static const _listEquality = ListEquality<EventChoice>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventRoomData &&
          title == other.title &&
          narrativeText == other.narrativeText &&
          _listEquality.equals(choices, other.choices);

  @override
  int get hashCode =>
      Object.hash(title, narrativeText, _listEquality.hash(choices));

  @override
  String toString() =>
      'EventRoomData(title: $title, choices: ${choices.length})';
}
