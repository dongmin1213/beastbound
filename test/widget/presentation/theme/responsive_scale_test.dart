import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';

void main() {
  group('ResponsiveScale', () {
    /// 지정 화면 크기에서 ResponsiveScale 메서드를 테스트하기 위한 헬퍼.
    /// addTearDown으로 크기를 복원하여 테스트 오염을 방지한다.
    void setTestScreenSize(
      WidgetTester tester,
      Size size,
    ) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Widget buildTestWidget(void Function(BuildContext) callback) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            callback(context);
            return const SizedBox.shrink();
          },
        ),
      );
    }

    group('scaleWidth', () {
      testWidgets('기준 화면(375x667)에서 scale = 1.0', (tester) async {
        setTestScreenSize(tester, const Size(375, 667));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleWidth(ctx);
        }));
        expect(result, closeTo(1.0, 0.001));
      });

      testWidgets('좁은 화면(320x568)에서 scale < 1.0', (tester) async {
        setTestScreenSize(tester, const Size(320, 568));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleWidth(ctx);
        }));
        expect(result, lessThan(1.0));
        expect(result, closeTo(320 / 375, 0.001));
      });

      testWidgets('넓은 화면(428x926)에서 scale > 1.0', (tester) async {
        setTestScreenSize(tester, const Size(428, 926));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleWidth(ctx);
        }));
        expect(result, greaterThan(1.0));
        expect(result, closeTo(428 / 375, 0.001));
      });
    });

    group('scaleHeight', () {
      testWidgets('기준 화면(375x667)에서 scale = 1.0', (tester) async {
        setTestScreenSize(tester, const Size(375, 667));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleHeight(ctx);
        }));
        expect(result, closeTo(1.0, 0.001));
      });

      testWidgets('20:9 긴 화면(360x800)에서 scale > 1.0', (tester) async {
        setTestScreenSize(tester, const Size(360, 800));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleHeight(ctx);
        }));
        expect(result, greaterThan(1.0));
        expect(result, closeTo(800 / 667, 0.001));
      });
    });

    group('scaleFontSize', () {
      testWidgets('기준 화면에서 폰트 크기 = base 값', (tester) async {
        setTestScreenSize(tester, const Size(375, 667));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleFontSize(ctx, 16);
        }));
        expect(result, closeTo(16.0, 0.01));
      });

      testWidgets('좁은 화면(320w)에서 16px → 최소 14.08px (한글 가독성)',
          (tester) async {
        setTestScreenSize(tester, const Size(320, 568));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleFontSize(ctx, 16);
        }));
        // 320/375 * 16 = 13.65 → clamp → 16 * 0.88 = 14.08
        expect(result, closeTo(14.08, 0.01));
        expect(result, greaterThanOrEqualTo(16 * 0.88));
      });

      testWidgets('넓은 화면(428w)에서 폰트 최대값 제한', (tester) async {
        setTestScreenSize(tester, const Size(428, 926));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleFontSize(ctx, 16);
        }));
        // 428/375 * 16 = 18.25 → clamp → 16 * 1.15 = 18.4 (안 넘음, 그대로)
        expect(result, closeTo(18.25, 0.1));
        expect(result, lessThanOrEqualTo(16 * 1.15));
      });

      testWidgets('테스트 환경(800w)에서 폰트 최대값 제한', (tester) async {
        setTestScreenSize(tester, const Size(800, 600));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleFontSize(ctx, 16);
        }));
        // 800/375 * 16 = 34.13 → clamp → 16 * 1.15 = 18.4
        expect(result, closeTo(18.4, 0.01));
      });
    });

    group('scalePadding', () {
      testWidgets('기준 화면에서 패딩 = base 값', (tester) async {
        setTestScreenSize(tester, const Size(375, 667));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scalePadding(ctx, 20);
        }));
        expect(result, closeTo(20.0, 0.01));
      });

      testWidgets('좁은 화면(320w)에서 패딩 clamp 하한', (tester) async {
        setTestScreenSize(tester, const Size(320, 568));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scalePadding(ctx, 20);
        }));
        // 320/375 * 20 = 17.07 → clamp → 20 * 0.85 = 17
        expect(result, closeTo(17.07, 0.1));
        expect(result, greaterThanOrEqualTo(20 * 0.85));
      });

      testWidgets('테스트 환경(800x600)에서 패딩 폭발 방지 (clamp 상한)',
          (tester) async {
        setTestScreenSize(tester, const Size(800, 600));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scalePadding(ctx, 20);
        }));
        // 800/375 * 20 = 42.67 → clamp → 20 * 1.3 = 26
        expect(result, closeTo(26.0, 0.01));
      });

      testWidgets('패딩 비례 계산 정확성 (414w)', (tester) async {
        setTestScreenSize(tester, const Size(414, 736));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scalePadding(ctx, 20);
        }));
        // 414/375 * 20 = 22.08 → within clamp range
        expect(result, closeTo(22.08, 0.1));
      });
    });

    group('scaleVerticalPadding', () {
      testWidgets('기준 화면에서 수직 패딩 = base 값', (tester) async {
        setTestScreenSize(tester, const Size(375, 667));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleVerticalPadding(ctx, 16);
        }));
        expect(result, closeTo(16.0, 0.01));
      });

      testWidgets('20:9 긴 화면에서 수직 패딩 적절히 증가', (tester) async {
        setTestScreenSize(tester, const Size(360, 800));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleVerticalPadding(ctx, 16);
        }));
        // 800/667 * 16 = 19.19 → within clamp range
        expect(result, closeTo(19.19, 0.1));
        expect(result, greaterThan(16.0));
      });

      testWidgets('수직 패딩 clamp 상한 1.5x', (tester) async {
        setTestScreenSize(tester, const Size(375, 1200));
        double? result;
        await tester.pumpWidget(buildTestWidget((ctx) {
          result = ResponsiveScale.scaleVerticalPadding(ctx, 16);
        }));
        // 1200/667 * 16 = 28.78 → clamp → 16 * 1.5 = 24
        expect(result, closeTo(24.0, 0.01));
      });
    });

    group('다양한 화면 크기 통합', () {
      testWidgets('393x852 (iPhone 15) 스케일링', (tester) async {
        setTestScreenSize(tester, const Size(393, 852));
        double? widthScale;
        double? heightScale;
        await tester.pumpWidget(buildTestWidget((ctx) {
          widthScale = ResponsiveScale.scaleWidth(ctx);
          heightScale = ResponsiveScale.scaleHeight(ctx);
        }));
        expect(widthScale, closeTo(393 / 375, 0.001));
        expect(heightScale, closeTo(852 / 667, 0.001));
      });

      testWidgets('360x780 (Samsung S24) 스케일링', (tester) async {
        setTestScreenSize(tester, const Size(360, 780));
        double? fontSize;
        double? padding;
        await tester.pumpWidget(buildTestWidget((ctx) {
          fontSize = ResponsiveScale.scaleFontSize(ctx, 16);
          padding = ResponsiveScale.scalePadding(ctx, 20);
        }));
        // 360/375 = 0.96
        expect(fontSize, closeTo(16 * 0.96, 0.1));
        expect(padding, closeTo(20 * 0.96, 0.1));
      });
    });
  });
}
