import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';

import 'combat_actor.dart';
import 'floating_number.dart';
import 'slash_effect.dart';

/// 전투 씬에 배치할 적 1체의 초기 정의.
typedef EnemyDef = ({String? path, int hp, int maxHp});

/// 카드 전투의 Flame 씬 — 플레이어/적 스프라이트 + VFX + 화면 흔들림.
///
/// Reforged 2단계 파일럿. CombatBloc 상태는 [FlameCombatScene] 위젯이 구독해
/// diff를 계산하고 이 게임의 트리거 메서드를 호출한다. 게임 자체는 Bloc을
/// 알지 못한다(순수 연출 레이어).
class CombatFlameGame extends FlameGame {
  final Color bgTop;
  final Color bgBottom;
  final String? playerSpritePath;
  final List<EnemyDef> initialEnemies;

  CombatActor? _player;
  final List<CombatActor> _enemies = [];

  final _rnd = math.Random();
  double _shake = 0; // 화면 흔들림 강도(px), 매 프레임 감쇠.

  CombatFlameGame({
    required this.bgTop,
    required this.bgBottom,
    required this.playerSpritePath,
    required this.initialEnemies,
  });

  // ── 레이아웃 ──
  double get _groundY => size.y * 0.80;
  double get _playerX => size.x * 0.22;
  double get _enemyActorSize => (size.x * 0.16).clamp(48.0, 84.0);
  double get _playerActorSize => (size.x * 0.18).clamp(52.0, 92.0);

  Vector2 _enemyPosition(int index, int count) {
    // 오른쪽 절반에 균등 분포.
    final startX = size.x * 0.56;
    final endX = size.x * 0.86;
    final t = count <= 1 ? 0.5 : index / (count - 1);
    return Vector2(lerpDouble(startX, endX, t)!, _groundY);
  }

  @override
  Future<void> onLoad() async {
    images.prefix = ''; // assets/pixel_art/... 절대 경로 사용.

    final pSize = _playerActorSize;
    _player = CombatActor(
      spritePath: playerSpritePath,
      facingRight: true,
      hp: 1,
      maxHp: 1,
      position: Vector2(_playerX, _groundY),
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
    final eSize = _enemyActorSize;
    for (var i = 0; i < defs.length; i++) {
      final def = defs[i];
      final actor = CombatActor(
        spritePath: def.path,
        facingRight: false,
        hp: def.hp,
        maxHp: def.maxHp,
        position: _enemyPosition(i, defs.length),
        size: Vector2(eSize, eSize),
        showHpBar: true,
      );
      _enemies.add(actor);
      await add(actor);
    }
  }

  // ── 외부(위젯)에서 호출하는 트리거 ──

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

  /// 특정 적 HP 갱신 (씬 내 HP 바 반영).
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

  void _addShake(double amount) {
    _shake = math.max(_shake, amount);
  }

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
    if (_shake > 0) {
      _shake = math.max(0, _shake - dt * 40); // 감쇠.
    }
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
    super.render(canvas);
    canvas.restore();
  }

  void _renderBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = Gradient.linear(
      Offset(size.x / 2, 0),
      Offset(size.x / 2, size.y),
      [bgTop, bgBottom],
    );
    canvas.drawRect(rect, Paint()..shader = gradient);
    // 바닥 라인 — 캐릭터가 서 있는 지면 암시.
    canvas.drawRect(
      Rect.fromLTWH(0, _groundY, size.x, size.y - _groundY),
      Paint()..color = const Color(0x22000000),
    );
  }
}
