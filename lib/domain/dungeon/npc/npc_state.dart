import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';

/// NpcBloc 상태 — sealed class (Dart 3 switch exhaustiveness).
sealed class NpcState extends Equatable {
  const NpcState();
}

/// 초기 상태 — NPC 미만남.
final class NpcInitial extends NpcState {
  const NpcInitial();

  @override
  List<Object?> get props => [];
}

/// NPC 준비 완료 — NPC 데이터, 보유 금화, 대화 읽음 여부, 누적 소비 금화.
final class NpcReady extends NpcState {
  final NpcData npc;
  final int playerGold;
  final bool dialogueRead;
  final int totalGoldSpent;

  const NpcReady({
    required this.npc,
    required this.playerGold,
    required this.dialogueRead,
    this.totalGoldSpent = 0,
  });

  @override
  List<Object?> get props => [npc, playerGold, dialogueRead, totalGoldSpent];
}

/// NPC 종료 — 골드 보상, 카드 강화, 총 소비 금화.
final class NpcClosed extends NpcState {
  final int goldReward;
  final int totalGoldSpent;
  final bool upgradeRandomCard;

  const NpcClosed({
    required this.goldReward,
    required this.totalGoldSpent,
    this.upgradeRandomCard = false,
  });

  @override
  List<Object?> get props =>
      [goldReward, totalGoldSpent, upgradeRandomCard];
}
