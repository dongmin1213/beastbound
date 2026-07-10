import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';

void main() {
  group('소울 경제 시뮬레이션', () {
    test('5런 사망 소울 축적 (층 1~5, base=5)', () {
      int totalSoul = 0;
      for (int floor = 1; floor <= 5; floor++) {
        totalSoul += SoulCalculator.calculateDeathReward(floor, 5);
      }
      // 5+10+15+20+25 = 75
      expect(totalSoul, 75);
    });

    test('클리어 보상 (base=5)', () {
      final reward = SoulCalculator.calculateClearReward(5);
      expect(reward, 50); // 5 * 10
    });

    test('업그레이드 가격 곡선 (exponent=1.5)', () {
      final prices = <int>[];
      for (int level = 0; level < 5; level++) {
        prices.add(SoulCalculator.upgradePrice(15, level, 1.5));
      }
      // 각 레벨별 가격이 점점 증가하는지 확인
      for (int i = 1; i < prices.length; i++) {
        expect(prices[i], greaterThanOrEqualTo(prices[i - 1]));
      }
    });

    test('가장 싼 업그레이드 (starting_gold base=15) — 1런(3층 사망) 소울로 구매 가능',
        () {
      final soulAfter1Run =
          SoulCalculator.calculateDeathReward(3, 5); // 15
      final price = SoulCalculator.upgradePrice(15, 0, 1.5); // 15
      expect(soulAfter1Run, greaterThanOrEqualTo(price));
    });

  });
}
