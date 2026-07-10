import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_event.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_state.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_event.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_state.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_event.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_state.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_event.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_state.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_state.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/event_room_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/mystery_room_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/npc_room_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/rest_room_handler.dart';
import 'package:soul_dungeon/presentation/screens/game/rooms/shop_room_handler.dart';
import 'package:soul_dungeon/presentation/widgets/event/event_widget.dart';
import 'package:soul_dungeon/presentation/widgets/mystery/mystery_widget.dart';
import 'package:soul_dungeon/presentation/widgets/npc/npc_widget.dart';
import 'package:soul_dungeon/domain/progression/memory/memory_fragment_pool.dart';
import 'package:soul_dungeon/presentation/widgets/rest/memory_exploration_widget.dart';
import 'package:soul_dungeon/presentation/widgets/rest/rest_widget.dart';
import 'package:soul_dungeon/presentation/widgets/shop/shop_widget.dart';

/// 방 유형별 BlocBuilder 위젯 목록 — GameScreen에서 추출 (Step 5).
///
/// Shop/Mystery/Event/Rest/NPC 5개 BlocBuilder를 조건부로 빌드한다.
class RoomWidgetBuilder {
  const RoomWidgetBuilder._();

  static List<Widget> build({
    required ShopRoomHandler shopHandler,
    required MysteryRoomHandler mysteryHandler,
    required EventRoomHandler eventHandler,
    required RestRoomHandler restHandler,
    required NpcRoomHandler npcHandler,
    required double blockSpacing,
    Set<String> unlockedMemoryIds = const {},
    Color? frameBackground,
  }) {
    return [
      // 상점 위젯
      if (shopHandler.isShowing && shopHandler.bloc != null)
        BlocBuilder<ShopBloc, ShopState>(
          bloc: shopHandler.bloc,
          builder: (context, shopState) {
            if (shopState is ShopReady) {
              return Padding(
                padding: EdgeInsets.only(bottom: blockSpacing),
                child: ShopWidget(
                  items: shopState.items,
                  gold: shopState.gold,
                  onBuy: shopHandler.onBuy,
                  onLeave: shopHandler.onLeave,
                  frameBackground: frameBackground,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      // 미스터리 위젯
      if (mysteryHandler.isShowing && mysteryHandler.bloc != null)
        BlocBuilder<MysteryBloc, MysteryState>(
          bloc: mysteryHandler.bloc,
          builder: (context, mysteryState) {
            if (mysteryState is MysteryRevealed) {
              return Padding(
                padding: EdgeInsets.only(bottom: blockSpacing),
                child: MysteryWidget(
                  outcome: mysteryState.outcome,
                  onProceed: () {
                    mysteryHandler.bloc!.add(const AcceptResult());
                  },
                  frameBackground: frameBackground,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      // 이벤트 위젯
      if (eventHandler.isShowing && eventHandler.bloc != null)
        BlocBuilder<EventRoomBloc, EventRoomState>(
          bloc: eventHandler.bloc,
          builder: (context, eventState) {
            if (eventState is EventRoomReady) {
              return Padding(
                padding: EdgeInsets.only(bottom: blockSpacing),
                child: EventWidget(
                  data: eventState.data,
                  onChoiceSelected: (index) {
                    eventHandler.bloc!.add(SelectEventChoice(index));
                  },
                  frameBackground: frameBackground,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      // 휴식 위젯
      if (restHandler.isShowing && restHandler.bloc != null)
        BlocBuilder<RestBloc, RestState>(
          bloc: restHandler.bloc,
          builder: (context, restState) {
            if (restState is RestReady) {
              final fragments =
                  MemoryFragmentPool.unlockedFragments(unlockedMemoryIds);
              return Padding(
                padding: EdgeInsets.only(bottom: blockSpacing),
                child: RestWidget(
                  currentHp: restState.currentHp,
                  maxHp: restState.maxHp,
                  healAmount: restState.healAmount,
                  upgradeAmount: restState.upgradeAmount,
                  onChooseHeal: () {
                    restHandler.bloc!.add(const ChooseHeal());
                  },
                  onChooseUpgrade: () {
                    restHandler.bloc!.add(const ChooseUpgrade());
                  },
                  unlockedMemoryCount: fragments.length,
                  totalMemoryCount: MemoryFragmentPool.totalCount,
                  onExploreMemory: fragments.isNotEmpty
                      ? () {
                          final first = fragments.first;
                          restHandler.bloc!.add(ExploreMemory(
                            memoryId: first.id,
                            memoryTitle: first.title,
                            memoryDescription: first.description,
                          ));
                        }
                      : null,
                  frameBackground: frameBackground,
                ),
              );
            }
            if (restState is MemoryExploring) {
              final fragments =
                  MemoryFragmentPool.unlockedFragments(unlockedMemoryIds);
              return Padding(
                padding: EdgeInsets.only(bottom: blockSpacing),
                child: MemoryExplorationWidget(
                  unlockedFragments: fragments,
                  onSelectFragment: (fragment) {
                    restHandler.bloc!.add(ExploreMemory(
                      memoryId: fragment.id,
                      memoryTitle: fragment.title,
                      memoryDescription: fragment.description,
                    ));
                  },
                  onBack: () {
                    restHandler.bloc!
                        .add(const CompleteMemoryExploration());
                  },
                  frameBackground: frameBackground,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      // NPC 위젯
      if (npcHandler.isShowing && npcHandler.bloc != null)
        BlocBuilder<NpcBloc, NpcState>(
          bloc: npcHandler.bloc,
          builder: (context, npcState) {
            if (npcState is NpcReady) {
              return Padding(
                padding: EdgeInsets.only(bottom: blockSpacing),
                child: NpcWidget(
                  npc: npcState.npc,
                  playerGold: npcState.playerGold,
                  dialogueRead: npcState.dialogueRead,
                  onPurchase: npcHandler.onBuy,
                  onReadDialogue: () {
                    npcHandler.bloc!.add(const ReadDialogue());
                  },
                  onLeave: () {
                    npcHandler.bloc!.add(const LeaveNpc());
                  },
                  frameBackground: frameBackground,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
    ];
  }
}
