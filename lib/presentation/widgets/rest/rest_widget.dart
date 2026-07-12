import 'package:flutter/material.dart' hide SelectAction;
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 휴식 방 위젯 — "휴식의 방" 테두리 프레임.
///
/// StatelessWidget — 상태 전환 없음, 선택지 카드 표시.
/// 순수 presentation — domain 로직 의존 없음.
class RestWidget extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final int healAmount;
  final int upgradeAmount;
  final VoidCallback onChooseHeal;
  final VoidCallback onChooseUpgrade;

  /// 기억 탐색 콜백 — null이면 해금된 기억 없음 (버튼 미표시).
  final VoidCallback? onExploreMemory;

  /// 해금된 기억 조각 수.
  final int unlockedMemoryCount;

  /// 총 기억 조각 수.
  final int totalMemoryCount;

  final Color? frameBackground;

  const RestWidget({
    super.key,
    required this.currentHp,
    required this.maxHp,
    required this.healAmount,
    required this.upgradeAmount,
    required this.onChooseHeal,
    required this.onChooseUpgrade,
    this.onExploreMemory,
    this.unlockedMemoryCount = 0,
    this.totalMemoryCount = 15,
    this.frameBackground,
  });

  @override
  Widget build(BuildContext context) {
    return RetroWindowFrame(
      title: '휴식의 방',
      borderColor: AppTheme.restFrameColor,
      titleBarColor: const Color(0xFF1A2A1A),
      backgroundColor: frameBackground ?? const Color(0xFF0D0D14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HP: $currentHp / $maxHp',
              style: TextStyle(
                color: AppTheme.choiceCardText,
                fontSize: ResponsiveScale.scaleFontSize(context, 14),
                fontFamily: 'Galmuri11',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '선택 시 야성이 초기화됩니다',
              style: TextStyle(
                color: AppTheme.restDisabledColor,
                fontSize: ResponsiveScale.scaleFontSize(context, 12),
                fontFamily: 'Galmuri11',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // HP 회복 카드
            _buildChoiceCard(
              context,
              title: '체력 회복',
              description: healAmount > 0
                  ? '지친 몸을 쉬어 체력을 회복한다.'
                  : '이미 최대 체력이지만, 잠시 쉬어갈 수 있다.',
              effectText: '+$healAmount HP',
              effectColor: healAmount > 0
                  ? AppTheme.restRecoveryColor
                  : AppTheme.restDisabledColor,
              onTap: onChooseHeal,
            ),
            const SizedBox(height: 12),
            // 축복 강화 카드
            _buildChoiceCard(
              context,
              title: '축복 강화',
              description: '던전의 축복으로 최대 체력이 증가한다.',
              effectText: '+$upgradeAmount 최대 HP',
              effectColor: AppTheme.restUpgradeColor,
              onTap: onChooseUpgrade,
            ),
            // 기억 탐색 카드 — 해금된 기억이 있을 때만 표시
            if (onExploreMemory != null && unlockedMemoryCount > 0) ...[
              const SizedBox(height: 12),
              _buildChoiceCard(
                context,
                title: '기억 탐색',
                description: '누군가의 기억 조각을 살펴본다. (비소비)',
                effectText: '$unlockedMemoryCount / $totalMemoryCount 조각',
                effectColor: AppTheme.memoryColor,
                onTap: onExploreMemory!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard(
    BuildContext context, {
    required String title,
    required String description,
    required String effectText,
    required Color effectColor,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title, $effectText',
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: effectColor.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: effectColor,
                fontSize: ResponsiveScale.scaleFontSize(context, 14),
                fontWeight: FontWeight.bold,
                fontFamily: 'Galmuri11',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: AppTheme.choiceCardText,
                fontSize: ResponsiveScale.scaleFontSize(context, 12),
                fontFamily: 'Galmuri11',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              effectText,
              style: TextStyle(
                color: effectColor,
                fontSize: ResponsiveScale.scaleFontSize(context, 13),
                fontWeight: FontWeight.bold,
                fontFamily: 'Galmuri11',
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
