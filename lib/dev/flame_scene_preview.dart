// 개발용 하네스 — Flame 전투 씬을 게임 진입 없이 격리 실행한다.
//
// 실행:
//   flutter run -t lib/dev/flame_scene_preview.dart -d chrome
// 버튼으로 공격/피격/방어/회복/처치 연출을 직접 트리거해 "생동감"을 확인한다.
//
// 포켓몬 골드식 구성 — 씬이 상단을 크게 차지(대각선 대치 + 코너 HP 플레이트),
// 하단은 메시지 한 줄 + 카드. 전투기록/손패 패널 없음.
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

  CombatFlameGame _newGame() {
    final g = CombatFlameGame(
      bgTop: const Color(0xFF241B33),
      bgBottom: const Color(0xFF0E0A18),
      playerSpritePath: PixelArtAssets.jobSprite('warrior'),
      playerName: '전사',
      initialEnemies: [
        (
          path: PixelArtAssets.enemySprite('enemy_goblin'),
          name: '고블린',
          hp: 20,
          maxHp: 20,
        ),
      ],
    );
    g.setPlayer(60, 60);
    return g;
  }

  void _playerAttack() {
    setState(() => _enemyHp = (_enemyHp - 9).clamp(0, 20));
    _game.playerAttack(0, 9);
    _game.setEnemyHp(0, _enemyHp);
    if (_enemyHp == 0) _game.killEnemy(0);
  }

  @override
  Widget build(BuildContext context) {
    // [Flame 씬: 대각선 대치 + 코너 HP 플레이트] → [메시지] → [카드]
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0710),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 전투 씬 (상단 지배) ──
              Expanded(flex: 6, child: GameWidget(game: _game)),
              // ── 명령/메시지 박스 (하단) ──
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15101F),
                    border: Border.all(color: const Color(0xFF6A5A8C), width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('고블린이 이빨을 드러낸다...',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'monospace')),
                      const Spacer(),
                      Row(
                        children: [
                          _card('강타', '1AP'),
                          _card('수비', '1AP'),
                          _card('연격', '2AP'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // ── 데모 트리거 (실제 게임엔 없음 — 카드 플레이가 대신함) ──
              Container(
                color: const Color(0xFF120C1C),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _btn('강타 (-9)', _playerAttack),
                    _btn('피격 (-6)', () => _game.enemyAttackPlayer(0, 6)),
                    _btn('방어', _game.playerBlock),
                    _btn('회복 (+5)', () => _game.playerHeal(5)),
                    _btn('처치', () => _game.killEnemy(0)),
                    _btn('리셋', () => setState(() {
                          _enemyHp = 20;
                          _game = _newGame();
                        })),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String name, String cost) => Expanded(
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2140),
            border: Border.all(color: const Color(0xFF6A5A8C)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
              const SizedBox(height: 4),
              Text(cost,
                  style: const TextStyle(
                      color: Color(0xFF9A8AC0),
                      fontSize: 11,
                      fontFamily: 'monospace')),
            ],
          ),
        ),
      );

  Widget _btn(String label, VoidCallback onTap) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E2440),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
      );
}
