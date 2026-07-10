import 'dart:math';

import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/item_pool_selector.dart';
import 'package:soul_dungeon/core/models/reward_pool.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 상점 아이템 생성기 — 시드 기반 PRNG, RarityConfig 4단계 보상 풀.
class ShopItemGenerator {
  ShopItemGenerator._();

  /// Blessing placeholder 데이터.
  static const _blessingPool = [
    ('blessing_001', '힘의 축복', '전투 시작 시 힘 +1'),
    ('blessing_002', '방어의 축복', '전투 시작 시 블록 +3'),
    ('blessing_003', '속도의 축복', '전투 시작 시 드로우 +1'),
    ('blessing_004', '생명의 축복', '전투 시작 시 HP 5 회복'),
    ('blessing_005', '기세의 축복', '전투 시작 시 기세 +10'),
    ('blessing_006', '회피의 축복', '첫 피격 시 데미지 50% 감소'),
    ('blessing_007', '집중의 축복', '전투 시작 시 AP +1 (첫 턴만)'),
    ('blessing_008', '재생의 축복', '매 턴 시작 시 HP 2 회복'),
  ];

  /// Supply 아이템 데이터 — (id, name, description, effectType, effectValue, priceMultiplier).
  static const _supplyPool = [
    ('supply_001', '치유의 물약', 'HP 20 회복', 'heal', 20, 1.3),
    ('supply_002', '기세의 대부적', '다음 전투 시작 기세 +30', 'momentumBonus', 30, 1.3),
    ('supply_005', '응급 붕대', 'HP 10 회복', 'heal', 10, 0.7),
    ('supply_007', '카드 교환권', '덱에서 카드 1장을 랜덤 무색 카드로 교체', 'cardExchange', 1, 1.5),
    ('supply_008', '정화의 물', '저주 1개 제거', 'removeCurse', 1, 2.0),
    ('supply_009', '강화 망치', '랜덤 카드 1장 업그레이드', 'upgradeRandomCard', 1, 1.8),
    ('supply_010', '기세의 부적', '다음 전투 시작 기세 +15', 'momentumBonus', 15, 1.0),
    ('supply_011', '생명의 과일', '최대 HP +5 (영구)', 'maxHpBonus', 5, 2.5),
  ];

  /// Cursed 등급 전용 — 위험 높은 실제 CardBlessing (cb_* ID로 전투 효과 적용됨).
  static const _cursedPool = [
    ('cb_glass_cannon', '유리대포', '힘 +5, 최대 HP -20'),
    ('cb_overload', '과부하', 'AP +1, 매 턴 HP -3'),
    ('cb_blood_contract', '피의 계약', '카드 업그레이드 HP -10 (무료)'),
  ];

  /// 유물 데이터 — (id, name, description). common 유물만 상점 풀.
  static const _relicPool = [
    ('relic_001', '녹슨 부적', '전투 시작 시 기세 5 회복'),
    ('relic_002', '치유의 돌', '방 이동 시 HP 3 회복'),
    ('relic_003', '행운의 동전', '전투 승리 시 골드 5 추가 획득'),
    ('relic_004', '강화 가죽', '전투 시작 시 블록 3 획득'),
  ];

  /// 카드 제거 서비스 가격.
  static const int cardRemovalPrice = 35;

