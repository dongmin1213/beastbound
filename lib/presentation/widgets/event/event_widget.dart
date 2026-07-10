import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_button.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 이벤트 방 위젯 — "[이벤트]" 테두리 프레임 + 선택지 버튼.
///
/// 순수 presentation — domain 로직 의존 없음 (EventRoomData 모델 import는 허용).
/// 선택지 버튼에는 choice.label만 표시 — outcomeText는 선택 전에 노출 금지.
class EventWidget extends StatelessWidget {
  final EventRoomData data;
  final void Function(int choiceIndex) onChoiceSelected;
  final Color? frameBackground;

  const EventWidget({
    super.key,
    required this.data,
    required this.onChoiceSelected,
    this.frameBackground,
  });

  @override
  Widget build(BuildContext context) {
    return RetroWindowFrame(
      title: '[이벤트]',
      borderColor: AppTheme.eventFrameColor,
      titleBarColor: const Color(0xFF2A1A00),
      backgroundColor: frameBackground ?? const Color(0xFF0D0D14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이벤트 제목
            Text(
              data.title,
              style: TextStyle(
                color: AppTheme.eventFrameColor,
                fontSize: ResponsiveScale.scaleFontSize(context, 14),
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            // 서술 텍스트
            Text(
              data.narrativeText,
              style: TextStyle(
                color: AppTheme.choiceCardText,
                fontSize: ResponsiveScale.scaleFontSize(context, 12),
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 선택지 버튼 목록
            ...data.choices.indexed.map((entry) {
              final (index, choice) = entry;
              final suffix = _buildEffectSuffix(choice);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RetroButton(
                  label: suffix.isEmpty
                      ? choice.label
                      : '${choice.label} ($suffix)',
                  onTap: () => onChoiceSelected(index),
                  backgroundColor: AppTheme.eventButtonColor,
                  borderColor:
                      AppTheme.eventFrameColor.withValues(alpha: 0.5),
                  textColor: AppTheme.choiceCardText,
                  fontSize:
                      ResponsiveScale.scaleFontSize(context, 14),
                  fullWidth: true,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 선택지 효과 요약 문자열 생성 (예: "HP -3 / 카드 강화 / 지혜 +2").
  static String _buildEffectSuffix(EventChoice choice) {
    final parts = <String>[];
    if (choice.hpChange > 0) parts.add('HP +${choice.hpChange}');
    if (choice.hpChange < 0) parts.add('HP ${choice.hpChange}');
    if (choice.goldChange > 0) parts.add('골드 +${choice.goldChange}');
    if (choice.goldChange < 0) parts.add('골드 ${choice.goldChange}');
    if (choice.upgradeRandomCard) parts.add('카드 강화');
    if (choice.removeRandomCard) parts.add('카드 제거');
    if (choice.cardRewardId != null) parts.add('카드 획득');
    for (final e in choice.dispositionRewards.entries) {
      parts.add('${e.key.displayName} +${e.value}');
    }
    return parts.join(' / ');
  }
}
