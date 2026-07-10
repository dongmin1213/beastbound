import 'package:flutter/material.dart' hide SelectAction;
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_button.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';
import 'package:soul_dungeon/presentation/widgets/shared/rarity_helpers.dart';

enum _NpcView { main, dialogue, trade }

/// NPC 위젯 — "NPC 방" 테두리 프레임.
///
/// StatefulWidget: 내부 뷰 전환 (메인/대화/거래).
/// 순수 presentation — domain 로직 의존 없음.
class NpcWidget extends StatefulWidget {
  final NpcData npc;
  final int playerGold;
  final bool dialogueRead;
  final ValueChanged<int> onPurchase;
  final VoidCallback onReadDialogue;
  final VoidCallback onLeave;
  final Color? frameBackground;

  const NpcWidget({
    super.key,
    required this.npc,
    required this.playerGold,
    required this.dialogueRead,
    required this.onPurchase,
    required this.onReadDialogue,
    required this.onLeave,
    this.frameBackground,
  });

  @override
  State<NpcWidget> createState() => _NpcWidgetState();
}

class _NpcWidgetState extends State<NpcWidget> {
  _NpcView _currentView = _NpcView.main;

  Color _npcTypeColor() {
    return switch (widget.npc.npcType) {
      NpcType.trader => AppTheme.npcTraderColor,
      NpcType.sage => AppTheme.npcSageColor,
      NpcType.wanderer => AppTheme.npcWandererColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return RetroWindowFrame(
      title: 'NPC 방',
      borderColor: AppTheme.npcFrameColor,
      titleBarColor: const Color(0xFF1A2A1A),
      backgroundColor: widget.frameBackground ?? const Color(0xFF0D0D14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: switch (_currentView) {
          _NpcView.main => _buildMainView(context),
          _NpcView.dialogue => _buildDialogueView(context),
          _NpcView.trade => _buildTradeView(context),
        },
      ),
    );
  }

  Widget _buildMainView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.npc.name,
          style: TextStyle(
            color: _npcTypeColor(),
            fontSize: ResponsiveScale.scaleFontSize(context, 15),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.npc.greetingText,
          style: TextStyle(
            color: AppTheme.npcDialogueColor,
            fontSize: ResponsiveScale.scaleFontSize(context, 13),
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        // sage/wanderer 대화 보상 힌트
        if (!widget.npc.hasTradeItems && widget.npc.hasDialogueReward) ...[
          const SizedBox(height: 8),
          Text(
            '대화하면 보상을 받을 수 있을 것 같다.',
            style: TextStyle(
              color: AppTheme.npcGoldColor,
              fontSize: ResponsiveScale.scaleFontSize(context, 12),
              fontStyle: FontStyle.italic,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RetroButton(
              label: '대화하기',
              onTap: () {
                widget.onReadDialogue();
                setState(() => _currentView = _NpcView.dialogue);
              },
              backgroundColor: const Color(0xFF1A2A1A),
              borderColor: AppTheme.npcFrameColor.withValues(alpha: 0.5),
              textColor: AppTheme.choiceCardText,
              fontSize: ResponsiveScale.scaleFontSize(context, 13),
            ),
            if (widget.npc.hasTradeItems) ...[
              const SizedBox(width: 8),
              RetroButton(
                label: '거래하기',
                onTap: () {
                  setState(() => _currentView = _NpcView.trade);
                },
                backgroundColor: const Color(0xFF1A2A1A),
                borderColor: AppTheme.npcFrameColor.withValues(alpha: 0.5),
                textColor: AppTheme.choiceCardText,
                fontSize: ResponsiveScale.scaleFontSize(context, 13),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        RetroButton(
          label: '떠나기',
          onTap: widget.onLeave,
          backgroundColor: const Color(0xFF1A2A1A),
          borderColor: AppTheme.npcFrameColor.withValues(alpha: 0.5),
          textColor: AppTheme.choiceCardText,
          fontSize: ResponsiveScale.scaleFontSize(context, 13),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildDialogueView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.npc.name,
          style: TextStyle(
            color: _npcTypeColor(),
            fontSize: ResponsiveScale.scaleFontSize(context, 15),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.npc.dialogueText,
          style: TextStyle(
            color: AppTheme.npcDialogueColor,
            fontSize: ResponsiveScale.scaleFontSize(context, 13),
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.npc.hasDialogueReward) ...[
          const SizedBox(height: 10),
          ..._buildRewardTexts(context),
        ],
        const SizedBox(height: 16),
        RetroButton(
          label: '돌아가기',
          onTap: () {
            setState(() => _currentView = _NpcView.main);
          },
          backgroundColor: const Color(0xFF1A2A1A),
          borderColor: AppTheme.npcFrameColor.withValues(alpha: 0.5),
          textColor: AppTheme.choiceCardText,
          fontSize: ResponsiveScale.scaleFontSize(context, 13),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildTradeView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.npc.name}의 물품',
          style: TextStyle(
            color: _npcTypeColor(),
            fontSize: ResponsiveScale.scaleFontSize(context, 14),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '보유 금화: ${widget.playerGold}',
          style: TextStyle(
            color: AppTheme.npcGoldColor,
            fontSize: ResponsiveScale.scaleFontSize(context, 13),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(widget.npc.tradeItems.length, (index) {
          final item = widget.npc.tradeItems[index];
          return _buildItemCard(context, item, index);
        }),
        const SizedBox(height: 8),
        RetroButton(
          label: '돌아가기',
          onTap: () {
            setState(() => _currentView = _NpcView.main);
          },
          backgroundColor: const Color(0xFF1A2A1A),
          borderColor: AppTheme.npcFrameColor.withValues(alpha: 0.5),
          textColor: AppTheme.choiceCardText,
          fontSize: ResponsiveScale.scaleFontSize(context, 13),
          fullWidth: true,
        ),
      ],
    );
  }

  List<Widget> _buildRewardTexts(BuildContext context) {
    final npc = widget.npc;
    final rewardStyle = TextStyle(
      color: AppTheme.npcGoldColor,
      fontSize: ResponsiveScale.scaleFontSize(context, 13),
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    );
    final parts = <String>[];
    if (npc.goldReward > 0) parts.add('${npc.goldReward} 골드');
    for (final e in npc.dispositionRewards.entries) {
      parts.add('${e.key.displayName} +${e.value}');
    }
    if (npc.upgradeRandomCard) parts.add('카드 강화');

    return [
      Text(
        '${parts.join(' / ')}를 받았다!',
        style: rewardStyle,
        textAlign: TextAlign.center,
      ),
    ];
  }

  Widget _buildItemCard(BuildContext context, ShopItem item, int index) {
    final canBuy = !item.sold && widget.playerGold >= item.price;
    final itemColor = rarityColor(item.rarity);

    return Opacity(
      opacity: item.sold ? 0.4 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: itemColor.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(2),
          color: item.sold ? AppTheme.shopSoldOverlay : AppTheme.npcItemCardBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: ResponsiveScale.scaleFontSize(context, 13),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      decoration: item.sold ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Text(
                  '[${rarityLabel(item.rarity)}]',
                  style: TextStyle(
                    color: itemColor,
                    fontSize: ResponsiveScale.scaleFontSize(context, 11),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(
                color: AppTheme.shopRarityCommonColor,
                fontSize: ResponsiveScale.scaleFontSize(context, 12),
                fontFamily: 'monospace',
                decoration: item.sold ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${item.price}',
                  style: TextStyle(
                    color: AppTheme.npcGoldColor,
                    fontSize: ResponsiveScale.scaleFontSize(context, 12),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                RetroButton(
                  label: item.sold
                      ? '완료'
                      : (widget.playerGold >= item.price ? '구매' : '부족'),
                  onTap: canBuy ? () => widget.onPurchase(index) : null,
                  enabled: canBuy,
                  backgroundColor: canBuy
                      ? AppTheme.npcBuyButtonColor
                      : AppTheme.npcButtonColor,
                  borderColor: canBuy
                      ? AppTheme.npcBuyButtonColor
                      : AppTheme.npcButtonColor,
                  fontSize: ResponsiveScale.scaleFontSize(context, 11),
                  height: 28,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
