import 'package:flutter/material.dart';

import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/gauge_bar.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';

/// 멀티몹 적 표시 데이터.
class EnemyHudData {
  final String name;
  final int hp;
  final int maxHp;
  final bool isSelected;
  final bool isDead;

  const EnemyHudData({
    required this.name,
    required this.hp,
    required this.maxHp,
    this.isSelected = false,
    this.isDead = false,
  });
}

/// 카드 전투 중 화면 상단에 고정되는 HUD.
///
/// 3+ 행 구조:
///  1행: 플레이어 HP 수치 + 게이지 바 + 턴 수
///  2행: AP 다이아몬드 (◆/◇)
///  3행~: 적 이름 + 적 HP 게이지 바 (멀티몹 시 적 수만큼 표시)
class CombatHudWidget extends StatelessWidget {
  final int playerHp;
  final int playerMaxHp;
  final int playerBlock;
  final int actionPoints;
  final int maxActionPoints;
  final int currentTurn;

  /// 멀티몹 적 목록. 제공 시 enemyName/enemyHp/enemyMaxHp 무시.
  final List<EnemyHudData>? enemies;

  /// 하위 호환 단일 적 파라미터.
  final String? enemyName;
  final int? enemyHp;
  final int? enemyMaxHp;

  const CombatHudWidget({
    super.key,
    required this.playerHp,
    required this.playerMaxHp,
    required this.playerBlock,
    required this.actionPoints,
    required this.maxActionPoints,
    required this.currentTurn,
    this.enemies,
    this.enemyName,
    this.enemyHp,
    this.enemyMaxHp,
  });

  static const _bgColor = Color(0xFF0D0D1A);
  static const _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 12);
    final hPadding = ResponsiveScale.scalePadding(context, 16);
    final isLowHp = playerHp <= (playerMaxHp * 0.3).ceil();

    final blockLabel = playerBlock > 0 ? ', 방어 $playerBlock' : '';
    return Semantics(
      label: 'HP $playerHp/$playerMaxHp$blockLabel, AP $actionPoints/$maxActionPoints, $currentTurn턴',
      child: Container(
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1행: 플레이어 HP + 게이지 + 턴
          Row(
            children: [
              PixelArtIcon(PixelArtAssets.hpIcon, size: fontSize),
              const SizedBox(width: 4),
              Text(
                '$playerHp/$playerMaxHp',
                style: TextStyle(
                  fontSize: fontSize,
                  color: isLowHp ? AppTheme.gaugeHp : AppTheme.gaugeHpSafe,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (playerBlock > 0) ...[
                const SizedBox(width: 6),
                PixelArtIcon(PixelArtAssets.blockIcon, size: fontSize),
                const SizedBox(width: 2),
                Text(
                  '$playerBlock',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppTheme.gaugeBlock,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: GaugeBar(
                  current: playerHp,
                  max: playerMaxHp,
                  fillColor: AppTheme.gaugeHp,
                  height: 8,
                  pulsing: isLowHp,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$currentTurn턴',
                style: TextStyle(
                  fontSize: fontSize,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 2행: AP 다이아몬드
          Row(
            children: [
              for (int i = 0; i < maxActionPoints; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Opacity(
                  opacity: i < actionPoints ? 1.0 : 0.3,
                  child: PixelArtIcon(
                    PixelArtAssets.apIcon,
                    size: fontSize,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // 3행~: 적 HP (멀티몹 지원)
          ..._buildEnemyRows(fontSize),
        ],
      ),
    ),
    );
  }

  List<Widget> _buildEnemyRows(double fontSize) {
    final enemyList = enemies ??
        (enemyName != null
            ? [EnemyHudData(
                name: enemyName!,
                hp: enemyHp ?? 0,
                maxHp: enemyMaxHp ?? 1,
                isSelected: true,
              )]
            : const <EnemyHudData>[]);

    return [
      for (var i = 0; i < enemyList.length; i++) ...[
        if (i > 0) const SizedBox(height: 2),
        _buildEnemyRow(enemyList[i], fontSize),
      ],
    ];
  }

  Widget _buildEnemyRow(EnemyHudData enemy, double fontSize) {
    final nameColor = enemy.isDead
        ? const Color(0xFF555555)
        : enemy.isSelected
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF888888);
    final hpColor = enemy.isDead
        ? const Color(0xFF555555)
        : const Color(0xFFB0B0B0);
    final gaugeColor = enemy.isDead
        ? const Color(0xFF444444)
        : enemy.isSelected
            ? AppTheme.gaugeEnemy
            : AppTheme.gaugeEnemy.withAlpha(180);

    return Row(
      children: [
        if (enemy.isSelected && !enemy.isDead)
          Text(
            '\u25B6 ',
            style: TextStyle(fontSize: fontSize - 2, color: nameColor),
          ),
        Text(
          enemy.isDead ? '${enemy.name} (쓰러짐)' : enemy.name,
          style: TextStyle(
            fontSize: fontSize,
            color: nameColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GaugeBar(
            current: enemy.isDead ? 0 : enemy.hp,
            max: enemy.maxHp,
            fillColor: gaugeColor,
            height: 6,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${enemy.hp}/${enemy.maxHp}',
          style: TextStyle(
            fontSize: fontSize,
            color: hpColor,
          ),
        ),
      ],
    );
  }
}
