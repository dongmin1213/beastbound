/// 전투 보상 불변 모델.
/// rewardTag: null(일반), "elite_loot"(엘리트) — 범용 태그, E4에서 분기.
class CombatReward {
  final int goldAmount;
  final String? rewardTag;

  const CombatReward({required this.goldAmount, this.rewardTag});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombatReward &&
          goldAmount == other.goldAmount &&
          rewardTag == other.rewardTag;

  @override
  int get hashCode => Object.hash(goldAmount, rewardTag);

  @override
  String toString() =>
      'CombatReward(goldAmount: $goldAmount, rewardTag: $rewardTag)';
}