  /// 3~5개 상점 아이템 + 카드 1~2장 + 카드 제거 서비스 생성.
  static List<ShopItem> generateItems({
    required int floor,
    required EconomyConfig economyConfig,
    required List<CardData> Function(String jobId) jobRewardsLookup,
    required List<CardData> colorlessCards,
    RarityConfig rarityConfig = const RarityConfig(),
    double priceMultiplier = 1.0,
    double upgradeMultiplier = 1.0,
    String? jobId,
    List<CardData> ownedDeck = const [],
    List<String> ownedRelicIds = const [],
    bool hasFreeCardRemoval = false,
    int? seed,
  }) {
    final rng = seed != null ? Random(seed) : Random();

    // 아이템 개수: 3~5
    final count = 3 + rng.nextInt(3); // 0,1,2 → 3,4,5

    // 기본 가격 계산 (저주 배율 포함)
    final basePrice = ((economyConfig.shopPriceBase *
                pow(economyConfig.shopPriceFloorMultiplier, floor - 1)) *
            priceMultiplier)
        .round();

    // 보유 유물 필터링 → 미보유 유물만 상점에 진열
    final availableRelics = _relicPool
        .where((r) => !ownedRelicIds.contains(r.$1))
        .toList();

    final items = <ShopItem>[];
    final usedBlessingIndices = <int>{};
    final usedSupplyIndices = <int>{};
    final usedCursedIndices = <int>{};
    final usedRelicIndices = <int>{};

    for (int i = 0; i < count; i++) {
      // Rarity 결정 (RarityConfig 가중치 기반)
      final rarity = RewardPool.rollRarity(rarityConfig, rng);

      // 희귀도 보정 가격
      final price = RewardPool.calculatePrice(rarityConfig, basePrice, rarity);

      // Cursed 아이템은 전용 풀에서 선택
      final String id;
      final String name;
      final String description;
      final ItemType itemType;
      String? effectType;
      int? effectValue;
      var itemPrice = price;

      if (rarity == Rarity.cursed) {
        itemType = ItemType.curse;
        (id, name, description) = ItemPoolSelector.selectFromPool(
            _cursedPool, usedCursedIndices, rng);
      } else {
        // ItemType 결정 (blessing 45%, supply 40%, relic 15%)
        final typeRoll = rng.nextDouble();
        if (typeRoll < 0.45) {
          itemType = ItemType.blessing;
        } else if (typeRoll < 0.85) {
          itemType = ItemType.supply;
        } else if (availableRelics.isNotEmpty) {
          itemType = ItemType.relic;
        } else {
          // 유물 풀 소진 시 축복으로 폴백
          itemType = ItemType.blessing;
        }

        // 풀에서 선택 (중복 방지)
        if (itemType == ItemType.blessing) {
          (id, name, description) = ItemPoolSelector.selectFromPool(
              _blessingPool, usedBlessingIndices, rng);
        } else if (itemType == ItemType.relic) {
          (id, name, description) = ItemPoolSelector.selectFromPool(
              availableRelics, usedRelicIndices, rng);
        } else {
          final supplyData = ItemPoolSelector.selectFromPool(
              _supplyPool, usedSupplyIndices, rng);
          id = supplyData.$1;
          name = supplyData.$2;
          description = supplyData.$3;
          effectType = supplyData.$4;
          effectValue = supplyData.$5;
          // 효과값 비례 가격 보정
          final supplyPriceMul = supplyData.$6;
          itemPrice = (price * supplyPriceMul).round();
          // 업그레이드 보급품 가격 배율 (relic_012 장인의 망치 -50%, 저주 curse_010 +50%)
          if (effectType == 'upgradeRandomCard') {
            if (ownedRelicIds.contains('relic_012')) {
              itemPrice = (itemPrice * 0.5).round();
            }
            if (upgradeMultiplier != 1.0) {
              itemPrice = (itemPrice * upgradeMultiplier).round();
            }
          }
        }
      }

      items.add(ShopItem(
        id: id,
        name: name,
        description: description,
        itemType: itemType,
        rarity: rarity,
        price: itemPrice,
        effectType: effectType,
        effectValue: effectValue,
      ));
    }

    // 카드 1~2장 추가 (직업 보상 카드 + 무색 카드)
    final cardItems = _generateCardItems(
      jobId: jobId,
      ownedDeck: ownedDeck,
      floor: floor,
      basePrice: basePrice,
      rng: rng,
      jobRewardsLookup: jobRewardsLookup,
      colorlessCards: colorlessCards,
    );
    items.addAll(cardItems);

    // 카드 제거 서비스 항상 추가
    // relic_013 차원의 주머니 또는 소울 업그레이드: 카드 제거 비용 무료 (1회/층)
    final isFreeRemoval = ownedRelicIds.contains('relic_013') || hasFreeCardRemoval;
    final removalCost = isFreeRemoval ? 0 : cardRemovalPrice;
    items.add(ShopItem(
      id: 'service_card_removal',
      name: '카드 제거',
      description: isFreeRemoval
          ? '덱에서 카드 1장을 제거한다. (무료!)'
          : '덱에서 카드 1장을 제거한다.',
      itemType: ItemType.cardRemoval,
      rarity: Rarity.common,
      price: removalCost,
      effectType: 'removeCard',
    ));

    return items;
  }

  /// 직업 보상 카드 + 무색 카드에서 1~2장 생성.
  static List<ShopItem> _generateCardItems({
    String? jobId,
    List<CardData> ownedDeck = const [],
    required int floor,
    required int basePrice,
    required Random rng,
    required List<CardData> Function(String jobId) jobRewardsLookup,
    required List<CardData> colorlessCards,
  }) {
    final ownedIds = ownedDeck.map((c) => c.id).toSet();
    final candidates = <CardData>[];

    // 직업 보상 카드 (보유 중이 아닌 것)
    if (jobId != null) {
      candidates.addAll(
        jobRewardsLookup(jobId).where((c) => !ownedIds.contains(c.id)),
      );
    }

    // 무색 카드 (보유 중이 아닌 것)
    candidates.addAll(
      colorlessCards.where((c) => !ownedIds.contains(c.id)),
    );

    if (candidates.isEmpty) return [];

    // 셔플 후 1~2장 선택
    final shuffled = List.of(candidates)..shuffle(rng);
    final pickCount = shuffled.length == 1 ? 1 : (1 + rng.nextInt(2)); // 1~2

    final result = <ShopItem>[];
    for (int i = 0; i < pickCount && i < shuffled.length; i++) {
      final card = shuffled[i];
      // 카드 가격: 15~60G (apCost 기반 스케일링)
      final cardPrice = (15 + card.apCost * 10 + rng.nextInt(10))
          .clamp(15, 60);

      result.add(ShopItem(
        id: 'shop_card_${card.id}',
        name: card.name,
        description: card.description,
        itemType: ItemType.card,
        rarity: card.apCost >= 3 ? Rarity.rare : Rarity.common,
        price: cardPrice,
        effectType: 'card',
        cardId: card.id,
        apCost: card.apCost,
      ));
    }

    return result;
  }
}
