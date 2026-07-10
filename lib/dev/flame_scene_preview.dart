// 개발용 하네스 — Flame 전투 씬을 게임 진입 없이 격리 실행한다.
//
// 실행:
//   flutter run -t lib/dev/flame_scene_preview.dart -d chrome
// 버튼으로 공격/피격/방어/회복/처치 연출을 직접 트리거해 "생동감"을 확인한다.
//
// 프로덕션 빌드에는 포함되지 않는다(별도 엔트리포인트).

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/flame/combat_flame_game.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatefulWidget {
  const _PreviewApp();
  @override
  State<_PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<_PreviewApp> {
  late CombatFlameGame _game;
  int _enemyHp = 20;

  @override
  void initState() {
    super.initState();
    _game = _newGame();
  }

  CombatFlameGame _newGame() => CombatFlameGame(
        bgTop: const Color(0xFF241B33),
        bgBottom: const Color(0xFF0E0A18),
        playerSpritePath: PixelArtAssets.jobSprite('warrior'),
        initialEnemies: [
          (path: PixelArtAssets.enemySprite('enemy_goblin'), hp: 20, maxHp: 20),
        ],
      );

  void _playerAttack() {
    setState(() => _enemyHp = (_enemyHp - 9).clamp(0, 20));
    _game.playerAttack(0, 9);
    _game.setEnemyHp(0, _enemyHp);
    if (_enemyHp == 0) _game.killEnemy(0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0710),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Flame 전투 씬 프리뷰 (Reforged 2단계 파일럿)',
                    style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              ),
              Expanded(child: GameWidget(game: _game)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _btn('플레이어 공격 (-9)', _playerAttack),
                  _btn('적 공격 (-6)', () => _game.enemyAttackPlayer(0, 6)),
                  _btn('방어', _game.playerBlock),
                  _btn('회복 (+5)', () => _game.playerHeal(5)),
                  _btn('처치', () => _game.killEnemy(0)),
                  _btn('리셋', () => setState(() {
                        _enemyHp = 20;
                        _game = _newGame();
                      })),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E2440),
          foregroundColor: Colors.white,
        ),
        child: Text(label, style: const TextStyle(fontFamily: 'monospace')),
      );
}
