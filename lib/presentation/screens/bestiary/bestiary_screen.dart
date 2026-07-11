import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/config/tamed_monster_store.dart';
import 'package:soul_dungeon/domain/combat/content/boss_enemies.dart';
import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';
import 'package:soul_dungeon/domain/combat/content/monster_cards.dart';
import 'package:soul_dungeon/domain/combat/content/monster_passives.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';

/// 도감(Bestiary) — 길들일 수 있는 몬스터와 그 무브풀을 보여준다.
///
/// "네가 싸운 적이, 네 덱이 된다"의 메타 화면. 야수(일반/정예) + 영역의 주인(보스)을
/// 모두 표시한다. 포획 여부는 [TamedMonsterStore]에 영속.
class BestiaryScreen extends StatelessWidget {
  final VoidCallback onBack;

  const BestiaryScreen({super.key, required this.onBack});

  /// 야수(일반/정예) — 무브풀이 정의된 종만.
  static List<_Entry> get _beasts => [
        ...FloorEnemies.floor1Normal,
        ...FloorEnemies.floor1Elite,
        ...FloorEnemies.floor2Normal,
        ...FloorEnemies.floor2Elite,
        ...FloorEnemies.floor3Normal,
        ...FloorEnemies.floor3Elite,
        ...FloorEnemies.floor4Normal,
        ...FloorEnemies.floor4Elite,
        ...FloorEnemies.floor5Normal,
        ...FloorEnemies.floor5Elite,
      ]
          .where((e) => MonsterCards.hasMovepool(e.id))
          .map((e) => _Entry(
                id: e.id,
                name: e.name,
                isElite: e.isElite,
                isBoss: false,
                spritePath: PixelArtAssets.enemySprite(e.id),
              ))
          .toList();

  /// 영역의 주인(보스) — 무브풀이 정의된 종만.
  static List<_Entry> get _lords => BossEnemies.all
      .where((b) => MonsterCards.hasMovepool(b.id))
      .map((b) => _Entry(
            id: b.id,
            name: b.name,
            isElite: false,
            isBoss: true,
            spritePath: PixelArtAssets.bossSprite(b.id),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    final beasts = _beasts;
    final lords = _lords;
    final all = [...beasts, ...lords];
    final tamedCount = all.where((m) => TamedMonsterStore.isTamed(m.id)).length;

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
                    '$tamedCount/${all.length} 포획',
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
            // ── 섹션: 야수 + 영역의 주인 ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _sectionLabel('야수', beasts),
                  _grid(beasts),
                  const SizedBox(height: 16),
                  _sectionLabel('영역의 주인', lords),
                  _grid(lords),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, List<_Entry> entries) {
    final tamed = entries.where((e) => TamedMonsterStore.isTamed(e.id)).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFC8BEE0),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$tamed/${entries.length}',
            style: const TextStyle(
              color: Color(0xFF6A6280),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(List<_Entry> entries) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.74,
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) => _MonsterCard(
        entry: entries[i],
        tamed: TamedMonsterStore.isTamed(entries[i].id),
      ),
    );
  }
}

/// 도감 표시용 통합 엔트리 (야수 + 보스).
class _Entry {
  final String id;
  final String name;
  final bool isElite;
  final bool isBoss;
  final String? spritePath;

  const _Entry({
    required this.id,
    required this.name,
    required this.isElite,
    required this.isBoss,
    required this.spritePath,
  });
}

class _MonsterCard extends StatelessWidget {
  final _Entry entry;
  final bool tamed;

  const _MonsterCard({required this.entry, this.tamed = false});

  @override
  Widget build(BuildContext context) {
    final spritePath = entry.spritePath;
    final cardCount = MonsterCards.movepoolIds(entry.id).length;
    final borderColor = entry.isBoss
        ? const Color(0xFF6A2C4C)
        : entry.isElite
            ? const Color(0xFF6A5A2C)
            : const Color(0xFF3A3352);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15101F),
        border: Border.all(color: borderColor),
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
                    if (entry.isBoss)
                      const Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Text('☠',
                            style: TextStyle(
                                color: Color(0xFFDD6699), fontSize: 11)),
                      )
                    else if (entry.isElite)
                      const Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Text('★',
                            style: TextStyle(
                                color: Color(0xFFE0C040), fontSize: 11)),
                      ),
                    Expanded(
                      child: Text(
                        tamed ? entry.name : '???',
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
                    const Icon(Icons.style, size: 11, color: Color(0xFF9A8AC0)),
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
                if (!MonsterPassives.forMonster(entry.id).isNone) ...[
                  const SizedBox(height: 2),
                  Text(
                    '✦ ${MonsterPassives.forMonster(entry.id).label}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8FB0E0),
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
