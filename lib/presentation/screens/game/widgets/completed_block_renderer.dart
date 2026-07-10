import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/combat_result_renderer.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/text_block_style.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 완료된 텍스트 블록을 렌더링하는 순수 UI 클래스.
///
/// 상태 의존 없음 — CompletedBlock 데이터만으로 위젯 생성.
class CompletedBlockRenderer {
  const CompletedBlockRenderer._();

  static Widget build(BuildContext context, CompletedBlock block) {
    if (block.isChoice) {
      return RichText(
        text: TextSpan(
          text: '> ${block.text}',
          style: TextStyle(
            color: AppTheme.choiceHistoryAccent,
            fontSize: ResponsiveScale.scaleFontSize(context, 14),
            height: 1.5,
          ),
        ),
      );
    }

    return switch (block.blockType) {
      TextBlockType.combatPreview => _buildPreview(context, block),
      TextBlockType.turnDivider => _buildTurnDivider(context, block),
      TextBlockType.combatResult =>
        CombatResultRenderer.build(context, block.text, block.metadata),
      TextBlockType.combatOutcome => _buildOutcome(context, block),
      TextBlockType.environmentNarration ||
      TextBlockType.environmentDiscovery =>
        _buildEnvironment(context, block),
      TextBlockType.dispositionHint => _buildDispositionHint(context, block),
      TextBlockType.classChange => _buildClassChange(context, block),
      TextBlockType.normal => _buildNormal(context, block),
    };
  }

  static Widget _buildNormal(BuildContext context, CompletedBlock block) {
    final isRunSummary = block.metadata?['runSummary'] == true;
    final isEliteWarning = block.metadata?['eliteWarning'] == true;
    final isSynergy = block.metadata?['synergy'] == true;
    final isChain = block.metadata?['chain'] == true;
    final isChainBadge = block.metadata?['chainBadge'] == true;
    final isApChange = block.metadata?['apChange'] == true;
    final isApRules = block.metadata?['apRules'] == true;

    if (isRunSummary) {
      return _buildRunSummary(context, block);
    }

    if (isSynergy) {
      return _buildSynergy(context, block);
    }

    if (isChain || isChainBadge) {
      return _buildChain(context, block);
    }

    if (isApChange) {
      return _buildApChange(context, block);
    }

    if (isApRules) {
      return _buildApRules(context, block);
    }

    final style = isEliteWarning
        ? TextBlockStyle.eliteWarning(context)
        : AppTheme.scaledBodyLarge(context);

    return RichText(
      text: TextSpan(text: block.text, style: style),
    );
  }

