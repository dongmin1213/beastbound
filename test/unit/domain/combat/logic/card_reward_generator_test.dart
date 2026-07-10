import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/warrior_cards.dart';
import 'package:soul_dungeon/domain/combat/content/sage_cards.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_reward_generator.dart';

void main() {
  group('CardRewardGenerator', () {
    test('기본 3장 보상 생성', () {
      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        random: Random(42),
      );
      expect(rewards.length, 3);
    });

    test('보상 카드는 중복 없음', () {
      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        random: Random(42),
      );
      final ids = rewards.map((c) => c.id).toSet();
      expect(ids.length, 3);
    });

    test('보상 풀은 직업 보상 + 무색', () {
      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 20,
        random: Random(42),
      );
      final warriorRewardIds = WarriorCards.rewards.map((c) => c.id).toSet();
      final colorlessIds = ColorlessCards.all.map((c) => c.id).toSet();
      final validPool = {...warriorRewardIds, ...colorlessIds};
      for (final card in rewards) {
        expect(validPool.contains(card.id), true,
            reason: '${card.id} should be in warrior rewards or colorless');
      }
    });

    test('sage 직업 보상은 sage 보상 + 무색', () {
      final rewards = CardRewardGenerator.generate(
        jobId: 'sage',
        count: 20,
        random: Random(42),
      );
      final sageRewardIds = SageCards.rewards.map((c) => c.id).toSet();
      final colorlessIds = ColorlessCards.all.map((c) => c.id).toSet();
      final validPool = {...sageRewardIds, ...colorlessIds};
      for (final card in rewards) {
        expect(validPool.contains(card.id), true,
            reason: '${card.id} should be in sage rewards or colorless');
      }
    });

    test('이미 보유한 카드는 제외', () {
      final allRewards = CardPool.jobRewards('warrior');
      final ownedIds = allRewards.map((c) => c.id).toSet();

      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        ownedCardIds: ownedIds,
        random: Random(42),
      );
      // 전사 보상 3장 모두 소유 → 무색에서만 선택
      for (final card in rewards) {
        expect(ownedIds.contains(card.id), false);
      }
    });

    test('count보다 후보가 적으면 가능한 만큼만 반환', () {
      // 전체 보상 풀 소유 (무색 20 + 전사 보상 3 = 23)
      final allPool = [
        ...CardPool.jobRewards('warrior'),
        ...CardPool.colorless,
      ];
      final allIds = allPool.map((c) => c.id).toSet();

      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 30,
        ownedCardIds: allIds,
        random: Random(42),
      );
      expect(rewards.isEmpty, true);
    });

    test('같은 seed는 같은 결과', () {
      final r1 = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        random: Random(42),
      );
      final r2 = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        random: Random(42),
      );
      expect(r1.map((c) => c.id).toList(), r2.map((c) => c.id).toList());
    });

    test('알 수 없는 직업은 무색만 반환', () {
      final rewards = CardRewardGenerator.generate(
        jobId: 'unknown',
        count: 3,
        random: Random(42),
      );
      expect(rewards.length, 3);
      final colorlessIds = ColorlessCards.all.map((c) => c.id).toSet();
      for (final card in rewards) {
        expect(colorlessIds.contains(card.id), true);
      }
    });

    test('count=0이면 빈 리스트', () {
      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 0,
        random: Random(42),
      );
      expect(rewards.isEmpty, true);
    });

    test('시작 카드는 보상 풀에 포함되지 않음', () {
      // 보상 풀은 jobRewards + colorless이므로 starter 카드는 없어야 함
      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 23, // 최대치
        random: Random(42),
      );
      final starterIds = {'starter_strike_1', 'starter_strike_2',
        'starter_strike_3', 'starter_defend_1', 'starter_defend_2'};
      for (final card in rewards) {
        expect(starterIds.contains(card.id), false,
            reason: '${card.id} is a starter card');
      }
    });
  });
}
