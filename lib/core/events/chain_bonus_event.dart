import 'package:soul_dungeon/core/events/game_event.dart';

/// 연쇄 보너스 발동 이벤트 — 같은 타입 카드 2연쇄+ 시 emit.
/// presentation 레이어에서 구독하여 연쇄 보너스 연출 표시.
class ChainBonusEvent extends GameEvent {
  final int chainCount;
  final int bonusPercent;

  ChainBonusEvent({
    required this.chainCount,
    required this.bonusPercent,
  });

  @override
  String toString() =>
      'ChainBonusEvent(chain: $chainCount, bonus: $bonusPercent%)';
}
