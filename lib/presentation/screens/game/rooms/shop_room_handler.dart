import 'dart:math';
import 'package:soul_dungeon/core/text/korean_particles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/momentum_gain_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/build/data/card_blessing_pool.dart';
import 'package:soul_dungeon/domain/build/data/curse_pool.dart';
import 'package:soul_dungeon/domain/build/logic/devil_deal_generator.dart';
import 'package:soul_dungeon/core/models/devil_deal_data.dart';
import 'package:soul_dungeon/domain/combat/logic/curse_modifier_resolver.dart';
import 'package:soul_dungeon/core/models/curse_modifier_pool.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_upgrade_registry.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_event.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item_generator.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_state.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/screens/game/room_context.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

class ShopRoomHandler {
  final RoomContext _ctx;
  final EconomyConfig economyConfig;
  final RarityConfig rarityConfig;

  /// 소울 업그레이드 상점 할인율 (0.0 ~ 1.0). 0이면 할인 없음.
  final double shopDiscountRate;

  /// 소울 업그레이드 무료 카드 제거 여부.
  final bool hasFreeCardRemoval;

  ShopBloc? _shopBloc;
  bool _showingShop = false;

  /// 악마의 거래 대기 상태.
  DevilDealData? _pendingDeal;
  DungeonRoomEntered? _pendingShopState;

  /// 카드 제거 선택 대기 상태.
  bool _pendingCardRemoval = false;

  ShopBloc? get bloc => _shopBloc;
  bool get hasPendingCardRemoval => _pendingCardRemoval;
  bool get isShowing => _showingShop;
  bool get hasDevilDeal => _pendingDeal != null;

  ShopRoomHandler({
    required RoomContext context,
    required this.economyConfig,
    this.rarityConfig = const RarityConfig(),
    this.shopDiscountRate = 0.0,
    this.hasFreeCardRemoval = false,
  }) : _ctx = context;

  void enter(DungeonRoomEntered dState) {
    final floorNumber = dState.floorMap.floorNumber;
    // 노드 ID 기반 고정 seed — 이어하기 시에도 동일한 결과 보장
    final seed = dState.currentNodeId.hashCode;

    // 악마의 거래 확률 체크
    if (DevilDealGenerator.shouldOffer(floor: floorNumber, seed: seed)) {
      final deal = DevilDealGenerator.generateDeal(
        ownedBlessingIds: _ctx.runController.playerRunState.ownedBlessingIds,
        seed: seed + 1,
      );
      if (deal != null) {
        _pendingDeal = deal;
        _pendingShopState = dState;
        _showDevilDeal(deal);
        return;
      }
    }

    _openShop(dState);
  }

  void _showDevilDeal(DevilDealData deal) {
    final blessing = CursePool.findDevilBlessingById(deal.blessingId);
    final curse = CursePool.findCurseById(deal.curseId);
    if (blessing == null || curse == null) {
      _openShop(_pendingShopState!);
      _pendingDeal = null;
      _pendingShopState = null;
      return;
    }

    final costText = deal.cost > 0 ? ' (${deal.cost} 골드)' : '';

    _ctx.setTextBlockData([
      const TextBlockData(
        text: '상점 입구에서 수상한 인물이 다가온다...',
      ),
      TextBlockData(
        text: '"${deal.flavorText}"',
      ),
      TextBlockData(
        text: '축복: ${blessing.name} — ${blessing.description}\n'
            '저주: ${curse.name} — ${curse.description}$costText',
        choices: [
          ChoiceData(
            id: 'devil_accept_${deal.id}',
            text: '거래를 수락한다',
            resultTextBlocks: [],
          ),
          ChoiceData(
            id: 'devil_reject_${deal.id}',
            text: '거절하고 상점으로 간다',
            resultTextBlocks: [],
          ),
        ],
      ),
    ]);
  }

