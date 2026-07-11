import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/choice/card_icon_mapper.dart';
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

  // ── 카드 전투 선택지 (프리미엄 카드 레이아웃) ──

  Widget _buildCombatCard(BuildContext context) {
    final cardType = choice.cardType!;
    final typeColor = AppTheme.cardTypeColor(cardType);
    final isSelected = state == ChoiceCardState.selected;
    final isDisabled = state == ChoiceCardState.disabled;
    final isPlayed = state == ChoiceCardState.played;
    final isEnabled = choice.enabled;
    final isUpgraded = choice.sourceCard?.upgraded ?? false;

    final opacity = isDisabled || !isEnabled ? 0.45 : 1.0;

    // 카드 이름과 효과 텍스트 분리
    final parts = choice.text.split(' \u2014 ');
    final cardName = parts.first;
    final effectText = parts.length > 1 ? parts.last : null;

    final apColor = isEnabled ? AppTheme.apAvailable : AppTheme.apInsufficient;

    // 테두리 색상
    final borderColor = isUpgraded
        ? AppTheme.cardUpgradedBorder
        : isSelected
            ? typeColor
            : AppTheme.cardBorderDefault;

    // 선택 시 글로우 그림자
    final shadows = isSelected
        ? [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ]
        : isUpgraded
            ? [
                BoxShadow(
                  color: AppTheme.cardUpgradedBorder.withValues(alpha: 0.2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ]
            : <BoxShadow>[];

    final cardWidth = ResponsiveScale.scalePadding(context, 100);
    final cardHeight = ResponsiveScale.scaleVerticalPadding(context, 125);

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
              border: Border.all(
                color: borderColor,
                width: isSelected || isUpgraded ? 2.0 : 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: shadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 아트 영역 (아이콘 + glow, 프레임 제거) ──
                Expanded(
                  child: Stack(
                    children: [
                      // 배경 타입색 틴트
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // 아이콘 (크게, 중앙)
                      Center(
                        child: _buildCardIcon(context, cardType, typeColor),
                      ),
                      // AP 다이아몬드 뱃지 (좌상단)
                      Positioned(
                        left: 3,
                        top: 3,
                        child: _buildApDiamond(context, apColor),
                      ),
                      // 타겟 배지 (우상단) — 단일/전체
                      if (choice.sourceCard != null)
                        Positioned(
                          right: 3,
                          top: 3,
                          child: _buildTargetBadge(context, typeColor),
                        ),
                    ],
                  ),
                ),

                // ── 하단 정보 영역 (타입색 배경) ──
                Container(
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    border: Border(
                      top: BorderSide(
                        color: typeColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: Column(
                    children: [
                      // 카드 이름
                      Text(
                        cardName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                              ResponsiveScale.scaleFontSize(context, 13),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      // 효과 텍스트
                      if (effectText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            effectText,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize:
                                  ResponsiveScale.scaleFontSize(context, 12),
                              color: const Color(0xFFCCCCCC),
                              height: 1.2,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      // "사용" 확인 (선택 시)
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '사용',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  ResponsiveScale.scaleFontSize(context, 11),
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

                // ── 하단 타입 바 ──
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
              ],
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

  // ── 카드 아이콘 (SVG 우선, 폴백 Material Icon) ──

  Widget _buildCardIcon(BuildContext context, CardType cardType, Color typeColor) {
    final iconPath = CardIconMapper.iconPath(choice.sourceCard?.id ?? choice.id);
    final iconSize = ResponsiveScale.scaleFontSize(context, 38);

    final Widget iconWidget;
    if (iconPath != null) {
      iconWidget = SvgPicture.asset(
        iconPath,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(
          typeColor.withValues(alpha: 0.75),
          BlendMode.srcIn,
        ),
      );
    } else {
      iconWidget = Icon(
        AppTheme.cardWatermarkIcon(cardType),
        size: iconSize,
        color: typeColor.withValues(alpha: 0.4),
      );
    }

    // 아이콘 뒤 glow 효과
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: iconWidget,
    );
  }

  // ── AP 다이아몬드 뱃지 ──

  Widget _buildApDiamond(BuildContext context, Color apColor) {
    final size = ResponsiveScale.scalePadding(context, 16);
    final fontSize = ResponsiveScale.scaleFontSize(context, 10);

    return SizedBox(
      width: size + 4,
      height: size + 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                border: Border.all(color: apColor, width: 1.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            '${choice.apCost}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: apColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── 타겟 배지 (우상단) ──

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
        ),
      ),
    );
  }
}
