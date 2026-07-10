import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/domain/build/bloc/build_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_state.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_state.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_state.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_state.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_state.dart';

/// BlocListener 조건부 래핑 — GameScreen에서 추출 (Step 5).
///
/// Build/Dungeon/Shop/Mystery/Rest/Event/NPC 7개의 BlocListener를
/// 조건부로 중첩하여 child를 감싼다.
class BlocListenerStack extends StatelessWidget {
  final Widget child;

  final BuildBloc buildBloc;
  final void Function(BuildContext, BuildState) onBuildStateChanged;

  final DungeonBloc? dungeonBloc;
  final void Function(BuildContext, DungeonBlocState)? onDungeonStateChanged;

  final ShopBloc? shopBloc;
  final void Function(BuildContext, ShopState)? onShopStateChanged;

  final MysteryBloc? mysteryBloc;
  final void Function(BuildContext, MysteryState)? onMysteryStateChanged;

  final RestBloc? restBloc;
  final void Function(BuildContext, RestState)? onRestStateChanged;

  final EventRoomBloc? eventRoomBloc;
  final void Function(BuildContext, EventRoomState)? onEventRoomStateChanged;

  final NpcBloc? npcBloc;
  final void Function(BuildContext, NpcState)? onNpcStateChanged;

  const BlocListenerStack({
    super.key,
    required this.child,
    required this.buildBloc,
    required this.onBuildStateChanged,
    this.dungeonBloc,
    this.onDungeonStateChanged,
    this.shopBloc,
    this.onShopStateChanged,
    this.mysteryBloc,
    this.onMysteryStateChanged,
    this.restBloc,
    this.onRestStateChanged,
    this.eventRoomBloc,
    this.onEventRoomStateChanged,
    this.npcBloc,
    this.onNpcStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    var result = child;

    // BuildBloc listener (직업 분화)
    result = BlocListener<BuildBloc, BuildState>(
      bloc: buildBloc,
      listener: onBuildStateChanged,
      child: result,
    );

    if (dungeonBloc != null) {
      result = BlocProvider<DungeonBloc>.value(
        value: dungeonBloc!,
        child: BlocListener<DungeonBloc, DungeonBlocState>(
          bloc: dungeonBloc,
          listener: onDungeonStateChanged!,
          child: result,
        ),
      );
    }

    if (shopBloc != null && onShopStateChanged != null) {
      result = BlocListener<ShopBloc, ShopState>(
        bloc: shopBloc,
        listener: onShopStateChanged!,
        child: result,
      );
    }

    if (mysteryBloc != null && onMysteryStateChanged != null) {
      result = BlocListener<MysteryBloc, MysteryState>(
        bloc: mysteryBloc,
        listener: onMysteryStateChanged!,
        child: result,
      );
    }

    if (restBloc != null && onRestStateChanged != null) {
      result = BlocListener<RestBloc, RestState>(
        bloc: restBloc,
        listener: onRestStateChanged!,
        child: result,
      );
    }

    if (eventRoomBloc != null && onEventRoomStateChanged != null) {
      result = BlocListener<EventRoomBloc, EventRoomState>(
        bloc: eventRoomBloc,
        listener: onEventRoomStateChanged!,
        child: result,
      );
    }

    if (npcBloc != null && onNpcStateChanged != null) {
      result = BlocListener<NpcBloc, NpcState>(
        bloc: npcBloc,
        listener: onNpcStateChanged!,
        child: result,
      );
    }

    return result;
  }
}
