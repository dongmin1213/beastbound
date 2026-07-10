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
    // 실제 폰 세로 전투 화면 레이아웃 근사:
    //   [적 영역 밴드 = Flame 씬] → [전투 기록] → [플레이어 상태] → [카드]
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0710),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 적 영역 밴드 (Flame 연출 씬) ──
              _frame('☠ 고블린', SizedBox(height: 200, child: GameWidget(game: _game))),
              // ── 전투 기록 (텍스트 로그 자리) ──
              Expanded(child: _frame('전투 기록', const _Placeholder('고블린이 이빨을 드러낸다...'))),
              // ── 플레이어 상태 (기세/HP/AP/덱 자리) ──
              _frame('손패', const _Placeholder('❤ 60/60   ◆ AP 3   🂠 덱 12')),
              // ── 카드 (손패 카드 자리) ──
              _frame('카드', const _Placeholder('[강타 1AP]  [수비 1AP]  [연격 2AP]')),
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

  Widget _frame(String title, Widget child) => Container(
        margin: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        decoration: BoxDecoration(
          color: const Color(0xFF15101F),
          border: Border.all(color: const Color(0xFF43395C)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: const Color(0xFF2A2140),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'monospace')),
            ),
            child,
          ],
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

/// 실제 위젯(전투로그/손패/카드) 자리를 대신하는 회색 플레이스홀더.
class _Placeholder extends StatelessWidget {
  final String text;
  const _Placeholder(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white38, fontSize: 12, fontFamily: 'monospace')),
      );
}
