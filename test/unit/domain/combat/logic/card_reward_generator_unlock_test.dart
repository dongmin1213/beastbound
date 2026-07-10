import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/warrior_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_reward_generator.dart';

void main() {
  group('CardRewardGenerator — unlockedCardIds', () {
    test('unlockedCardIds 비어있으면 기존 동작', () {
      final r1 = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        random: Random(42),
      );
      final r2 = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        unlockedCardIds: const {},
        random: Random(42),
      );
      expect(
        r1.map((c) => c.id).toList(),
        r2.map((c) => c.id).toList(),
      );
    });

    test('unlockedCardIds에 있는 카드가 풀에 추가', () {
      // starter_strike_1은 기본 보상 풀(jobRewards+colorless)에 없음
      final starterCardId = 'starter_strike_1';
      final basePool = [
        ...CardPool.jobRewards('warrior'),
        ...CardPool.colorless,
      ];
      expect(basePool.any((c) => c.id == starterCardId), false,
          reason: 'starter_strike_1 is not in the default reward pool');

      // 전체 기본 풀 소유하여 해금 카드만 나오게 강제
      final ownedIds = basePool.map((c) => c.id).toSet();
      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 1,
        ownedCardIds: ownedIds,
        unlockedCardIds: {starterCardId},
        random: Random(42),
      );
      expect(rewards.length, 1);
      expect(rewards[0].id, starterCardId);
    });

    test('이미 ownedCardIds에 있으면 제외', () {
      final starterCardId = 'starter_strike_1';
      final basePool = [
        ...CardPool.jobRewards('warrior'),
        ...CardPool.colorless,
      ];
      final ownedIds = {
        ...basePool.map((c) => c.id),
        starterCardId, // 해금 카드도 이미 보유
      };

      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        ownedCardIds: ownedIds,
        unlockedCardIds: {starterCardId},
        random: Random(42),
      );
      expect(rewards.isEmpty, true);
    });

    test('존재하지 않는 카드 ID는 무시', () {
      final r1 = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        random: Random(42),
      );
      final r2 = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        unlockedCardIds: {'nonexistent_card_xyz'},
        random: Random(42),
      );
      expect(
        r1.map((c) => c.id).toList(),
        r2.map((c) => c.id).toList(),
      );
    });

    test('이미 풀에 있는 카드를 unlockedCardIds에 넣어도 중복 추가되지 않음', () {
      // warrior reward 카드 ID를 해금에도 넣기
      final warriorRewardId = WarriorCards.rewards.first.id;
      final r1 = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 23,
        random: Random(42),
      );
      final r2 = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 23,
        unlockedCardIds: {warriorRewardId},
        random: Random(42),
      );
      // 풀 크기 동일 → 결과 수 동일
      expect(r1.length, r2.length);
    });
  });
}
