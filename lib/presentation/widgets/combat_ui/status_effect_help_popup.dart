import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 상태효과 뱃지 탭 시 표시되는 설명 팝업.
class StatusEffectHelpPopup {
  StatusEffectHelpPopup._();

  static void show(BuildContext context, StatusEffectType type, int stacks) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _HelpDialog(type: type, stacks: stacks),
    );
  }
}

class _HelpDialog extends StatelessWidget {
  final StatusEffectType type;
  final int stacks;

  const _HelpDialog({required this.type, required this.stacks});

  @override
  Widget build(BuildContext context) {
    final bodySize = ResponsiveScale.scaleFontSize(context, 12);
    final smallSize = ResponsiveScale.scaleFontSize(context, 11);

    final borderColor = type.isDebuff
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFFFD54F);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 내부 탭 시 닫히지 않도록
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: RetroWindowFrame(
                title: '${type.displayName} — ${type.isDebuff ? "디버프" : "버프"}',
                borderColor: borderColor,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 현재 중첩 표시
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: borderColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: borderColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '현재 $stacks중첩',
                          style: TextStyle(
                            fontSize: smallSize,
                            color: borderColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 효과 설명
                      Text(
                        type.description,
                        style: TextStyle(
                          fontSize: bodySize,
                          color: const Color(0xFFCCCCCC),
                          height: 1.5,
                        ),
                      ),
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
}
