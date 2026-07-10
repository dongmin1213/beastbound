import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';

/// 이어하기 로딩 오버레이 — 층 전환 오버레이와 유사한 스타일.
///
/// 세이브 데이터 복원 중 전체 화면을 덮는 검은 오버레이.
/// [isReady] = true가 되면 "준비 완료" + 탭 힌트 표시.
class ContinueLoadingOverlay extends StatefulWidget {
  final int floor;
  final bool isReady;
  final VoidCallback onComplete;

  const ContinueLoadingOverlay({
    super.key,
    required this.floor,
    required this.isReady,
    required this.onComplete,
  });

  @override
  State<ContinueLoadingOverlay> createState() =>
      _ContinueLoadingOverlayState();
}

class _ContinueLoadingOverlayState extends State<ContinueLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: AppTheme.enableAnimations
          ? const Duration(milliseconds: 1200)
          : Duration.zero,
    );
    _progressController.forward();
  }

  @override
  void didUpdateWidget(ContinueLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady && !oldWidget.isReady) {
      // 준비 완료 시 프로그레스 바 완주
      if (_progressController.value < 1.0) {
        _progressController.forward();
      }
      if (!AppTheme.enableAnimations) {
        // 애니메이션 꺼진 환경(테스트) → 자동 진행
        widget.onComplete();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeVisuals = FloorThemeVisuals.fromFloor(widget.floor);

    Widget floorText = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.floor}층',
          style: TextStyle(
            color: themeVisuals.accentColor,
            fontSize: ResponsiveScale.scaleFontSize(context, 28),
            fontFamily: 'monospace',
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
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
      ],
    );

    Widget statusText = Text(
      widget.isReady ? '복원 완료' : '데이터 복원 중...',
      style: TextStyle(
        color: const Color(0xFF666666),
        fontSize: ResponsiveScale.scaleFontSize(context, 13),
        fontFamily: 'monospace',
        letterSpacing: 1,
      ),
    );

    Widget progressBar = SizedBox(
      width: 200,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          // isReady이면 100%, 아니면 애니메이션 80%에서 대기
          final targetValue = widget.isReady
              ? 1.0
              : (_progressController.value * 0.8);
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
              widthFactor: targetValue,
              child: Container(
                color: themeVisuals.accentColor,
              ),
            ),
          );
        },
      ),
    );

    Widget tapHint = const SizedBox.shrink();
    if (widget.isReady) {
      tapHint = Text(
        '\u25bc 탭하여 진입',
        style: TextStyle(
          color: const Color(0xFF888888),
          fontSize: ResponsiveScale.scaleFontSize(context, 11),
          fontFamily: 'monospace',
        ),
      );
      if (AppTheme.enableAnimations) {
        tapHint = tapHint
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 600.ms)
            .then()
            .fadeOut(duration: 600.ms);
      }
    }

    if (AppTheme.enableAnimations) {
      floorText = floorText.animate().fadeIn(duration: 400.ms);
      statusText = statusText
          .animate()
          .fadeIn(duration: 300.ms, delay: 200.ms);
      progressBar = progressBar
          .animate()
          .fadeIn(duration: 300.ms, delay: 200.ms);
    }

    return GestureDetector(
      onTap: widget.isReady ? widget.onComplete : null,
      child: Material(
        color: themeVisuals.combatBackground,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              floorText,
              const SizedBox(height: 24),
              statusText,
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
