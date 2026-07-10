import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// 대상에 나타났다 빠르게 사라지는 대각선 슬래시 VFX.
///
/// 카드 공격 명중 지점에 흰 섬광 두 줄을 그린다. 수동 `update` 페이드.
class SlashEffect extends PositionComponent {
  static const _lifetime = 0.24;
  double _elapsed = 0;
  final double _length;

  SlashEffect({required Vector2 position, double length = 46})
      : _length = length,
        super(position: position, anchor: Anchor.center, priority: 90);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _lifetime) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_elapsed / _lifetime).clamp(0.0, 1.0);
    // 0→1 : 빠르게 나타났다 사라짐 (sin 곡선).
    final alpha = math.sin(t * math.pi);
    final half = _length / 2;

    final paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, alpha)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    // 대각선 두 줄 (살짝 어긋나게).
    canvas.drawLine(Offset(-half, -half), Offset(half, half), paint);
    canvas.drawLine(
      Offset(-half + 8, -half - 4),
      Offset(half + 8, half - 4),
      paint..strokeWidth = 2,
    );
  }
}
