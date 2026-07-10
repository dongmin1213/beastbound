import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';

/// CompletedBlockRenderer · CurrentBlockRenderer 공통 TextStyle 유틸.
///
/// 동일 blockType에 대한 스타일 중복을 제거하고,
/// ResponsiveScale 적용을 보장한다.
class TextBlockStyle {
  const TextBlockStyle._();

  static TextStyle classChange(BuildContext context) => TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.amber,
        fontSize: ResponsiveScale.scaleFontSize(context, 13),
      );

  static TextStyle dispositionHint(BuildContext context) => TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.white54,
        fontSize: ResponsiveScale.scaleFontSize(context, 13),
      );

  static TextStyle turnDivider(BuildContext context) => TextStyle(
        color: AppTheme.turnDividerColor,
        fontSize: ResponsiveScale.scaleFontSize(context, 13),
        height: 1.5,
      );

  static TextStyle environment(BuildContext context) => TextStyle(
        fontSize: ResponsiveScale.scaleFontSize(context, 13),
        height: 1.5,
        color: AppTheme.environmentClueColor,
      );

  static TextStyle eliteWarning(BuildContext context) => TextStyle(
        fontSize: ResponsiveScale.scaleFontSize(context, 13),
        height: 1.5,
        color: AppTheme.combatPreviewAttackColor,
        fontWeight: FontWeight.w600,
      );

  static const BoxDecoration environmentBorder = BoxDecoration(
    border: Border(
      left: BorderSide(
        color: AppTheme.environmentBorderColor,
        width: 4,
      ),
    ),
  );

  static const EdgeInsets environmentPadding = EdgeInsets.only(left: 12);
}
