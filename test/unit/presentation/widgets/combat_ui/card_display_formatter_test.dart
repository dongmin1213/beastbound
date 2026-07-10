import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';
import 'package:soul_dungeon/domain/combat/content/warrior_cards.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/card_display_formatter.dart';

void main() {
  group('CardDisplayFormatter.typeIcon', () {
    test('Attack → ⚔', () {
      expect(CardDisplayFormatter.typeIcon(CardType.attack), '⚔');
    });

    test('Skill → 🛡', () {
      expect(CardDisplayFormatter.typeIcon(CardType.skill), '🛡');
    });

    test('Power → ✨', () {
      expect(CardDisplayFormatter.typeIcon(CardType.power), '✨');
    });
  });

  group('CardDisplayFormatter.keywordTags', () {
    test('빈 키워드', () {
      expect(CardDisplayFormatter.keywordTags({}), '');
    });

    test('소진', () {
      expect(
        CardDisplayFormatter.keywordTags({CardKeyword.exhaust}),
        '[소진]',
      );
    });

    test('복수 키워드', () {
      final result = CardDisplayFormatter.keywordTags({
        CardKeyword.exhaust,
        CardKeyword.innate,
      });
      expect(result, contains('[소진]'));
      expect(result, contains('[선천]'));
    });
  });

  group('CardDisplayFormatter.formatCardLine', () {
    test('타격 — 데미지 표시', () {
      final line = CardDisplayFormatter.formatCardLine(StarterCards.strike1);
      expect(line, contains('[1AP]'));
      expect(line, contains('⚔'));
      expect(line, contains('타격'));
      expect(line, contains('데미지'));
    });

    test('방어 — 블록 표시', () {
      final line = CardDisplayFormatter.formatCardLine(StarterCards.defend1);
      expect(line, contains('[1AP]'));
      expect(line, contains('🛡'));
      expect(line, contains('방어'));
      expect(line, contains('블록'));
    });

    test('키워드 있는 카드', () {
      const card = CardData(
        id: 'test_exhaust',
        name: '소진 카드',
        description: 'Test',
        type: CardType.attack,
        apCost: 1,
        damage: 10,
        keywords: {CardKeyword.exhaust},
      );
      final line = CardDisplayFormatter.formatCardLine(card);
      expect(line, contains('[소진]'));
    });

    test('관찰 — 효과만 있는 카드', () {
      final line = CardDisplayFormatter.formatCardLine(ColorlessCards.observe);
      expect(line, contains('[1AP]'));
      expect(line, contains('🛡'));
      expect(line, contains('관찰'));
    });

    test('전사 강타 — 데미지 표시', () {
      final line = CardDisplayFormatter.formatCardLine(WarriorCards.heavyStrike);
      expect(line, contains('⚔'));
      expect(line, contains('강타'));
      expect(line, contains('데미지'));
    });
  });

  group('CardDisplayFormatter.formatCardChoice', () {
    test('AP 충분 — 비용 초과 없음', () {
      final text = CardDisplayFormatter.formatCardChoice(
        StarterCards.strike1,
        3,
      );
      expect(text, isNot(contains('[비용 초과]')));
    });

    test('AP 부족 — 비용 초과 표시', () {
      final text = CardDisplayFormatter.formatCardChoice(
        StarterCards.strike1,
        0,
      );
      expect(text, contains('[비용 초과]'));
    });
  });

  group('CardDisplayFormatter.formatStatusBar', () {
    test('기본 상태 바', () {
      final bar = CardDisplayFormatter.formatStatusBar(
        playerHp: 72,
        playerMaxHp: 80,
        playerBlock: 0,
        actionPoints: 3,
        maxActionPoints: 3,
        enemyName: '쥐',
        enemyHp: 20,
        enemyMaxHp: 25,
        enemyBlock: 0,
        currentTurn: 1,
      );
      expect(bar, contains('72/80'));
      expect(bar, contains('■■■'));
      expect(bar, contains('3/3'));
      expect(bar, contains('쥐: 20/25'));
      expect(bar, contains('[1턴]'));
    });

    test('블록 있을 때', () {
      final bar = CardDisplayFormatter.formatStatusBar(
        playerHp: 50,
        playerMaxHp: 80,
        playerBlock: 5,
        actionPoints: 1,
        maxActionPoints: 3,
        enemyName: '고블린',
        enemyHp: 30,
        enemyMaxHp: 30,
        enemyBlock: 3,
        currentTurn: 2,
      );
      expect(bar, contains('블록: 5'));
      expect(bar, contains('■□□'));
      expect(bar, contains('[블록 3]'));
    });

    test('블록 0이면 블록 미표시', () {
      final bar = CardDisplayFormatter.formatStatusBar(
        playerHp: 50,
        playerMaxHp: 80,
        playerBlock: 0,
        actionPoints: 2,
        maxActionPoints: 3,
        enemyName: '쥐',
        enemyHp: 10,
        enemyMaxHp: 25,
        enemyBlock: 0,
        currentTurn: 0,
      );
      expect(bar, isNot(contains('블록')));
    });
  });

  group('CardDisplayFormatter.formatStatusEffects', () {
    test('빈 효과', () {
      expect(CardDisplayFormatter.formatStatusEffects([]), '');
    });

    test('복수 효과', () {
      final text = CardDisplayFormatter.formatStatusEffects([
        (name: '독', stacks: 5),
        (name: '힘', stacks: 2),
      ]);
      expect(text, contains('독 5'));
      expect(text, contains('힘 2'));
      expect(text, contains('|'));
    });
  });
}
