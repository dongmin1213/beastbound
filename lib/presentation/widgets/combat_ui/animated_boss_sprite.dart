import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';

/// 보스 스프라이트 애니메이션 위젯 -- 미세한 호흡 애니메이션(부유 + 스케일).
///
/// [AppTheme.enableAnimations]이 false면 정적 이미지를 반환.
class AnimatedBossSprite extends StatefulWidget {
  final String assetPath;
  final double size;

  const AnimatedBossSprite({
    super.key,
    required this.assetPath,
    this.size = 48,
  });

  @override
  State<AnimatedBossSprite> createState() => _AnimatedBossSpriteState();
}

class _AnimatedBossSpriteState extends State<AnimatedBossSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (AppTheme.enableAnimations) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      widget.assetPath,
      width: widget.size,
      height: widget.size,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );

    if (!AppTheme.enableAnimations) return image;

    return AnimatedBuilder(
      animation: _controller,
      child: image,
      builder: (context, child) {
        // y offset: -2px ~ +2px
        final yOffset = -2.0 + 4.0 * _controller.value;
        // scale: 1.0 ~ 1.03
        final scale = 1.0 + 0.03 * _controller.value;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }
}
