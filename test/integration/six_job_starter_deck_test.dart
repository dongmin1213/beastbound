import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/logic/starting_deck_builder.dart';

void main() {
  group('6직업 시작 덱 검증', () {
    for (final jobId in [
      'warrior',
      'sage',
      'assassin',
      'saint',
      'guardian',
      'wanderer',
    ]) {
      test('$jobId 시작 덱 — 12장', () {
        final deck = StartingDeckBuilder.build(jobId);
        expect(deck, hasLength(12));
      });

      test('$jobId 직업 카드 jobId 일치', () {
        final deck = StartingDeckBuilder.build(jobId);
        final jobCards = deck.where((c) => c.jobId == jobId);
        expect(jobCards, hasLength(5));
      });
    }

    test('soul_starting_deck_upgrade — 타격 카드 업그레이드', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        purchasedUpgradeIds: {'soul_starting_deck_upgrade'},
      );
      final strikes = deck.where((c) => c.id.startsWith('starter_strike'));
      for (final s in strikes) {
        expect(s.upgraded, isTrue);
      }
    });

    test('allCards = 241종', () {
      expect(CardPool.allCards, hasLength(241));
    });

    test('카드 ID 고유성', () {
      final ids = CardPool.allCards.map((c) => c.id).toSet();
      expect(ids, hasLength(241));
    });

    test('9직업 카드 + 무색 30 + 공통 7', () {
      expect(CardPool.jobCards('warrior'), hasLength(15));
      expect(CardPool.jobCards('sage'), hasLength(16));
      expect(CardPool.jobCards('assassin'), hasLength(16));
      expect(CardPool.jobCards('saint'), hasLength(14));
      expect(CardPool.jobCards('guardian'), hasLength(15));
      expect(CardPool.jobCards('wanderer'), hasLength(15));
      expect(CardPool.jobCards('reaper'), hasLength(14));
      expect(CardPool.jobCards('illusionist'), hasLength(15));
      expect(CardPool.jobCards('harmonist'), hasLength(14));
      expect(CardPool.colorless, hasLength(28));
      expect(CardPool.starter, hasLength(7));
    });
  });
}
