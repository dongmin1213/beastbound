import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';

/// 앰비언트 파티클 오버레이 — 층별 분위기 연출.
///
/// CustomPainter + Ticker 기반 경량 파티클 (15~25개).
/// IgnorePointer로 터치 이벤트를 통과시킴.
class AmbientParticleOverlay extends StatefulWidget {
  final FloorThemeVisuals themeVisuals;

  const AmbientParticleOverlay({super.key, required this.themeVisuals});

  @override
  State<AmbientParticleOverlay> createState() =>
      _AmbientParticleOverlayState();
}

class _AmbientParticleOverlayState extends State<AmbientParticleOverlay>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<_Particle> _particles = [];
  final Random _rng = Random();
  Duration _lastElapsed = Duration.zero;
  Size _lastSize = Size.zero;

  ParticleConfig get _config => widget.themeVisuals.particleConfig;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (AppTheme.enableAnimations) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant AmbientParticleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeVisuals.theme != widget.themeVisuals.theme) {
      _particles.clear();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.5) return; // 프레임 스킵 방지

    if (_lastSize == Size.zero) return;
    _updateParticles(dt);
    _spawnIfNeeded();

    // CustomPainter 리페인트 트리거
    if (mounted) setState(() {});
  }

  void _spawnIfNeeded() {
    while (_particles.length < _config.maxParticles) {
      _particles.add(_spawnParticle());
    }
  }

  _Particle _spawnParticle() {
    final w = _lastSize.width;
    final h = _lastSize.height;
    final config = _config;

    final size =
        config.minSize + _rng.nextDouble() * (config.maxSize - config.minSize);
    final speed = config.minSpeed +
        _rng.nextDouble() * (config.maxSpeed - config.minSpeed);
    final maxOpacity = config.minOpacity +
        _rng.nextDouble() * (config.maxOpacity - config.minOpacity);
    final maxLife = 6.0 + _rng.nextDouble() * 8.0; // 6~14초

    double x, y, vx, vy;

    switch (config.direction) {
      case ParticleDirection.down:
        x = _rng.nextDouble() * w;
        y = -size;
        vx = (_rng.nextDouble() - 0.5) * speed * 10;
        vy = speed * 40;
      case ParticleDirection.up:
        x = _rng.nextDouble() * w;
        y = h + size;
        vx = (_rng.nextDouble() - 0.5) * speed * 15;
        vy = -speed * 40;
      case ParticleDirection.lateral:
        x = -size;
        y = _rng.nextDouble() * h;
        vx = speed * 30;
        vy = (_rng.nextDouble() - 0.5) * speed * 10;
      case ParticleDirection.random:
        x = _rng.nextDouble() * w;
        y = _rng.nextDouble() * h;
        vx = (_rng.nextDouble() - 0.5) * speed * 20;
        vy = (_rng.nextDouble() - 0.5) * speed * 20;
      case ParticleDirection.swirl:
        // 가장자리에서 생성, 느리게 중심 수렴
        final edge = _rng.nextInt(4);
        switch (edge) {
          case 0:
            x = _rng.nextDouble() * w;
            y = -size;
          case 1:
            x = w + size;
            y = _rng.nextDouble() * h;
          case 2:
            x = _rng.nextDouble() * w;
            y = h + size;
          default:
            x = -size;
            y = _rng.nextDouble() * h;
        }
        final cx = w / 2;
        final cy = h / 2;
        final dx = cx - x;
        final dy = cy - y;
        final dist = sqrt(dx * dx + dy * dy);
        final nx = dist > 0 ? dx / dist : 0.0;
        final ny = dist > 0 ? dy / dist : 0.0;
        // 약간의 접선 방향 추가 (소용돌이)
        vx = (nx * 0.6 + ny * 0.4) * speed * 25;
        vy = (ny * 0.6 - nx * 0.4) * speed * 25;
    }

    final useSecondary = _rng.nextDouble() < 0.3;
    final color = useSecondary
        ? widget.themeVisuals.particleSecondary
        : widget.themeVisuals.particlePrimary;

    return _Particle(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      size: size,
      maxOpacity: maxOpacity,
      life: 0,
      maxLife: maxLife,
      color: color,
      phase: _rng.nextDouble() * pi * 2, // 사인파 위상 오프셋
    );
  }

  void _updateParticles(double dt) {
    final w = _lastSize.width;
    final h = _lastSize.height;

    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life += dt;

      if (p.life >= p.maxLife) {
        _particles[i] = _spawnParticle();
        continue;
      }

      // 사인파 좌우 흔들림 (sanctuary 불씨 등)
      final wobble = sin(p.life * 1.5 + p.phase) * 8.0;

      p.x += (p.vx + wobble * (_config.direction == ParticleDirection.up ? 1 : 0)) * dt;
      p.y += p.vy * dt;

      // 화면 밖 체크 (swirl/random은 제외 — 수명으로 관리)
      if (_config.direction != ParticleDirection.swirl &&
          _config.direction != ParticleDirection.random) {
        if (p.x < -20 || p.x > w + 20 || p.y < -20 || p.y > h + 20) {
          _particles[i] = _spawnParticle();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppTheme.enableAnimations) return const SizedBox.shrink();

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _lastSize = Size(constraints.maxWidth, constraints.maxHeight);
          return CustomPaint(
            painter: _ParticlePainter(particles: _particles),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double maxOpacity;
  double life;
  double maxLife;
  Color color;
  double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.maxOpacity,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.phase,
  });

  double get opacity {
    final t = life / maxLife;
    // fade in (0~0.15), full (0.15~0.7), fade out (0.7~1.0)
    if (t < 0.15) return maxOpacity * (t / 0.15);
    if (t > 0.7) return maxOpacity * (1.0 - (t - 0.7) / 0.3);
    return maxOpacity;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Paint _paint = Paint();

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final alpha = (p.opacity * 255).clamp(0, 255).toInt();
      if (alpha <= 0) continue;

      _paint.color = p.color.withAlpha(alpha);
      canvas.drawCircle(Offset(p.x, p.y), p.size, _paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
