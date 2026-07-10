import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/deck_view_handler.dart';

void main() {
  group('DeckViewHandler', () {
    final attackCard = const CardData(
      id: 'strike',
      name: '강타',
      type: CardType.attack,
      apCost: 1,
      damage: 6,
      description: '6 데미지',
    );

    final skillCard = const CardData(
      id: 'defend',
      name: '방어',
      type: CardType.skill,
      apCost: 1,
      block: 5,
      description: '5 블록',
    );

    final powerCard = const CardData(
      id: 'power_up',
      name: '힘의 형태',
      type: CardType.power,
      apCost: 2,
      description: '힘 +2',
      effects: [CardEffect(type: CardEffectType.gainStrength, value: 2)],
    );

    final upgradedAttack = const CardData(
      id: 'strike_plus',
      name: '강타+',
      type: CardType.attack,
      apCost: 1,
      damage: 9,
      description: '9 데미지',
      upgraded: true,
    );

    group('formatDeckList', () {
      test('sorts cards by type: attack → skill → power', () {
        // 순서를 섞어서 입력 (power, attack, skill)
        final deck = [powerCard, attackCard, skillCard];

        final result = DeckViewHandler.formatDeckList(deck);

        expect(result.length, 3);
        // 첫째 = attack (강타), 둘째 = skill (방어), 셋째 = power (힘의 형태)
        expect(result[0], contains('강타'));
        expect(result[1], contains('방어'));
        expect(result[2], contains('힘의 형태'));
      });

      test('formats each card using CardDisplayFormatter', () {
        final deck = [attackCard];

        final result = DeckViewHandler.formatDeckList(deck);

        expect(result.length, 1);
        expect(result[0], contains('[1AP]'));
        expect(result[0], contains('강타'));
        expect(result[0], contains('6 데미지'));
      });

      test('handles empty deck', () {
        final result = DeckViewHandler.formatDeckList([]);
        expect(result, isEmpty);
      });

      test('does not modify original deck order', () {
        final deck = [powerCard, attackCard, skillCard];
        DeckViewHandler.formatDeckList(deck);

        // 원본 순서 유지 확인
        expect(deck[0].id, 'power_up');
        expect(deck[1].id, 'strike');
        expect(deck[2].id, 'defend');
      });
    });

    group('formatDeckStats', () {
      test('counts attack/skill/power correctly', () {
        final deck = [attackCard, attackCard, skillCard, powerCard];

        final result = DeckViewHandler.formatDeckStats(deck);

        expect(result, contains('4장'));
        expect(result, contains('공격 2'));
        expect(result, contains('스킬 1'));
        expect(result, contains('파워 1'));
        expect(result, contains('업그레이드: 0'));
      });

      test('counts upgraded cards', () {
        final deck = [upgradedAttack, attackCard, skillCard];

        final result = DeckViewHandler.formatDeckStats(deck);

        expect(result, contains('3장'));
        expect(result, contains('공격 2'));
        expect(result, contains('스킬 1'));
        expect(result, contains('파워 0'));
        expect(result, contains('업그레이드: 1'));
      });

      test('handles empty deck', () {
        final result = DeckViewHandler.formatDeckStats([]);

        expect(result, contains('0장'));
        expect(result, contains('공격 0'));
        expect(result, contains('스킬 0'));
        expect(result, contains('파워 0'));
        expect(result, contains('업그레이드: 0'));
      });
    });
  });
}
