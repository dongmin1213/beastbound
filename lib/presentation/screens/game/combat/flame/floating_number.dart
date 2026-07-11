import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

/// 데미지/회복 수치가 위로 떠오르며 사라지는 텍스트 컴포넌트.
///
/// Effect API 대신 수동 `update`로 상승·페이드 → 버전 무관.
class FloatingNumber extends PositionComponent {
  final String text;
  final Color color;
  final double fontSize;

  static const _lifetime = 0.9;
  double _elapsed = 0;

  FloatingNumber({
    required this.text,
    required this.color,
    required Vector2 position,
    this.fontSize = 18,
  }) : super(position: position, anchor: Anchor.center, priority: 100);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.y -= dt * 34; // 상승
    if (_elapsed >= _lifetime) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_elapsed / _lifetime).clamp(0.0, 1.0);
    final alpha = (1 - t * t); // 후반부 가속 페이드
    final painter = TextPaint(
      style: TextStyle(
        color: color.withValues(alpha: alpha),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Galmuri11',
        shadows: [
          Shadow(
            color: const Color(0xFF000000).withValues(alpha: alpha * 0.8),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
    painter.render(canvas, text, Vector2.zero(), anchor: Anchor.center);
  }
}
