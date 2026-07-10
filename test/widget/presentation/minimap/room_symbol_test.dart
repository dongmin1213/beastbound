import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/minimap/room_symbol.dart';

void main() {
  group('RoomSymbolData', () {
    test('8개 RoomType 전체 매핑 완전성', () {
      expect(RoomSymbolData.symbol(RoomType.combat), 'X');
      expect(RoomSymbolData.symbol(RoomType.elite), 'E');
      expect(RoomSymbolData.symbol(RoomType.event), '!');
      expect(RoomSymbolData.symbol(RoomType.mystery), '?');
      expect(RoomSymbolData.symbol(RoomType.shop), '\$');
      expect(RoomSymbolData.symbol(RoomType.npc), '@');
      expect(RoomSymbolData.symbol(RoomType.rest), 'R');
      expect(RoomSymbolData.symbol(RoomType.boss), 'B');
    });

    test('NodeVisualState별 색상 할당', () {
      for (final state in NodeVisualState.values) {
        final color = RoomSymbolData.color(state);
        expect(color, isNotNull);
        expect(color, isA<Color>());
      }
    });

    test('엘리트 available → 타입별 악센트 색상 반환', () {
      final color = RoomSymbolData.color(
        NodeVisualState.available,
        roomType: RoomType.elite,
      );
      // available 노드는 타입별 고유 색상으로 표시
      expect(color, RoomSymbolData.typeAccentColor(RoomType.elite));
    });

    test('엘리트 current → 엘리트 현재색(minimapEliteCurrentColor) 반환', () {
      final color = RoomSymbolData.color(
        NodeVisualState.current,
        roomType: RoomType.elite,
      );
      expect(color, AppTheme.minimapEliteCurrentColor);
    });

    test('available 노드 — roomType별 고유 색상 반환', () {
      final combatColor = RoomSymbolData.color(
        NodeVisualState.available,
        roomType: RoomType.combat,
      );
      expect(combatColor, RoomSymbolData.typeAccentColor(RoomType.combat));

      // roomType 미전달 시 기본 available 색상
      final colorNoType = RoomSymbolData.color(NodeVisualState.available);
      expect(colorNoType, AppTheme.minimapAvailableColor);
    });
  });

  group('RoomSymbolWidget', () {
    testWidgets('심볼 텍스트 렌더링', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoomSymbolWidget(
              roomType: RoomType.combat,
              visualState: NodeVisualState.current,
            ),
          ),
        ),
      );

      expect(find.text('[X]'), findsOneWidget);
    });

    testWidgets('available 상태에서 실제 심볼 표시 + 탭 콜백 호출', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoomSymbolWidget(
              roomType: RoomType.shop,
              visualState: NodeVisualState.available,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // available 상태에서 실제 심볼 표시 (방 타입 공개)
      expect(find.text('[\$]'), findsOneWidget);
      await tester.tap(find.text('[\$]'));
      expect(tapped, isTrue);
    });

    testWidgets('locked + typeRevealed → 실제 심볼 표시', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoomSymbolWidget(
              roomType: RoomType.shop,
              visualState: NodeVisualState.locked,
              typeRevealed: true,
            ),
          ),
        ),
      );

      expect(find.text('[\$]'), findsOneWidget);
    });

    testWidgets('locked + typeRevealed=false → [·] 표시', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoomSymbolWidget(
              roomType: RoomType.shop,
              visualState: NodeVisualState.locked,
              typeRevealed: false,
            ),
          ),
        ),
      );

      expect(find.text('[\u00B7]'), findsOneWidget);
    });
  });
}
