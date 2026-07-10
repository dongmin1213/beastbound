import 'package:flutter/material.dart' hide SelectAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/rest/rest_widget.dart';

void main() {
  Widget buildRestWidget({
    int currentHp = 60,
    int maxHp = 100,
    int healAmount = 30,
    int upgradeAmount = 10,
    VoidCallback? onChooseHeal,
    VoidCallback? onChooseUpgrade,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          child: RestWidget(
            currentHp: currentHp,
            maxHp: maxHp,
            healAmount: healAmount,
            upgradeAmount: upgradeAmount,
            onChooseHeal: onChooseHeal ?? () {},
            onChooseUpgrade: onChooseUpgrade ?? () {},
          ),
        ),
      ),
    );
  }

  group('RestWidget', () {
    testWidgets('HP 회복 카드 렌더링', (tester) async {
      await tester.pumpWidget(buildRestWidget());

      expect(find.text('체력 회복'), findsOneWidget);
      expect(find.text('지친 몸을 쉬어 체력을 회복한다.'), findsOneWidget);
      expect(find.text('+30 HP'), findsOneWidget);
    });

    testWidgets('축복 강화 카드 렌더링', (tester) async {
      await tester.pumpWidget(buildRestWidget());

      expect(find.text('축복 강화'), findsOneWidget);
      expect(find.text('던전의 축복으로 최대 체력이 증가한다.'), findsOneWidget);
      expect(find.text('+10 최대 HP'), findsOneWidget);
    });

    testWidgets('회복 버튼 탭 → 콜백 호출', (tester) async {
      var called = false;
      await tester.pumpWidget(buildRestWidget(
        onChooseHeal: () => called = true,
      ));

      await tester.tap(find.text('체력 회복'));
      expect(called, isTrue);
    });

    testWidgets('강화 버튼 탭 → 콜백 호출', (tester) async {
      var called = false;
      await tester.pumpWidget(buildRestWidget(
        onChooseUpgrade: () => called = true,
      ));

      await tester.tap(find.text('축복 강화'));
      expect(called, isTrue);
    });

    testWidgets('full HP시 회복 카드 탭 가능 (비활성 아님)', (tester) async {
      var called = false;
      await tester.pumpWidget(buildRestWidget(
        currentHp: 100,
        maxHp: 100,
        healAmount: 0,
        onChooseHeal: () => called = true,
      ));

      // full HP 전용 문구
      expect(find.text('이미 최대 체력이지만, 잠시 쉬어갈 수 있다.'), findsOneWidget);
      expect(find.text('+0 HP'), findsOneWidget);

      // 탭 가능 확인
      await tester.tap(find.text('체력 회복'));
      expect(called, isTrue);
    });

    // === Story 3-7: 기세 초기화 경고 ===

    testWidgets('기세 초기화 경고 텍스트 항상 표시 (기세 0 포함, AC 2)', (tester) async {
      await tester.pumpWidget(buildRestWidget());

      expect(find.text('선택 시 기세가 초기화됩니다'), findsOneWidget);
    });

    testWidgets('현재 HP/maxHp 표시', (tester) async {
      await tester.pumpWidget(buildRestWidget(
        currentHp: 75,
        maxHp: 110,
      ));

      expect(find.text('HP: 75 / 110'), findsOneWidget);
      expect(find.text('휴식의 방'), findsOneWidget);
    });
  });
}
