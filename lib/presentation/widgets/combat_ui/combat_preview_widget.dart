import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

/// 적 행동 예고 표시 위젯
class CombatPreviewWidget extends StatefulWidget {
  final EnemyAction action;

  const CombatPreviewWidget({super.key, required this.action});

  @override
  State<CombatPreviewWidget> createState() => _CombatPreviewWidgetState();
}

class _CombatPreviewWidgetState extends State<CombatPreviewWidget> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Trigger fade-in on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  Color _colorForType(EnemyActionType type) {
    return switch (type) {
      EnemyActionType.attack ||
      EnemyActionType.heavy =>
        AppTheme.combatPreviewAttackColor,
      EnemyActionType.defend ||
      EnemyActionType.charge ||
      EnemyActionType.heal ||
      EnemyActionType.buff =>
        AppTheme.combatPreviewDefendColor,
      EnemyActionType.observe => AppTheme.combatPreviewObserveColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(widget.action.type);
    final prefix = widget.action.type.prefix;

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveScale.scalePadding(context, 16),
          vertical: ResponsiveScale.scaleVerticalPadding(context, 12),
        ),
        decoration: const BoxDecoration(
          color: AppTheme.combatPreviewBackground,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: RichText(
          text: TextSpan(
            text: '$prefix${widget.action.previewText}',
            style: TextStyle(
              color: color,
              fontSize: ResponsiveScale.scaleFontSize(context, 16),
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
