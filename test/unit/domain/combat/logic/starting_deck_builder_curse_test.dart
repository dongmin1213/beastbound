import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/curse_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/starting_deck_builder.dart';

void main() {
  group('StartingDeckBuilder - Curse Integration', () {
    test('저주 없음 → 저주 카드 없음 (덱 크기 12)', () {
      final deck = StartingDeckBuilder.build('warrior');
      expect(deck.length, 12);
      final curseIds = CurseCards.all.map((c) => c.id).toSet();
      expect(deck.where((c) => curseIds.contains(c.id)).length, 0);
    });

    test('activeCurseIds 빈 리스트 → 저주 없음과 동일', () {
      final deck = StartingDeckBuilder.build('warrior', activeCurseIds: []);
      expect(deck.length, 12);
      final curseIds = CurseCards.all.map((c) => c.id).toSet();
      expect(deck.where((c) => curseIds.contains(c.id)).length, 0);
    });

    test('레벨 1 카드 저주 → 저주 카드 1장 (덱 크기 13)', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        activeCurseIds: ['curse_mod_card:1'],
      );
      expect(deck.length, 13);
      final curseIds = CurseCards.all.map((c) => c.id).toSet();
      final curseCards = deck.where((c) => curseIds.contains(c.id)).toList();
      expect(curseCards.length, 1);
    });

    test('레벨 3 카드 저주 → 저주 카드 2장 (덱 크기 14)', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        activeCurseIds: ['curse_mod_card:3'],
      );
      expect(deck.length, 14);
      final curseIds = CurseCards.all.map((c) => c.id).toSet();
      final curseCards = deck.where((c) => curseIds.contains(c.id)).toList();
      expect(curseCards.length, 2);
    });

    test('레벨 5 카드 저주 → 저주 카드 3장 (덱 크기 15)', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        activeCurseIds: ['curse_mod_card:5'],
      );
      expect(deck.length, 15);
      final curseIds = CurseCards.all.map((c) => c.id).toSet();
      final curseCards = deck.where((c) => curseIds.contains(c.id)).toList();
      expect(curseCards.length, 3);
    });

    test('저주 카드는 CurseCards에서 가져옴 (weakness/decay 패턴)', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        activeCurseIds: ['curse_mod_card:3'],
      );
      final curseIds = CurseCards.all.map((c) => c.id).toSet();
      final curseCards = deck.where((c) => curseIds.contains(c.id)).toList();

      expect(curseCards.length, 2);
      // forCount(2) → [weakness, decay]
      expect(curseCards[0].id, CurseCards.weakness.id);
      expect(curseCards[1].id, CurseCards.decay.id);
    });

    test('전투 저주는 시작 덱에 영향 없음', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        activeCurseIds: ['curse_mod_combat:5'],
      );
      expect(deck.length, 12); // 전투 저주는 카드 추가 안 함
    });

    test('덱 저주는 시작 덱에 영향 없음', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        activeCurseIds: ['curse_mod_deck:5'],
      );
      expect(deck.length, 12); // 덱 저주는 카드 추가 안 함
    });

    test('서술자 저주는 시작 덱에 영향 없음', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        activeCurseIds: ['curse_mod_narrator:5'],
      );
      expect(deck.length, 12); // 서술자 저주는 카드 추가 안 함
    });

    test('다중 저주 — 카드 저주만 덱 추가', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        activeCurseIds: [
          'curse_mod_combat:3',
          'curse_mod_deck:3',
          'curse_mod_card:3',
          'curse_mod_narrator:3',
        ],
      );
      expect(deck.length, 14); // 카드 저주 레벨 3 = 2장만 추가
      final curseIds = CurseCards.all.map((c) => c.id).toSet();
      final curseCards = deck.where((c) => curseIds.contains(c.id)).toList();
      expect(curseCards.length, 2);
    });

    test('소울 업그레이드 + 저주 조합', () {
      final deck = StartingDeckBuilder.build(
        'warrior',
        purchasedUpgradeIds: {'soul_starting_deck_upgrade'},
        activeCurseIds: ['curse_mod_card:1'],
      );
      expect(deck.length, 13); // 12 + 1 저주 카드
      final curseIds = CurseCards.all.map((c) => c.id).toSet();
      final curseCards = deck.where((c) => curseIds.contains(c.id)).toList();
      expect(curseCards.length, 1);
    });
  });
}
