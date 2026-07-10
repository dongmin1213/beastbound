import 'package:flutter/foundation.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_event.dart';
import 'dart:math';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_upgrade_registry.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_generator.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_state.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/screens/game/room_context.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

class EventRoomHandler {
  final RoomContext _ctx;
  final EventConfig eventConfig;
  final DispositionConfig dispositionConfig;
  final EconomyConfig economyConfig;
  final double soulGainMultiplier;

  EventRoomBloc? _eventBloc;
  bool _showingEvent = false;

  EventRoomBloc? get bloc => _eventBloc;
  bool get isShowing => _showingEvent;

  EventRoomHandler({
    required RoomContext context,
    required this.eventConfig,
    required this.dispositionConfig,
    this.economyConfig = const EconomyConfig(),
    this.soulGainMultiplier = 1.0,
  }) : _ctx = context;

  void enter(DungeonRoomEntered dState) {
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '이 방에는 무언가 특별한 기운이 감돈다...',
      ),
    ]);

    final floorNumber = dState.floorMap.floorNumber;
    final seed = dState.currentNodeId.hashCode;
    final eventData = EventRoomGenerator.generate(
      floor: floorNumber,
      eventConfig: eventConfig,
      dispositionConfig: dispositionConfig,
      seed: seed,
    );

    _eventBloc?.close();
    _eventBloc = EventRoomBloc(gameEventBus: _ctx.runController.gameEventBus);
    _eventBloc!.add(OpenEventRoom(eventData));

    _showingEvent = true;
    _ctx.notifyStateChanged();

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'Event entered: ${eventData.title}, choices=${eventData.choices.length}');
    }
  }

  void onCompleted(EventRoomCompleted state) {
    final choice = state.selectedChoice;
    final rc = _ctx.runController;

    // 골드 변화
    if (choice.goldChange != 0) {
      final newGold =
          (rc.playerRunState.gold + choice.goldChange).clamp(0, 99999);
      rc.playerRunState = rc.playerRunState.copyWith(gold: newGold);
      rc.runBloc.add(SetGold(newGold));
    }

    // HP 변화
    if (choice.hpChange != 0) {
      final newHp = rc.playerRunState.currentHp + choice.hpChange;
      rc.playerRunState = rc.playerRunState.copyWith(
        currentHp: newHp.clamp(0, rc.playerRunState.maxHp),
      );
      rc.runBloc.add(ChangeHp(choice.hpChange));
    }

    // 성향 변화
    if (choice.dispositionRewards.isNotEmpty) {
      rc.applyDisposition(choice.dispositionRewards);
    }

    // 카드 업그레이드
    String? upgradeText;
    if (choice.upgradeRandomCard) {
      upgradeText = _applyUpgradeRandomCard(rc);
    }

    // 카드 제거
    String? removedCardName;
    if (choice.removeRandomCard) {
      removedCardName = _applyRemoveRandomCard(rc);
    }

    // 카드 보상
    String? cardRewardText;
    if (choice.cardRewardId != null) {
      cardRewardText = _applyCardReward(rc, choice.cardRewardId!);
    }

    // HP ≤ 0 → 퍼마데스
    if (rc.playerRunState.currentHp <= 0) {
      _showingEvent = false;
      _ctx.notifyStateChanged();
      final baseSoul = SoulCalculator.calculateDeathReward(
        rc.playerRunState.currentFloor,
        economyConfig.soulBaseGain,
      );
      final soulGained = (baseSoul * soulGainMultiplier).toInt();
      _ctx.setTextBlockData([
        TextBlockData(
          text: '${choice.outcomeText}\n\n치명적인 결과... 의식이 점점 흐려진다.',
        ),
        const TextBlockData(
          text: '어둠이 밀려온다... 의식이 점점 흐려진다.',
        ),
        CombatFlowManager.buildRunSummaryBlock(
          runState: rc.playerRunState,
          soulGained: soulGained,
          showSoulHint: GameHintManager.checkAndMark(GameHintManager.hintSoul),
        ),
        TextBlockData(
          text: '',
          choices: [
            ChoiceData(
              id: 'restart_run',
              text: '처음부터 다시 시작',
              resultTextBlocks: const [],
            ),
          ],
        ),
      ]);
      _eventBloc?.close();
      _eventBloc = null;
      return;
    }

    // 골드 획득 이벤트
    if (choice.goldChange > 0) {
      rc.gameEventBus.emit(GoldGainedEvent(
        amount: choice.goldChange,
        totalGold: rc.playerRunState.gold,
      ));
    }

    // 피드백 텍스트 — pending 큐에 저장하여 다음 화면(갈림길) 상단에 표시.
    // CompleteRoom 후 즉시 경로 선택으로 전환되므로 completedBlocks 직접 추가는
    // 화면 전환 시 유실됨. 전직 텍스트와 동일한 pending 패턴 사용.
    final feedbackLines = <String>[choice.outcomeText];
    if (choice.goldChange > 0) {
      feedbackLines.add('${choice.goldChange} 골드 획득!');
    } else if (choice.goldChange < 0) {
      feedbackLines.add('${-choice.goldChange} 골드 소비.');
    }
    if (choice.hpChange > 0) {
      feedbackLines.add('HP ${choice.hpChange} 회복!');
    } else if (choice.hpChange < 0) {
      feedbackLines.add('HP ${-choice.hpChange} 손실!');
    }
    if (choice.dispositionRewards.isNotEmpty) {
      final maxEntry = choice.dispositionRewards.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      feedbackLines.add('${maxEntry.key.displayName}의 기운이 느껴진다.');
    }
    if (upgradeText != null) {
      feedbackLines.add(upgradeText);
    }
    if (removedCardName != null) {
      feedbackLines.add('[$removedCardName] 카드가 덱에서 제거되었다.');
    } else if (choice.removeRandomCard) {
      feedbackLines.add('제거할 수 있는 카드가 없었다.');
    }
    if (cardRewardText != null) {
      feedbackLines.add(cardRewardText);
    }
    rc.appendEventResultText(feedbackLines.join('\n'));

    _showingEvent = false;
    _eventBloc?.close();
    _eventBloc = null;
    _ctx.notifyStateChanged();
    _ctx.getDungeonBloc()?.add(const CompleteRoom());
  }

  /// 덱에서 업그레이드 가능한 랜덤 카드 1장을 업그레이드.
  /// 결과 텍스트를 반환 (불가 시에도 사유 반환).
  String _applyUpgradeRandomCard(GameRunController rc) {
    final deck = rc.playerRunState.masterDeck;
    final upgradable = <int>[];
    for (int i = 0; i < deck.length; i++) {
      if (CardUpgradeRegistry.canUpgrade(deck[i].id)) {
        upgradable.add(i);
      }
    }
    if (upgradable.isEmpty) {
      return '업그레이드할 수 있는 카드가 없다.';
    }
    final rng = Random();
    final targetIndex = upgradable[rng.nextInt(upgradable.length)];
    final original = deck[targetIndex];
    final upgraded = CardUpgradeRegistry.upgrade(original.id);
    if (upgraded == null) {
      return '카드를 강화할 수 없다.';
    }
    final newDeck = List.of(deck);
    newDeck[targetIndex] = upgraded;
    rc.playerRunState = rc.playerRunState.copyWith(masterDeck: newDeck);
    return '${original.name} → ${upgraded.name} 강화!';
  }

  /// 덱에서 기본 카드가 아닌 랜덤 카드 1장을 제거.
  /// 제거된 카드 이름을 반환 (제거 불가 시 null).
  String? _applyRemoveRandomCard(GameRunController rc) {
    final deck = rc.playerRunState.masterDeck;
    // 기본 타격/방어(starter_) 카드는 제거 대상에서 제외
    final removable = <int>[];
    for (int i = 0; i < deck.length; i++) {
      if (!deck[i].id.startsWith('starter_')) {
        removable.add(i);
      }
    }
    if (removable.isEmpty) {
      return null;
    }
    final rng = Random();
    final targetIndex = removable[rng.nextInt(removable.length)];
    final removed = deck[targetIndex];
    final newDeck = List.of(deck)..removeAt(targetIndex);
    rc.playerRunState = rc.playerRunState.copyWith(masterDeck: newDeck);
    return removed.name;
  }

  /// 카드 보상 ID로 카드를 덱에 추가.
  /// 결과 텍스트를 반환.
  String _applyCardReward(GameRunController rc, String cardRewardId) {
    CardData? card;
    if (cardRewardId == 'colorless_random') {
      final rng = Random();
      final pool = ColorlessCards.base;
      card = pool[rng.nextInt(pool.length)];
    } else {
      card = CardPool.findById(cardRewardId);
    }
    if (card == null) {
      return '보상 카드를 찾을 수 없다.';
    }
    final newDeck = [...rc.playerRunState.masterDeck, card];
    rc.playerRunState = rc.playerRunState.copyWith(masterDeck: newDeck);
    return '[${card.name}] 카드를 획득했다!';
  }

  /// 이벤트 상태 리셋 — 비이벤트 방 진입 시 호출.
  void reset() {
    _eventBloc?.close();
    _eventBloc = null;
    _showingEvent = false;
  }

  void enterForTest(EventRoomData eventData, {int? withGold, int? withHp}) {
    final rc = _ctx.runController;
    if (withGold != null) {
      rc.playerRunState = rc.playerRunState.copyWith(gold: withGold);
    }
    if (withHp != null) {
      rc.playerRunState = rc.playerRunState.copyWith(currentHp: withHp);
    }
    rc.syncToRunBloc();
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '이 방에는 무언가 특별한 기운이 감돈다...',
      ),
    ]);
    _eventBloc?.close();
    _eventBloc = EventRoomBloc(gameEventBus: rc.gameEventBus);
    _eventBloc!.add(OpenEventRoom(eventData));
    _showingEvent = true;
    _ctx.notifyStateChanged();
  }

  void dispose() {
    _eventBloc?.close();
  }
}
