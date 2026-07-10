import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_event.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_state.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_upgrade_data.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_upgrade_pool.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_button.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 소울 업그레이드 상점 화면 — 영구 메타 진행 업그레이드 구매.
///
/// ProgressionBloc에서 소울 잔액/업그레이드 레벨을 읽고,
/// 구매 시 PurchaseUpgrade 이벤트를 dispatch한다.
class SoulShopScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SoulShopScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Theme(
        data: AppTheme.dark,
        child: Scaffold(
          backgroundColor: AppTheme.screenBackground,
          body: SafeArea(
            child: BlocBuilder<ProgressionBloc, ProgressionState>(
              builder: (context, state) {
                if (state is! ProgressionLoaded) {
                  return const Center(
                    child: Text(
                      '데이터 로딩 중...',
                      style: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }

                return _SoulShopBody(
                  soulCount: state.soulCount,
                  upgradeLevels: state.upgradeLevels,
                  onBack: onBack,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 소울 상점 본문 — 스크롤 가능한 업그레이드 목록.
class _SoulShopBody extends StatelessWidget {
  final int soulCount;
  final Map<String, int> upgradeLevels;
  final VoidCallback onBack;

  const _SoulShopBody({
    required this.soulCount,
    required this.upgradeLevels,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final available = SoulUpgradePool.available(upgradeLevels);
    final completed = SoulUpgradePool.all.where((upgrade) {
      final currentLevel = upgradeLevels[upgrade.id] ?? 0;
      return currentLevel >= upgrade.maxLevel;
    }).toList();

    return Column(
      children: [
        // ── 헤더 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: RetroWindowFrame(
            title: '소울 업그레이드 상점',
            titleBarColor: const Color(0xFF1A1A3E),
            borderColor: _soulAccentColor,
            onClose: onBack,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PixelArtIcon(
                        PixelArtAssets.soulIcon,
                        size: ResponsiveScale.scaleFontSize(context, 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '보유 소울: $soulCount',
                        style: TextStyle(
                          color: _soulAccentColor,
                          fontSize:
                              ResponsiveScale.scaleFontSize(context, 15),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '사망과 클리어를 통해 소울을 모아 영구 강화를 해금하세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF888888),
                      fontSize:
                          ResponsiveScale.scaleFontSize(context, 11),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── 업그레이드 목록 ──
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (available.isNotEmpty) ...[
                _buildSectionLabel(context, '구매 가능'),
                const SizedBox(height: 8),
                ...available.map((upgrade) => _SoulUpgradeCard(
                      upgrade: upgrade,
                      currentLevel: upgradeLevels[upgrade.id] ?? 0,
                      soulCount: soulCount,
                    )),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionLabel(context, '완료'),
                const SizedBox(height: 8),
                ...completed.map((upgrade) => _SoulUpgradeCard(
                      upgrade: upgrade,
                      currentLevel: upgradeLevels[upgrade.id] ?? 0,
                      soulCount: soulCount,
                    )),
              ],
              if (available.isEmpty && completed.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    '아직 해금할 수 있는 업그레이드가 없습니다.\n던전에서 소울을 모아 오세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF666666),
                      fontSize:
                          ResponsiveScale.scaleFontSize(context, 13),
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── 하단 돌아가기 버튼 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: RetroButton(
            label: '돌아가기',
            onTap: onBack,
            fullWidth: true,
            backgroundColor: const Color(0xFF1A1A2E),
            borderColor: const Color(0xFF555555),
            textColor: const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: const Color(0xFF333333)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF888888),
              fontSize: ResponsiveScale.scaleFontSize(context, 11),
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: const Color(0xFF333333)),
        ),
      ],
    );
  }

  static const _soulAccentColor = Color(0xFF9C7CFF);
}

/// 개별 업그레이드 카드 위젯.
class _SoulUpgradeCard extends StatelessWidget {
  final SoulUpgradeData upgrade;
  final int currentLevel;
  final int soulCount;

  const _SoulUpgradeCard({
    required this.upgrade,
    required this.currentLevel,
    required this.soulCount,
  });

  bool get _isMaxed => currentLevel >= upgrade.maxLevel;

  int get _price => _isMaxed
      ? 0
      : SoulCalculator.upgradePrice(
          upgrade.basePrice,
          currentLevel,
          upgrade.priceExponent,
        );

  bool get _canAfford => !_isMaxed && soulCount >= _price;

  Color get _borderColor {
    if (_isMaxed) return const Color(0xFF4A4A4A);
    if (_canAfford) return const Color(0xFF9C7CFF);
    return const Color(0xFF555555);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isMaxed ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor, width: 1),
          borderRadius: BorderRadius.circular(2),
          color: _isMaxed
              ? const Color(0xFF0A0A14)
              : const Color(0xFF12122A),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 이름 + 레벨 ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    upgrade.name,
                    style: TextStyle(
                      color: _isMaxed
                          ? const Color(0xFF888888)
                          : const Color(0xFFE0E0E0),
                      fontSize:
                          ResponsiveScale.scaleFontSize(context, 14),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      decoration:
                          _isMaxed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (upgrade.maxLevel > 1)
                  Text(
                    'Lv.$currentLevel/${upgrade.maxLevel}',
                    style: TextStyle(
                      color: _isMaxed
                          ? const Color(0xFF666666)
                          : const Color(0xFF9C7CFF),
                      fontSize:
                          ResponsiveScale.scaleFontSize(context, 11),
                      fontFamily: 'monospace',
                    ),
                  ),
                if (_isMaxed && upgrade.maxLevel <= 1)
                  Text(
                    '해금 완료',
                    style: TextStyle(
                      color: const Color(0xFF666666),
                      fontSize:
                          ResponsiveScale.scaleFontSize(context, 11),
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // ── 설명 ──
            Text(
              upgrade.description,
              style: TextStyle(
                color: const Color(0xFFB0B0B0),
                fontSize: ResponsiveScale.scaleFontSize(context, 12),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),

            // ── 가격 + 구매 버튼 ──
            if (!_isMaxed)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PixelArtIcon(
                    PixelArtAssets.soulIcon,
                    size: ResponsiveScale.scaleFontSize(context, 13),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$_price',
                    style: TextStyle(
                      color: _canAfford
                          ? const Color(0xFF9C7CFF)
                          : const Color(0xFF666666),
                      fontSize:
                          ResponsiveScale.scaleFontSize(context, 13),
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  RetroButton(
                    label: _canAfford ? '구매' : '부족',
                    enabled: _canAfford,
                    onTap: _canAfford
                        ? () => _onPurchase(context)
                        : null,
                    backgroundColor: _canAfford
                        ? const Color(0xFF2A1A4E)
                        : const Color(0xFF1A1A2E),
                    borderColor: _canAfford
                        ? const Color(0xFF9C7CFF)
                        : const Color(0xFF444444),
                    textColor: _canAfford
                        ? const Color(0xFFE0E0E0)
                        : const Color(0xFF666666),
                    fontSize:
                        ResponsiveScale.scaleFontSize(context, 11),
                    height: 28,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 0,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _onPurchase(BuildContext context) {
    GameLogger.info(
      LogSystem.progression,
      'Soul upgrade purchase: ${upgrade.id} '
      '(level $currentLevel -> ${currentLevel + 1}, cost: $_price)',
    );
    context.read<ProgressionBloc>().add(PurchaseUpgrade(upgrade.id));
  }
}
