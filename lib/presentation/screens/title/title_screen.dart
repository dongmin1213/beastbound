import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_dungeon/core/app_branding.dart';
import 'package:soul_dungeon/l10n/app_localizations.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
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
  final VoidCallback? onSettings;
  const TitleScreen({
    super.key,
    required this.hasSaveData,
    required this.onNewGame,
    required this.onContinue,
    this.onSoulShop,
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      body: Stack(
        children: [
          _buildVignette(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  _buildLogo(context),
                  const SizedBox(height: 12),
                  _buildSubtitle(l10n),
                  const Spacer(flex: 2),
                  _buildMonsterShowcase(),
                  const Spacer(flex: 3),
                  // ── 커맨드 메뉴 (GBC 버튼) ──
                  _buildCommandButton(
                    context: context,
                    icon: Icons.play_arrow_rounded,
                    label: l10n.menuNewGame,
                    opacity: _menuNewGameOpacity,
                    enabled: true,
                    accent: AppTheme.titleGold,
                    onTap: widget.onNewGame,
                  ),
                  const SizedBox(height: 10),
                  _buildCommandButton(
                    context: context,
                    icon: Icons.restore_rounded,
                    label: l10n.menuContinue,
                    opacity: _menuContinueOpacity,
                    enabled: widget.hasSaveData,
                    accent: const Color(0xFF7FC8A0),
                    onTap: widget.hasSaveData ? widget.onContinue : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCommandButton(
                          context: context,
                          icon: Icons.pets_rounded,
                          label: l10n.menuBestiary,
                          opacity: _menuSoulShopOpacity,
                          enabled: widget.onSoulShop != null,
                          accent: const Color(0xFF8FB0E0),
                          onTap: widget.onSoulShop,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCommandButton(
                          context: context,
                          icon: Icons.settings_rounded,
                          label: l10n.menuSettings,
                          opacity: _menuSettingsOpacity,
                          enabled: widget.onSettings != null,
                          accent: const Color(0xFF9A8AC0),
                          onTap: widget.onSettings,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  AnimatedOpacity(
                    opacity: _versionOpacity,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      AppBranding.version,
                      style: TextStyle(
                        fontSize: ResponsiveScale.scaleFontSize(context, 11),
                        color: const Color(0xFF6A6280),
                        fontFamily: AppTheme.pixelFont,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVignette() {
    return Positioned.fill(
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _NoisePainter(seed: _titleCharCount),
          ),
          AmbientParticleOverlay(
            themeVisuals: FloorThemeVisuals.fromTheme(FloorTheme.abyss),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  AppTheme.screenBackground.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로고 — 타자기 등장 + 글리치 + shimmer.
  Widget _buildLogo(BuildContext context) {
    final visibleText = _title.substring(0, _titleCharCount);
    final cursor = _titleCharCount >= _title.length
        ? (_cursorVisible ? '_' : ' ')
        : '_';

    Widget titleWidget = Transform.translate(
      offset: _glitchActive ? const Offset(1.5, -0.5) : Offset.zero,
      child: Text(
        '$visibleText$cursor',
        style: TextStyle(
          fontSize: ResponsiveScale.scaleFontSize(context, 30),
          fontWeight: FontWeight.bold,
          color: _glitchActive
              ? AppTheme.titleGold.withValues(alpha: 0.7)
              : AppTheme.titleGold,
          letterSpacing: 1,
          fontFamily: AppTheme.pixelFont,
          shadows: const [
            Shadow(color: Color(0xFF5A3A00), offset: Offset(0, 3)),
          ],
        ),
      ),
    );

    if (_titleCharCount >= _title.length && AppTheme.enableAnimations) {
      titleWidget = titleWidget
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 3000.ms,
            delay: 2000.ms,
            color: const Color(0x33FFFFFF),
          );
    }
    return titleWidget;
  }

  Widget _buildSubtitle(AppLocalizations l10n) {
    return AnimatedOpacity(
      opacity: _subtitleOpacity,
      duration: const Duration(milliseconds: 600),
      child: Text(
        l10n.appTagline,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.titleSubtext,
          letterSpacing: 0.5,
          fontFamily: AppTheme.pixelFont,
        ),
      ),
    );
  }

  /// 스타터 몬스터 3종 쇼케이스 — 각 스프라이트가 부드럽게 떠오름.
  Widget _buildMonsterShowcase() {
    const starters = ['enemy_goblin', 'enemy_slime', 'enemy_poison_toad'];
    const accents = [Color(0xFFE0704C), Color(0xFF5FB0C0), Color(0xFF7FC04C)];
    return AnimatedOpacity(
      opacity: _subtitleOpacity,
      duration: const Duration(milliseconds: 800),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < starters.length; i++) ...[
            if (i > 0) const SizedBox(width: 18),
            _showcaseSprite(starters[i], accents[i], i),
          ],
        ],
      ),
    );
  }

  Widget _showcaseSprite(String id, Color accent, int index) {
    final path = PixelArtAssets.enemySprite(id);
    Widget sprite = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: path == null
              ? Icon(Icons.pets, color: accent.withValues(alpha: 0.7))
              : Image.asset(path,
                  width: 56, height: 56, filterQuality: FilterQuality.none),
        ),
        // 발밑 그림자 타원
        Container(
          width: 40,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
    if (AppTheme.enableAnimations) {
      sprite = sprite
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -6,
            duration: (1400 + index * 200).ms,
            curve: Curves.easeInOut,
          );
    }
    return sprite;
  }

  /// GBC 커맨드 버튼 — 아이콘 + 라벨, 둥근 두께 테두리 + 입체 그림자.
  Widget _buildCommandButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required double opacity,
    required bool enabled,
    required Color accent,
    VoidCallback? onTap,
  }) {
    final tappable = enabled && opacity >= 1.0;
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 400),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Semantics(
          button: true,
          label: label,
          enabled: enabled,
          child: GestureDetector(
            onTap: tappable ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1430),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: enabled ? accent.withValues(alpha: 0.8) : const Color(0xFF3A3352),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: accent, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveScale.scaleFontSize(context, 15),
                        color: enabled
                            ? const Color(0xFFEDE6F5)
                            : AppTheme.titleMenuDisabled,
                        fontFamily: AppTheme.pixelFont,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
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
