import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';
import 'package:soul_dungeon/core/config/tamed_monster_store.dart';
import 'package:soul_dungeon/domain/combat/content/monster_cards.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';

/// 도감(Bestiary) — 길들일 수 있는 몬스터와 그 무브풀을 보여준다.
///
/// "네가 싸운 적이, 네 덱이 된다"의 메타 화면. 현재는 1층 몬스터를 표시하는
/// 플레이스홀더 — 포획 영속(로스터/도감 저장)은 이후 시스템 ④에서 연결.
class BestiaryScreen extends StatelessWidget {
  final VoidCallback onBack;

  const BestiaryScreen({super.key, required this.onBack});

  /// 도감에 표시할 몬스터 (현재 1층). 무브풀이 정의된 종만.
  static List<EnemyCombatData> get _monsters => [
        ...FloorEnemies.floor1Normal,
        ...FloorEnemies.floor1Elite,
      ].where((e) => MonsterCards.hasMovepool(e.id)).toList();

  @override
  Widget build(BuildContext context) {
    final monsters = _monsters;
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 헤더 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFB0A8C0)),
                    onPressed: onBack,
                    tooltip: '뒤로',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '도감',
                    style: TextStyle(
                      color: AppTheme.titleGold,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${monsters.length}종',
                    style: const TextStyle(
                      color: Color(0xFF8A80A0),
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(
                '적을 제압해 길들이면 도감에 등록되고, 그 몬스터의 카드를 배운다.',
                style: TextStyle(
                  color: Color(0xFF8A80A0),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── 몬스터 그리드 ──
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemCount: monsters.length,
                itemBuilder: (context, i) => _MonsterCard(
                  monster: monsters[i],
                  tamed: TamedMonsterStore.isTamed(monsters[i].id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonsterCard extends StatelessWidget {
  final EnemyCombatData monster;
  final bool tamed;

  const _MonsterCard({required this.monster, this.tamed = false});

  @override
  Widget build(BuildContext context) {
    final spritePath = PixelArtAssets.enemySprite(monster.id);
    final cardCount = MonsterCards.movepoolIds(monster.id).length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15101F),
        border: Border.all(
          color: monster.isElite
              ? const Color(0xFF6A5A2C)
              : const Color(0xFF3A3352),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // 스프라이트 영역
          Expanded(
            child: Center(
              child: spritePath == null
                  ? const Icon(Icons.help_outline, color: Color(0xFF554C6A))
                  : ColorFiltered(
                      // 미포획 = 실루엣(어둡게), 포획 = 원색.
                      colorFilter: tamed
                          ? const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply)
                          : const ColorFilter.mode(
                              Color(0xFF120C1C), BlendMode.saturation),
                      child: Image.asset(
                        spritePath,
                        width: 64,
                        height: 64,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
            ),
          ),
          // 정보 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1530),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (monster.isElite)
                      const Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Text('★',
                            style: TextStyle(
                                color: Color(0xFFE0C040), fontSize: 11)),
                      ),
                    Expanded(
                      child: Text(
                        tamed ? monster.name : '???',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFEDE6F5),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.style,
                        size: 11, color: Color(0xFF9A8AC0)),
                    const SizedBox(width: 3),
                    Text(
                      '무브풀 $cardCount장',
                      style: const TextStyle(
                        color: Color(0xFF9A8AC0),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      tamed ? '포획' : '미포획',
                      style: TextStyle(
                        color: tamed
                            ? const Color(0xFF6FCF6F)
                            : const Color(0xFF6A6280),
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
