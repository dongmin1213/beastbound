import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';

void main() {
  group('SoulCalculator', () {
    group('calculateDeathReward', () {
      test('0층 사망 -> 보상 0', () {
        expect(SoulCalculator.calculateDeathReward(0, 5), 0);
      });

      test('1층 사망 -> floorReached x soulBaseGain', () {
        expect(SoulCalculator.calculateDeathReward(1, 5), 5);
      });

      test('5층 사망 -> 5 x 5 = 25', () {
        expect(SoulCalculator.calculateDeathReward(5, 5), 25);
      });

      test('3층 사망, soulBaseGain 10 -> 30', () {
        expect(SoulCalculator.calculateDeathReward(3, 10), 30);
      });

      test('soulBaseGain 0 -> 항상 0', () {
        expect(SoulCalculator.calculateDeathReward(5, 0), 0);
      });
    });

    group('calculateClearReward', () {
      test('soulBaseGain 5 -> 50', () {
        expect(SoulCalculator.calculateClearReward(5), 50);
      });

      test('soulBaseGain 10 -> 100', () {
        expect(SoulCalculator.calculateClearReward(10), 100);
      });

      test('soulBaseGain 0 -> 0', () {
        expect(SoulCalculator.calculateClearReward(0), 0);
      });
    });

    group('upgradePrice', () {
      test('미구매 (level 0) -> basePrice x 1^exp = basePrice', () {
        expect(SoulCalculator.upgradePrice(20, 0, 1.5), 20);
      });

      test('1회 구매 후 (level 1) -> basePrice x 2^1.5', () {
        // 20 * 2^1.5 = 20 * 2.828... = 56.56... -> 56
        expect(SoulCalculator.upgradePrice(20, 1, 1.5), 56);
      });

      test('2회 구매 후 (level 2) -> basePrice x 3^1.5', () {
        // 20 * 3^1.5 = 20 * 5.196... = 103.92... -> 103
        expect(SoulCalculator.upgradePrice(20, 2, 1.5), 103);
      });

      test('exponent 1.0 -> 선형 증가', () {
        // 30 * (0+1)^1.0 = 30
        expect(SoulCalculator.upgradePrice(30, 0, 1.0), 30);
        // 30 * (1+1)^1.0 = 60
        expect(SoulCalculator.upgradePrice(30, 1, 1.0), 60);
        // 30 * (2+1)^1.0 = 90
        expect(SoulCalculator.upgradePrice(30, 2, 1.0), 90);
      });

      test('exponent 2.0 -> 제곱 증가', () {
        // 10 * (0+1)^2 = 10
        expect(SoulCalculator.upgradePrice(10, 0, 2.0), 10);
        // 10 * (1+1)^2 = 40
        expect(SoulCalculator.upgradePrice(10, 1, 2.0), 40);
        // 10 * (2+1)^2 = 90
        expect(SoulCalculator.upgradePrice(10, 2, 2.0), 90);
      });

      test('basePrice 0 -> 항상 0', () {
        expect(SoulCalculator.upgradePrice(0, 0, 1.5), 0);
        expect(SoulCalculator.upgradePrice(0, 5, 1.5), 0);
      });
    });
  });
}
