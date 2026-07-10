import 'dart:math';

import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/combat/logic/enemy_ai.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/domain/combat/models/enemy_battle_state.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/animated_boss_sprite.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/gauge_bar.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/status_effect_badges_widget.dart';

/// 멀티몹 전투 상단 — 적 목록 + HP + 의도 + 타겟 선택.
///
/// 단일 적일 때는 기존 EnemyAreaWidget과 동일한 레이아웃,
/// 멀티몹일 때 각 적을 행으로 표시 + 탭으로 타겟 선택.
class MultiEnemyAreaWidget extends StatelessWidget {
  final List<EnemyBattleState> enemies;
  final int selectedTargetIndex;
  final int currentTurn;
  final bool intentRevealed;
  final bool isBoss;
  final BossCombatData? bossData;
  final int currentBossPhase;
  final ValueChanged<int> onSelectTarget;

  /// 보스 기믹 태그 텍스트.
  final String gimmickTag;

  const MultiEnemyAreaWidget({
    super.key,
    required this.enemies,
    required this.selectedTargetIndex,
    required this.currentTurn,
    required this.intentRevealed,
    required this.onSelectTarget,
    this.isBoss = false,
    this.bossData,
    this.currentBossPhase = 0,
    this.gimmickTag = '',
  });

  /// 적이 2마리 이상이면 컴팩트 모드.
  bool get _compact => enemies.length >= 2;