  /// AP 변동 텍스트 — 기세 색상 + 볼드.
  static Widget _buildApChange(BuildContext context, CompletedBlock block) {
    final isRise = block.text.contains('상승');
    final color = isRise
        ? AppTheme.momentumHighColor
        : AppTheme.momentumLowColor;

    return RichText(
      text: TextSpan(
        text: block.text,
        style: TextStyle(
          color: color,
          fontSize: ResponsiveScale.scaleFontSize(context, 14),
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// AP 규칙 요약 — 정보 박스 스타일.
  static Widget _buildApRules(BuildContext context, CompletedBlock block) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveScale.scalePadding(context, 10),
        vertical: ResponsiveScale.scaleVerticalPadding(context, 6),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.momentumMediumColor.withValues(alpha: 0.4),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: AppTheme.momentumMediumColor.withValues(alpha: 0.08),
      ),
      child: RichText(
        text: TextSpan(
          text: block.text,
          style: TextStyle(
            color: AppTheme.momentumMediumColor,
            fontSize: ResponsiveScale.scaleFontSize(context, 13),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// 런 요약 카드 — 구조화된 통계 표시 (층별 컬러 적용).
  static Widget _buildRunSummary(BuildContext context, CompletedBlock block) {
    final lines = block.text.split('\n');
    final isVictory = block.metadata?['isVictory'] == true;
    final floor = block.metadata?['floor'] as int? ?? 1;

    final Color accentColor;
    if (isVictory) {
      accentColor = AppTheme.combatVictoryColor;
    } else {
      final theme = FloorThemeVisuals.fromFloor(floor);
      accentColor = theme.accentColor;
    }
    final borderColor = accentColor.withValues(alpha: 0.5);
    final bgColor = accentColor.withValues(alpha: 0.08);
    final fontSize = ResponsiveScale.scaleFontSize(context, 14);

    final children = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      // 장식 구분선 (══════)
      if (line.contains('══════')) {
        children.add(Center(
          child: Text(
            line,
            style: TextStyle(
              color: accentColor,
              fontSize: ResponsiveScale.scaleFontSize(context, 15),
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
        ));
        continue;
      }

      // 획득 소울 — 특별 강조
      if (line.startsWith('획득 소울')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: RichText(
            text: TextSpan(
              text: line,
              style: TextStyle(
                color: accentColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
          ),
        ));
        continue;
      }

      // 라벨: 값 쌍
      final colonIdx = line.indexOf(':');
      if (colonIdx > 0 && colonIdx < line.length - 1) {
        final label = line.substring(0, colonIdx + 1);
        final value = line.substring(colonIdx + 1);
        children.add(RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.8),
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  color: AppTheme.choiceCardText,
                  fontSize: fontSize,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // 기본 텍스트
      children.add(RichText(
        text: TextSpan(
          text: line,
          style: TextStyle(
            color: AppTheme.choiceCardText,
            fontSize: fontSize,
            height: 1.6,
          ),
        ),
      ));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveScale.scalePadding(context, 16),
        vertical: ResponsiveScale.scaleVerticalPadding(context, 12),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// 연쇄 보너스 연출 — 오렌지 강조 테두리 + 텍스트.
  static Widget _buildChain(BuildContext context, CompletedBlock block) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveScale.scalePadding(context, 8),
        vertical: ResponsiveScale.scaleVerticalPadding(context, 3),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.chainBonusColor.withValues(alpha: 0.5),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: AppTheme.chainBonusColor.withValues(alpha: 0.1),
      ),
      child: RichText(
        text: TextSpan(
          text: block.text,
          style: TextStyle(
            color: AppTheme.chainBonusColor,
            fontSize: ResponsiveScale.scaleFontSize(context, 14),
            height: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 시너지 폭발 연출 — 강조 테두리 + 골드 텍스트.
  static Widget _buildSynergy(BuildContext context, CompletedBlock block) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveScale.scalePadding(context, 8),
        vertical: ResponsiveScale.scaleVerticalPadding(context, 4),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.combatVictoryColor.withValues(alpha: 0.4),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: AppTheme.combatVictoryColor.withValues(alpha: 0.08),
      ),
      child: RichText(
        text: TextSpan(
          text: block.text,
          style: TextStyle(
            color: AppTheme.combatVictoryColor,
            fontSize: ResponsiveScale.scaleFontSize(context, 15),
            height: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _buildPreview(BuildContext context, CompletedBlock block) {
    final actionTypeName = block.metadata?['actionType'] ?? 'attack';
    final actionType = EnemyActionType.values.firstWhere(
      (e) => e.name == actionTypeName,
      orElse: () => EnemyActionType.attack,
    );
    final color = switch (actionType) {
      EnemyActionType.attack ||
      EnemyActionType.heavy =>
        AppTheme.combatPreviewAttackColor,
      EnemyActionType.defend ||
      EnemyActionType.charge ||
      EnemyActionType.heal ||
      EnemyActionType.buff =>
        AppTheme.combatPreviewDefendColor,
      EnemyActionType.observe => AppTheme.combatPreviewObserveColor,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveScale.scalePadding(context, 16),
        vertical: ResponsiveScale.scaleVerticalPadding(context, 12),
      ),
      decoration: const BoxDecoration(
        color: AppTheme.combatPreviewBackground,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: RichText(
        text: TextSpan(
          text: block.text,
          style: TextStyle(
            color: color,
            fontSize: ResponsiveScale.scaleFontSize(context, 14),
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget _buildOutcome(BuildContext context, CompletedBlock block) {
    final isVictory = block.metadata?['combatOutcome'] == 'victory';
    final color = isVictory
        ? AppTheme.combatVictoryColor
        : AppTheme.combatDefeatColor;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveScale.scaleVerticalPadding(context, 24),
      ),
      child: Center(
        child: Text(
          block.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: ResponsiveScale.scaleFontSize(context, 18),
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  static Widget _buildTurnDivider(BuildContext context, CompletedBlock block) {
    return Center(
      child: Text(
        block.text,
        style: TextBlockStyle.turnDivider(context),
      ),
    );
  }

  static Widget _buildDispositionHint(
    BuildContext context,
    CompletedBlock block,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveScale.scaleVerticalPadding(context, 4),
      ),
      child: Text(
        block.text,
        style: TextBlockStyle.dispositionHint(context),
      ),
    );
  }

  static Widget _buildClassChange(BuildContext context, CompletedBlock block) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveScale.scaleVerticalPadding(context, 8),
      ),
      child: Text(
        block.text,
        style: TextBlockStyle.classChange(context),
      ),
    );
  }

  static Widget _buildEnvironment(BuildContext context, CompletedBlock block) {
    return Container(
      decoration: TextBlockStyle.environmentBorder,
      padding: TextBlockStyle.environmentPadding,
      child: RichText(
        text: TextSpan(
          text: block.text,
          style: TextBlockStyle.environment(context),
        ),
      ),
    );
  }
}
