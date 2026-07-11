import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';

/// 층 전환 연출 오버레이 — "접속 중..." 스타일 프로그레스 바.
///
/// 전체 화면을 덮는 검은 오버레이 + 중앙 텍스트 + 프로그레스 바.
/// 프로그레스 완료 후 탭하면 [onComplete] 콜백 호출.
class FloorTransitionOverlay extends StatefulWidget {
  final int targetFloor;
  final VoidCallback onComplete;

  const FloorTransitionOverlay({
    super.key,
    required this.targetFloor,
    required this.onComplete,
  });

  @override
  State<FloorTransitionOverlay> createState() => _FloorTransitionOverlayState();
}

class _FloorTransitionOverlayState extends State<FloorTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  bool _progressDone = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: AppTheme.enableAnimations
          ? const Duration(milliseconds: 1500)
          : Duration.zero,
    );
    _progressController.forward().then((_) {
      if (mounted) {
        if (AppTheme.enableAnimations) {
          setState(() => _progressDone = true);
        } else {
          // 애니메이션 꺼진 환경(테스트) → 자동 진행
          widget.onComplete();
        }
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeVisuals = FloorThemeVisuals.fromFloor(widget.targetFloor);

    Widget floorText = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.targetFloor}층',
          style: TextStyle(
            color: themeVisuals.accentColor,
            fontSize: ResponsiveScale.scaleFontSize(context, 28),
            fontFamily: 'Galmuri11',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '— ${themeVisuals.displayName}',
          style: TextStyle(
            color: themeVisuals.accentColor.withValues(alpha: 0.6),
            fontSize: ResponsiveScale.scaleFontSize(context, 14),
            fontFamily: 'Galmuri11',
            letterSpacing: 1,
          ),
        ),
      ],
    );

    Widget connectingText = Text(
      _progressDone ? '준비 완료' : '접속 중...',
      style: TextStyle(
        color: const Color(0xFF666666),
        fontSize: ResponsiveScale.scaleFontSize(context, 13),
        fontFamily: 'Galmuri11',
        letterSpacing: 1,
      ),
    );

    Widget progressBar = SizedBox(
      width: 200,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              border: Border.all(
                color: const Color(0xFF333333),
                width: 0.5,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressController.value,
              child: Container(
                color: themeVisuals.accentColor,
              ),
            ),
          );
        },
      ),
    );

    Widget tapHint = const SizedBox.shrink();
    if (_progressDone) {
      tapHint = Text(
        '\u25bc 탭하여 진입',
        style: TextStyle(
          color: const Color(0xFF888888),
          fontSize: ResponsiveScale.scaleFontSize(context, 11),
          fontFamily: 'Galmuri11',
        ),
      );
      if (AppTheme.enableAnimations) {
        tapHint = tapHint.animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 600.ms)
            .then()
            .fadeOut(duration: 600.ms);
      }
    }

    if (AppTheme.enableAnimations) {
      floorText = floorText.animate().fadeIn(duration: 400.ms);
      connectingText = connectingText
          .animate()
          .fadeIn(duration: 300.ms, delay: 200.ms);
      progressBar = progressBar
          .animate()
          .fadeIn(duration: 300.ms, delay: 200.ms);
    }

    return GestureDetector(
      onTap: _progressDone ? widget.onComplete : null,
      child: Material(
        color: themeVisuals.combatBackground,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              floorText,
              const SizedBox(height: 24),
              connectingText,
              const SizedBox(height: 12),
              progressBar,
              const SizedBox(height: 24),
              tapHint,
            ],
          ),
        ),
      ),
    );
  }
}
