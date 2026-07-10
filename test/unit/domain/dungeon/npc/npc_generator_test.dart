import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_generator.dart';

void main() {
  const npcConfig = NpcConfig();
  const economyConfig = EconomyConfig();

  group('NpcGenerator', () {
    test('NPC 생성 — 필수 필드 비어있지 않음', () {
      final npc = NpcGenerator.generate(
        floor: 1,
        npcConfig: npcConfig,
        economyConfig: economyConfig,
        seed: 42,
      );

      expect(npc.id, isNotEmpty);
      expect(npc.name, isNotEmpty);
      expect(npc.greetingText, isNotEmpty);
      expect(npc.dialogueText, isNotEmpty);
      expect(NpcType.values, contains(npc.npcType));
    });

    test('시드 재현성 — 동일 시드로 동일 NPC 생성', () {
      final npc1 = NpcGenerator.generate(
        floor: 1,
        npcConfig: npcConfig,
        economyConfig: economyConfig,
        seed: 42,
      );
      final npc2 = NpcGenerator.generate(
        floor: 1,
        npcConfig: npcConfig,
        economyConfig: economyConfig,
        seed: 42,
      );

      expect(npc1, equals(npc2));
    });

    test('유형 확률 분포 — 1000회 생성, 각 유형 ±10%p tolerance', () {
      final counts = {
        NpcType.trader: 0,
        NpcType.sage: 0,
        NpcType.wanderer: 0,
      };

      for (int i = 0; i < 1000; i++) {
        final npc = NpcGenerator.generate(
          floor: 1,
          npcConfig: npcConfig,
          economyConfig: economyConfig,
          seed: i * 17,
        );
        counts[npc.npcType] = counts[npc.npcType]! + 1;
      }

      // trader 40% ± 10%p → 30~50%
      expect(counts[NpcType.trader]!, greaterThanOrEqualTo(300));
      expect(counts[NpcType.trader]!, lessThanOrEqualTo(500));

      // sage 30% ± 10%p → 20~40%
      expect(counts[NpcType.sage]!, greaterThanOrEqualTo(200));
      expect(counts[NpcType.sage]!, lessThanOrEqualTo(400));

      // wanderer 30% ± 10%p → 20~40%
      expect(counts[NpcType.wanderer]!, greaterThanOrEqualTo(200));
      expect(counts[NpcType.wanderer]!, lessThanOrEqualTo(400));
    });

    test('trader에만 tradeItems 존재', () {
      // 시드 탐색: trader를 반드시 생성하는 시드 찾기
      NpcData? traderNpc;
      NpcData? sageNpc;
      NpcData? wandererNpc;

      for (int i = 0; i < 100; i++) {
        final npc = NpcGenerator.generate(
          floor: 1,
          npcConfig: npcConfig,
          economyConfig: economyConfig,
          seed: i,
        );
        if (npc.npcType == NpcType.trader && traderNpc == null) {
          traderNpc = npc;
        }
        if (npc.npcType == NpcType.sage && sageNpc == null) {
          sageNpc = npc;
        }
        if (npc.npcType == NpcType.wanderer && wandererNpc == null) {
          wandererNpc = npc;
        }
        if (traderNpc != null && sageNpc != null && wandererNpc != null) break;
      }

      expect(traderNpc, isNotNull);
      expect(traderNpc!.hasTradeItems, true);
      expect(traderNpc.goldReward, 0);

      expect(sageNpc, isNotNull);
      expect(sageNpc!.hasTradeItems, false);
      expect(sageNpc.goldReward, npcConfig.npcDialogueGoldReward);

      expect(wandererNpc, isNotNull);
      expect(wandererNpc!.hasTradeItems, false);
      expect(wandererNpc.goldReward, npcConfig.npcDialogueGoldReward);
    });

    test('dialogueText 비어있지 않음 — 모든 NPC 유형', () {
      for (int i = 0; i < 30; i++) {
        final npc = NpcGenerator.generate(
          floor: 1,
          npcConfig: npcConfig,
          economyConfig: economyConfig,
          seed: i,
        );
        expect(npc.dialogueText, isNotEmpty);
      }
    });

    test('trader tradeItems.length == npcTradeItemCount', () {
      // 시드 탐색: trader를 생성하는 시드
      for (int i = 0; i < 100; i++) {
        final npc = NpcGenerator.generate(
          floor: 1,
          npcConfig: npcConfig,
          economyConfig: economyConfig,
          seed: i,
        );
        if (npc.npcType == NpcType.trader) {
          expect(npc.tradeItems.length, npcConfig.npcTradeItemCount);
          // 가격이 양수인지 확인
          for (final item in npc.tradeItems) {
            expect(item.price, greaterThan(0));
          }
          return;
        }
      }
      fail('No trader NPC generated in 100 seeds');
    });
  });
}
