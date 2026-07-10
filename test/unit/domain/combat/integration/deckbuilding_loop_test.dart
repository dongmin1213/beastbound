import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_reward_generator.dart';
import 'package:soul_dungeon/domain/combat/logic/starting_deck_builder.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_reward_calculator.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  group('덱빌딩 루프 통합', () {
    test('전사: 시작덱 12장 → 전투3회 보상 → 15장', () {
      const jobId = 'warrior';
      final rng = Random(42);

      // 시작 덱 생성
      final startDeck = StartingDeckBuilder.build(jobId);
      expect(startDeck, hasLength(StartingDeckBuilder.deckSize));

      // 공통 7 + 전사 5
      final commonIds = StarterCards.all.map((c) => c.id).toSet();
      final jobIds = startDeck
          .where((c) => !commonIds.contains(c.id))
          .map((c) => c.id)
          .toSet();
      expect(jobIds, hasLength(5));

      // 3번 전투 승리 → 보상 각 1장 선택
      var currentDeck = List<CardData>.from(startDeck);
      for (int i = 0; i < 3; i++) {
        final ownedIds = currentDeck.map((c) => c.id).toSet();
        final rewards = CardRewardGenerator.generate(
          jobId: jobId,
          count: 3,
          ownedCardIds: ownedIds,
          random: rng,
        );

        // 보상은 최대 3장 (풀에 남은 카드가 있을 때)
        expect(rewards, isNotEmpty);
        expect(rewards.length, lessThanOrEqualTo(3));

        // 보상 카드가 이미 보유한 카드와 중복 없음
        for (final reward in rewards) {
          expect(ownedIds.contains(reward.id), isFalse);
        }

        // 첫 번째 보상 선택
        currentDeck.add(rewards.first);
      }

      expect(currentDeck, hasLength(15));
    });

    test('현자: 시작덱 12장', () {
      final deck = StartingDeckBuilder.build('sage');
      expect(deck, hasLength(12));
      // 공통 7장 포함
      final hasCommon = StarterCards.all.every(
        (c) => deck.any((d) => d.id == c.id),
      );
      expect(hasCommon, isTrue);
    });

    test('암살자: 시작덱 12장', () {
      final deck = StartingDeckBuilder.build('assassin');
      expect(deck, hasLength(12));
    });

    test('effectiveDeck: removedCardIds 반영', () {
      final deck = StartingDeckBuilder.build('warrior');
      final playerState = PlayerRunState.initial(maxHp: 80).copyWith(
        masterDeck: deck,
        removedCardIds: {deck.first.id},
      );

      expect(playerState.effectiveDeck, hasLength(11));
      expect(
        playerState.effectiveDeck.any((c) => c.id == deck.first.id),
        isFalse,
      );
    });

    test('보상 풀 고갈 → 빈 리스트 반환', () {
      // 모든 카드를 이미 보유
      final allIds = CardPool.allCards.map((c) => c.id).toSet();
      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 3,
        ownedCardIds: allIds,
      );
      expect(rewards, isEmpty);
    });

    test('보상 카드 풀: 직업 보상 + 무색', () {
      final rewards = CardRewardGenerator.generate(
        jobId: 'warrior',
        count: 100, // 전체 풀
        random: Random(0),
      );
      // 직업 보상 + 무색에서만 나옴 (starter 제외 확인은 CardPool 구현에 의존)
      for (final card in rewards) {
        final isJobReward = CardPool.jobRewards('warrior').any(
          (c) => c.id == card.id,
        );
        final isColorless = CardPool.colorless.any(
          (c) => c.id == card.id,
        );
        expect(isJobReward || isColorless, isTrue,
            reason: '${card.id}는 직업보상/무색이어야 함');
      }
    });
  });

  group('골드 경제 시뮬레이션', () {
    test('50방 골드 수입 범위 검증', () {
      const config = EconomyConfig();
      int totalGold = 0;

      // 50방 시뮬레이션: 40 일반 + 8 엘리트 + 2 보스
      for (int i = 0; i < 40; i++) {
        final reward = CombatRewardCalculator.calculate(
          roomType: RoomType.combat,
          economyConfig: config,
        );
        totalGold += reward.goldAmount;
      }
      for (int i = 0; i < 8; i++) {
        final reward = CombatRewardCalculator.calculate(
          roomType: RoomType.elite,
          economyConfig: config,
        );
        totalGold += reward.goldAmount;
      }
      for (int i = 0; i < 2; i++) {
        final reward = CombatRewardCalculator.calculate(
          roomType: RoomType.boss,
          economyConfig: config,
        );
        totalGold += reward.goldAmount;
      }

      // 기본 8 × 40 = 320, 엘리트 24 × 8 = 192, 보스 24 × 2 = 48
      // 합계 = 560
      expect(totalGold, 560);
    });

    test('일반 전투 보상 = baseGoldPerCombat', () {
      const config = EconomyConfig();
      final reward = CombatRewardCalculator.calculate(
        roomType: RoomType.combat,
        economyConfig: config,
      );
      expect(reward.goldAmount, config.baseGoldPerCombat);
    });

    test('엘리트 전투 보상 = base × 2.0', () {
      const config = EconomyConfig();
      final reward = CombatRewardCalculator.calculate(
        roomType: RoomType.elite,
        economyConfig: config,
      );
      expect(reward.goldAmount,
          (config.baseGoldPerCombat * config.eliteGoldMultiplier).round());
      expect(reward.rewardTag, 'elite_loot');
    });

    test('보스 전투 보상 = base × 3.0', () {
      const config = EconomyConfig();
      final reward = CombatRewardCalculator.calculate(
        roomType: RoomType.boss,
        economyConfig: config,
      );
      expect(reward.goldAmount,
          (config.baseGoldPerCombat * config.bossGoldMultiplier).round());
      expect(reward.rewardTag, 'boss_loot');
    });

    test('상점 가격 대비 골드 비율 — 2~3전투로 1아이템', () {
      const config = EconomyConfig();
      final combatGold = config.baseGoldPerCombat;
      final shopBase = config.shopPriceBase;

      // shopPriceBase=20, baseGoldPerCombat=8 → 2~3전투로 1아이템
      expect(shopBase ~/ combatGold, lessThanOrEqualTo(4));
      expect(shopBase ~/ combatGold, greaterThanOrEqualTo(1));
    });

    test('커스텀 EconomyConfig', () {
      const custom = EconomyConfig(
        baseGoldPerCombat: 15,
        eliteGoldMultiplier: 2.5,
        bossGoldMultiplier: 4.0,
      );
      final elite = CombatRewardCalculator.calculate(
        roomType: RoomType.elite,
        economyConfig: custom,
      );
      expect(elite.goldAmount, (15 * 2.5).round());

      final boss = CombatRewardCalculator.calculate(
        roomType: RoomType.boss,
        economyConfig: custom,
      );
      expect(boss.goldAmount, (15 * 4.0).round());
    });
  });
}
