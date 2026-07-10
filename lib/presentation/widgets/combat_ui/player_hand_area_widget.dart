import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/gauge_bar.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/status_effect_badges_widget.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';

/// 카드 전투 하단 — 플레이어 HP + AP + 상태효과 + 덱 카운터.
class PlayerHandAreaWidget extends StatelessWidget {
  final int playerHp;
  final int playerMaxHp;
  final int playerBlock;
  final int actionPoints;
  final int maxActionPoints;
  final int currentTurn;
  final int drawPileCount;
  final int discardPileCount;
  final int exhaustPileCount;
  final List<StatusEffect> playerStatuses;

  const PlayerHandAreaWidget({
    super.key,
    required this.playerHp,
    required this.playerMaxHp,
    required this.playerBlock,
    required this.actionPoints,
    required this.maxActionPoints,
    required this.currentTurn,
    required this.drawPileCount,
    required this.discardPileCount,
    required this.exhaustPileCount,
    this.playerStatuses = const [],
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 12);
    final hPadding = ResponsiveScale.scalePadding(context, 12);
    final isLowHp = playerHp <= (playerMaxHp * 0.3).ceil();

    final blockLabel = playerBlock > 0 ? ', 방어 $playerBlock' : '';
    return Semantics(
      label: 'HP $playerHp/$playerMaxHp$blockLabel, AP $actionPoints/$maxActionPoints, 뽑기 $drawPileCount, 버림 $discardPileCount',
      child: Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 플레이어 상태효과 뱃지
          if (playerStatuses.isNotEmpty) ...[
            StatusEffectBadgesWidget(statuses: playerStatuses),
            const SizedBox(height: 4),
          ],
          // HP + 블록 + 게이지 + 턴
          Row(
            children: [
              PixelArtIcon(PixelArtAssets.hpIcon, size: fontSize),
              const SizedBox(width: 4),
              Text(
                '$playerHp/$playerMaxHp',
                style: TextStyle(
                  fontSize: fontSize,
                  color: isLowHp ? AppTheme.gaugeHp : AppTheme.gaugeHpSafe,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (playerBlock > 0) ...[
                const SizedBox(width: 6),
                PixelArtIcon(PixelArtAssets.blockIcon, size: fontSize),
                const SizedBox(width: 2),
                Text(
                  '$playerBlock',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppTheme.gaugeBlock,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: GaugeBar(
                  current: playerHp,
                  max: playerMaxHp,
                  fillColor: AppTheme.gaugeHp,
                  height: 8,
                  pulsing: isLowHp,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$currentTurn턴',
                style: TextStyle(
                  fontSize: fontSize,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // AP + 덱 카운터
          Row(
            children: [
              // AP 다이아몬드
              for (int i = 0; i < maxActionPoints; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Opacity(
                  opacity: i < actionPoints ? 1.0 : 0.3,
                  child: PixelArtIcon(
                    PixelArtAssets.apIcon,
                    size: fontSize,
                  ),
                ),
              ],
              const Spacer(),
              // 덱 카운터
              _buildDeckCounter(context),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildDeckCounter(BuildContext context) {
    final smallFont = ResponsiveScale.scaleFontSize(context, 10);
    const labelColor = Color(0xFF888888);
    const countColor = Color(0xFFB0B0B0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '뽑기 ',
          style: TextStyle(fontSize: smallFont, color: labelColor),
        ),
        Text(
          '$drawPileCount',
          style: TextStyle(
            fontSize: smallFont,
            color: countColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ' | 버림 ',
          style: TextStyle(fontSize: smallFont, color: labelColor),
        ),
        Text(
          '$discardPileCount',
          style: TextStyle(
            fontSize: smallFont,
            color: countColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (exhaustPileCount > 0) ...[
          Text(
            ' | 소진 ',
            style: TextStyle(fontSize: smallFont, color: labelColor),
          ),
          Text(
            '$exhaustPileCount',
            style: TextStyle(
              fontSize: smallFont,
              color: const Color(0xFFFF6B6B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

}
