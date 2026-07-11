import 'dart:math';

import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/core/models/item_pool_selector.dart';
import 'package:soul_dungeon/core/models/reward_pool.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// NPC 생성기 — static 유틸리티 (ShopItemGenerator/MysteryResultGenerator 패턴).
/// 가중치 누적합 방식으로 NPC 유형 선택, 시드 기반 PRNG 지원.
class NpcGenerator {
  NpcGenerator._();

  // NPC 전용 아이템 풀 (trader 거래용)
  static const _npcBlessingPool = [
    ('npc_blessing_001', '은둔자의 부적', '전투 시작 시 블록 +2'),
    ('npc_blessing_002', '여행자의 부적', '전투 시작 시 기세 +5'),
    ('npc_blessing_003', '전사의 완장', '전투 시작 시 힘 +1'),
    ('npc_blessing_004', '치유의 부적', '전투 시작 시 HP 3 회복'),
    ('npc_blessing_005', '행운의 동전', '전투 시작 시 랜덤 카드 1장 생성'),
    ('npc_blessing_006', '인내의 반지', '블록 25% 다음 턴 유지'),
  ];

  /// (id, name, description, effectType, effectValue, priceMultiplier).
  static const _npcSupplyPool = [
    ('npc_supply_001', '방랑자의 물약', 'HP 10 회복', 'heal', 10, 1.0),
    ('npc_supply_003', '여행자의 붕대', 'HP 5 회복', 'heal', 5, 0.6),
    ('npc_supply_004', '기력 회복제', 'HP 5 회복', 'heal', 5, 0.6),
    ('npc_supply_005', '힘의 물약', '다음 전투 힘 +3', 'strength', 3, 1.2),
    ('npc_supply_006', '보호의 두루마리', '다음 전투 블록 10', 'block', 10, 0.8),
    ('npc_supply_007', '카드 교환권', '덱에서 카드 1장을 랜덤 무색 카드로 교체', 'cardExchange', 1, 1.5),
    ('npc_supply_008', '정화의 물', '저주 1개 제거', 'removeCurse', 1, 2.0),
    ('npc_supply_009', '강화 망치', '랜덤 카드 1장 업그레이드', 'upgradeRandomCard', 1, 1.8),
    ('npc_supply_010', '기세의 부적', '다음 전투 시작 기세 +15', 'momentumBonus', 15, 1.0),
    ('npc_supply_011', '생명의 과일', '최대 HP +5 (영구)', 'maxHpBonus', 5, 2.5),
  ];

  // NPC 유형별 이름 풀 (각 10개)
  static const _traderNames = [
    '방랑 상인 이즈',
    '여행 상인 카른',
    '교역 상인 델라',
    '야시장 상인 루카',
    '노련한 행상 마일로',
    '은밀한 거래꾼 지노',
    '보따리 상인 하나',
    '골동품 상인 에드',
    '떠도는 약장수 필',
    '보석 상인 오팔',
  ];
  static const _sageNames = [
    '현자 마로',
    '늙은 현자 세이',
    '은둔 현자 릴라',
    '수정 현자 글라스',
    '맹인 현자 아르스',
    '떠도는 점술사 미라',
    '고대 학자 벤',
    '별을 읽는 자 루나',
    '침묵의 현자 무',
    '시간의 현자 크론',
  ];
  static const _wandererNames = [
    '방랑자 노아',
    '떠돌이 카이',
    '길 잃은 나그네',
    '상처 입은 기사 렌',
    '탈주병 마르코',
    '숲에서 온 사냥꾼 이브',
    '떠도는 음유시인 핀',
    '버려진 아이 릴',
    '은퇴한 모험가 갈',
    '미궁의 생존자 토르',
  ];

  // NPC 유형별 인사말 풀 (각 10개)
  static const _traderGreetings = [
    '방랑 상인이 반갑게 손을 흔든다.',
    '낡은 외투를 두른 상인이 물건을 펼쳐 보인다.',
    '어둠 속에서 상인의 눈이 반짝인다.',
    '상인이 보따리를 풀며 능글맞은 미소를 짓는다.',
    '\'손님이 오셨군.\' 상인이 등불을 밝힌다.',
    '벽에 기대 졸던 상인이 당신을 보고 벌떡 일어난다.',
    '상인이 동전 몇 닢을 손가락 사이로 굴린다.',
    '\'좋은 타이밍이야.\' 상인이 진열대를 내민다.',
    '먼지를 털어내며 상인이 자리에서 일어선다.',
    '상인이 작은 종을 흔들어 당신의 주의를 끈다.',
  ];
  static const _sageGreetings = [
    '긴 수염의 현자가 고개를 끄덕인다.',
    '벽에 기대어 앉은 현자가 조용히 눈을 뜬다.',
    '고서를 읽던 현자가 올려다본다.',
    '현자가 수정 구슬에서 손을 뗀다.',
    '\'기다리고 있었네.\' 현자가 미소 짓는다.',
    '향 연기 사이로 현자의 형체가 드러난다.',
    '현자가 바닥에 그려진 마법진 위에서 일어선다.',
    '낡은 두루마리를 펼치던 현자가 고개를 돌린다.',
    '현자가 눈을 감은 채 당신의 기척을 느낀다.',
    '벽면의 문자를 해독하던 현자가 돌아본다.',
  ];
  static const _wandererGreetings = [
    '지친 표정의 방랑자가 모닥불 곁에 앉아 있다.',
    '먼 곳에서 온 듯한 여행자가 쉬고 있다.',
    '누더기를 걸친 방랑자가 약한 미소를 짓는다.',
    '벽에 등을 기댄 채 방랑자가 숨을 고르고 있다.',
    '방랑자가 상처를 감싸며 당신을 올려다본다.',
    '\'당신도 여기 갇힌 건가.\' 방랑자가 중얼거린다.',
    '바닥에 쓰러져 있던 방랑자가 가까스로 몸을 일으킨다.',
    '물을 마시던 방랑자가 당신에게 물통을 내민다.',
    '방랑자가 칼집을 어루만지며 먼 곳을 응시한다.',
    '방랑자가 조용히 고개를 끄덕이며 자리를 내준다.',
  ];

