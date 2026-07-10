import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/reward_pool.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('RewardPool', () {
    group('rollRarity', () {
      test('기본 가중치 — 4등급 모두 생성됨', () {
        const config = RarityConfig();
        final counts = <Rarity, int>{};
        final rng = Random(42);

        for (int i = 0; i < 10000; i++) {
          final rarity = RewardPool.rollRarity(config, rng);
          counts[rarity] = (counts[rarity] ?? 0) + 1;
        }

        expect(counts[Rarity.common], isNotNull);
        expect(counts[Rarity.rare], isNotNull);
        expect(counts[Rarity.legendary], isNotNull);
        expect(counts[Rarity.cursed], isNotNull);
      });

      test('common 비율이 가장 높음', () {
        const config = RarityConfig();
        final counts = <Rarity, int>{};
        final rng = Random(42);

        for (int i = 0; i < 10000; i++) {
          final rarity = RewardPool.rollRarity(config, rng);
          counts[rarity] = (counts[rarity] ?? 0) + 1;
        }

        expect(counts[Rarity.common]!, greaterThan(counts[Rarity.rare]!));
        expect(counts[Rarity.rare]!, greaterThan(counts[Rarity.legendary]!));
      });

      test('cursed 가중치 0 → cursed 생성 안 됨', () {
        const config = RarityConfig(weightCursed: 0);
        final rng = Random(42);

        for (int i = 0; i < 1000; i++) {
          final rarity = RewardPool.rollRarity(config, rng);
          expect(rarity, isNot(Rarity.cursed));
        }
      });

      test('cursed만 가중치 있음 → 항상 cursed', () {
        const config = RarityConfig(
          weightCommon: 0,
          weightRare: 0,
          weightLegendary: 0,
          weightCursed: 100,
        );
        final rng = Random(42);

        for (int i = 0; i < 100; i++) {
          expect(RewardPool.rollRarity(config, rng), Rarity.cursed);
        }
      });

      test('같은 시드 → 같은 결과 (결정론적)', () {
        const config = RarityConfig();
        final results1 = <Rarity>[];
        final results2 = <Rarity>[];

        for (int i = 0; i < 100; i++) {
          results1.add(RewardPool.rollRarity(config, Random(i)));
          results2.add(RewardPool.rollRarity(config, Random(i)));
        }

        expect(results1, equals(results2));
      });
    });

    group('rollRarityNoCursed', () {
      test('cursed 생성 안 됨', () {
        const config = RarityConfig();
        final rng = Random(42);

        for (int i = 0; i < 1000; i++) {
          final rarity = RewardPool.rollRarityNoCursed(config, rng);
          expect(rarity, isNot(Rarity.cursed));
        }
      });

      test('3등급만 생성됨', () {
        const config = RarityConfig();
        final counts = <Rarity, int>{};
        final rng = Random(42);

        for (int i = 0; i < 10000; i++) {
          final rarity = RewardPool.rollRarityNoCursed(config, rng);
          counts[rarity] = (counts[rarity] ?? 0) + 1;
        }

        expect(counts.keys, everyElement(isIn([
          Rarity.common,
          Rarity.rare,
          Rarity.legendary,
        ])));
      });
    });

    group('getPriceMultiplier', () {
      test('기본 가격 배율 반환', () {
        const config = RarityConfig();
        expect(RewardPool.getPriceMultiplier(config, Rarity.common), 1.0);
        expect(RewardPool.getPriceMultiplier(config, Rarity.rare), 1.5);
        expect(RewardPool.getPriceMultiplier(config, Rarity.legendary), 2.0);
        expect(RewardPool.getPriceMultiplier(config, Rarity.cursed), 0.8);
      });
    });

    group('calculatePrice', () {
      test('기본 가격 × 배율', () {
        const config = RarityConfig();
        expect(RewardPool.calculatePrice(config, 30, Rarity.common), 30);
        expect(RewardPool.calculatePrice(config, 30, Rarity.rare), 45);
        expect(RewardPool.calculatePrice(config, 30, Rarity.legendary), 60);
        expect(RewardPool.calculatePrice(config, 30, Rarity.cursed), 24);
      });

      test('커스텀 배율 적용', () {
        const config = RarityConfig(priceMultiplierCursed: 2.0);
        expect(RewardPool.calculatePrice(config, 30, Rarity.cursed), 60);
      });
    });
  });

  group('RarityConfig', () {
    test('기본값', () {
      const config = RarityConfig();
      expect(config.weightCommon, 55);
      expect(config.weightRare, 30);
      expect(config.weightLegendary, 10);
      expect(config.weightCursed, 5);
      expect(config.totalWeight, 100);
    });

    test('JSON 역직렬화', () {
      final config = RarityConfig.fromJson({
        'weight_common': 50,
        'weight_rare': 25,
        'weight_legendary': 15,
        'weight_cursed': 10,
        'price_multiplier_common': 1.0,
        'price_multiplier_rare': 1.8,
        'price_multiplier_legendary': 3.0,
        'price_multiplier_cursed': 0.5,
      });
      expect(config.weightCommon, 50);
      expect(config.weightRare, 25);
      expect(config.weightLegendary, 15);
      expect(config.weightCursed, 10);
      expect(config.priceMultiplierRare, 1.8);
      expect(config.priceMultiplierCursed, 0.5);
    });

    test('totalWeight 합산', () {
      const config = RarityConfig(
        weightCommon: 10,
        weightRare: 20,
        weightLegendary: 30,
        weightCursed: 40,
      );
      expect(config.totalWeight, 100);
    });
  });
}