  @override
  Widget build(BuildContext context) {
    final hPadding = ResponsiveScale.scalePadding(context, 12);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: _compact ? 2 : 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1마리: 기존 세로 레이아웃, 2마리+: 가로 그리드 (한 줄 최대 2)
          if (enemies.length <= 1)
            for (var i = 0; i < enemies.length; i++) _buildEnemyRow(context, i)
          else
            ..._buildEnemyGrid(context),
          // 보스 기믹 뱃지 (단일 보스)
          if (gimmickTag.isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                gimmickTag,
                style: TextStyle(
                  fontSize: ResponsiveScale.scaleFontSize(context, 10),
                  color: const Color(0xFFFFAA44),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 2마리 이상일 때 가로 그리드 배치 (한 줄 최대 2마리)
  List<Widget> _buildEnemyGrid(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < enemies.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 4));
      final hasSecond = i + 1 < enemies.length;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildEnemyRow(context, i)),
            if (hasSecond) ...[
              const SizedBox(width: 6),
              Expanded(child: _buildEnemyRow(context, i + 1)),
            ] else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
    }
    return rows;
  }

  Widget _buildEnemyRow(BuildContext context, int index) {
    final enemy = enemies[index];
    final isSelected = index == selectedTargetIndex;
    final isDead = enemy.isDead;
    final fontSize = ResponsiveScale.scaleFontSize(context, 12);
    final displayHp = max(0, enemy.currentHp);

    final spritePath = isBoss
        ? PixelArtAssets.bossSprite(enemy.data.id)
        : PixelArtAssets.enemySprite(enemy.data.id);

    final nameColor = isBoss
        ? const Color(0xFFFFD700)
        : enemy.data.isElite
            ? const Color(0xFFFF6B6B)
            : const Color(0xFFE0E0E0);

    final semanticLabel = isDead
        ? '${enemy.data.name}, 쓰러짐'
        : '${enemy.data.name}, HP $displayHp/${enemy.maxHp}${isSelected ? ", 선택됨" : ""}';

    return Semantics(
      button: !isDead && enemies.length > 1,
      label: semanticLabel,
      child: GestureDetector(
      onTap: isDead ? null : () => onSelectTarget(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDead ? 0.4 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: _compact ? 2 : 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: enemies.length > 1 && isSelected && !isDead
                ? Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 적 스프라이트 + 이름
              Row(
                children: [
                  if (spritePath != null) ...[
                    if (isBoss)
                      AnimatedBossSprite(assetPath: spritePath, size: _compact ? 32 : 48)
                    else
                      Image.asset(
                        spritePath,
                        width: _compact ? 24 : 36,
                        height: _compact ? 24 : 36,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    SizedBox(width: _compact ? 4 : 6),
                  ],
                  Expanded(
                    child: Text(
                      isDead ? '${enemy.data.name} (쓰러짐)' : enemy.data.name,
                      style: TextStyle(
                        fontSize: ResponsiveScale.scaleFontSize(context, _compact ? 11 : 13),
                        color: isDead ? nameColor.withValues(alpha: 0.5) : nameColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: _compact ? 1 : 2),
              // HP 바 + 블록
              Row(
                children: [
                  if (enemies.length > 1 && !_compact) const SizedBox(width: 16),
                  if (enemy.block > 0 && !isDead) ...[
                    Text(
                      '\u{1F6E1} ${enemy.block}',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: AppTheme.gaugeBlock,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: GaugeBar(
                      current: displayHp,
                      max: enemy.maxHp,
                      fillColor: AppTheme.gaugeEnemy,
                      height: _compact ? 4 : 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$displayHp/${enemy.maxHp}',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: const Color(0xFFB0B0B0),
                    ),
                  ),
                ],
              ),
              // 적 의도 (죽은 적은 표시 안함)
              if (!isDead) ...[
                SizedBox(height: _compact ? 1 : 2),
                _buildIntent(context, index, fontSize),
              ],
              // 적 상태효과 뱃지 (strength 필드도 포함)
              if ((enemy.statuses.isNotEmpty || enemy.strength > 0) && !isDead) ...[
                SizedBox(height: _compact ? 2 : 4),
                Row(
                  children: [
                    if (enemies.length > 1 && !_compact) const SizedBox(width: 16),
                    Expanded(
                      child: StatusEffectBadgesWidget(statuses: [
                        ...enemy.statuses,
                        if (enemy.strength > 0)
                          StatusEffect(
                            type: StatusEffectType.strength,
                            stacks: enemy.strength,
                          ),
                      ]),
                    ),
                  ],
                ),
              ],
              // 환경카드 효과 뱃지
              if (!isDead &&
                  (enemy.healBlockedTurns > 0 ||
                      enemy.stunnedTurns > 0 ||
                      enemy.drainBlockedTurns > 0)) ...[
                SizedBox(height: _compact ? 2 : 4),
                Row(
                  children: [
                    if (enemies.length > 1 && !_compact) const SizedBox(width: 16),
                    Expanded(child: _buildEnvironmentBadges(context, enemy)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildIntent(BuildContext context, int index, double fontSize) {
    final enemy = enemies[index];
    final showIntent = EnemyAI.shouldShowIntent(
      isElite: enemy.data.isElite,
      isBoss: isBoss,
      currentTurn: currentTurn,
      intentRevealed: intentRevealed,
    );

    final leftPad = (enemies.length > 1 && !_compact)
        ? const SizedBox(width: 16)
        : const SizedBox.shrink();

    if (showIntent) {
      final nextAction = EnemyAI.getAction(
        enemy.data, currentTurn,
        patternOffset: enemy.patternOffset,
      );
      final intentStr = EnemyAI.intentText(
        enemy.data,
        currentTurn,
        enemyStrength: enemy.strength,
        patternOffset: enemy.patternOffset,
      );
      final icon = _intentIcon(nextAction);
      final color = _intentColor(nextAction);

      return Row(
        children: [
          leftPad,
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
        leftPad,
        const Icon(Icons.help_outline, size: 14, color: Color(0xFF666666)),
        const SizedBox(width: 4),
        Text(
          EnemyAI.hiddenIntentText(enemy.data),
          style: TextStyle(
            fontSize: ResponsiveScale.scaleFontSize(context, 11),
            color: const Color(0xFF666666),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentBadges(BuildContext context, EnemyBattleState enemy) {
    final badgeFontSize = ResponsiveScale.scaleFontSize(context, 10);
    final badges = <Widget>[];

    if (enemy.healBlockedTurns > 0) {
      badges.add(_envBadge(
        '재생차단 ${enemy.healBlockedTurns}',
        const Color(0xFF66BB6A),
        badgeFontSize,
      ));
    }
    if (enemy.stunnedTurns > 0) {
      badges.add(_envBadge(
        '기절 ${enemy.stunnedTurns}',
        const Color(0xFFFFAA44),
        badgeFontSize,
      ));
    }
    if (enemy.drainBlockedTurns > 0) {
      badges.add(_envBadge(
        '흡혈차단 ${enemy.drainBlockedTurns}',
        const Color(0xFFFF6B6B),
        badgeFontSize,
      ));
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
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
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
