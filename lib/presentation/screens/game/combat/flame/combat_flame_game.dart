import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';

import 'combat_actor.dart';
import 'combat_sprites.dart';
import 'floating_number.dart';
import 'slash_effect.dart';

/// 전투 씬에 배치할 적 1체의 초기 정의.
typedef EnemyDef = ({ActorSprites sprites, String name, int hp, int maxHp});

/// 카드 전투의 Flame 씬 — 포켓몬 골드식 대각선 대치 구도.
///
///   [적 HP 플레이트]────────────┐
///   │                    (적 스프라이트, 우상단)
///   │        (플레이어, 좌하단, 크게)
///   └──────────────[플레이어 HP 플레이트]
///
/// Reforged 2단계 파일럿. CombatBloc 상태는 [FlameCombatScene] 위젯이 구독해
/// diff를 계산하고 이 게임의 트리거 메서드를 호출한다. 게임 자체는 Bloc을
/// 알지 못한다(순수 연출 레이어).
class CombatFlameGame extends FlameGame {
  final Color bgTop;
  final Color bgBottom;
  final ActorSprites playerSprites;
  final String playerName;
  final List<EnemyDef> initialEnemies;

  CombatActor? _player;
  final List<CombatActor> _enemies = [];
  List<EnemyDef> _enemyDefs = const [];

  int _playerHp = 1;
  int _playerMaxHp = 1;

  final _rnd = math.Random();
  double _shake = 0; // 화면 흔들림 강도(px), 매 프레임 감쇠.

  CombatFlameGame({
    required this.bgTop,
    required this.bgBottom,
    required this.playerSprites,
    required this.playerName,
    required this.initialEnemies,
  });

  // ── 레이아웃 (포켓몬 골드식 대각선) ──
  Vector2 get _playerPos => Vector2(size.x * 0.30, size.y * 0.86);
  double get _playerSize => (size.x * 0.30).clamp(56.0, 128.0);
  double get _enemySize => (size.x * 0.21).clamp(44.0, 92.0);

  Vector2 _enemyPos(int index, int count) {
    // 우상단 영역. 멀티몹이면 가로로 살짝 분산.
    final baseX = size.x * 0.66;
    final y = size.y * 0.40;
    if (count <= 1) return Vector2(baseX, y);
    final spread = size.x * 0.14;
    final t = index / (count - 1); // 0..1
    return Vector2(baseX - spread / 2 + spread * t, y - index * 6);
  }

  @override
  Future<void> onLoad() async {
    images.prefix = ''; // assets/pixel_art/... 절대 경로 사용.

    final pSize = _playerSize;
    _player = CombatActor(
      sprites: playerSprites,
      facingRight: true,
      hp: 1,
      maxHp: 1,
      position: _playerPos,
      size: Vector2(pSize, pSize),
    );
    await add(_player!);

    await _spawnEnemies(initialEnemies);
  }

  Future<void> _spawnEnemies(List<EnemyDef> defs) async {
    for (final a in _enemies) {
      a.removeFromParent();
    }
    _enemies.clear();
    _enemyDefs = defs;
    final multi = defs.length > 1;
    final eSize = _enemySize;
    for (var i = 0; i < defs.length; i++) {
      final def = defs[i];
      final actor = CombatActor(
        sprites: def.sprites,
        facingRight: false,
        hp: def.hp,
        maxHp: def.maxHp,
        position: _enemyPos(i, defs.length),
        size: Vector2(eSize, eSize),
        showHpBar: multi, // 멀티몹만 머리 위 미니 바; 단일은 코너 플레이트.
      );
      _enemies.add(actor);
      await add(actor);
    }
  }

  // ── 외부(위젯)에서 호출하는 트리거 ──

  /// 플레이어 상태 갱신 (플레이어 HP 플레이트 반영).
  void setPlayer(int hp, int maxHp) {
    _playerHp = hp;
    _playerMaxHp = maxHp;
  }

  /// 플레이어가 카드로 [index] 적을 공격 → 런지 + 슬래시 + 피격 + 데미지 + 흔들림.
  void playerAttack(int index, int damage) {
    _player?.triggerAttack();
    final target = _enemyAt(index);
    if (target != null) {
      target.triggerHurt();
      _spawnSlash(target);
      if (damage > 0) _spawnDamage(target, damage, const Color(0xFFFFF0C0));
    }
    _addShake(damage > 0 ? 6.0 : 3.0);
  }

  /// 적이 플레이어를 공격 → 적 런지 + 플레이어 피격 + 데미지 + 흔들림.
  void enemyAttackPlayer(int enemyIndex, int damage) {
    _enemyAt(enemyIndex)?.triggerAttack();
    final p = _player;
    if (p != null && damage > 0) {
      p.triggerHurt();
      _spawnDamage(p, damage, const Color(0xFFFF6060));
    }
    _addShake(5.0);
  }

  /// 특정 적 HP 갱신 (플레이트/미니바 반영).
  void setEnemyHp(int index, int hp) {
    _enemyAt(index)?.hp = hp;
  }

