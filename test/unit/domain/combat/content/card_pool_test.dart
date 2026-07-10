import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';

void main() {
  group('CardPool', () {
    test('allCards — 241종', () {
      expect(CardPool.allCards, hasLength(241));
    });

    test('모든 ID 고유', () {
      final ids = CardPool.allCards.map((c) => c.id).toSet();
      expect(ids, hasLength(241));
    });

    test('starter 7장', () {
      expect(CardPool.starter, hasLength(7));
    });

    test('colorless 28장 (소울 해금 카드 제외)', () {
      expect(CardPool.colorless, hasLength(28));
    });

    test('jobCards — warrior 15장', () {
      expect(CardPool.jobCards('warrior'), hasLength(15));
    });

    test('jobCards — sage 16장', () {
      expect(CardPool.jobCards('sage'), hasLength(16));
    });

    test('jobCards — assassin 16장', () {
      expect(CardPool.jobCards('assassin'), hasLength(16));
    });

    test('jobCards — saint 14장', () {
      expect(CardPool.jobCards('saint'), hasLength(14));
    });

    test('jobCards — guardian 15장', () {
      expect(CardPool.jobCards('guardian'), hasLength(15));
    });

    test('jobCards — wanderer 15장', () {
      expect(CardPool.jobCards('wanderer'), hasLength(15));
    });

    test('jobCards — unknown → 빈 리스트', () {
      expect(CardPool.jobCards('unknown'), isEmpty);
    });

    test('jobStarter — warrior 5장', () {
      expect(CardPool.jobStarter('warrior'), hasLength(5));
    });

    test('jobRewards — sage 11장', () {
      expect(CardPool.jobRewards('sage'), hasLength(11));
    });

    test('findById — 존재하는 카드', () {
      final card = CardPool.findById('starter_strike_1');
      expect(card, isNotNull);
      expect(card!.name, '타격');
    });

    test('findById — 없는 ID → null', () {
      expect(CardPool.findById('nonexistent'), isNull);
    });
  });
}