  /// 악마의 거래 선택 처리. 반환값: 처리 여부.
  bool handleDevilChoice(ChoiceData choice) {
    if (_pendingDeal == null) return false;

    final deal = _pendingDeal!;
    final shopState = _pendingShopState;
    _pendingDeal = null;
    _pendingShopState = null;

    if (choice.id.startsWith('devil_accept_')) {
      _acceptDeal(deal);
    }

    // 거래 수락/거절 후 상점 진입 (shopState가 있을 때만)
    if (shopState != null) {
      _openShop(shopState);
    }
    return true;
  }

  void _acceptDeal(DevilDealData deal) {
    final prs = _ctx.runController.playerRunState;

    // 골드 부족 시 거래 거부
    if (deal.cost > 0 && prs.gold < deal.cost) return;

    // 골드 비용 지불
    if (deal.cost > 0) {
      _ctx.runController.playerRunState = prs.copyWith(
        gold: prs.gold - deal.cost,
      );
      _ctx.runController.runBloc.add(SetGold(prs.gold - deal.cost));
    }

    // 축복 획득
    _ctx.runController.playerRunState =
        _ctx.runController.playerRunState.copyWith(
      ownedBlessingIds: [
        ..._ctx.runController.playerRunState.ownedBlessingIds,
        deal.blessingId,
      ],
    );
    _ctx.runController.runBloc.add(AcquireBlessing(deal.blessingId));

    // 저주 적용
    _ctx.runController.playerRunState =
        _ctx.runController.playerRunState.copyWith(
      activeCurseIds: [
        ..._ctx.runController.playerRunState.activeCurseIds,
        deal.curseId,
      ],
    );
    _ctx.runController.runBloc.add(ApplyCurse(deal.curseId));

    // 즉시 효과 저주 처리 (maxHpPenalty 등)
    final curseData = CursePool.findCurseById(deal.curseId);
    if (curseData != null && curseData.effectType == 'maxHpPenalty') {
      final current = _ctx.runController.playerRunState;
      final reduction = (current.maxHp * curseData.effectValue / 100).round();
      final newMaxHp = (current.maxHp - reduction).clamp(1, 9999);
      final newHp = current.currentHp.clamp(0, newMaxHp);
      _ctx.runController.playerRunState = current.copyWith(
        maxHp: newMaxHp,
        currentHp: newHp,
      );
      _ctx.runController.runBloc.add(SetPlayerRunState(
        _ctx.runController.playerRunState,
      ));
    }

    _ctx.runController.completedBlocks.add(CompletedBlock(
      text: '어둠의 거래를 수락했다.',
      isChoice: true,
    ));

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'Devil deal accepted: blessing=${deal.blessingId}, curse=${deal.curseId}');
    }
  }

  void _openShop(DungeonRoomEntered dState) {
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '여행자의 상점에 들어섰다. 진열대에 물건이 놓여 있다.',
      ),
    ]);

    final floorNumber = dState.floorMap.floorNumber;
    final prs = _ctx.runController.playerRunState;
    // E9 저주 상점 가격 배율 적용
    final curses = CurseModifierPool.resolveIds(prs.activeCurseIds);
    final cursePriceMultiplier =
        CurseModifierResolver.resolveShopPriceMultiplier(curses);
    // 악마의 거래 저주: 상점 가격/업그레이드 비용 증가
    final devilCurses = CursePool.resolveCurseIds(prs.activeCurseIds);
    var devilPriceMultiplier = 1.0;
    var devilUpgradeMultiplier = 1.0;
    for (final dc in devilCurses) {
      if (dc.effectType == 'shopPricePenalty') {
        devilPriceMultiplier *= (1 + dc.effectValue / 100);
      }
      if (dc.effectType == 'upgradeCostIncrease') {
        devilUpgradeMultiplier *= (1 + dc.effectValue / 100);
      }
    }
    final items = ShopItemGenerator.generateItems(
      floor: floorNumber,
      economyConfig: economyConfig,
      jobRewardsLookup: CardPool.jobRewards,
      colorlessCards: ColorlessCards.base,
      rarityConfig: rarityConfig,
      priceMultiplier: ((1.0 - shopDiscountRate) * cursePriceMultiplier * devilPriceMultiplier).clamp(0.1, 100.0),
      upgradeMultiplier: devilUpgradeMultiplier,
      jobId: prs.currentJobId,
      ownedDeck: prs.masterDeck,
      ownedRelicIds: prs.ownedRelicIds,
      hasFreeCardRemoval: hasFreeCardRemoval,
      // 노드 ID 기반 고정 seed — 이어하기 시 상품 리롤 악용 방지
      seed: dState.currentNodeId.hashCode,
    );

    _shopBloc?.close();
    _shopBloc = ShopBloc(gameEventBus: _ctx.runController.gameEventBus);
    _shopBloc!.add(OpenShop(
      items: items,
      playerGold: _ctx.runController.playerRunState.gold,
    ));

    _showingShop = true;
    _ctx.notifyStateChanged();

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'Shop entered: ${items.length} items, gold=${_ctx.runController.playerRunState.gold}');
    }
  }

  void onBuy(int index) {
    if (_shopBloc == null) return;
    final currentState = _shopBloc!.state;
    if (currentState is ShopReady) {
      final item = currentState.items[index];
      _shopBloc!.add(PurchaseItem(index));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newState = _shopBloc?.state;
        if (newState is ShopReady && newState.items[index].sold) {
          _applyItemEffect(item);
          _ctx.runController.appendFeedbackText(
            "'${item.name}'${KoreanParticles.eulReul(item.name)} 구매했다."
            '${item.description.isNotEmpty ? '\n→ ${item.description}' : ''}',
          );
        }
      });
    }
  }

  /// 구매한 아이템의 즉시 효과를 적용한다.
  void _applyItemEffect(ShopItem item) {
    final rc = _ctx.runController;
    final prs = rc.playerRunState;

    // 축복 아이템 → ownedBlessingIds 등록
    if (item.itemType == ItemType.blessing && !item.id.startsWith('cursed_')) {
      rc.playerRunState = prs.copyWith(
        ownedBlessingIds: [...prs.ownedBlessingIds, item.id],
      );
      rc.runBloc.add(AcquireBlessing(item.id));
      return;
    }

    // 저주 아이템 → ownedBlessingIds (전투 효과) + 즉시 패널티 적용
    if (item.itemType == ItemType.curse) {
      rc.playerRunState = prs.copyWith(
        ownedBlessingIds: [...prs.ownedBlessingIds, item.id],
      );
      rc.runBloc.add(AcquireBlessing(item.id));
      _applyCurseImmediateEffect(rc, item);
      return;
    }

    // 유물 아이템 → ownedRelicIds 등록 (중복 방지)
    if (item.itemType == ItemType.relic &&
        !prs.ownedRelicIds.contains(item.id)) {
      rc.playerRunState = prs.copyWith(
        ownedRelicIds: [...prs.ownedRelicIds, item.id],
      );
      rc.runBloc.add(AcquireRelic(item.id));
      return;
    }

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
      case 'card':
        _applyCardPurchase(rc, item);
      case 'removeCard':
        _applyCardRemoval(rc);
      case 'momentum':
        if (item.effectValue != null && item.effectValue! > 0) {
          final amount = item.effectValue!;
          rc.gameEventBus.emit(MomentumGainEvent(amount: amount));
          rc.appendFeedbackText('야성이 $amount 충전되었다.');
        }
      case 'momentumBonus':
        if (item.effectValue != null && item.effectValue! > 0) {
          final bonus = item.effectValue!;
          rc.playerRunState = prs.copyWith(
            tempMomentumBonus: prs.tempMomentumBonus + bonus,
          );
          rc.appendFeedbackText('다음 전투에서 야성이 $bonus 증가한다.');
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
      case 'cardExchange':
        _applyCardExchange(rc);
      case 'removeCurse':
        _applyRemoveCurse(rc);
      case 'upgradeRandomCard':
        _applyUpgradeRandomCard(rc);
      case 'maxHpBonus':
        if (item.effectValue != null && item.effectValue! > 0) {
          final bonus = item.effectValue!;
          final newMaxHp = (prs.maxHp + bonus).clamp(1, 9999);
          final newHp = (prs.currentHp + bonus).clamp(1, newMaxHp);
          rc.playerRunState = prs.copyWith(
            maxHp: newMaxHp,
            currentHp: newHp,
          );
          rc.runBloc.add(ChangeMaxHp(bonus));
          rc.appendFeedbackText('최대 HP가 $bonus 증가했다! (현재 $newMaxHp)');
        }
      default:
        break;
    }
  }

  /// 카드 구매 — 덱에 카드 추가.
  void _applyCardPurchase(GameRunController rc, ShopItem item) {
    if (item.cardId == null) return;
    final card = CardPool.findById(item.cardId!);
    if (card == null) {
      rc.appendFeedbackText('카드를 찾을 수 없다.');
      return;
    }
    final newDeck = [...rc.playerRunState.masterDeck, card];
    rc.playerRunState = rc.playerRunState.copyWith(masterDeck: newDeck);
    rc.appendFeedbackText('${card.name} 카드를 덱에 추가했다!');
  }

  /// 카드 교환 — 덱에서 비기본 카드 1장을 랜덤 무색 카드로 교체.
  void _applyCardExchange(GameRunController rc) {
    final deck = rc.playerRunState.masterDeck;
    final removable = <int>[];
    for (int i = 0; i < deck.length; i++) {
      if (!deck[i].id.startsWith('starter_')) {
        removable.add(i);
      }
    }
    if (removable.isEmpty) {
      rc.appendFeedbackText('교환할 수 있는 카드가 없다.');
      return;
    }
    final rng = Random();
    final targetIndex = removable[rng.nextInt(removable.length)];
    final removed = deck[targetIndex];

    // 보유 중이 아닌 무색 카드에서 랜덤 선택
    final ownedIds = deck.map((c) => c.id).toSet();
    final candidates = ColorlessCards.base.where((c) => !ownedIds.contains(c.id)).toList();
    if (candidates.isEmpty) {
      rc.appendFeedbackText('교환할 수 있는 무색 카드가 없다.');
      return;
    }
    final newCard = candidates[rng.nextInt(candidates.length)];
    final newDeck = List.of(deck)
      ..removeAt(targetIndex)
      ..add(newCard);
    rc.playerRunState = rc.playerRunState.copyWith(masterDeck: newDeck);
    rc.appendFeedbackText('${removed.name}이(가) ${newCard.name}(으)로 교체되었다!');
  }

  /// 저주 제거 — activeCurseIds에서 1개 랜덤 제거.
  void _applyRemoveCurse(GameRunController rc) {
    final curses = rc.playerRunState.activeCurseIds;
    if (curses.isEmpty) {
      rc.appendFeedbackText('제거할 저주가 없다.');
      return;
    }
    final rng = Random();
    final targetIndex = rng.nextInt(curses.length);
    final removedId = curses[targetIndex];
    final newCurses = List.of(curses)..removeAt(targetIndex);
    rc.playerRunState = rc.playerRunState.copyWith(activeCurseIds: newCurses);
    rc.appendFeedbackText('저주가 정화되었다!');
    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon, 'Curse removed: $removedId');
    }
  }

  /// 카드 업그레이드 — 덱에서 업그레이드 가능한 카드 1장 랜덤 업그레이드.
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
    if (upgraded == null) return;
    final newDeck = List.of(deck)..[targetIndex] = upgraded;
    rc.playerRunState = rc.playerRunState.copyWith(masterDeck: newDeck);
    rc.appendFeedbackText('${original.name}이(가) ${upgraded.name}(으)로 강화되었다!');
  }

  /// 저주 아이템 구매 시 즉시 적용되는 효과 (maxHP 감소 등).
  void _applyCurseImmediateEffect(GameRunController rc, ShopItem item) {
    final blessing = CardBlessingPool.findById(item.id);
    if (blessing == null) return;

    switch (blessing.effectType) {
      case 'strengthWithHpPenalty':
        // maxHP 즉시 감소 (힘은 전투 시작 시 적용)
        final penalty = blessing.secondaryValue ?? 0;
        if (penalty > 0) {
          final prs = rc.playerRunState;
          final newMaxHp = (prs.maxHp - penalty).clamp(1, prs.maxHp);
          final newHp = prs.currentHp.clamp(0, newMaxHp);
          rc.playerRunState = prs.copyWith(maxHp: newMaxHp, currentHp: newHp);
          rc.runBloc.add(ChangeMaxHp(-penalty));
          rc.appendFeedbackText('최대 HP가 $penalty 감소했다.');
        }
      default:
        break;
    }
  }

  /// 카드 제거 — 덱의 모든 카드 선택지를 표시 (시작 카드 포함).
  void _applyCardRemoval(GameRunController rc) {
    final deck = rc.playerRunState.masterDeck;
    final choices = <ChoiceData>[];
    for (int i = 0; i < deck.length; i++) {
      choices.add(ChoiceData(
        id: 'card_removal_$i',
        text: deck[i].name,
        resultTextBlocks: [],
        sourceCard: deck[i],
      ));
    }
    if (choices.isEmpty) {
      rc.appendFeedbackText('제거할 수 있는 카드가 없다.');
      return;
    }
    _pendingCardRemoval = true;
    _showingShop = false;
    _ctx.notifyStateChanged();
    _ctx.setTextBlockData([
      TextBlockData(
        text: '제거할 카드를 선택하라.',
        choices: choices,
      ),
    ]);
  }

  /// 카드 제거 선택 처리. 반환값: 처리 여부.
  bool handleCardRemovalChoice(ChoiceData choice) {
    if (!_pendingCardRemoval) return false;
    _pendingCardRemoval = false;

    final indexStr = choice.id.replaceFirst('card_removal_', '');
    final index = int.tryParse(indexStr);
    final rc = _ctx.runController;
    final deck = rc.playerRunState.masterDeck;

    String feedbackText;
    if (index != null && index >= 0 && index < deck.length) {
      final removed = deck[index];
      final newDeck = List.of(deck)..removeAt(index);
      rc.playerRunState = rc.playerRunState.copyWith(masterDeck: newDeck);
      feedbackText = '${removed.name} 카드가 덱에서 제거되었다.';
    } else {
      feedbackText = '카드를 제거하지 못했다.';
    }

    // 상점으로 복귀: 텍스트 블록 초기화 후 상점 재표시
    _showingShop = true;
    _ctx.setTextBlockData([
      TextBlockData(text: feedbackText),
    ]);
    _ctx.notifyStateChanged();
    return true;
  }

  void onLeave() {
    _shopBloc?.add(const LeaveShop());
  }

  void onClosed(ShopClosed state) {
    _ctx.runController.playerRunState =
        _ctx.runController.playerRunState.copyWith(gold: state.remainingGold);
    _showingShop = false;
    _ctx.notifyStateChanged();
    _ctx.runController.runBloc.add(SetGold(state.remainingGold));
    _shopBloc?.close();
    _shopBloc = null;
    _ctx.getDungeonBloc()?.add(const CompleteRoom());
  }

  /// 테스트 전용: 악마의 거래 직접 진입 시뮬레이션.
  @visibleForTesting
  void enterDevilDealForTest(DevilDealData deal) {
    _pendingDeal = deal;
    _showDevilDeal(deal);
  }

  void enterForTest(List<ShopItem> items, {int? withGold}) {
    if (withGold != null) {
      _ctx.runController.setGold(withGold);
    }
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '여행자의 상점에 들어섰다. 진열대에 물건이 놓여 있다.',
      ),
    ]);
    _shopBloc?.close();
    _shopBloc = ShopBloc(gameEventBus: _ctx.runController.gameEventBus);
    _shopBloc!.add(OpenShop(
      items: items,
      playerGold: _ctx.runController.playerRunState.gold,
    ));
    _showingShop = true;
    _ctx.notifyStateChanged();
  }

  void dispose() {
    _shopBloc?.close();
  }
}
