import 'package:soul_dungeon/core/events/game_event.dart';

/// 전투 보상 이벤트 — 전투 승리 시 GameEventBus를 통해 발행.
/// core → domain 의존 방지를 위해 primitive 필드 사용.
class CombatRewardEvent extends GameEvent {
  final int goldAmount;
  final String? rewardTag;

  CombatRewardEvent({required this.goldAmount, this.rewardTag});

  @override
  String toString() => 'CombatRewardEvent(goldAmount: $goldAmount, rewardTag: $rewardTag)';
}
