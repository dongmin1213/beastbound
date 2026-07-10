import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';

import 'flame/combat_flame_game.dart';

/// CombatBloc 상태를 구독해 [CombatFlameGame] 연출로 변환하는 브릿지 위젯.
///
/// Reforged 2단계 파일럿: 기존 `MultiEnemyAreaWidget`(정적 초상화)을 대체해
/// 플레이어/적 스프라이트가 실제로 공격·피격·사망하는 씬을 그린다.
///
/// **domain 값은 절대 변경하지 않는다** — 상태 diff를 읽어 애니메이션만 트리거.
class FlameCombatScene extends StatefulWidget {
  final CombatBloc combatBloc;
  final FloorThemeVisuals floorVisuals;

  /// 플레이어 직업 ID (스프라이트 매핑용). null이면 실루엣.
  final String? playerJobId;

  /// 플레이어 HP 플레이트에 표시할 이름.
  final String playerName;

  const FlameCombatScene({
    super.key,
    required this.combatBloc,
    required this.floorVisuals,
    required this.playerJobId,
    this.playerName = '나',
  });

  @override
  State<FlameCombatScene> createState() => _FlameCombatSceneState();
}

class _FlameCombatSceneState extends State<FlameCombatScene> {
  CombatFlameGame? _game;
  StreamSubscription<CombatState>? _sub;
  CardCombatActive? _prev;

  @override
  void initState() {
    super.initState();
    final state = widget.combatBloc.state;
    if (state is CardCombatActive) {
      _game = _buildGame(state);
      _prev = state;
    }
    _sub = widget.combatBloc.stream.listen(_onState);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  CombatFlameGame _buildGame(CardCombatActive state) {
    final game = CombatFlameGame(
      bgTop: widget.floorVisuals.backgroundColor,
      bgBottom: widget.floorVisuals.combatBackground,
      playerSpritePath:
          widget.playerJobId != null ? PixelArtAssets.jobSprite(widget.playerJobId!) : null,
      playerName: widget.playerName,
      initialEnemies: state.enemies.map(_enemyDef).toList(),
    );
    game.setPlayer(state.playerHp, state.playerMaxHp);
    return game;
  }

  EnemyDef _enemyDef(dynamic e) {
    // EnemyBattleState: data(id, name), currentHp, maxHp.
    final id = e.data.id as String;
    final path = PixelArtAssets.enemySprite(id) ?? PixelArtAssets.bossSprite(id);
    return (
      path: path,
      name: e.data.name as String,
      hp: e.currentHp as int,
      maxHp: e.maxHp as int,
    );
  }

  void _onState(CombatState state) {
    if (state is! CardCombatActive) return;
    final game = _game;

    // 첫 활성 상태(전투 진입)면 게임 생성.
    if (game == null) {
      setState(() {
        _game = _buildGame(state);
        _prev = state;
      });
      return;
    }

    final prev = _prev;
    _prev = state;
    if (prev == null) return;

    // 새 전투(적 구성 변화) → 무애니메이션 재동기화.
    if (_enemiesChanged(prev, state)) {
      game.resyncEnemies(state.enemies.map(_enemyDef).toList());
      return;
    }

    // ── 적 HP diff → 피격/사망 연출 ──
    final n = state.enemies.length;
    for (var i = 0; i < n && i < prev.enemies.length; i++) {
      final before = prev.enemies[i].currentHp;
      final after = state.enemies[i].currentHp;
      if (after < before) {
        game.playerAttack(i, before - after);
        game.setEnemyHp(i, after);
      }
      if (!prev.enemies[i].isDead && state.enemies[i].isDead) {
        game.killEnemy(i);
      }
    }

    // ── 플레이어 HP/방어 diff → 피격/회복/방어 연출 ──
    if (state.playerHp < prev.playerHp) {
      game.enemyAttackPlayer(0, prev.playerHp - state.playerHp);
    } else if (state.playerHp > prev.playerHp) {
      game.playerHeal(state.playerHp - prev.playerHp);
    }
    if (state.playerBlock > prev.playerBlock) {
      game.playerBlock();
    }

    // 플레이어 HP 플레이트 갱신.
    game.setPlayer(state.playerHp, state.playerMaxHp);
  }

  bool _enemiesChanged(CardCombatActive a, CardCombatActive b) {
    if (a.enemies.length != b.enemies.length) return true;
    for (var i = 0; i < a.enemies.length; i++) {
      if (a.enemies[i].data.id != b.enemies[i].data.id) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    // 부모(Expanded)가 크기를 결정 — 씬이 상단 영역을 채운다.
    return game == null ? const SizedBox.shrink() : GameWidget(game: game);
  }
}
