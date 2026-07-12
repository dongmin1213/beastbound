import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/card_detail_overlay.dart';

enum ChoiceCardState { idle, selected, disabled, played }

class ChoiceCardWidget extends StatelessWidget {
  final ChoiceData choice;
  final ChoiceCardState state;
  final ValueChanged<ChoiceData> onTap;
  final int currentFloor;

  const ChoiceCardWidget({
    super.key,
    required this.choice,
    required this.state,
    required this.onTap,
    this.currentFloor = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (choice.isCard) return _buildCombatCard(context);
    return _buildTextChoice(context);
  }

  // ── 비전투 선택지 (스타일 위계 적용) ──

  Widget _buildTextChoice(BuildContext context) {
    final isSelected = state == ChoiceCardState.selected;
    final style = choice.choiceStyle;

    return Semantics(
      button: true,
      label: choice.text,
      enabled: state == ChoiceCardState.idle,
      child: GestureDetector(
        onTap: state == ChoiceCardState.idle ? () => onTap(choice) : null,
        child: AnimatedOpacity(
          opacity: state == ChoiceCardState.disabled
              ? AppTheme.choiceDisabledOpacity
              : 1.0,
          duration: const Duration(milliseconds: 200),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Container(
              padding: EdgeInsets.zero,
              decoration: _textChoiceDecoration(isSelected, style),
              child: _buildTextChoiceInner(context, isSelected, style),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _textChoiceDecoration(bool isSelected, ChoiceStyle style) {
    final floorVisuals = FloorThemeVisuals.fromFloor(currentFloor);
    final floorBg = floorVisuals.frameBackground;
    final floorTint = floorVisuals.combatUiTint;
    final floorBorder = floorVisuals.combatFleeBorder;

    // GBC식 둥근 버튼: 큰 라운드 + 두꺼운 테두리 + 단단한 하단 그림자(입체감).
    const radius = 9.0;
    const hardShadow = BoxShadow(
      color: Color(0x66000000),
      blurRadius: 0,
      offset: Offset(0, 2),
    );

    if (isSelected) {
      return BoxDecoration(
        color: AppTheme.choiceSelectedBackground,
        border: Border.all(color: AppTheme.choiceSelectedBorder, width: 2),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [hardShadow],
      );
    }
    return switch (style) {
      ChoiceStyle.normal => BoxDecoration(
          color: floorBg,
          border: Border.all(
            color: floorBorder,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [hardShadow],
        ),
      ChoiceStyle.caution => BoxDecoration(
          color: floorTint,
          border: Border.all(color: floorBorder, width: 1.5),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            hardShadow,
            BoxShadow(
              color: AppTheme.choiceCautionGlow,
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
      ChoiceStyle.reward => BoxDecoration(
          color: floorTint,
          border: Border.all(color: floorBorder, width: 1.5),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [hardShadow],
        ),
    };
  }

  Widget _buildTextChoiceInner(BuildContext context, bool isSelected, ChoiceStyle style) {
    final horizontalPad = ResponsiveScale.scalePadding(context, 16);
    final verticalPad = ResponsiveScale.scaleVerticalPadding(context, 8);

    if (choice.apCost != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: verticalPad),
        child: _buildApBadgeRow(context),
      );
    }

    // normal: 버튼 스타일 (배경 + 테두리)
    if (style == ChoiceStyle.normal && !isSelected) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: verticalPad),
        child: Text(
          choice.text,
          style: AppTheme.scaledChoiceText(context).copyWith(height: 1.4),
        ),
      );
    }

    // caution/reward: 좌측 컬러 바 + 텍스트
    if ((style == ChoiceStyle.caution || style == ChoiceStyle.reward) && !isSelected) {
      final barColor = style == ChoiceStyle.caution
          ? AppTheme.choiceCautionBar
          : AppTheme.choiceRewardBar;
      final textColor = style == ChoiceStyle.reward
          ? AppTheme.choiceRewardText
          : AppTheme.choiceCardText;

      return IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: verticalPad),
                child: Text(
                  choice.text,
                  style: AppTheme.scaledChoiceText(context).copyWith(
                    height: 1.4,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 선택된 상태 (isSelected=true): 기존 스타일
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: verticalPad),
      child: Text(
        choice.text,
        style: AppTheme.scaledChoiceText(context).copyWith(height: 1.4),
      ),
    );
  }

  /// apCost가 있지만 cardType 없는 경우 (레거시 호환용)
  Widget _buildApBadgeRow(BuildContext context) {
    final isEnabled = choice.enabled;
    final badgeColor = isEnabled ? AppTheme.apAvailable : AppTheme.apInsufficient;
    final fontSize = ResponsiveScale.scaleFontSize(context, 11);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.gaugeHpBg,
            shape: BoxShape.circle,
            border: Border.all(color: badgeColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '${choice.apCost}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            choice.text,
            style: AppTheme.scaledChoiceText(context).copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }

  // ── 카드 전투 선택지 (GBC 픽셀 배틀 카드) ──

  Widget _buildCombatCard(BuildContext context) {
    final cardType = choice.cardType!;
    final typeColor = AppTheme.cardTypeColor(cardType);
    final isSelected = state == ChoiceCardState.selected;
    final isDisabled = state == ChoiceCardState.disabled;
    final isPlayed = state == ChoiceCardState.played;
    final isEnabled = choice.enabled;
    final isUpgraded = choice.sourceCard?.upgraded ?? false;

    final opacity = isDisabled || !isEnabled ? 0.45 : 1.0;

    // 카드 이름과 효과 텍스트 분리 (' — '로 구분).
    final parts = choice.text.split(' — ');
    final cardName = parts.first;
    final effectText = parts.length > 1 ? parts.last : null;

    final apColor = isEnabled ? AppTheme.apAvailable : AppTheme.apInsufficient;

    // 이름/테두리 색 — 강화 시 골드, 그 외 타입색.
    final borderColor = isUpgraded ? AppTheme.cardUpgradedBorder : typeColor;
    final nameColor = isUpgraded ? AppTheme.cardUpgradedBorder : typeColor;

    // GBC식 단단한 하단 그림자 + 선택 시 타입색 글로우.
    const hardShadow = BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 3),
      blurRadius: 0,
    );
    final shadows = isSelected
        ? [
            hardShadow,
            BoxShadow(
              color: typeColor.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ]
        : const [hardShadow];

    final cardWidth = ResponsiveScale.scalePadding(context, 96);
    final cardHeight = ResponsiveScale.scaleVerticalPadding(context, 128);

    final Widget card = Semantics(
      button: true,
      label: cardName,
      enabled: state == ChoiceCardState.idle || isSelected,
      child: GestureDetector(
        onTap: (state == ChoiceCardState.idle || isSelected)
            ? () => onTap(choice)
            : null,
        onLongPress: choice.sourceCard != null
            ? () => CardDetailOverlay.show(context, choice.sourceCard!)
            : null,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: isSelected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: cardWidth,
              height: cardHeight,
              margin: EdgeInsets.only(
                top: isSelected ? 0 : 8,
                bottom: isSelected ? 8 : 0,
              ),
              clipBehavior: Clip.none,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                border: Border.all(color: borderColor, width: 2.5),
                borderRadius: BorderRadius.circular(6),
                boxShadow: shadows,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 상단 밴드: 타입색 스트립 (AP 비용 + 타겟 배지) ──
                    Container(
                      height: 22,
                      color: typeColor,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          _buildApBadge(context, apColor),
                          const Spacer(),
                          if (choice.sourceCard != null)
                            _buildTargetBadge(context, typeColor),
                        ],
                      ),
                    ),

                    // ── 본문: 카드 이름 + 효과 텍스트 (텍스트 중심) ──
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 6, 5, 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cardName,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveScale.scaleFontSize(context, 13),
                                fontWeight: FontWeight.w700,
                                color: nameColor,
                                height: 1.2,
                                fontFamily: AppTheme.pixelFont,
                              ),
                            ),
                            if (effectText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  effectText,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: ResponsiveScale.scaleFontSize(
                                        context, 11),
                                    color: const Color(0xFFAAAAAA),
                                    height: 1.2,
                                    fontFamily: AppTheme.pixelFont,
                                  ),
                                ),
                              ),
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '사용',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ResponsiveScale.scaleFontSize(
                                        context, 11),
                                    fontWeight: FontWeight.bold,
                                    color: typeColor,
                                    fontFamily: AppTheme.pixelFont,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // 카드 플레이 시 exit 애니메이션
    if (isPlayed && AppTheme.enableAnimations) {
      return card
          .animate()
          .slideY(begin: 0, end: -0.3, duration: 250.ms, curve: Curves.easeIn)
          .fadeOut(duration: 250.ms);
    }

    return card;
  }

  // ── AP 비용 뱃지 (상단 밴드 좌측, 청키 픽셀) ──

  Widget _buildApBadge(BuildContext context, Color apColor) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 11);
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border.all(color: apColor, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '${choice.apCost}',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: apColor,
          height: 1.0,
          fontFamily: AppTheme.pixelFont,
        ),
      ),
    );
  }

  // ── 타겟 배지 (상단 밴드 우측) ──

  Widget _buildTargetBadge(BuildContext context, Color typeColor) {
    final isAoe = choice.sourceCard?.effectiveTargetType == CardTargetType.all;
    final label = isAoe ? '전체' : '단일';
    final badgeColor = isAoe ? const Color(0xFFFF6B6B) : const Color(0xFF6B9BFF);
    final fontSize = ResponsiveScale.scaleFontSize(context, 8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: badgeColor,
          height: 1.2,
          fontFamily: AppTheme.pixelFont,
        ),
      ),
    );
  }
}
