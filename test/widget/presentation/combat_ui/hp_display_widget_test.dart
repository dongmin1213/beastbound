import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/hp_display_widget.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';

void main() {
  Widget buildWidget({required int currentHp, required int maxHp}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: HpDisplayWidget(currentHp: currentHp, maxHp: maxHp),
      ),
    );
  }

  group('HpDisplayWidget', () {
    testWidgets('displays HP in correct format', (tester) async {
      await tester.pumpWidget(buildWidget(currentHp: 100, maxHp: 100));

      // PixelArtIcon으로 하트 아이콘 + 별도 Text로 HP 표시
      expect(find.byType(PixelArtIcon), findsOneWidget);
      expect(find.text('100/100'), findsOneWidget);
    });

    testWidgets('displays red color when HP <= 30%', (tester) async {
      await tester.pumpWidget(buildWidget(currentHp: 30, maxHp: 100));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final textWidget = tester.widget<AnimatedDefaultTextStyle>(
        find.descendant(
          of: find.byType(HpDisplayWidget),
          matching: find.byType(AnimatedDefaultTextStyle),
        ),
      );
      expect(textWidget.style.color, AppTheme.combatDefeatColor);
    });

    testWidgets('reflects updated HP values', (tester) async {
      await tester.pumpWidget(buildWidget(currentHp: 100, maxHp: 100));
      expect(find.text('100/100'), findsOneWidget);

      await tester.pumpWidget(buildWidget(currentHp: 70, maxHp: 100));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('70/100'), findsOneWidget);
    });

    testWidgets('displays 0 HP correctly', (tester) async {
      await tester.pumpWidget(buildWidget(currentHp: 0, maxHp: 100));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('0/100'), findsOneWidget);

      final textWidget = tester.widget<AnimatedDefaultTextStyle>(
        find.descendant(
          of: find.byType(HpDisplayWidget),
          matching: find.byType(AnimatedDefaultTextStyle),
        ),
      );
      expect(textWidget.style.color, AppTheme.combatDefeatColor);
    });
  });
}
