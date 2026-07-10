
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_result_generator.dart';

void main() {
  const config = MysteryConfig();

  group('MysteryResultGenerator', () {
    test('generate returns a valid MysteryOutcome', () {
      final outcome = MysteryResultGenerator.generate(
        floor: 1,
        mysteryConfig: config,
        seed: 42,
      );

      expect(outcome, isA<MysteryOutcome>());
    });

    test('generate with same seed produces identical results', () {
      final outcome1 = MysteryResultGenerator.generate(
        floor: 1,
        mysteryConfig: config,
        seed: 12345,
      );
      final outcome2 = MysteryResultGenerator.generate(
        floor: 1,
        mysteryConfig: config,
        seed: 12345,
      );

      expect(outcome1, equals(outcome2));
      expect(outcome1.runtimeType, outcome2.runtimeType);
      expect(outcome1.goldChange, outcome2.goldChange);
      expect(outcome1.hpChange, outcome2.hpChange);
    });

    test('generate covers all 5 outcome types over large sample', () {
      const sampleSize = 1000;
      final counts = <Type, int>{};

      for (var i = 0; i < sampleSize; i++) {
        final outcome = MysteryResultGenerator.generate(
          floor: 1,
          mysteryConfig: config,
          seed: i,
        );
        counts[outcome.runtimeType] = (counts[outcome.runtimeType] ?? 0) + 1;
      }

      // 모든 5개 타입이 등장해야 함
      expect(counts.containsKey(TreasureOutcome), isTrue);
      expect(counts.containsKey(TrapOutcome), isTrue);
      expect(counts.containsKey(EncounterOutcome), isTrue);
      expect(counts.containsKey(EventOutcome), isTrue);
      expect(counts.containsKey(MinorOutcome), isTrue);

      // ±10%p tolerance (15% → 5~25%, 20% → 10~30%, 30% → 20~40%)
      final total = sampleSize.toDouble();
      expect(counts[TreasureOutcome]! / total, closeTo(0.15, 0.10));
      expect(counts[TrapOutcome]! / total, closeTo(0.20, 0.10));
      expect(counts[EncounterOutcome]! / total, closeTo(0.30, 0.10));
      expect(counts[EventOutcome]! / total, closeTo(0.15, 0.10));
      expect(counts[MinorOutcome]! / total, closeTo(0.20, 0.10));
    });

    test('generate returns non-empty narrativeText', () {
      // 다양한 시드로 narrativeText 확인
      for (var seed = 0; seed < 50; seed++) {
        final outcome = MysteryResultGenerator.generate(
          floor: 1,
          mysteryConfig: config,
          seed: seed,
        );
        expect(outcome.narrativeText, isNotEmpty);
      }
    });

    test('generate returns correct reward/penalty signs', () {
      // 다양한 시드로 보상/페널티 부호 확인
      for (var seed = 0; seed < 100; seed++) {
        final outcome = MysteryResultGenerator.generate(
          floor: 1,
          mysteryConfig: config,
          seed: seed,
        );

        switch (outcome) {
          case TreasureOutcome():
            expect(outcome.goldChange, greaterThan(0));
            expect(outcome.hpChange, equals(0));
          case TrapOutcome():
            expect(outcome.goldChange, equals(0));
            expect(outcome.hpChange, lessThan(0));
          case EncounterOutcome():
            expect(outcome.goldChange, greaterThan(0));
            expect(outcome.hpChange, equals(0));
          case EventOutcome():
            expect(outcome.goldChange, greaterThan(0));
            expect(outcome.hpChange, equals(0));
          case MinorOutcome():
            expect(outcome.goldChange, greaterThan(0));
            expect(outcome.hpChange, equals(0));
        }
      }
    });

    group('load()', () {
      test('load — valid JSON replaces defaults', () async {
        final bundle = _TestBundle();
        await MysteryResultGenerator.load(bundle: bundle);

        final outcome = MysteryResultGenerator.generate(
          floor: 1,
          mysteryConfig: config,
          seed: 42,
        );

        // JSON 텍스트가 로드되었으므로 기본값과 다른 텍스트여야 함
        expect(outcome.narrativeText, contains('TEST'));

        // 복원: invalid bundle로 로드 → 기본값 폴백
        await MysteryResultGenerator.load(bundle: _InvalidBundle());
      });

      test('load — invalid JSON keeps defaults', () async {
        // 먼저 기본값 상태의 결과를 기록
        final before = MysteryResultGenerator.generate(
          floor: 1,
          mysteryConfig: config,
          seed: 42,
        );

        await MysteryResultGenerator.load(bundle: _InvalidBundle());

        final after = MysteryResultGenerator.generate(
          floor: 1,
          mysteryConfig: config,
          seed: 42,
        );

        expect(after.narrativeText, before.narrativeText);
      });
    });
  });
}

class _TestBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"treasure":["TEST 보물"],"trap":["TEST 함정"],"combat":["TEST 전투"],"event":["TEST 이벤트"],"minor":["TEST 소소한"]}';
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}

class _InvalidBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return 'not valid json';
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}
