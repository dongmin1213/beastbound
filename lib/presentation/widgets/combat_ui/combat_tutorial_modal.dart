import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/combat/content/tutorial_text.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 첫 전투 진입 시 1회만 표시되는 전투 튜토리얼 모달.
class CombatTutorialModal extends StatelessWidget {
  final VoidCallback onDismiss;

  const CombatTutorialModal({super.key, required this.onDismiss});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => CombatTutorialModal(
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 13);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 340,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Material(
          color: Colors.transparent,
          child: RetroWindowFrame(
            title: '◆ 전투 가이드',
            expand: true,
            onClose: onDismiss,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < TutorialText.steps.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          Text(
                            TutorialText.steps[i],
                            style: TextStyle(
                              fontSize: fontSize,
                              color: const Color(0xFFE0E0E0),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xFF333333), height: 1),
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      '확인',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveScale.scaleFontSize(context, 15),
                        color: AppTheme.apAvailable,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
