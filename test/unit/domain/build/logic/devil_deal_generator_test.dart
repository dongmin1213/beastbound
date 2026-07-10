import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/build/logic/devil_deal_generator.dart';

void main() {
  group('DevilDealGenerator', () {
    group('shouldOffer', () {
      test('1층에서는 제공하지 않음 (기본 floorStart=2)', () {
        // 확률 100%로 설정해도 1층에서는 false
        expect(
          DevilDealGenerator.shouldOffer(
              floor: 1, seed: 42, probability: 1.0),
          isFalse,
        );
      });

      test('2층부터 확률 기반 제공', () {
        // probability=1.0 → 항상 true
        expect(
          DevilDealGenerator.shouldOffer(
              floor: 2, seed: 42, probability: 1.0),
          isTrue,
        );
      });

      test('확률 0 → 항상 false', () {
        expect(
          DevilDealGenerator.shouldOffer(
              floor: 3, seed: 42, probability: 0.0),
          isFalse,
        );
      });

      test('같은 시드 → 같은 결과 (결정론적)', () {
        final r1 = DevilDealGenerator.shouldOffer(floor: 3, seed: 12345);
        final r2 = DevilDealGenerator.shouldOffer(floor: 3, seed: 12345);
        expect(r1, equals(r2));
      });

      test('다른 시드 → 다른 결과 가능', () {
        // 여러 시드 시도해서 최소 하나는 다른 결과
        final results = <bool>{};
        for (int s = 0; s < 100; s++) {
          results.add(DevilDealGenerator.shouldOffer(
              floor: 3, seed: s, probability: 0.5));
        }
        expect(results.length, 2, reason: '100개 시드 중 true/false 모두 나와야 함');
      });

      test('커스텀 floorStart 적용', () {
        expect(
          DevilDealGenerator.shouldOffer(
              floor: 3, floorStart: 4, seed: 42, probability: 1.0),
          isFalse,
        );
        expect(
          DevilDealGenerator.shouldOffer(
              floor: 4, floorStart: 4, seed: 42, probability: 1.0),
          isTrue,
        );
      });
    });

    group('generateDeal', () {
      test('거래 1개 반환', () {
        final deal = DevilDealGenerator.generateDeal(seed: 42);
        expect(deal, isNotNull);
      });

      test('같은 시드 → 같은 거래', () {
        final d1 = DevilDealGenerator.generateDeal(seed: 42);
        final d2 = DevilDealGenerator.generateDeal(seed: 42);
        expect(d1!.id, d2!.id);
      });

      test('이미 보유한 축복 제외', () {
        // 모든 거래의 blessingId 수집
        final allBlessingIds = <String>{};
        for (int s = 0; s < 1000; s++) {
          final d = DevilDealGenerator.generateDeal(seed: s);
          if (d != null) allBlessingIds.add(d.blessingId);
        }

        // 모든 blessingId를 이미 보유한 것으로 설정
        final deal = DevilDealGenerator.generateDeal(
          ownedBlessingIds: allBlessingIds.toList(),
          seed: 42,
        );
        expect(deal, isNull, reason: '모든 축복 보유 시 거래 없음');
      });

      test('보유 축복 1개만 제외', () {
        final d1 = DevilDealGenerator.generateDeal(
          ownedBlessingIds: ['devil_blessing_001'],
          seed: 42,
        );
        // 결과가 있으면 devil_blessing_001이 아니어야 함
        if (d1 != null) {
          expect(d1.blessingId, isNot('devil_blessing_001'));
        }
      });
    });
  });
}
