import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';

/// NpcBloc 이벤트 — sealed class (Dart 3 switch exhaustiveness).
sealed class NpcEvent {
  const NpcEvent();
}

/// NPC 만남 — NPC 데이터와 플레이어 보유 금화로 초기화.
final class MeetNpc extends NpcEvent {
  final NpcData npc;
  final int playerGold;

  const MeetNpc({required this.npc, required this.playerGold});
}

/// 대화 읽기.
final class ReadDialogue extends NpcEvent {
  const ReadDialogue();
}

/// NPC 아이템 구매 시도 — index로 지정.
final class PurchaseNpcItem extends NpcEvent {
  final int index;

  const PurchaseNpcItem(this.index);
}

/// NPC 떠나기 — 탐색으로 복귀.
final class LeaveNpc extends NpcEvent {
  const LeaveNpc();
}
