import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/combat/content/monster_cards.dart';
import 'package:soul_dungeon/domain/combat/content/monster_passives.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';

/// 스타터 몬스터 정의 (선택 화면용).
class StarterMonster {
  final String id;
  final String name;
  final String archetype;
  final String description;
  final Color accent;
  final bool unlocked;

  const StarterMonster({
    required this.id,
    required this.name,
    required this.archetype,
    required this.description,
    required this.accent,
    this.unlocked = true,
  });
}

/// 시작 스타터 몬스터 선택 화면 (포켓몬 스타터식).
///
/// 고른 몬스터의 무브풀 카드가 시작 덱이 된다. 일부 스타터는 추후 업적 해금.
class StarterSelectScreen extends StatelessWidget {
  final void Function(String monsterId) onSelect;
  final VoidCallback onBack;

  const StarterSelectScreen({
    super.key,
    required this.onSelect,
    required this.onBack,
  });

  /// 현재 선택 가능한 스타터 (초기 3종). 잠금 스타터는 추후 업적으로 해금.
  static const List<StarterMonster> starters = [
    StarterMonster(
      id: 'enemy_goblin',
      name: '고블린',
      archetype: '공격',
      description: '강타와 돌진으로 밀어붙이는 정통 근접 공격수.',
      accent: Color(0xFFE0704C),
    ),
    StarterMonster(
      id: 'enemy_slime',
      name: '슬라임',
      archetype: '방어',
      description: '방어와 가시로 버티며 반격하는 탱커.',
      accent: Color(0xFF5FB0C0),
    ),
    StarterMonster(
      id: 'enemy_poison_toad',
      name: '독 두꺼비',
      archetype: '중독',
      description: '독을 쌓아 서서히 무너뜨리는 지속 딜러.',
      accent: Color(0xFF7FC04C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFB0A8C0)),
                    onPressed: onBack,
                    tooltip: '뒤로',
                  ),
                  Text(
                    '스타터 선택',
                    style: TextStyle(
                      color: AppTheme.titleGold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Text(
                '함께 시작할 몬스터를 고른다. 이 몬스터의 카드가 첫 덱이 된다.',
                style: TextStyle(
                  color: Color(0xFF8A80A0),
                  fontSize: 13,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 스타터 카드 목록
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: starters.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _StarterCard(
                  starter: starters[i],
                  onTap: () => onSelect(starters[i].id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  final StarterMonster starter;
  final VoidCallback onTap;

  const _StarterCard({required this.starter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final spritePath = PixelArtAssets.enemySprite(starter.id);
    final deckSize = 7 + MonsterCards.movepoolIds(starter.id).length; // 공통 7 + 무브풀

    return GestureDetector(
      onTap: starter.unlocked ? onTap : null,
      child: Opacity(
        opacity: starter.unlocked ? 1.0 : 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15101F),
            border: Border.all(color: starter.accent.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 스프라이트
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0A18),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: spritePath == null
                    ? const Icon(Icons.pets, color: Color(0xFF554C6A))
                    : Image.asset(
                        spritePath,
                        width: 56,
                        height: 56,
                        filterQuality: FilterQuality.none,
                      ),
              ),
              const SizedBox(width: 14),
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          starter.name,
                          style: const TextStyle(
                            color: Color(0xFFEDE6F5),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: starter.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            starter.archetype,
                            style: TextStyle(
                              color: starter.accent,
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      starter.description,
                      style: const TextStyle(
                        color: Color(0xFF9A90B0),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '시작 덱 $deckSize장',
                          style: const TextStyle(
                            color: Color(0xFF6A6280),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!MonsterPassives.forMonster(starter.id).isNone)
                          Flexible(
                            child: Text(
                              '✦ ${MonsterPassives.forMonster(starter.id).label}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: starter.accent,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6A6280)),
            ],
          ),
        ),
      ),
    );
  }
}
