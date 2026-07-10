import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';

void main() {
  group('AppTheme scaling methods', () {
    void setTestScreenSize(WidgetTester tester, Size size) {
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

    testWidgets('scaledBodyLarge 기준 화면에서 fontSize=14, height=1.5',
        (tester) async {
      setTestScreenSize(tester, const Size(375, 667));
      TextStyle? style;
      await tester.pumpWidget(buildTestWidget((ctx) {
        style = AppTheme.scaledBodyLarge(ctx);
      }));
      expect(style!.fontSize, closeTo(14.0, 0.01));
      expect(style!.height, 1.5);
    });

    testWidgets('scaledBodyMedium 기준 화면에서 fontSize=13, height=1.4',
        (tester) async {
      setTestScreenSize(tester, const Size(375, 667));
      TextStyle? style;
      await tester.pumpWidget(buildTestWidget((ctx) {
        style = AppTheme.scaledBodyMedium(ctx);
      }));
      expect(style!.fontSize, closeTo(13.0, 0.01));
      expect(style!.height, 1.4);
    });

    testWidgets('scaledChoiceText 기준 화면에서 fontSize=choiceCardFontSize',
        (tester) async {
      setTestScreenSize(tester, const Size(375, 667));
      TextStyle? style;
      await tester.pumpWidget(buildTestWidget((ctx) {
        style = AppTheme.scaledChoiceText(ctx);
      }));
      expect(style!.fontSize, closeTo(AppTheme.choiceCardFontSize, 0.01));
    });

    testWidgets('scaledScreenPadding 기준 화면에서 horizontal=20, vertical=16',
        (tester) async {
      setTestScreenSize(tester, const Size(375, 667));
      EdgeInsets? padding;
      await tester.pumpWidget(buildTestWidget((ctx) {
        padding = AppTheme.scaledScreenPadding(ctx);
      }));
      expect(padding!.left, closeTo(20.0, 0.01));
      expect(padding!.right, closeTo(20.0, 0.01));
      expect(padding!.top, closeTo(16.0, 0.01));
      expect(padding!.bottom, closeTo(16.0, 0.01));
    });

    testWidgets('scaledBlockSpacing 기준 화면에서 16', (tester) async {
      setTestScreenSize(tester, const Size(375, 667));
      double? spacing;
      await tester.pumpWidget(buildTestWidget((ctx) {
        spacing = AppTheme.scaledBlockSpacing(ctx);
      }));
      expect(spacing, closeTo(16.0, 0.01));
    });

    testWidgets('넓은 화면(428w)에서 스케일링 증가', (tester) async {
      setTestScreenSize(tester, const Size(428, 926));
      TextStyle? style;
      EdgeInsets? padding;
      await tester.pumpWidget(buildTestWidget((ctx) {
        style = AppTheme.scaledBodyLarge(ctx);
        padding = AppTheme.scaledScreenPadding(ctx);
      }));
      // scaledBodyLarge uses base 14: 14 * (428/375) = 15.98
      expect(style!.fontSize, greaterThan(14.0));
      expect(padding!.left, greaterThan(20.0));
    });

    testWidgets('테스트 환경(800x600)에서 clamp 적용', (tester) async {
      // 기본 테스트 환경 — clamp이 상한을 제한해야 함
      setTestScreenSize(tester, const Size(800, 600));
      EdgeInsets? padding;
      await tester.pumpWidget(buildTestWidget((ctx) {
        padding = AppTheme.scaledScreenPadding(ctx);
      }));
      // 800/375 * 20 = 42.67 → clamp → 26
      expect(padding!.left, closeTo(26.0, 0.01));
    });
  });

  group('AppTheme shop color constants', () {
    test('상점 전용 색상 상수 8개 존재', () {
      expect(AppTheme.shopGoldColor, isA<Color>());
      expect(AppTheme.shopItemCardBackground, isA<Color>());
      expect(AppTheme.shopItemCardBorder, isA<Color>());
      expect(AppTheme.shopSoldOverlay, isA<Color>());
      expect(AppTheme.shopRarityCommonColor, isA<Color>());
      expect(AppTheme.shopRarityRareColor, isA<Color>());
      expect(AppTheme.shopRarityLegendaryColor, isA<Color>());
      expect(AppTheme.shopRarityCursedColor, isA<Color>());
      expect(AppTheme.shopBuyButtonColor, isA<Color>());
    });
  });

  group('AppTheme NPC color constants', () {
    test('NPC 전용 색상 상수 9개 존재 (5 고유 + 4 alias)', () {
      expect(AppTheme.npcFrameColor, isA<Color>());
      expect(AppTheme.npcTraderColor, isA<Color>());
      expect(AppTheme.npcSageColor, isA<Color>());
      expect(AppTheme.npcWandererColor, isA<Color>());
      expect(AppTheme.npcDialogueColor, isA<Color>());
      // alias 상수
      expect(AppTheme.npcButtonColor, isA<Color>());
      expect(AppTheme.npcItemCardBackground, isA<Color>());
      expect(AppTheme.npcGoldColor, isA<Color>());
      expect(AppTheme.npcBuyButtonColor, isA<Color>());
    });
  });

  group('AppTheme rest color constants', () {
    test('휴식 전용 색상 상수 5개 존재', () {
      expect(AppTheme.restFrameColor, isA<Color>());
      expect(AppTheme.restRecoveryColor, isA<Color>());
      expect(AppTheme.restUpgradeColor, isA<Color>());
      expect(AppTheme.restCardBackground, isA<Color>());
      expect(AppTheme.restDisabledColor, isA<Color>());
    });
  });

  group('AppTheme mystery color constants', () {
    test('미스터리 전용 색상 상수 7개 존재', () {
      expect(AppTheme.mysteryFrameColor, isA<Color>());
      expect(AppTheme.mysteryTreasureColor, isA<Color>());
      expect(AppTheme.mysteryTrapColor, isA<Color>());
      expect(AppTheme.mysteryEncounterColor, isA<Color>());
      expect(AppTheme.mysteryRewardColor, isA<Color>());
      expect(AppTheme.mysteryCardBackground, isA<Color>());
      expect(AppTheme.mysteryButtonColor, isA<Color>());
    });
  });
}
