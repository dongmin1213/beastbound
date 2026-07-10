import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 카드 롱프레스 시 표시되는 상세 정보 오버레이.
class CardDetailOverlay {
  CardDetailOverlay._();

  static void show(BuildContext context, CardData card) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _CardDetailDialog(card: card),
    );
  }
}

class _CardDetailDialog extends StatelessWidget {
  final CardData card;

  const _CardDetailDialog({required this.card});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.cardTypeColor(card.type);
    final bodySize = ResponsiveScale.scaleFontSize(context, 13);
    final smallSize = ResponsiveScale.scaleFontSize(context, 11);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 내부 탭 시 닫히지 않도록
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: RetroWindowFrame(
                title: card.name,
                borderColor: typeColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카드 타입 + AP
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: typeColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              card.type.displayName,
                              style: TextStyle(
                                fontSize: smallSize,
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'AP ${card.apCost}',
                            style: TextStyle(
                              fontSize: bodySize,
                              color: AppTheme.apAvailable,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 데미지/블록
                      if (card.damage != null || card.block != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              if (card.damage != null)
                                _buildStatChip(
                                  '데미지 ${card.damage}',
                                  const Color(0xFFFF6B6B),
                                  smallSize,
                                ),
                              if (card.damage != null && card.block != null)
                                const SizedBox(width: 8),
                              if (card.block != null)
                                _buildStatChip(
                                  '블록 ${card.block}',
                                  AppTheme.gaugeBlock,
                                  smallSize,
                                ),
                            ],
                          ),
                        ),
                      // 설명
                      Text(
                        card.description,
                        style: TextStyle(
                          fontSize: bodySize,
                          color: const Color(0xFFCCCCCC),
                          height: 1.5,
                        ),
                      ),
                      // 키워드 (Power 카드는 자동 소진 포함) + 설명
                      if (card.keywords.isNotEmpty ||
                          card.type == CardType.power) ...[
                        const SizedBox(height: 8),
                        for (final k in _effectiveKeywords(card))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A3E),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    k.displayName,
                                    style: TextStyle(
                                      fontSize: smallSize,
                                      color: const Color(0xFF888888),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    k.description,
                                    style: TextStyle(
                                      fontSize: smallSize,
                                      color: const Color(0xFF777777),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      // 효과
                      if (card.effects.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        for (final effect in card.effects)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '\u2022 ${effect.type.name}: ${effect.value}${effect.duration != null ? ' (${effect.duration}턴)' : ''}',
                              style: TextStyle(
                                fontSize: smallSize,
                                color: const Color(0xFFAAAACC),
                              ),
                            ),
                          ),
                      ],
                      // 업그레이드 표시
                      if (card.upgraded) ...[
                        const SizedBox(height: 8),
                        Text(
                          '\u2605 강화됨',
                          style: TextStyle(
                            fontSize: smallSize,
                            color: AppTheme.cardUpgradedBorder,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Power 카드는 자동 소진 — keywords에 exhaust가 없어도 표시.
  static Set<CardKeyword> _effectiveKeywords(CardData card) {
    if (card.type == CardType.power &&
        !card.keywords.contains(CardKeyword.exhaust)) {
      return {...card.keywords, CardKeyword.exhaust};
    }
    return card.keywords;
  }

  Widget _buildStatChip(String text, Color color, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
