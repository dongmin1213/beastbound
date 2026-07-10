import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_hud_widget.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';

void main() {
  Widget buildHud({
    int playerHp = 72,
    int playerMaxHp = 80,
    int playerBlock = 0,
    int actionPoints = 3,
    int maxActionPoints = 4,
    String enemyName = '골렘',
    int enemyHp = 120,
    int enemyMaxHp = 150,
    int currentTurn = 1,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CombatHudWidget(
          playerHp: playerHp,
          playerMaxHp: playerMaxHp,
          playerBlock: playerBlock,
          actionPoints: actionPoints,
          maxActionPoints: maxActionPoints,
          enemyName: enemyName,
          enemyHp: enemyHp,
          enemyMaxHp: enemyMaxHp,
          currentTurn: currentTurn,
        ),
      ),
    );
  }

  group('CombatHudWidget', () {
    testWidgets('HP 표시', (tester) async {
      await tester.pumpWidget(buildHud());

      expect(find.textContaining('72/80'), findsOneWidget);
    });

    testWidgets('적 정보 표시', (tester) async {
      await tester.pumpWidget(buildHud());

      expect(find.textContaining('골렘'), findsOneWidget);
      expect(find.textContaining('120/150'), findsOneWidget);
    });

    testWidgets('턴 표시', (tester) async {
      await tester.pumpWidget(buildHud(currentTurn: 3));

      expect(find.textContaining('3턴'), findsOneWidget);
    });

    testWidgets('AP 바 — PixelArtIcon + Opacity 표시', (tester) async {
      await tester.pumpWidget(buildHud(actionPoints: 2, maxActionPoints: 4));

      // AP는 PixelArtIcon으로 표시, filled/empty는 Opacity로 구분
      // HP 아이콘 1개 + AP 아이콘 4개 = 최소 5개
      final pixelIcons = find.byType(PixelArtIcon);
      expect(pixelIcons, findsAtLeast(4));
    });

    testWidgets('블록 0이면 블록 아이콘 미표시', (tester) async {
      await tester.pumpWidget(buildHud(playerBlock: 0));

      // playerBlock == 0일 때 블록 아이콘이 없어야 함
      // HP 아이콘(1) + AP 아이콘(4) = 5개만 존재
      final pixelIcons = find.byType(PixelArtIcon);
      expect(pixelIcons, findsNWidgets(5));
    });

    testWidgets('블록 > 0이면 블록 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildHud(playerBlock: 8));

      // 블록 값은 별도 Text로 표시 (아이콘은 PixelArtIcon)
      expect(find.text('8'), findsOneWidget);
      // HP 아이콘(1) + 블록 아이콘(1) + AP 아이콘(4) = 6개
      final pixelIcons = find.byType(PixelArtIcon);
      expect(pixelIcons, findsNWidgets(6));
    });

    testWidgets('HP 30% 이하 — 빨간색 텍스트', (tester) async {
      await tester.pumpWidget(buildHud(playerHp: 20, playerMaxHp: 80));

      final hpText = tester.widget<Text>(
        find.textContaining('20/80'),
      );
      expect(hpText.style?.color, const Color(0xFFE53935));
    });

    testWidgets('HP 31% 이상 — 기본 텍스트 색', (tester) async {
      await tester.pumpWidget(buildHud(playerHp: 40, playerMaxHp: 80));

      final hpText = tester.widget<Text>(
        find.textContaining('40/80'),
      );
      expect(hpText.style?.color, const Color(0xFFE0E0E0));
    });
  });
}
