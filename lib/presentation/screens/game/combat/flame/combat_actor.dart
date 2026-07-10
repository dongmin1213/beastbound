import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'combat_sprites.dart';

/// 전투 씬의 캐릭터(플레이어/적) 컴포넌트.
///
/// 상태별 프레임([ActorSprites])이 있으면 그걸 쓰고, 없으면 idle 한 장에
/// 컴포넌트 트랜스폼(런지/플래시/디졸브)을 얹어 생동감을 만든다.
/// → 아트를 나중에 채워도 코드 변경 없이 자동으로 프레임이 반영된다.
/// 애니메이션은 Effect API 대신 수동 `update(dt)`로 구동해 버전 의존성을 없앤다.
class CombatActor extends PositionComponent {
  /// 상태별 스프라이트 세트 (idle 필수, 나머지는 선택).
  final ActorSprites sprites;

  /// 바라보는 방향 — 플레이어는 오른쪽(적 방향), 적은 왼쪽.
  final bool facingRight;

  /// 씬 내 HP 바 표시 여부 (멀티몹만; 단일은 코너 플레이트 사용).
  final bool showHpBar;

  int hp;
  int maxHp;

  final Map<String, Sprite> _frames = {};

  // ── 애니메이션 상태 (수동 구동) ──
  double _bobT = 0; // idle 호흡 위상
  double _flash = 0; // 1→0 피격 플래시
  double _lunge = 0; // 0→1 공격 런지 진행 (0=대기)
  double _death = 0; // 0→1 사망 디졸브
  double _block = 0; // 1→0 방어 쉬머
  bool _dying = false;

  CombatActor({
    required this.sprites,
    required this.facingRight,
    required this.hp,
    required this.maxHp,
    required Vector2 position,
    required Vector2 size,
    this.showHpBar = false,
  }) : super(position: position, size: size, anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    final game = findGame();
    if (game is! FlameGame) return;
    for (final path in sprites.allPaths) {
      _frames[path] = await Sprite.load(path, images: game.images);
    }
  }

  /// 현재 상태에 맞는 스프라이트 (프레임 없으면 idle 폴백).
  Sprite? get _currentSprite {
    String? key;
    if (_dying) {
      key = sprites.death ?? sprites.idle;
    } else if (_flash > 0.4) {
      key = sprites.hurt ?? sprites.idle;
    } else if (_lunge > 0) {
      key = sprites.attack ?? sprites.idle;
    } else {
      key = sprites.idle;
    }
    return key != null ? _frames[key] : null;
  }

  /// 공격 런지 시작 (대상 방향으로 찔렀다 복귀).
  void triggerAttack() => _lunge = 0.0001;

  /// 피격 플래시 시작.
  void triggerHurt() => _flash = 1.0;

  /// 방어 쉬머 시작.
  void triggerBlock() => _block = 1.0;

  /// 사망 디졸브 시작.
  void triggerDeath() => _dying = true;

  @override
  void update(double dt) {
    super.update(dt);
    _bobT += dt;
    if (_flash > 0) _flash = (_flash - dt * 3.0).clamp(0.0, 1.0);
    if (_block > 0) _block = (_block - dt * 1.5).clamp(0.0, 1.0);
    if (_lunge > 0) {
      _lunge += dt / 0.28; // 0.28초 왕복
      if (_lunge >= 1) _lunge = 0;
    }
    if (_dying) {
      _death = (_death + dt * 1.6).clamp(0.0, 1.0);
      if (_death >= 1) removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite = _currentSprite;
    // 런지: sin(πt) → 나갔다 복귀. 방향에 따라 부호.
    final lungeOffset =
        _lunge > 0 ? math.sin(_lunge * math.pi) * 26 * (facingRight ? 1 : -1) : 0.0;
    final bob = math.sin(_bobT * 2.2) * 2.0;
    final opacity = (1 - _death).clamp(0.0, 1.0);

    canvas.save();
    canvas.translate(lungeOffset, bob - _death * 6); // 사망 시 살짝 가라앉음

    if (sprite != null) {
      final paint = Paint()
        ..filterQuality = FilterQuality.none
        ..isAntiAlias = false
        ..color = Color.fromRGBO(255, 255, 255, opacity);
      // 전용 hurt 프레임이 없을 때만 붉은 틴트로 피격 표현.
      if (_flash > 0 && sprites.hurt == null) {
        paint.colorFilter = ColorFilter.mode(
          Color.fromRGBO(255, 90, 90, 0.75 * _flash),
          BlendMode.srcATop,
        );
      }

      canvas.save();
      if (!facingRight) {
        // 좌우 반전 (적은 왼쪽을 봄).
        canvas.translate(size.x, 0);
        canvas.scale(-1, 1);
      }
      sprite.render(canvas, size: size, overridePaint: paint);
      canvas.restore();
    }

    // 방어 쉬머 — 스프라이트 앞 반투명 청록 아크.
    if (_block > 0) {
      final shimmer = Paint()
        ..color = Color.fromRGBO(150, 220, 255, 0.5 * _block)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromLTWH(-2, size.y * 0.25, size.x + 4, size.y * 0.6),
        -math.pi * 0.35,
        math.pi * 0.7,
        false,
        shimmer,
      );
    }
    canvas.restore();

    if (showHpBar) _renderHpBar(canvas);
  }

  void _renderHpBar(Canvas canvas) {
    const barH = 4.0;
    final w = size.x;
    final top = -10.0;
    final ratio = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;
    canvas.drawRect(
      Rect.fromLTWH(0, top, w, barH),
      Paint()..color = const Color(0xCC1A1015),
    );
    final fillColor = ratio > 0.5
        ? const Color(0xFF6FCF6F)
        : ratio > 0.25
            ? const Color(0xFFE0C040)
            : const Color(0xFFE05050);
    canvas.drawRect(
      Rect.fromLTWH(0, top, w * ratio, barH),
      Paint()..color = fillColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top, w, barH),
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
