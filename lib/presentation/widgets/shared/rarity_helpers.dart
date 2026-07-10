import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';

/// Rarity → Color 매핑 (ShopWidget, NpcWidget 공용).
Color rarityColor(Rarity rarity) {
  return switch (rarity) {
    Rarity.common => AppTheme.shopRarityCommonColor,
    Rarity.rare => AppTheme.shopRarityRareColor,
    Rarity.legendary => AppTheme.shopRarityLegendaryColor,
    Rarity.cursed => AppTheme.shopRarityCursedColor,
  };
}

/// Rarity → 한글 라벨 매핑 (ShopWidget, NpcWidget 공용).
String rarityLabel(Rarity rarity) {
  return switch (rarity) {
    Rarity.common => '일반',
    Rarity.rare => '희귀',
    Rarity.legendary => '전설',
    Rarity.cursed => '저주',
  };
}
