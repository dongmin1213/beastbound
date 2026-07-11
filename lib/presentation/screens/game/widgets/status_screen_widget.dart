import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/build/logic/build_archetype_detector.dart';
import 'package:soul_dungeon/core/models/card_blessing_data.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/card_relic_data.dart';
import 'package:soul_dungeon/core/models/curse_data.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/presentation/screens/game/deck_view_handler.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';
import 'package:soul_dungeon/presentation/widgets/common/programmatic_job_icon.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/gauge_bar.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/card_detail_overlay.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';
import 'package:soul_dungeon/presentation/widgets/shared/rarity_helpers.dart';

/// 풀 스탯 화면 — 플레이어 빌드 상태 전체 표시.
class StatusScreenWidget extends StatelessWidget {
  final PlayerRunState runState;
  final List<CardBlessingData> blessings;
  final List<CardRelicData> relics;
  final List<CurseData> curses;

  const StatusScreenWidget({
    super.key,
    required this.runState,
    required this.blessings,
    required this.relics,
    required this.curses,
  });

  static const _dividerColor = Color(0xFF2A2A3A);
  static const _textPrimary = Color(0xFFE0E0E0);
  static const _textSecondary = Color(0xFF888888);
  static const _textMuted = Color(0xFF555555);


  @override
  Widget build(BuildContext context) {
    final jobName = _resolveJobName(runState.currentJobId);
    final subtitle =
        '$jobName  ${runState.currentFloor}층  G: ${runState.gold}';

    final floorVisuals = FloorThemeVisuals.fromFloor(runState.currentFloor);

    return RetroWindowFrame(
      title: 'SOUL STATUS — $subtitle',
      titleBarColor: floorVisuals.combatUiTint,
      borderColor: AppTheme.titleGold,
      backgroundColor: floorVisuals.frameBackground,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlayerInfo(context),
                  _buildBuildArchetype(context),
                  // 성향(disposition) 시스템 폐기 — 몬스터 패시브로 대체.
                  _buildSectionDivider(context, '덱'),
                  _buildDeck(context),
                  if (blessings.isNotEmpty) ...[
                    _buildSectionDivider(context, '축복'),
                    _buildBlessings(context),
                  ],
                  if (relics.isNotEmpty) ...[
                    _buildSectionDivider(context, '유물'),
                    _buildRelics(context),
                  ],
                  if (curses.isNotEmpty) ...[
                    _buildSectionDivider(context, '저주'),
                    _buildCurses(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Player Info ──

  Widget _buildPlayerInfo(BuildContext context) {
    final isLowHp = runState.currentHp <= (runState.maxHp * 0.3).ceil();
    final fontSize = ResponsiveScale.scaleFontSize(context, 12);

    return Semantics(
      label: 'HP ${runState.currentHp}/${runState.maxHp}, ${runState.gold}골드, 직업: ${_resolveJobName(runState.currentJobId)}, ${runState.currentFloor}층',
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              PixelArtIcon(PixelArtAssets.hpIcon, size: fontSize),
              const SizedBox(width: 4),
              Text(
                '${runState.currentHp}/${runState.maxHp}',
                style: TextStyle(
                  color: isLowHp ? AppTheme.gaugeHp : AppTheme.gaugeHpSafe,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GaugeBar(
                  current: runState.currentHp,
                  max: runState.maxHp,
                  fillColor: AppTheme.gaugeHp,
                  height: 6,
                  pulsing: isLowHp,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${runState.currentFloor}층',
                style: TextStyle(color: _textSecondary, fontSize: fontSize),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              PixelArtIcon(PixelArtAssets.goldIcon, size: fontSize),
              const SizedBox(width: 4),
              Text(
                '${runState.gold} 골드',
                style: TextStyle(
                  color: AppTheme.shopGoldColor,
                  fontSize: fontSize,
                ),
              ),
              const SizedBox(width: 16),
              if (runState.currentJobId != null) ...[
                if (PixelArtAssets.jobSprite(runState.currentJobId!) != null) ...[
                  PixelArtIcon(
                    PixelArtAssets.jobSprite(runState.currentJobId!)!,
                    size: fontSize + 4,
                  ),
                  const SizedBox(width: 4),
                ] else ...[
                  Builder(builder: (context) {
                    final job = JobPath.values
                        .where((j) => j.id == runState.currentJobId)
                        .firstOrNull;
                    if (job != null && job.tier == 2) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ProgrammaticJobIcon(
                          job: job,
                          size: fontSize + 4,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ],
              Text(
                '직업: ${_resolveJobName(runState.currentJobId)}',
                style: TextStyle(
                  color: runState.currentJobId != null
                      ? AppTheme.titleGold
                      : _textMuted,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  // ── Build Archetype ──

  Widget _buildBuildArchetype(BuildContext context) {
    final deck = runState.effectiveDeck;
    if (deck.isEmpty) return const SizedBox.shrink();

    final result = BuildArchetypeDetector.detect(deck, runState.currentJobId);
    final fontSize = ResponsiveScale.scaleFontSize(context, 11);

    final floorTint = FloorThemeVisuals.fromFloor(runState.currentFloor).combatUiTint;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: floorTint,
          borderRadius: BorderRadius.circular(4),
          border: const Border(
            left: BorderSide(color: AppTheme.titleGold, width: 2),
          ),
        ),
        child: Text(
          '현재 빌드: ${result.formatted()}',
          style: TextStyle(
            color: AppTheme.titleGold,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Disposition ──


  // ── Deck ──

  Widget _buildDeck(BuildContext context) {
    final deck = runState.effectiveDeck;
    final fontSize = ResponsiveScale.scaleFontSize(context, 11);

    if (deck.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '미분화 — 전투 시 기본 덱(10장)이 생성됩니다.',
          style: TextStyle(color: _textMuted, fontSize: fontSize),
        ),
      );
    }

    final stats = DeckViewHandler.formatDeckStats(deck);
    final cardLines = DeckViewHandler.formatDeckList(deck);
    // 정렬된 덱 — cardLines와 동일한 순서
    final sortedDeck = List<CardData>.from(deck)
      ..sort((a, b) => a.type.index.compareTo(b.type.index));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stats,
            style: TextStyle(
              color: _textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (runState.removedCardIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '제거: ${runState.removedCardIds.length}장',
                style: TextStyle(color: _textMuted, fontSize: fontSize),
              ),
            ),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: FloorThemeVisuals.fromFloor(runState.currentFloor).combatUiTint,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < cardLines.length; i++)
                    GestureDetector(
                      onTap: () => CardDetailOverlay.show(context, sortedDeck[i]),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: i < cardLines.length - 1 ? 3 : 0),
                        child: Text(
                          cardLines[i],
                          style: TextStyle(
                            color: _cardColor(sortedDeck[i].type),
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Blessings ──

  Widget _buildBlessings(BuildContext context) {
    return _buildItemList(
      context,
      items: blessings.map((b) => _ItemData(
        name: b.name,
        description: b.description,
        rarity: b.rarity,
      )).toList(),
    );
  }

  // ── Relics ──

  Widget _buildRelics(BuildContext context) {
    return _buildItemList(
      context,
      items: relics.map((r) => _ItemData(
        name: r.name,
        description: r.description,
        rarity: r.rarity,
      )).toList(),
    );
  }

  // ── Curses ──

  Widget _buildCurses(BuildContext context) {
    return _buildItemList(
      context,
      items: curses.map((c) => _ItemData(
        name: c.name,
        description: c.description,
        rarity: c.rarity,
      )).toList(),
      tintColor: const Color(0x1AEF5350),
    );
  }

  // ── Shared ──

  Widget _buildItemList(
    BuildContext context, {
    required List<_ItemData> items,
    Color? tintColor,
  }) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 11);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tintColor ?? FloorThemeVisuals.fromFloor(runState.currentFloor).combatUiTint,
                borderRadius: BorderRadius.circular(4),
                border: Border(
                  left: BorderSide(
                    color: rarityColor(item.rarity),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '[${rarityLabel(item.rarity)}] ',
                    style: TextStyle(
                      color: rarityColor(item.rarity),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: item.name,
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' — ${item.description}',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider(color: _dividerColor, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: TextStyle(
                color: _textSecondary,
                fontSize: ResponsiveScale.scaleFontSize(context, 10),
                letterSpacing: 1,
              ),
            ),
          ),
          const Expanded(child: Divider(color: _dividerColor, thickness: 1)),
        ],
      ),
    );
  }

  // ── Helpers ──

  String _resolveJobName(String? jobId) {
    if (jobId == null) return '미분화';
    try {
      return JobPath.values.firstWhere((j) => j.id == jobId).displayName;
    } catch (e) {
      GameLogger.warning(LogSystem.ui, 'Unknown jobId: $jobId ($e)');
      return jobId;
    }
  }

  Color _cardColor(CardType type) {
    return switch (type) {
      CardType.attack => AppTheme.cardAttackColor,
      CardType.skill => AppTheme.cardSkillColor,
      CardType.power => AppTheme.cardPowerColor,
    };
  }
}

class _ItemData {
  final String name;
  final String description;
  final Rarity rarity;

  const _ItemData({
    required this.name,
    required this.description,
    required this.rarity,
  });
}
