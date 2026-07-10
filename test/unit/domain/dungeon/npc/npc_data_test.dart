import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  const testItem = ShopItem(
    id: 'npc_blessing_001',
    name: '은둔자의 부적',
    description: '전투 시 방어력 약간 증가',
    itemType: ItemType.blessing,
    rarity: Rarity.common,
    price: 30,
  );

  const traderNpc = NpcData(
    id: 'npc_trader_42',
    npcType: NpcType.trader,
    name: '방랑 상인 이즈',
    greetingText: '방랑 상인이 반갑게 손을 흔든다.',
    dialogueText: '이 던전에서 좋은 물건을 많이 모았지.',
    tradeItems: [testItem],
    goldReward: 0,
  );

  const sageNpc = NpcData(
    id: 'npc_sage_42',
    npcType: NpcType.sage,
    name: '현자 마로',
    greetingText: '긴 수염의 현자가 고개를 끄덕인다.',
    dialogueText: '이 층의 적들은 만만치 않다네.',
    tradeItems: [],
    goldReward: 8,
  );

  group('NpcData', () {
    test('속성과 getter 동작 확인 (hasTradeItems, copyWith)', () {
      expect(traderNpc.id, 'npc_trader_42');
      expect(traderNpc.npcType, NpcType.trader);
      expect(traderNpc.name, '방랑 상인 이즈');
      expect(traderNpc.hasTradeItems, true);
      expect(traderNpc.goldReward, 0);

      expect(sageNpc.hasTradeItems, false);
      expect(sageNpc.goldReward, 8);

      // copyWith
      final soldItem = testItem.copyWith(sold: true);
      final updated = traderNpc.copyWith(tradeItems: [soldItem]);
      expect(updated.tradeItems[0].sold, true);
      expect(updated.id, traderNpc.id);
      expect(updated.name, traderNpc.name);
    });

    test('NpcType 3가지 값 존재', () {
      expect(NpcType.values.length, 3);
      expect(NpcType.values, contains(NpcType.trader));
      expect(NpcType.values, contains(NpcType.sage));
      expect(NpcType.values, contains(NpcType.wanderer));
    });

    test('==/hashCode 동등성', () {
      const same = NpcData(
        id: 'npc_trader_42',
        npcType: NpcType.trader,
        name: '방랑 상인 이즈',
        greetingText: '방랑 상인이 반갑게 손을 흔든다.',
        dialogueText: '이 던전에서 좋은 물건을 많이 모았지.',
        tradeItems: [testItem],
        goldReward: 0,
      );

      expect(traderNpc, equals(same));
      expect(traderNpc.hashCode, same.hashCode);

      // 다른 NPC
      expect(traderNpc, isNot(equals(sageNpc)));
    });
  });
}
