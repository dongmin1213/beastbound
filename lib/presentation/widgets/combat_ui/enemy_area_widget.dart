import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/combat/logic/enemy_ai.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/animated_boss_sprite.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/gauge_bar.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/status_effect_badges_widget.dart';

/// 카드 전투 상단 — 적 이름 + HP + 블록 + 의도 + 상태효과 + 기믹 뱃지.
class EnemyAreaWidget extends StatelessWidget {
  final EnemyCombatData enemy;
  final int enemyHp;
  final int enemyMaxHp;
  final int enemyBlock;
  final int currentTurn;
  final bool intentRevealed;
  final bool isBoss;
  final List<StatusEffect> enemyStatuses;
  final int enemyStrength;

  /// 보스 기믹 태그 텍스트 (예: "[재생]"). 보스가 아니면 빈 문자열.
  final String gimmickTag;

  /// 보스 환경카드 효과 잔여 턴.
  final int enemyHealBlockedTurns;
  final int enemyStunnedTurns;
  final int enemyDrainBlockedTurns;

  const EnemyAreaWidget({
    super.key,
    required this.enemy,
    required this.enemyHp,
    required this.enemyMaxHp,
    required this.enemyBlock,
    required this.currentTurn,
    required this.intentRevealed,
    this.isBoss = false,
    this.enemyStatuses = const [],
    this.enemyStrength = 0,
    this.gimmickTag = '',
    this.enemyHealBlockedTurns = 0,
    this.enemyStunnedTurns = 0,
    this.enemyDrainBlockedTurns = 0,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 12);
    final hPadding = ResponsiveScale.scalePadding(context, 12);

    final spritePath = isBoss
        ? PixelArtAssets.bossSprite(enemy.id)
        : PixelArtAssets.enemySprite(enemy.id);

    final blockLabel = enemyBlock > 0 ? ', 방어 $enemyBlock' : '';
    return Semantics(
      label: '${enemy.name}, HP $enemyHp/$enemyMaxHp$blockLabel',
      child: Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 적 스프라이트 + 이름
          if (spritePath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isBoss)
                    AnimatedBossSprite(assetPath: spritePath, size: 48)
                  else
                    Image.asset(
                      spritePath,
                      width: 36,
                      height: 36,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    enemy.name,
                    style: TextStyle(
                      fontSize: ResponsiveScale.scaleFontSize(context, 13),
                      color: isBoss
                          ? const Color(0xFFFFD700)
                          : enemy.isElite
                              ? const Color(0xFFFF6B6B)
                              : const Color(0xFFE0E0E0),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Galmuri11',
                    ),
                  ),
                ],
              ),
            ),
          // HP 바 + 블록
          Row(
            children: [
              if (enemyBlock > 0) ...[
                Text(
                  '\u{1F6E1} $enemyBlock',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppTheme.gaugeBlock,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: GaugeBar(
                  current: enemyHp,
                  max: enemyMaxHp,
                  fillColor: AppTheme.gaugeEnemy,
                  height: 6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$enemyHp/$enemyMaxHp',
                style: TextStyle(
                  fontSize: fontSize,
                  color: const Color(0xFFB0B0B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 보스 기믹 뱃지
          if (gimmickTag.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                gimmickTag,
                style: TextStyle(
                  fontSize: ResponsiveScale.scaleFontSize(context, 10),
                  color: const Color(0xFFFFAA44),
                  fontFamily: 'Galmuri11',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
          // 적 의도
          _buildIntent(context, fontSize),
          // 적 상태효과 뱃지 (strength 필드도 포함)
          if (enemyStatuses.isNotEmpty || enemyStrength > 0) ...[
            const SizedBox(height: 4),
            StatusEffectBadgesWidget(statuses: [
              ...enemyStatuses,
              if (enemyStrength > 0)
                StatusEffect(
                  type: StatusEffectType.strength,
                  stacks: enemyStrength,
                ),
            ]),
          ],
          // 환경카드 효과 뱃지
          if (enemyHealBlockedTurns > 0 ||
              enemyStunnedTurns > 0 ||
              enemyDrainBlockedTurns > 0) ...[
            const SizedBox(height: 4),
            _buildEnvironmentBadges(context),
          ],
        ],
      ),
    ),
    );
  }

  Widget _buildIntent(BuildContext context, double fontSize) {
    final showIntent = EnemyAI.shouldShowIntent(
      isElite: enemy.isElite,
      isBoss: isBoss,
      currentTurn: currentTurn,
      intentRevealed: intentRevealed,
    );
    if (showIntent) {
      final nextAction = EnemyAI.getAction(enemy, currentTurn);
      final intentStr = EnemyAI.intentText(enemy, currentTurn, enemyStrength: enemyStrength);
      final icon = _intentIcon(nextAction);
      final color = _intentColor(nextAction);

      return Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              intentStr,
              style: TextStyle(
                fontSize: ResponsiveScale.scaleFontSize(context, 11),
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.help_outline, size: 14, color: Color(0xFF666666)),
        const SizedBox(width: 4),
        Text(
          EnemyAI.hiddenIntentText(enemy),
          style: TextStyle(
            fontSize: ResponsiveScale.scaleFontSize(context, 11),
            color: const Color(0xFF666666),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  IconData _intentIcon(EnemyActionType action) {
    return switch (action) {
      EnemyActionType.attack => Icons.bolt,
      EnemyActionType.heavy => Icons.local_fire_department,
      EnemyActionType.charge => Icons.hourglass_bottom,
      EnemyActionType.defend => Icons.shield,
      EnemyActionType.heal => Icons.favorite,
      EnemyActionType.buff => Icons.arrow_upward,
      EnemyActionType.observe => Icons.visibility,
    };
  }

  Widget _buildEnvironmentBadges(BuildContext context) {
    final badgeFontSize = ResponsiveScale.scaleFontSize(context, 10);
    final badges = <Widget>[];

    if (enemyHealBlockedTurns > 0) {
      badges.add(_envBadge('재생차단 $enemyHealBlockedTurns', const Color(0xFF66BB6A), badgeFontSize));
    }
    if (enemyStunnedTurns > 0) {
      badges.add(_envBadge('기절 $enemyStunnedTurns', const Color(0xFFFFAA44), badgeFontSize));
    }
    if (enemyDrainBlockedTurns > 0) {
      badges.add(_envBadge('흡혈차단 $enemyDrainBlockedTurns', const Color(0xFFFF6B6B), badgeFontSize));
    }

    return Wrap(spacing: 6, runSpacing: 4, children: badges);
  }

  Widget _envBadge(String label, Color color, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontFamily: 'Galmuri11',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _intentColor(EnemyActionType action) {
    return switch (action) {
      EnemyActionType.attack => const Color(0xFFFF6B6B),
      EnemyActionType.heavy => const Color(0xFFFF4444),
      EnemyActionType.charge => const Color(0xFFFFAA44),
      EnemyActionType.defend => const Color(0xFF6B9BFF),
      EnemyActionType.heal => const Color(0xFF66BB6A),
      EnemyActionType.buff => const Color(0xFFFFD700),
      EnemyActionType.observe => const Color(0xFF888888),
    };
  }

}
