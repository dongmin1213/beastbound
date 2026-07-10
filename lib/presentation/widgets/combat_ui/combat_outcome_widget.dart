import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 전투 결과(승리/패배) 표시 위젯
class CombatOutcomeWidget extends StatelessWidget {
  final TextBlockData blockData;

  const CombatOutcomeWidget({
    super.key,
    required this.blockData,
  });

  bool get _isVictory => blockData.metadata?['combatOutcome'] == 'victory';

  @override
  Widget build(BuildContext context) {
    final color = _isVictory
        ? AppTheme.combatVictoryColor
        : AppTheme.combatDefeatColor;

    final scaledVerticalPadding = ResponsiveScale.scaleVerticalPadding(context, 24);

    // 승리: shimmer, 패배: shake
    Widget outcomeText = Text(
      blockData.text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: ResponsiveScale.scaleFontSize(context, 18),
        fontWeight: FontWeight.bold,
        height: 1.6,
      ),
    );

    if (AppTheme.enableAnimations) {
      if (_isVictory) {
        outcomeText = outcomeText
            .animate()
            .fadeIn(duration: 400.ms)
            .shimmer(
              duration: 1200.ms,
              delay: 200.ms,
              color: AppTheme.combatVictoryColor.withValues(alpha: 0.4),
            );
      } else {
        outcomeText = outcomeText
            .animate()
            .fadeIn(duration: 400.ms)
            .shake(
              hz: 3,
              offset: const Offset(2, 0),
              duration: 500.ms,
              delay: 200.ms,
            );
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaledVerticalPadding),
      child: Center(child: outcomeText),
    );
  }
}
