import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/npc_interaction_event.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_event.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_state.dart';

/// NPC Bloc — 생성자 주입, 3파일 분리.
/// NPC 대화/거래 로직 담당. presentation 의존 없음.
class NpcBloc extends Bloc<NpcEvent, NpcState> {
  final GameEventBus gameEventBus;

  NpcBloc({required this.gameEventBus}) : super(const NpcInitial()) {
    on<MeetNpc>(_onMeetNpc);
    on<ReadDialogue>(_onReadDialogue);
    on<PurchaseNpcItem>(_onPurchaseNpcItem);
    on<LeaveNpc>(_onLeaveNpc);
  }

  void _onMeetNpc(MeetNpc event, Emitter<NpcState> emit) {
    emit(NpcReady(
      npc: event.npc,
      playerGold: event.playerGold,
      dialogueRead: false,
    ));
  }

  void _onReadDialogue(ReadDialogue event, Emitter<NpcState> emit) {
    final currentState = state;
    if (currentState is! NpcReady) return;

    emit(NpcReady(
      npc: currentState.npc,
      playerGold: currentState.playerGold,
      dialogueRead: true,
      totalGoldSpent: currentState.totalGoldSpent,
    ));
  }

  void _onPurchaseNpcItem(PurchaseNpcItem event, Emitter<NpcState> emit) {
    final currentState = state;
    if (currentState is! NpcReady) return;

    final index = event.index;

    // 범위 검증
    if (index < 0 || index >= currentState.npc.tradeItems.length) return;

    final item = currentState.npc.tradeItems[index];

    // 이미 판매됨
    if (item.sold) return;

    // 골드 부족
    if (currentState.playerGold < item.price) return;

    // 구매 성공
    final updatedItems = List.of(currentState.npc.tradeItems);
    updatedItems[index] = item.copyWith(sold: true);
    final updatedNpc = currentState.npc.copyWith(tradeItems: updatedItems);
    final newGold = currentState.playerGold - item.price;

    final newTotalGoldSpent = currentState.totalGoldSpent + item.price;

    // NpcInteractionEvent GameEventBus 발행
    gameEventBus.emit(NpcInteractionEvent(
      npcName: currentState.npc.name,
      interactionType: 'trade',
      goldChange: -item.price,
    ));

    emit(NpcReady(
      npc: updatedNpc,
      playerGold: newGold,
      dialogueRead: currentState.dialogueRead,
      totalGoldSpent: newTotalGoldSpent,
    ));
  }

  void _onLeaveNpc(LeaveNpc event, Emitter<NpcState> emit) {
    final currentState = state;
    if (currentState is! NpcReady) return;

    final dialogueRead = currentState.dialogueRead;
    final npc = currentState.npc;

    final goldReward =
        dialogueRead && npc.goldReward > 0 ? npc.goldReward : 0;
    final upgradeRandomCard = dialogueRead && npc.upgradeRandomCard;

    // NpcInteractionEvent GameEventBus 발행
    gameEventBus.emit(NpcInteractionEvent(
      npcName: npc.name,
      interactionType: 'leave',
      goldChange: goldReward,
    ));

    emit(NpcClosed(
      goldReward: goldReward,
      totalGoldSpent: currentState.totalGoldSpent,
      upgradeRandomCard: upgradeRandomCard,
    ));
  }
}
