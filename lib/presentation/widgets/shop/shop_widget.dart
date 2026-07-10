import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_button.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';
import 'package:soul_dungeon/presentation/widgets/shared/rarity_helpers.dart';

/// 상점 위젯 — "여행자의 상점" 테두리 프레임.
///
/// 순수 presentation — domain 로직 의존 없음 (ShopItem 모델 import는 허용).
/// 데이터와 콜백은 모두 Props로 수신.
class ShopWidget extends StatelessWidget {
  final List<ShopItem> items;
  final int gold;
  final ValueChanged<int> onBuy;
  final VoidCallback onLeave;
  final Color? frameBackground;

  const ShopWidget({
    super.key,
    required this.items,
    required this.gold,
    required this.onBuy,
    required this.onLeave,
    this.frameBackground,
  });

  @override
  Widget build(BuildContext context) {
    return RetroWindowFrame(
      title: '여행자의 상점',
      titleBarColor: const Color(0xFF2A2A1A),
      borderColor: AppTheme.shopItemCardBorder,
      backgroundColor: frameBackground ?? const Color(0xFF0D0D14),
      child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '보유 금화: $gold',
            style: TextStyle(
              color: AppTheme.shopGoldColor,
              fontSize: ResponsiveScale.scaleFontSize(context, 13),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(items.length, (index) {
            final item = items[index];
            return _buildItemCard(context, item, index);
          }),
          const SizedBox(height: 8),
          RetroButton(
            label: '상점 나가기',
            onTap: onLeave,
            backgroundColor: AppTheme.shopItemCardBorder,
            borderColor: AppTheme.shopItemCardBorder,
            textColor: AppTheme.choiceCardText,
            fullWidth: true,
          ),
        ],
      ),
      ),
    );
  }

  String _itemTypeLabel(ShopItem item) {
    switch (item.itemType) {
      case ItemType.card:
        return '[카드]';
      case ItemType.cardRemoval:
        return '[서비스]';
      default:
        return '[${rarityLabel(item.rarity)}]';
    }
  }

  Widget _buildItemCard(BuildContext context, ShopItem item, int index) {
    final canBuy = !item.sold && gold >= item.price;
    final isCard = item.itemType == ItemType.card;
    final isService = item.itemType == ItemType.cardRemoval;
    final itemColor = isCard
        ? const Color(0xFF4FC3F7)
        : isService
            ? const Color(0xFFAED581)
            : rarityColor(item.rarity);

    return Opacity(
      opacity: item.sold ? 0.4 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: itemColor.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(2),
          color: item.sold ? AppTheme.shopSoldOverlay : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 카드 아이템: AP 코스트 다이아몬드 뱃지 (전투 카드와 동일 스타일)
                if (isCard && item.apCost != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: math.pi / 4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.cardBackground,
                                border: Border.all(color: AppTheme.apAvailable, width: 1.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Text(
                            '${item.apCost}',
                            style: TextStyle(
                              fontSize: ResponsiveScale.scaleFontSize(context, 10),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.apAvailable,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: ResponsiveScale.scaleFontSize(context, 13),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      decoration:
                          item.sold ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Text(
                  _itemTypeLabel(item),
                  style: TextStyle(
                    color: itemColor,
                    fontSize: ResponsiveScale.scaleFontSize(context, 11),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(
                color: AppTheme.shopRarityCommonColor,
                fontSize: ResponsiveScale.scaleFontSize(context, 12),
                fontFamily: 'monospace',
                decoration: item.sold ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  item.price == 0 ? '무료' : '${item.price}',
                  style: TextStyle(
                    color: item.price == 0
                        ? const Color(0xFF66BB6A)
                        : AppTheme.shopGoldColor,
                    fontSize: ResponsiveScale.scaleFontSize(context, 12),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                RetroButton(
                  label: item.sold
                      ? '완료'
                      : (gold >= item.price ? '구매' : '부족'),
                  onTap: canBuy ? () => onBuy(index) : null,
                  enabled: canBuy,
                  backgroundColor: canBuy
                      ? AppTheme.shopBuyButtonColor
                      : AppTheme.shopItemCardBorder,
                  borderColor: canBuy
                      ? AppTheme.shopBuyButtonColor
                      : AppTheme.shopItemCardBorder,
                  fontSize: ResponsiveScale.scaleFontSize(context, 11),
                  height: 28,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