  /// 적 사망 디졸브.
  void killEnemy(int index) => _enemyAt(index)?.triggerDeath();

  /// 플레이어 방어 획득 쉬머.
  void playerBlock() => _player?.triggerBlock();

  /// 플레이어 회복 수치 표시.
  void playerHeal(int amount) {
    final p = _player;
    if (p != null && amount > 0) {
      _spawnDamage(p, amount, const Color(0xFF80E0A0), prefix: '+');
    }
  }

  /// 적 목록 재동기화 (멀티몹 카운트/HP 변화 시 — 파일럿에선 주로 초기 1회).
  Future<void> resyncEnemies(List<EnemyDef> defs) => _spawnEnemies(defs);

  // ── 내부 헬퍼 ──

  CombatActor? _enemyAt(int index) =>
      (index >= 0 && index < _enemies.length) ? _enemies[index] : null;

  void _addShake(double amount) => _shake = math.max(_shake, amount);

  void _spawnSlash(CombatActor target) {
    add(SlashEffect(position: target.position.clone()..y -= target.size.y * 0.5));
  }

  void _spawnDamage(CombatActor target, int amount, Color color,
      {String prefix = ''}) {
    add(FloatingNumber(
      text: '$prefix$amount',
      color: color,
      position: target.position.clone()..y -= target.size.y * 0.9,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shake > 0) _shake = math.max(0, _shake - dt * 40);
  }

  @override
  void render(Canvas canvas) {
    _renderBackground(canvas);
    canvas.save();
    if (_shake > 0.1) {
      canvas.translate(
        (_rnd.nextDouble() * 2 - 1) * _shake,
        (_rnd.nextDouble() * 2 - 1) * _shake,
      );
    }
    super.render(canvas); // 스프라이트/이펙트 (흔들림 적용).
    canvas.restore();
    _renderPlates(canvas); // HP 플레이트는 흔들림 무관(고정 UI).
  }

  void _renderBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = Gradient.linear(
          Offset(size.x / 2, 0),
          Offset(size.x / 2, size.y),
          [bgTop, bgBottom],
        ),
    );
    // 발판(플랫폼) 타원 — 원근감.
    _drawPlatform(canvas, _enemyPos(0, _enemies.isEmpty ? 1 : _enemies.length),
        _enemySize * 0.9);
    _drawPlatform(canvas, _playerPos, _playerSize * 1.05);
  }

  void _drawPlatform(Canvas canvas, Vector2 footPos, double width) {
    final rect = Rect.fromCenter(
      center: Offset(footPos.x, footPos.y + 2),
      width: width,
      height: width * 0.28,
    );
    canvas.drawOval(rect, Paint()..color = const Color(0x33000000));
    canvas.drawOval(
      rect,
      Paint()
        ..color = const Color(0x22FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _renderPlates(Canvas canvas) {
    // 적 플레이트 — 좌상단 (단일 적일 때만; 멀티몹은 머리 위 미니바).
    if (_enemies.length == 1 && _enemyDefs.isNotEmpty) {
      final e = _enemies.first;
      _drawPlate(
        canvas,
        Rect.fromLTWH(6, 8, (size.x * 0.52).clamp(120.0, 240.0), 30),
        _enemyDefs.first.name,
        e.hp,
        e.maxHp,
        showNumbers: false,
      );
    }
    // 플레이어 플레이트 — 우하단.
    final pw = (size.x * 0.52).clamp(120.0, 240.0);
    _drawPlate(
      canvas,
      Rect.fromLTWH(size.x - pw - 6, size.y - 38, pw, 30),
      playerName,
      _playerHp,
      _playerMaxHp,
      showNumbers: true,
    );
  }

  void _drawPlate(Canvas canvas, Rect box, String name, int hp, int maxHp,
      {required bool showNumbers}) {
    final rrect = RRect.fromRectAndRadius(box, const Radius.circular(4));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xE6120C1C));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF6A5A8C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final pad = 6.0;
    // 이름.
    TextPaint(
      style: const TextStyle(
        color: Color(0xFFEDE6F5),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    ).render(canvas, name, Vector2(box.left + pad, box.top + 4));

    // HP 바.
    final barRect = Rect.fromLTWH(box.left + pad, box.top + 18,
        box.width - pad * 2 - (showNumbers ? 44 : 0), 5);
    final ratio = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF2A2036),
    );
    final fill = ratio > 0.5
        ? const Color(0xFF6FCF6F)
        : ratio > 0.25
            ? const Color(0xFFE0C040)
            : const Color(0xFFE05050);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barRect.left, barRect.top, barRect.width * ratio, barRect.height),
        const Radius.circular(2),
      ),
      Paint()..color = fill,
    );

    if (showNumbers) {
      TextPaint(
        style: const TextStyle(
          color: Color(0xFFCFC6DF),
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      ).render(
        canvas,
        '$hp/$maxHp',
        Vector2(box.right - pad, box.top + 16),
        anchor: Anchor.topRight,
      );
    }
  }
}
