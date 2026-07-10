import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_state.dart';
import 'package:soul_dungeon/presentation/screens/game/narrator_display.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';

/// HP 텍스트 표시 위젯. ♥ {currentHp}/{maxHp} 형식.
/// HP 30% 이하 시 붉은색 강조. AnimatedDefaultTextStyle로 색상 전환.
/// narratorState가 주어지면 표시값만 왜곡 (domain 값 변경 금지).
class HpDisplayWidget extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final NarratorState? narratorState;

  const HpDisplayWidget({
    super.key,
    required this.currentHp,
    required this.maxHp,
    this.narratorState,
  });

  @override
  Widget build(BuildContext context) {
    final displayHp = NarratorDisplay.displayHp(currentHp, narratorState);
    final hpPercent = maxHp > 0 ? currentHp / maxHp : 0.0;
    final isLow = hpPercent <= 0.3;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        color: isLow ? AppTheme.combatDefeatColor : AppTheme.combatResultNeutralColor,
        fontSize: ResponsiveScale.scaleFontSize(context, 14),
        fontWeight: isLow ? FontWeight.bold : FontWeight.normal,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelArtIcon(PixelArtAssets.hpIcon, size: 14),
          const SizedBox(width: 4),
          Text('$displayHp/$maxHp'),
        ],
      ),
    );
  }
}
