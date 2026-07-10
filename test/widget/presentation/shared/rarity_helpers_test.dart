import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/shared/rarity_helpers.dart';

void main() {
  group('rarityColor', () {
    test('common → shopRarityCommonColor', () {
      expect(rarityColor(Rarity.common), AppTheme.shopRarityCommonColor);
    });

    test('rare → shopRarityRareColor', () {
      expect(rarityColor(Rarity.rare), AppTheme.shopRarityRareColor);
    });

    test('legendary → shopRarityLegendaryColor', () {
      expect(rarityColor(Rarity.legendary), AppTheme.shopRarityLegendaryColor);
    });

    test('cursed → shopRarityCursedColor', () {
      expect(rarityColor(Rarity.cursed), AppTheme.shopRarityCursedColor);
    });

    test('각 등급별 색상이 서로 다름', () {
      final colors = Rarity.values.map(rarityColor).toSet();
      expect(colors.length, Rarity.values.length);
    });
  });

  group('rarityLabel', () {
    test('common → 일반', () {
      expect(rarityLabel(Rarity.common), '일반');
    });

    test('rare → 희귀', () {
      expect(rarityLabel(Rarity.rare), '희귀');
    });

    test('legendary → 전설', () {
      expect(rarityLabel(Rarity.legendary), '전설');
    });

    test('cursed → 저주', () {
      expect(rarityLabel(Rarity.cursed), '저주');
    });

    test('모든 Rarity 값이 빈 문자열이 아닌 라벨 반환', () {
      for (final rarity in Rarity.values) {
        expect(rarityLabel(rarity).isNotEmpty, isTrue);
      }
    });
  });
}
