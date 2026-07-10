import 'package:soul_dungeon/core/events/game_event.dart';

/// NPC 상호작용 이벤트 — NpcBloc이 PurchaseItem/LeaveNpc 처리 시 발행.
/// primitive/String 타입만 사용 — core → domain 역방향 의존 방지.
/// 향후 통계/세이브 시스템 연동용.
class NpcInteractionEvent extends GameEvent {
  final String npcName;
  final String interactionType;
  final int goldChange;

  NpcInteractionEvent({
    required this.npcName,
    required this.interactionType,
    required this.goldChange,
  });

  @override
  String toString() =>
      'NpcInteractionEvent(npcName: $npcName, interactionType: $interactionType, goldChange: $goldChange)';
}
