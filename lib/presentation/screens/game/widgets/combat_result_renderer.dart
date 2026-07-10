import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';

/// 전투 결과 렌더링 — current block과 completed block 양쪽에서 공유.
///
/// 인라인 색상 코딩:
///  - "8 데미지" → 숫자 빨강
///  - "5 블록" → 숫자 하늘색
///  - "3 회복" / "3 HP" → 숫자 초록
///  - "약화 2턴" / "취약 3턴" → 키워드+숫자 주황
///  - "독 3" / "화상 5" → 키워드+숫자 빨강
///  - "힘 +2" / "민첩 +1" → 키워드+숫자 초록
class CombatResultRenderer {
  const CombatResultRenderer._();

  /// 숫자-먼저 패턴: "8 데미지", "5 블록", "3 회복", "3 HP"
  static final _numberFirstPattern =
      RegExp(r'(\d+)\s*(데미지|블록|회복|HP)');

  /// 키워드-먼저 패턴: "약화 2턴", "취약 3", "독 5", "화상 3", "힘 +2"
  static final _keywordFirstPattern =
      RegExp(r'(약화|취약|독|화상|힘|민첩)\s*(\+?\d+)(턴)?');

  static Widget build(
    BuildContext context,
    String text,
    Map<String, dynamic>? metadata,
  ) {
    final actionResultName = metadata?['actionResult'] ?? 'neutral';
    final actionResult = ActionResult.values.firstWhere(
      (e) => e.name == actionResultName,
      orElse: () => ActionResult.neutral,
    );

    final color = switch (actionResult) {
      ActionResult.effective => AppTheme.combatResultEffectiveColor,
      ActionResult.neutral => AppTheme.combatResultNeutralColor,
      ActionResult.ineffective => AppTheme.combatResultIneffectiveColor,
    };

    final fontSize = ResponsiveScale.scaleFontSize(context, 16);
    final baseStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      height: 1.6,
      fontWeight: FontWeight.w600,
    );

    final tierEffectText = metadata?['tierEffectText'] as String?;
    final tierEffectLevel = metadata?['tierEffectLevel'] as String?;

    if (tierEffectText != null) {
      final tierColor = switch (tierEffectLevel) {
        'enhanced' => AppTheme.tierEffectEnhancedColor,
        'diminished' => AppTheme.tierEffectDiminishedColor,
        _ => AppTheme.combatResultNeutralColor,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: _buildColoredSpans(text, baseStyle),
            ),
          ),
          Text(
            tierEffectText,
            style: TextStyle(
              color: tierColor,
              fontSize: fontSize,
              height: 1.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return RichText(
      text: TextSpan(
        children: _buildColoredSpans(text, baseStyle),
      ),
    );
  }

  /// 텍스트를 파싱하여 숫자/키워드에 맞는 색상을 적용한 TextSpan 목록 반환.
  static List<TextSpan> _buildColoredSpans(String text, TextStyle baseStyle) {
    // 모든 매치를 수집하여 위치순 정렬
    final allMatches = <_ColorMatch>[];

    for (final m in _numberFirstPattern.allMatches(text)) {
      allMatches.add(_ColorMatch(
        start: m.start,
        end: m.end,
        numberStart: m.start,
        numberEnd: m.start + m.group(1)!.length,
        color: _colorForNumberFirst(m.group(2)!),
        colorWholeMatch: false,
      ));
    }

    for (final m in _keywordFirstPattern.allMatches(text)) {
      allMatches.add(_ColorMatch(
        start: m.start,
        end: m.end,
        numberStart: m.start,
        numberEnd: m.end,
        color: _colorForKeywordFirst(m.group(1)!),
        colorWholeMatch: true,
      ));
    }

    // 겹치는 매치 제거 (먼저 등장하는 것 우선)
    allMatches.sort((a, b) => a.start.compareTo(b.start));
    final filtered = <_ColorMatch>[];
    var lastEnd = 0;
    for (final m in allMatches) {
      if (m.start >= lastEnd) {
        filtered.add(m);
        lastEnd = m.end;
      }
    }

    if (filtered.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    final spans = <TextSpan>[];
    var cursor = 0;

    for (final m in filtered) {
      // 매치 이전 텍스트
      if (m.start > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, m.start),
          style: baseStyle,
        ));
      }

      if (m.colorWholeMatch) {
        // 키워드+숫자 전체를 색상 적용
        spans.add(TextSpan(
          text: text.substring(m.start, m.end),
          style: baseStyle.copyWith(color: m.color),
        ));
      } else {
        // 숫자 부분만 색상, 나머지는 기본
        spans.add(TextSpan(
          text: text.substring(m.numberStart, m.numberEnd),
          style: baseStyle.copyWith(color: m.color),
        ));
        spans.add(TextSpan(
          text: text.substring(m.numberEnd, m.end),
          style: baseStyle,
        ));
      }

      cursor = m.end;
    }

    // 나머지 텍스트
    if (cursor < text.length) {
      spans.add(TextSpan(
        text: text.substring(cursor),
        style: baseStyle,
      ));
    }

    return spans;
  }

  static Color _colorForNumberFirst(String keyword) {
    return switch (keyword) {
      '데미지' => AppTheme.textDamage,
      '블록' => AppTheme.textBlock,
      '회복' || 'HP' => AppTheme.textHeal,
      _ => AppTheme.combatResultNeutralColor,
    };
  }

  static Color _colorForKeywordFirst(String keyword) {
    return switch (keyword) {
      '약화' || '취약' => AppTheme.textStatusDebuff,
      '독' || '화상' => AppTheme.textStatusDot,
      '힘' || '민첩' => AppTheme.textStatusBuff,
      _ => AppTheme.combatResultNeutralColor,
    };
  }
}

class _ColorMatch {
  final int start;
  final int end;
  final int numberStart;
  final int numberEnd;
  final Color color;
  final bool colorWholeMatch;

  const _ColorMatch({
    required this.start,
    required this.end,
    required this.numberStart,
    required this.numberEnd,
    required this.color,
    required this.colorWholeMatch,
  });
}
