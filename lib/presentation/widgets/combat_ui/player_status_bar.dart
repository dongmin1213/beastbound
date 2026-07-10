import 'package:flutter/material.dart';

import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/gauge_bar.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';

/// 탐색 중 화면 상단에 고정되는 간소 상태 바.
///
/// HP 수치 + 게이지 바 + 현재 층수를 표시.
class PlayerStatusBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final int currentFloor;
  final Color? backgroundColor;

  const PlayerStatusBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    required this.currentFloor,
    this.backgroundColor,
  });

  static const _defaultBgColor = Color(0xFF0D0D1A);
  static const _borderColor = Color(0xFF333333);
  static const _floorColor = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 12);
    final hPadding = ResponsiveScale.scalePadding(context, 16);
    final isLowHp = currentHp <= (maxHp * 0.3).ceil();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? _defaultBgColor,
        border: const Border(bottom: BorderSide(color: _borderColor)),
      ),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
      child: Row(
        children: [
          PixelArtIcon(PixelArtAssets.hpIcon, size: fontSize),
          const SizedBox(width: 4),
          Text(
            '$currentHp/$maxHp',
            style: TextStyle(
              fontSize: fontSize,
              color: isLowHp ? AppTheme.gaugeHp : AppTheme.gaugeHpSafe,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GaugeBar(
              current: currentHp,
              max: maxHp,
              fillColor: AppTheme.gaugeHp,
              height: 6,
              pulsing: isLowHp,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '─── $currentFloor층',
            style: TextStyle(fontSize: fontSize, color: _floorColor),
          ),
        ],
      ),
    );
  }
}
