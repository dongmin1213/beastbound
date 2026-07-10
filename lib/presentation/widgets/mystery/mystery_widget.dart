import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_button.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 미스터리 방 위젯 — "??? 미스터리 방" 테두리 프레임.
///
/// 순수 presentation — domain 로직 의존 없음 (MysteryOutcome 모델 import는 허용).
/// 데이터와 콜백은 모두 Props로 수신.
class MysteryWidget extends StatelessWidget {
  final MysteryOutcome outcome;
  final VoidCallback onProceed;
  final Color? frameBackground;

  const MysteryWidget({
    super.key,
    required this.outcome,
    required this.onProceed,
    this.frameBackground,
  });

  String _outcomeTitle(MysteryOutcome outcome) {
    return switch (outcome) {
      TreasureOutcome() => '보물 발견!',
      TrapOutcome() => '함정!',
      EncounterOutcome() => '적과 조우!',
      EventOutcome() => '고대 문자 발견!',
      MinorOutcome() => '작은 발견',
    };
  }

  String _outcomeIcon(MysteryOutcome outcome) {
    return switch (outcome) {
      TreasureOutcome() => '[보물]',
      TrapOutcome() => '[경고]',
      EncounterOutcome() => '[전투]',
      EventOutcome() => '[문서]',
      MinorOutcome() => '[발견]',
    };
  }

  Color _outcomeColor(MysteryOutcome outcome) {
    return switch (outcome) {
      TreasureOutcome() => AppTheme.mysteryTreasureColor,
      TrapOutcome() => AppTheme.mysteryTrapColor,
      EncounterOutcome() => AppTheme.mysteryEncounterColor,
      EventOutcome() => AppTheme.mysteryRewardColor,
      MinorOutcome() => AppTheme.mysteryRewardColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _outcomeColor(outcome);

    return RetroWindowFrame(
      title: '??? 미스터리 방',
      borderColor: AppTheme.mysteryFrameColor,
      titleBarColor: const Color(0xFF1A1A2A),
      backgroundColor: frameBackground ?? const Color(0xFF0D0D14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 결과 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: [
                  // 아이콘 + 제목
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _outcomeIcon(outcome),
                        style: TextStyle(
                          color: color,
                          fontSize: ResponsiveScale.scaleFontSize(context, 13),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _outcomeTitle(outcome),
                        style: TextStyle(
                          color: color,
                          fontSize: ResponsiveScale.scaleFontSize(context, 14),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 서술 텍스트
                  Text(
                    outcome.narrativeText,
                    style: TextStyle(
                      color: AppTheme.choiceCardText,
                      fontSize: ResponsiveScale.scaleFontSize(context, 12),
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // 골드/HP 변화
                  if (outcome.goldChange > 0)
                    Text(
                      '+${outcome.goldChange} 골드',
                      style: TextStyle(
                        color: AppTheme.shopGoldColor,
                        fontSize: ResponsiveScale.scaleFontSize(context, 13),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  if (outcome.hpChange < 0)
                    Text(
                      '${outcome.hpChange} HP',
                      style: TextStyle(
                        color: AppTheme.mysteryTrapColor,
                        fontSize: ResponsiveScale.scaleFontSize(context, 13),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 진행하기 버튼
            RetroButton(
              label: '진행하기',
              onTap: onProceed,
              backgroundColor: AppTheme.mysteryButtonColor,
              borderColor:
                  AppTheme.mysteryFrameColor.withValues(alpha: 0.5),
              textColor: AppTheme.choiceCardText,
              fontSize: ResponsiveScale.scaleFontSize(context, 14),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
