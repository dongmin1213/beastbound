import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/progression/memory/memory_fragment_pool.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 기억 탐색 위젯 — 해금된 기억 조각 목록 표시.
///
/// 비소비 열람 — 선택 후 RestReady 복귀.
class MemoryExplorationWidget extends StatelessWidget {
  final List<MemoryFragment> unlockedFragments;
  final void Function(MemoryFragment fragment) onSelectFragment;
  final VoidCallback onBack;
  final Color? frameBackground;

  const MemoryExplorationWidget({
    super.key,
    required this.unlockedFragments,
    required this.onSelectFragment,
    required this.onBack,
    this.frameBackground,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 12);

    return RetroWindowFrame(
      title: '기억 탐색',
      borderColor: AppTheme.memoryColor,
      titleBarColor: const Color(0xFF1A1A2A),
      backgroundColor: frameBackground ?? const Color(0xFF0D0D14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${unlockedFragments.length} / ${MemoryFragmentPool.totalCount} 조각 해금됨',
              style: TextStyle(
                color: AppTheme.memoryColor,
                fontSize: fontSize,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            ...unlockedFragments.map((fragment) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildFragmentCard(context, fragment, fontSize),
                )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.restDisabledColor.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '돌아가기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.restDisabledColor,
                    fontSize: fontSize,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFragmentCard(
    BuildContext context,
    MemoryFragment fragment,
    double fontSize,
  ) {
    return GestureDetector(
      onTap: () => onSelectFragment(fragment),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.memoryColor.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '[${fragment.category.displayName}]',
                  style: TextStyle(
                    color: AppTheme.memoryColor.withValues(alpha: 0.7),
                    fontSize: fontSize * 0.9,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fragment.title,
                    style: TextStyle(
                      color: AppTheme.memoryColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              fragment.description,
              style: TextStyle(
                color: AppTheme.choiceCardText,
                fontSize: fontSize * 0.9,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
