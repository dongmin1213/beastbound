import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/core/events/momentum_gain_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/text/korean_particles.dart';
import 'package:soul_dungeon/domain/combat/logic/card_upgrade_registry.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_event.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_generator.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_state.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/screens/game/room_context.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

class NpcRoomHandler {
  final RoomContext _ctx;
  final NpcConfig npcConfig;
  final EconomyConfig economyConfig;

  /// 현재 런 번호 (1-based). totalRuns + 1.
  int currentRunNumber;

  NpcBloc? _npcBloc;
  bool _showingNpc = false;

  NpcBloc? get bloc => _npcBloc;
  bool get isShowing => _showingNpc;

  NpcRoomHandler({
    required RoomContext context,
    required this.npcConfig,
    required this.economyConfig,
    this.currentRunNumber = 1,
  }) : _ctx = context;

  void enter(DungeonRoomEntered dState) {
    final floorNumber = dState.floorMap.floorNumber;

    // 일반 NPC 생성.
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '누군가의 기척이 느껴진다...',
      ),
    ]);

    final seed = dState.currentNodeId.hashCode;
    final npcData = NpcGenerator.generate(
      floor: floorNumber,
      npcConfig: npcConfig,
      economyConfig: economyConfig,
      seed: seed,
    );

    _npcBloc?.close();
    _npcBloc = NpcBloc(gameEventBus: _ctx.runController.gameEventBus);
    _npcBloc!.add(MeetNpc(
      npc: npcData,
      playerGold: _ctx.runController.playerRunState.gold,
    ));

    _showingNpc = true;
    _ctx.notifyStateChanged();

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'NPC entered: ${npcData.npcType.name} "${npcData.name}", gold=${_ctx.runController.playerRunState.gold}');
    }
  }

  void onBuy(int index) {
    if (_npcBloc == null) return;
    final currentState = _npcBloc!.state;
    if (currentState is NpcReady) {
      final item = currentState.npc.tradeItems[index];
      _npcBloc!.add(PurchaseNpcItem(index));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newState = _npcBloc?.state;
        if (newState is NpcReady && newState.npc.tradeItems[index].sold) {
          _applyNpcItemEffect(item);
          _ctx.runController.appendFeedbackText(
              "'${item.name}'${KoreanParticles.eulReul(item.name)} 구매했다."
              '${item.description.isNotEmpty ? '\n→ ${item.description}' : ''}');
        }
      });
    }
  }

  /// NPC 아이템 효과 적용.
  void _applyNpcItemEffect(ShopItem item) {
    final rc = _ctx.runController;
    final prs = rc.playerRunState;

    // 축복 아이템 → ownedBlessingIds 등록
    if (item.itemType == ItemType.blessing) {
      rc.playerRunState = prs.copyWith(
        ownedBlessingIds: [...prs.ownedBlessingIds, item.id],
      );
      rc.runBloc.add(AcquireBlessing(item.id));
      return;
    }

    // supply 아이템 → effectType별 처리
    if (item.effectType == null) return;
    switch (item.effectType!) {
      case 'heal':
        if (item.effectValue != null && item.effectValue! > 0) {
          final healAmount = item.effectValue!;
          final newHp = (prs.currentHp + healAmount).clamp(0, prs.maxHp);
          rc.playerRunState = prs.copyWith(currentHp: newHp);
          rc.runBloc.add(ChangeHp(healAmount));
          rc.appendFeedbackText('HP가 $healAmount 회복되었다.');
        }
      case 'momentum':
        if (item.effectValue != null && item.effectValue! > 0) {
          final amount = item.effectValue!;
          rc.gameEventBus.emit(MomentumGainEvent(amount: amount));
          rc.appendFeedbackText('기세가 $amount 충전되었다.');
        }
      case 'cleanse':
        // 독/약화 해제 → 즉시 HP 5 회복 (전투 외 상태효과 없으므로 HP 보상)
        final newHp = (prs.currentHp + 5).clamp(0, prs.maxHp);
        if (newHp > prs.currentHp) {
          rc.playerRunState = prs.copyWith(currentHp: newHp);
          rc.runBloc.add(ChangeHp(5));
        }
        rc.appendFeedbackText('독소가 정화되고 기운이 돌아온다.');
      case 'momentumBonus':
        if (item.effectValue != null && item.effectValue! > 0) {
          final bonus = item.effectValue!;
          rc.playerRunState = prs.copyWith(
            tempMomentumBonus: prs.tempMomentumBonus + bonus,
          );
          rc.appendFeedbackText('다음 전투에서 기세가 $bonus 증가한다.');
        }
      case 'strength':
        if (item.effectValue != null && item.effectValue! > 0) {
          final bonus = item.effectValue!;
          rc.playerRunState = prs.copyWith(
            tempStrengthBonus: prs.tempStrengthBonus + bonus,
          );
          rc.appendFeedbackText('다음 전투에서 힘이 $bonus 증가한다.');
        }
      case 'block':
        if (item.effectValue != null && item.effectValue! > 0) {
          final bonus = item.effectValue!;
          rc.playerRunState = prs.copyWith(
            tempBlockBonus: prs.tempBlockBonus + bonus,
          );
          rc.appendFeedbackText('다음 전투에서 블록이 $bonus 증가한다.');
        }
      default:
        break;
    }
  }

  void onClosed(NpcClosed state) {
    final rc = _ctx.runController;
    final newGold = rc.playerRunState.gold - state.totalGoldSpent + state.goldReward;

    rc.playerRunState = rc.playerRunState.copyWith(gold: newGold);
    _showingNpc = false;
    _ctx.notifyStateChanged();
    rc.runBloc.add(SetGold(newGold));

    if (state.goldReward > 0) {
      rc.gameEventBus.emit(GoldGainedEvent(
        amount: state.goldReward,
        totalGold: rc.playerRunState.gold,
      ));
    }

    // 성향 변화 적용
    if (state.dispositionRewards.isNotEmpty) {
      rc.applyDisposition(state.dispositionRewards);
    }

    // 카드 강화 적용
    if (state.upgradeRandomCard) {
      _applyUpgradeRandomCard(rc);
    }

    // 결과 피드백 텍스트
    if (state.totalGoldSpent > 0 && state.goldReward > 0) {
      rc.appendFeedbackText('거래 완료! ${state.goldReward} 골드 획득!');
    } else if (state.totalGoldSpent > 0) {
      rc.appendFeedbackText('거래 완료!');
    } else if (state.goldReward > 0) {
      rc.appendFeedbackText('${state.goldReward} 골드 획득!');
    }

    if (state.dispositionRewards.isNotEmpty) {
      final maxEntry = state.dispositionRewards.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      rc.appendFeedbackText('${maxEntry.key.displayName}의 기운이 느껴진다.');
    }

    _npcBloc?.close();
    _npcBloc = null;
    _ctx.getDungeonBloc()?.add(const CompleteRoom());
  }

  /// 덱에서 업그레이드 가능한 랜덤 카드 1장을 업그레이드.
  void _applyUpgradeRandomCard(GameRunController rc) {
    final deck = rc.playerRunState.masterDeck;
    final upgradable = <int>[];
    for (int i = 0; i < deck.length; i++) {
      if (CardUpgradeRegistry.canUpgrade(deck[i].id)) {
        upgradable.add(i);
      }
    }
    if (upgradable.isEmpty) {
      rc.appendFeedbackText('업그레이드할 수 있는 카드가 없다.');
      return;
    }
    final rng = Random();
    final targetIndex = upgradable[rng.nextInt(upgradable.length)];
    final original = deck[targetIndex];
    final upgraded = CardUpgradeRegistry.upgrade(original.id);
    if (upgraded == null) {
      rc.appendFeedbackText('카드를 강화할 수 없다.');
      return;
    }
    final newDeck = List.of(deck);
    newDeck[targetIndex] = upgraded;
    rc.playerRunState = rc.playerRunState.copyWith(masterDeck: newDeck);
    rc.appendFeedbackText('${original.name} → ${upgraded.name} 강화!');
  }

  void enterForTest(NpcData npcData, {int? withGold}) {
    final rc = _ctx.runController;
    if (withGold != null) {
      rc.playerRunState = rc.playerRunState.copyWith(gold: withGold);
      rc.runBloc.add(SetGold(withGold));
    }
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '누군가의 기척이 느껴진다...',
      ),
    ]);
    _npcBloc?.close();
    _npcBloc = NpcBloc(gameEventBus: rc.gameEventBus);
    _npcBloc!.add(MeetNpc(
      npc: npcData,
      playerGold: rc.playerRunState.gold,
    ));
    _showingNpc = true;
    _ctx.notifyStateChanged();
  }

  void dispose() {
    _npcBloc?.close();
  }
}
