import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/mystery/mystery_widget.dart';

void main() {
  Widget buildTestWidget(MysteryOutcome outcome, {VoidCallback? onProceed}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: MysteryWidget(
          outcome: outcome,
          onProceed: onProceed ?? () {},
        ),
      ),
    );
  }

  group('MysteryWidget', () {
    testWidgets('보물 결과 렌더링', (tester) async {
      const outcome = TreasureOutcome(
        goldReward: 20,
        narrativeText: '빛나는 보물 상자를 발견했다!',
      );

      await tester.pumpWidget(buildTestWidget(outcome));

      expect(find.text('??? 미스터리 방'), findsOneWidget);
      expect(find.text('보물 발견!'), findsOneWidget);
      expect(find.text('빛나는 보물 상자를 발견했다!'), findsOneWidget);
      expect(find.text('+20 골드'), findsOneWidget);
      expect(find.text('진행하기'), findsOneWidget);
    });

    testWidgets('함정 결과 렌더링', (tester) async {
      const outcome = TrapOutcome(
        hpLoss: 15,
        narrativeText: '바닥이 갑자기 무너졌다!',
      );

      await tester.pumpWidget(buildTestWidget(outcome));

      expect(find.text('??? 미스터리 방'), findsOneWidget);
      expect(find.text('함정!'), findsOneWidget);
      expect(find.text('바닥이 갑자기 무너졌다!'), findsOneWidget);
      expect(find.text('-15 HP'), findsOneWidget);
      expect(find.text('진행하기'), findsOneWidget);
    });

    testWidgets('진행 버튼 탭 시 onProceed 콜백 호출', (tester) async {
      var called = false;
      const outcome = TreasureOutcome(
        goldReward: 20,
        narrativeText: '보물!',
      );

      await tester.pumpWidget(buildTestWidget(
        outcome,
        onProceed: () => called = true,
      ));

      await tester.tap(find.text('진행하기'));
      expect(called, isTrue);
    });

    testWidgets('테두리 프레임이 mysteryFrameColor 사용', (tester) async {
      const outcome = MinorOutcome(
        goldReward: 3,
        narrativeText: '잔돈 발견',
      );

      await tester.pumpWidget(buildTestWidget(outcome));

      // RetroWindowFrame 외부 Container에 mysteryFrameColor 테두리 확인
      final containers = tester.widgetList<Container>(
        find.ancestor(
          of: find.text('??? 미스터리 방'),
          matching: find.byType(Container),
        ),
      );

      // Border.all(color: borderColor)을 가진 Container 찾기
      final borderContainer = containers.firstWhere(
        (c) {
          if (c.decoration is! BoxDecoration) return false;
          final dec = c.decoration as BoxDecoration;
          if (dec.border == null) return false;
          return (dec.border as Border).top.color == AppTheme.mysteryFrameColor;
        },
      );
      final decoration = borderContainer.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(
        (decoration.border as Border).top.color,
        AppTheme.mysteryFrameColor,
      );
    });
  });
}
