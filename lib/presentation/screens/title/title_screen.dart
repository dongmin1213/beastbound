import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_dungeon/core/app_branding.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/ambient_particle_overlay.dart';


/// 타이틀 화면 — Dark Fantasy Terminal 스타일.
///
/// 타자기 효과로 타이틀 등장 → 글리치 깜빡임 → 메뉴 순차 페이드인.
class TitleScreen extends StatefulWidget {
  final bool hasSaveData;
  final VoidCallback onNewGame;
  final VoidCallback onContinue;
  final VoidCallback? onSoulShop;
  final VoidCallback? onJobCodex;
  final VoidCallback? onSettings;
  const TitleScreen({
    super.key,
    required this.hasSaveData,
    required this.onNewGame,
    required this.onContinue,
    this.onSoulShop,
    this.onJobCodex,
    this.onSettings,
  });

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with TickerProviderStateMixin {
  // 타자기 효과
  static const _title = AppBranding.title;
  int _titleCharCount = 0;
  Timer? _typewriterTimer;

  // 글리치 효과
  bool _glitchActive = false;
  Timer? _glitchTimer;

  // 순차 페이드인
  double _subtitleOpacity = 0.0;
  double _menuNewGameOpacity = 0.0;
  double _menuContinueOpacity = 0.0;
  double _menuSoulShopOpacity = 0.0;
  double _menuSettingsOpacity = 0.0;
  double _versionOpacity = 0.0;

  // 커서 깜빡임
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _glitchTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 80),
      (timer) {
        if (_titleCharCount >= _title.length) {
          timer.cancel();
          _onTitleComplete();
          return;
        }
        setState(() {
          _titleCharCount++;
        });
      },
    );
  }

  void _onTitleComplete() {
    // 커서 깜빡임 시작
    _cursorTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => setState(() => _cursorVisible = !_cursorVisible),
    );

    // 글리치 효과 (2~4초 간격)
    _startGlitchLoop();

    // 부제 + 메뉴 순차 페이드인
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _subtitleOpacity = 1.0);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _menuNewGameOpacity = 1.0);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _menuContinueOpacity = 1.0);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _menuSoulShopOpacity = 1.0);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _menuSettingsOpacity = 1.0);
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _versionOpacity = 1.0);
    });
  }

  void _startGlitchLoop() {
    final rng = Random();
    _glitchTimer = Timer.periodic(
      Duration(milliseconds: 2000 + rng.nextInt(2000)),
      (_) {
        if (!mounted) return;
        setState(() => _glitchActive = true);
        Future.delayed(const Duration(milliseconds: 80), () {
          if (!mounted) return;
          setState(() => _glitchActive = false);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // 배경 비네트 효과
            _buildVignette(),

            // 메인 콘텐츠
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(flex: 3),

                    // 타이틀 (신규 로고 아트는 추후 — 현재는 텍스트 타이틀)
                    _buildTitle(context),
                    const SizedBox(height: 12),

                    // 부제
                    _buildSubtitle(),
                    const SizedBox(height: 48),

                    // 메뉴
                    _buildMenuItem(
                      context: context,
                      text: '새 게임',
                      opacity: _menuNewGameOpacity,
                      enabled: true,
                      onTap: widget.onNewGame,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      context: context,
                      text: '이어하기',
                      opacity: _menuContinueOpacity,
                      enabled: widget.hasSaveData,
                      onTap: widget.hasSaveData ? widget.onContinue : null,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      context: context,
                      text: '도감',
                      opacity: _menuSoulShopOpacity,
                      enabled: widget.onSoulShop != null,
                      onTap: widget.onSoulShop,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      context: context,
                      text: '설정',
                      opacity: _menuSettingsOpacity,
                      enabled: widget.onSettings != null,
                      onTap: widget.onSettings,
                    ),

                    const Spacer(flex: 2),

                    // 버전 정보
                    AnimatedOpacity(
                      opacity: _versionOpacity,
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        AppBranding.version,
                        style: TextStyle(
                          fontSize: ResponsiveScale.scaleFontSize(context, 11),
                          color: const Color(0xFF808080),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVignette() {
    return Positioned.fill(
      child: Stack(
        children: [
          // 노이즈 텍스처 오버레이
          CustomPaint(
            size: Size.infinite,
            painter: _NoisePainter(seed: _titleCharCount),
          ),
          // 앰비언트 파티클 — 심연 테마
          AmbientParticleOverlay(
            themeVisuals: FloorThemeVisuals.fromTheme(FloorTheme.abyss),
          ),
          // 비네트 그라디언트
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  AppTheme.screenBackground.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final visibleText = _title.substring(0, _titleCharCount);
    final cursor = _titleCharCount >= _title.length
        ? (_cursorVisible ? '_' : ' ')
        : '_';

    final titleWidget = Transform.translate(
      offset: _glitchActive ? const Offset(1.5, -0.5) : Offset.zero,
      child: Text(
        '$visibleText$cursor',
        style: TextStyle(
          fontSize: ResponsiveScale.scaleFontSize(context, 28),
          fontWeight: FontWeight.bold,
          color: _glitchActive
              ? AppTheme.titleGold.withValues(alpha: 0.7)
              : AppTheme.titleGold,
          letterSpacing: 2,
          fontFamily: 'monospace',
        ),
      ),
    );

    // 타자기 완료 후 shimmer 효과
    if (_titleCharCount >= _title.length && AppTheme.enableAnimations) {
      return titleWidget
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 3000.ms,
            delay: 2000.ms,
            color: const Color(0x33FFFFFF),
          );
    }

    return titleWidget;
  }

  Widget _buildSubtitle() {
    return AnimatedOpacity(
      opacity: _subtitleOpacity,
      duration: const Duration(milliseconds: 600),
      child: const Text(
        AppBranding.tagline,
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.titleSubtext,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String text,
    required double opacity,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 400),
      child: Semantics(
        button: true,
        label: text,
        enabled: enabled,
        child: Center(
          child: GestureDetector(
            onTap: (enabled && opacity >= 1.0) ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Text(
                '> $text',
                style: TextStyle(
                  fontSize: ResponsiveScale.scaleFontSize(context, 18),
                  color: enabled
                      ? AppTheme.titleMenuText
                      : AppTheme.titleMenuDisabled,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 미세한 CRT 노이즈 텍스처. 성능 부담 최소화 (sparse random dots).
class _NoisePainter extends CustomPainter {
  final int seed;

  _NoisePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final paint = Paint()..color = const Color(0x0AFFFFFF);
    final dotCount = (size.width * size.height / 800).clamp(100, 600).toInt();

    for (var i = 0; i < dotCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => old.seed != seed;
}
