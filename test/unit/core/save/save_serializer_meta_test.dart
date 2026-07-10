import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_serializer.dart';

void main() {
  group('SaveSerializer — Meta (E6 소울 업그레이드 필드)', () {
    test('round-trip — 새 필드 포함 전체 직렬화/역직렬화', () {
      const meta = MetaSaveData(
        totalRuns: 10,
        deathCount: 7,
        endingsReached: {'slay', 'coexist'},
        soulCount: 250,
        purchasedUpgradeIds: {'soul_card_unlock_1', 'soul_shop_discount'},
        upgradeLevels: {'soul_shop_discount': 2, 'soul_starting_gold': 3},
        unlockedCardIds: {'card_soul_strike'},
      );

      final jsonString = SaveSerializer.serializeMeta(meta);
      final result = SaveSerializer.deserializeMeta(jsonString);

      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 10);
      expect(loaded.deathCount, 7);
      expect(loaded.endingsReached, {'slay', 'coexist'});
      expect(loaded.soulCount, 250);
      expect(loaded.purchasedUpgradeIds,
          {'soul_card_unlock_1', 'soul_shop_discount'});
      expect(loaded.upgradeLevels,
          {'soul_shop_discount': 2, 'soul_starting_gold': 3});
      expect(loaded.unlockedCardIds, {'card_soul_strike'});
    });

    test('round-trip — 빈 새 필드', () {
      const meta = MetaSaveData(
        totalRuns: 1,
        soulCount: 5,
      );

      final jsonString = SaveSerializer.serializeMeta(meta);
      final result = SaveSerializer.deserializeMeta(jsonString);

      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.purchasedUpgradeIds, isEmpty);
      expect(loaded.upgradeLevels, isEmpty);
      expect(loaded.unlockedCardIds, isEmpty);
    });

    test('구버전 JSON (새 필드 없음) -> 기본값 폴백', () {
      // E5.5 이전 형식: purchasedUpgradeIds, upgradeLevels, unlockedCardIds 없음
      final oldJson = jsonEncode({
        'schemaVersion': 1,
        'totalRuns': 3,
        'deathCount': 2,
        'endingsReached': ['slay'],
        'soulCount': 50,
      });

      final result = SaveSerializer.deserializeMeta(oldJson);

      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.totalRuns, 3);
      expect(loaded.deathCount, 2);
      expect(loaded.endingsReached, {'slay'});
      expect(loaded.soulCount, 50);
      // 새 필드는 빈 기본값
      expect(loaded.purchasedUpgradeIds, isEmpty);
      expect(loaded.upgradeLevels, isEmpty);
      expect(loaded.unlockedCardIds, isEmpty);
    });

    test('새 필드 null 값 -> 빈 기본값', () {
      final json = jsonEncode({
        'schemaVersion': 1,
        'totalRuns': 1,
        'deathCount': 0,
        'endingsReached': [],
        'soulCount': 10,
        'purchasedUpgradeIds': null,
        'upgradeLevels': null,
        'unlockedCardIds': null,
      });

      final result = SaveSerializer.deserializeMeta(json);

      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.purchasedUpgradeIds, isEmpty);
      expect(loaded.upgradeLevels, isEmpty);
      expect(loaded.unlockedCardIds, isEmpty);
    });

    test('upgradeLevels 다양한 레벨 값 보존', () {
      const meta = MetaSaveData(
        upgradeLevels: {
          'soul_shop_discount': 1,
          'soul_starting_gold': 5,
          'soul_starting_deck_upgrade': 0,
        },
      );

      final jsonString = SaveSerializer.serializeMeta(meta);
      final result = SaveSerializer.deserializeMeta(jsonString);

      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.upgradeLevels['soul_shop_discount'], 1);
      expect(loaded.upgradeLevels['soul_starting_gold'], 5);
      expect(loaded.upgradeLevels['soul_starting_deck_upgrade'], 0);
    });

    test('purchasedUpgradeIds 순서 무관 Set 보존', () {
      const meta = MetaSaveData(
        purchasedUpgradeIds: {
          'soul_elite_rare_relic',
          'soul_card_unlock_3',
          'soul_card_unlock_1',
        },
      );

      final jsonString = SaveSerializer.serializeMeta(meta);
      final result = SaveSerializer.deserializeMeta(jsonString);

      expect(result, isA<Success<MetaSaveData>>());
      final loaded = (result as Success<MetaSaveData>).data;
      expect(loaded.purchasedUpgradeIds, containsAll([
        'soul_elite_rare_relic',
        'soul_card_unlock_3',
        'soul_card_unlock_1',
      ]));
      expect(loaded.purchasedUpgradeIds.length, 3);
    });
  });
}
