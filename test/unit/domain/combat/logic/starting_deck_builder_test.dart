import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/monster_cards.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/content/warrior_cards.dart';
import 'package:soul_dungeon/domain/combat/content/sage_cards.dart';
import 'package:soul_dungeon/domain/combat/content/assassin_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/starting_deck_builder.dart';

void main() {
  group('StartingDeckBuilder', () {
    test('warrior 시작 덱 = 12장 (공통7 + 전사5)', () {
      final deck = StartingDeckBuilder.build('warrior');
      expect(deck.length, 12);
    });

    test('warrior 시작 덱에 공통 카드 7장 포함', () {
      final deck = StartingDeckBuilder.build('warrior');
      final starterIds = StarterCards.all.map((c) => c.id).toSet();
      final deckStarterCount = deck.where((c) => starterIds.contains(c.id)).length;
      expect(deckStarterCount, 7);
    });

    test('warrior 시작 덱에 전사 시작 카드 5장 포함', () {
      final deck = StartingDeckBuilder.build('warrior');
      final warriorStarterIds = WarriorCards.starter.map((c) => c.id).toSet();
      final count = deck.where((c) => warriorStarterIds.contains(c.id)).length;
      expect(count, 5);
    });

    test('sage 시작 덱 = 12장 (공통7 + 현자5)', () {
      final deck = StartingDeckBuilder.build('sage');
      expect(deck.length, 12);
      final sageStarterIds = SageCards.starter.map((c) => c.id).toSet();
      final count = deck.where((c) => sageStarterIds.contains(c.id)).length;
      expect(count, 5);
    });

    test('assassin 시작 덱 = 12장 (공통7 + 암살자5)', () {
      final deck = StartingDeckBuilder.build('assassin');
      expect(deck.length, 12);
      final assassinStarterIds = AssassinCards.starter.map((c) => c.id).toSet();
      final count = deck.where((c) => assassinStarterIds.contains(c.id)).length;
      expect(count, 5);
    });

    test('알 수 없는 직업은 공통 7장만', () {
      final deck = StartingDeckBuilder.build('unknown');
      expect(deck.length, 7);
      final starterIds = StarterCards.all.map((c) => c.id).toSet();
      expect(deck.every((c) => starterIds.contains(c.id)), true);
    });

    test('deckSize 상수 = 12', () {
      expect(StartingDeckBuilder.deckSize, 12);
    });

    test('시작 덱 카드는 모두 비업그레이드', () {
      final deck = StartingDeckBuilder.build('warrior');
      expect(deck.every((c) => !c.upgraded), true);
    });
  });
  group('buildFromMonster (스타터 몬스터)', () {
    test('공통 7장 + 몬스터 무브풀', () {
      final deck = StartingDeckBuilder.buildFromMonster('enemy_goblin');
      final movepool = MonsterCards.movepoolIds('enemy_goblin');
      expect(deck.length, 7 + movepool.length);
      // 무브풀 카드가 덱에 포함
      for (final id in movepool) {
        expect(deck.any((c) => c.id == id), isTrue, reason: 'missing \$id');
      }
    });

    test('무브풀 없는 몬스터 → 공통 7장만', () {
      final deck = StartingDeckBuilder.buildFromMonster('enemy_unknown_zzz');
      expect(deck.length, 7);
    });
  });
}