  // NPC 유형별 대화 텍스트 풀 (각 5개)
  static const _traderDialogues = [
    '이 심층에서 좋은 물건을 많이 모았지. 한번 살펴보게.',
    '싸게 줄 테니 골라 보게. 다음에 만날 수 있을진 모르니.',
    '이 밑에서 주운 것들이야. 쓸 만한 게 있을 걸세.',
    '돈이 있다면 거래하지. 이 아래선 금화가 생명이야.',
    '희귀한 물건이 들어왔네. 관심 있으면 말하게.',
  ];
  static const _sageDialogues = [
    '이 층의 적들은 만만치 않다네. 환경을 잘 활용하면 유리할 걸세.',
    '앞으로의 길이 험하다네. 이것이 도움이 될 걸세.',
    '이 영역엔 오래된 비밀이 숨어 있다네. 조심하게.',
    '내가 아는 지혜를 나누겠네. 이것이 마지막 선물이 될지도.',
    '오래 살면 많은 것을 보게 된다네. 자네의 여정에 축복을.',
    '적의 패턴을 읽는 것이 생존의 열쇠라네. 이 금화가 도움이 될 걸세.',
    '이 아래에선 탐욕이 가장 큰 적이라네. 현명하게 쓰게나.',
    '별의 움직임이 자네에게 행운을 가리키고 있네. 받아두게.',
    '이 영역의 벽에는 앞서간 이들의 지혜가 새겨져 있다네. 잘 읽어보게.',
    '자네의 영혼에서 강한 빛이 느껴지네. 이것으로 그 빛을 지키게나.',
  ];
  static const _wandererDialogues = [
    '여기서 누군가를 만나다니... 이건 작은 성의일세. 부디 조심하게나.',
    '나는 여기서 끝이지만, 당신은 다를지도 모르지. 이걸 가져가게.',
    '아래층은 더 험하다네. 이것이라도 도움이 되었으면.',
    '같은 처지끼리 돕는 건 당연한 거 아니겠나. 받게.',
    '당신의 눈빛... 아직 희망이 있군. 부디 살아남게나.',
  ];

