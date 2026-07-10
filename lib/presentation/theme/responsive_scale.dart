import 'package:flutter/widgets.dart';

/// 화면 크기 기반 비례 스케일링 유틸리티.
///
/// 기준 화면: iPhone SE/8 (375 × 667 논리 해상도).
/// 16:9 ~ 20:9 화면 비율에서 일관된 UI 경험을 제공한다.
class ResponsiveScale {
  ResponsiveScale._();

  // 기준 화면 크기 (iPhone SE/8 논리 해상도)
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 667.0;

  // 스케일 clamp 상수
  static const double _minFontScale = 0.88; // 한글 가독성 하한
  static const double _maxFontScale = 1.15;
  static const double _minPaddingScale = 0.85;
  static const double _maxPaddingScale = 1.3; // 테스트 환경(800x600) 폭발 방지
  static const double _maxVerticalPaddingScale = 1.5; // 20:9 긴 화면 허용

  /// 화면 너비.
  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  /// 화면 높이.
  static double height(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  /// 화면 너비 대비 비례 스케일 팩터.
  static double scaleWidth(BuildContext context) {
    return width(context) / _baseWidth;
  }

  /// 화면 높이 대비 비례 스케일 팩터.
  static double scaleHeight(BuildContext context) {
    return height(context) / _baseHeight;
  }

  /// 폰트 크기 스케일링 (한글 가독성 하한 보장).
  ///
  /// 최소값: baseFontSize * 0.88 (16px → 14.08px).
  /// 최대값: baseFontSize * 1.3.
  static double scaleFontSize(BuildContext context, double baseFontSize) {
    final scaled = baseFontSize * scaleWidth(context);
    return scaled.clamp(
      baseFontSize * _minFontScale,
      baseFontSize * _maxFontScale,
    );
  }

  /// 수평 패딩 스케일링.
  ///
  /// clamp: basePadding * 0.85 ~ basePadding * 1.3.
  static double scalePadding(BuildContext context, double basePadding) {
    final scaled = basePadding * scaleWidth(context);
    return scaled.clamp(
      basePadding * _minPaddingScale,
      basePadding * _maxPaddingScale,
    );
  }

  /// 수직 패딩 스케일링 (20:9 긴 화면 대응).
  ///
  /// clamp: basePadding * 0.85 ~ basePadding * 1.5.
  static double scaleVerticalPadding(BuildContext context, double basePadding) {
    final scaled = basePadding * scaleHeight(context);
    return scaled.clamp(
      basePadding * _minPaddingScale,
      basePadding * _maxVerticalPaddingScale,
    );
  }
}