  /// NPC 생성.
  /// [floor] 현재 층 (가격 계산용).
  /// [npcConfig] NPC 유형 가중치 및 보상 설정.
  /// [economyConfig] 아이템 가격 계산용.
  /// [seed] PRNG 시드 — 같은 시드 = 같은 NPC.
  static NpcData generate({
    required int floor,
    required NpcConfig npcConfig,
    required EconomyConfig economyConfig,
    int? seed,
  }) {
    final totalWeight = npcConfig.npcWeightTrader +
        npcConfig.npcWeightSage +
        npcConfig.npcWeightWanderer;
    assert(totalWeight > 0, 'NPC weight sum must be > 0');

    final rng = Random(seed);

    // 가중치 합계 0 방어 — release에서 nextInt(0) RangeError 방지
    if (totalWeight <= 0) {
      return _generateFallbackNpc(floor, npcConfig, economyConfig, rng);
    }

    // 가중치 누적합 방식으로 NPC 유형 선택
    final roll = rng.nextInt(totalWeight);
    var cumulative = 0;

    cumulative += npcConfig.npcWeightTrader;
    final NpcType npcType;
    if (roll < cumulative) {
      npcType = NpcType.trader;
    } else {
      cumulative += npcConfig.npcWeightSage;
      if (roll < cumulative) {
        npcType = NpcType.sage;
      } else {
        npcType = NpcType.wanderer;
      }
    }

    // 유형별 이름/인사말/대화 선택
    final String name;
    final String greetingText;
    final String dialogueText;
    switch (npcType) {
      case NpcType.trader:
        name = _traderNames[rng.nextInt(_traderNames.length)];
        greetingText = _traderGreetings[rng.nextInt(_traderGreetings.length)];
        dialogueText = _traderDialogues[rng.nextInt(_traderDialogues.length)];
      case NpcType.sage:
        name = _sageNames[rng.nextInt(_sageNames.length)];
        greetingText = _sageGreetings[rng.nextInt(_sageGreetings.length)];
        dialogueText = _sageDialogues[rng.nextInt(_sageDialogues.length)];
      case NpcType.wanderer:
        name = _wandererNames[rng.nextInt(_wandererNames.length)];
        greetingText =
            _wandererGreetings[rng.nextInt(_wandererGreetings.length)];
        dialogueText =
            _wandererDialogues[rng.nextInt(_wandererDialogues.length)];
    }

    // trader만 tradeItems 생성
    final List<ShopItem> tradeItems;
    if (npcType == NpcType.trader) {
      tradeItems = _generateTradeItems(
        floor: floor,
        economyConfig: economyConfig,
        count: npcConfig.npcTradeItemCount,
        rng: rng,
      );
    } else {
      tradeItems = const [];
    }

    // goldReward: trader=0, sage/wanderer=npcDialogueGoldReward
    final int goldReward;
    final Map<DispositionAxis, int> dispositionRewards;
    final bool upgradeRandomCard;
    if (npcType == NpcType.trader) {
      goldReward = 0;
      dispositionRewards = const {};
      upgradeRandomCard = false;
    } else {
      goldReward = npcConfig.npcDialogueGoldReward;
      // 현자 → 지혜+1, 방랑자 → 자비+1
      dispositionRewards = switch (npcType) {
        NpcType.sage => const {DispositionAxis.wisdom: 1},
        NpcType.wanderer => const {DispositionAxis.mercy: 1},
        _ => const {},
      };
      // ~15% 확률로 카드 강화 보상
      upgradeRandomCard = rng.nextInt(100) < 15;
    }

    return NpcData(
      id: 'npc_${npcType.name}_${seed ?? rng.nextInt(99999)}',
      npcType: npcType,
      name: name,
      greetingText: greetingText,
      dialogueText: dialogueText,
      tradeItems: tradeItems,
      goldReward: goldReward,
      dispositionRewards: dispositionRewards,
      upgradeRandomCard: upgradeRandomCard,
    );
  }

  /// 가중치 합계 0일 때 방어적 폴백 NPC (trader).
  static NpcData _generateFallbackNpc(
    int floor,
    NpcConfig npcConfig,
    EconomyConfig economyConfig,
    Random rng,
  ) {
    return NpcData(
      id: 'npc_trader_fallback',
      npcType: NpcType.trader,
      name: _traderNames[rng.nextInt(_traderNames.length)],
      greetingText: _traderGreetings[rng.nextInt(_traderGreetings.length)],
      dialogueText: _traderDialogues[rng.nextInt(_traderDialogues.length)],
      tradeItems: _generateTradeItems(
        floor: floor,
        economyConfig: economyConfig,
        count: npcConfig.npcTradeItemCount,
        rng: rng,
      ),
      goldReward: 0,
    );
  }

  /// NPC 전용 거래 아이템 생성 (ShopItemGenerator 미사용).
  static List<ShopItem> _generateTradeItems({
    required int floor,
    required EconomyConfig economyConfig,
    required int count,
    required Random rng,
  }) {
    final basePrice = (economyConfig.shopPriceBase *
            pow(economyConfig.shopPriceFloorMultiplier, floor - 1))
        .round();

    // 풀 크기 초과 시 중복 방지 — 전체 풀 크기로 클램핑
    final maxUniqueItems = _npcBlessingPool.length + _npcSupplyPool.length;
    final effectiveCount = count > maxUniqueItems ? maxUniqueItems : count;

    final items = <ShopItem>[];
    final usedBlessingIndices = <int>{};
    final usedSupplyIndices = <int>{};

    for (int i = 0; i < effectiveCount; i++) {
      // Rarity 결정 (RarityConfig 기반, NPC는 cursed 제외)
      const npcRarityConfig = RarityConfig();
      final rarity = RewardPool.rollRarityNoCursed(npcRarityConfig, rng);

      // 희귀도 보정 가격
      final price =
          RewardPool.calculatePrice(npcRarityConfig, basePrice, rarity);

      // ItemType 결정 (blessing 50%, supply 50%)
      final typeRoll = rng.nextDouble();
      final ItemType itemType;
      if (typeRoll < 0.5) {
        itemType = ItemType.blessing;
      } else {
        itemType = ItemType.supply;
      }

      // 풀에서 선택 (중복 방지)
      final String id;
      final String name;
      final String description;
      String? effectType;
      int? effectValue;
      var itemPrice = price;

      if (itemType == ItemType.blessing) {
        (id, name, description) = ItemPoolSelector.selectFromPool(
            _npcBlessingPool, usedBlessingIndices, rng);
      } else {
        final supplyData = ItemPoolSelector.selectFromPool(
            _npcSupplyPool, usedSupplyIndices, rng);
        id = supplyData.$1;
        name = supplyData.$2;
        description = supplyData.$3;
        effectType = supplyData.$4;
        effectValue = supplyData.$5;
        // 효과값 비례 가격 보정
        final priceMultiplier = supplyData.$6;
        itemPrice = (price * priceMultiplier).round();
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

    return items;
  }
}
