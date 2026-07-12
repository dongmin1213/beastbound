import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_calculator.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_gauge_widget.dart';

void main() {
  const config = MomentumConfig();

  Widget buildTestWidget({
    int momentum = 0,
    MomentumDelta? lastDelta,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: MomentumGaugeWidget(
          momentum: momentum,
          lastDelta: lastDelta,
          config: config,
        ),
      ),
    );
  }

  group('MomentumGaugeWidget', () {
    testWidgets('0 값 렌더링 — "야성 0" 라벨 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(momentum: 0));

      expect(find.text('야성 0'), findsOneWidget);
    });

    testWidgets('50 값 렌더링 — 수치 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(momentum: 50));

      expect(find.text('야성 50'), findsOneWidget);
    });

    testWidgets('100 값 렌더링 — 수치 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(momentum: 100));

      expect(find.text('야성 100'), findsOneWidget);
    });

    testWidgets('delta 양수 표시 (+15)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 15,
        lastDelta: const MomentumDelta(
          value: 15,
          reason: MomentumChangeReason.actionSwitch,
        ),
      ));

      expect(find.text('+15'), findsOneWidget);
    });

    testWidgets('delta 음수 표시 (-10)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 40,
        lastDelta: const MomentumDelta(
          value: -10,
          reason: MomentumChangeReason.sameAction,
        ),
      ));

      expect(find.text('-10'), findsOneWidget);
    });

    testWidgets('delta 0 → 변동 텍스트 미표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 0,
        lastDelta: const MomentumDelta(
          value: 0,
          reason: MomentumChangeReason.none,
        ),
      ));

      expect(find.text('+0'), findsNothing);
      expect(find.text('야성 0'), findsOneWidget); // 수치만 표시
    });

    testWidgets('delta null → 변동 텍스트 미표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 50,
        lastDelta: null,
      ));

      expect(find.text('+15'), findsNothing);
      expect(find.text('-10'), findsNothing);
    });

    testWidgets('단계별 색상 — low (momentum=0)', (tester) async {
      await tester.pumpWidget(buildTestWidget(momentum: 0));

      // "야성 0" 텍스트가 low 색상으로 표시되는지 확인
      final textWidget = tester.widget<Text>(find.text('야성 0'));
      expect(
        (textWidget.style?.color),
        AppTheme.momentumLowColor,
      );
    });

    testWidgets('단계별 색상 — medium (momentum=60)', (tester) async {
      await tester.pumpWidget(buildTestWidget(momentum: 60));

      final textWidget = tester.widget<Text>(find.text('야성 60'));
      expect(
        (textWidget.style?.color),
        AppTheme.momentumMediumColor,
      );
    });

    testWidgets('단계별 색상 — high (momentum=80)', (tester) async {
      await tester.pumpWidget(buildTestWidget(momentum: 80));

      final textWidget = tester.widget<Text>(find.text('야성 80'));
      expect(
        (textWidget.style?.color),
        AppTheme.momentumHighColor,
      );
    });

    testWidgets('delta 양수 색상 = momentumGainColor', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 15,
        lastDelta: const MomentumDelta(
          value: 15,
          reason: MomentumChangeReason.actionSwitch,
        ),
      ));

      final deltaText = tester.widget<Text>(find.text('+15'));
      expect(deltaText.style?.color, AppTheme.momentumGainColor);
    });

    testWidgets('delta 음수 색상 = momentumLossColor', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 40,
        lastDelta: const MomentumDelta(
          value: -10,
          reason: MomentumChangeReason.sameAction,
        ),
      ));

      final deltaText = tester.widget<Text>(find.text('-10'));
      expect(deltaText.style?.color, AppTheme.momentumLossColor);
    });

    testWidgets('delta 1.2초 후 페이드 시작 (opacity 0)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 15,
        lastDelta: const MomentumDelta(
          value: 15,
          reason: MomentumChangeReason.actionSwitch,
        ),
      ));

      // 초기: opacity 1.0
      var animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 1.0);

      // 1.2초 경과 → 페이드 시작
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(); // setState 반영

      animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 0.0);
    });

    testWidgets('delta 1.5초 후 완전 제거', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 15,
        lastDelta: const MomentumDelta(
          value: 15,
          reason: MomentumChangeReason.actionSwitch,
        ),
      ));

      // delta 표시 확인
      expect(find.text('+15'), findsOneWidget);

      // 1.5초 경과 → 완전 제거
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(); // setState 반영

      expect(find.text('+15'), findsNothing);
    });

    testWidgets('새 delta 도착 → 이전 타이머 캔슬 + 새 delta 표시', (tester) async {
      // 첫 delta: +15
      await tester.pumpWidget(buildTestWidget(
        momentum: 15,
        lastDelta: const MomentumDelta(
          value: 15,
          reason: MomentumChangeReason.actionSwitch,
        ),
      ));
      expect(find.text('+15'), findsOneWidget);

      // 1초 대기 (아직 첫 delta 표시 중)
      await tester.pump(const Duration(milliseconds: 1000));

      // 새 delta: -10 (didUpdateWidget 트리거)
      await tester.pumpWidget(buildTestWidget(
        momentum: 5,
        lastDelta: const MomentumDelta(
          value: -10,
          reason: MomentumChangeReason.sameAction,
        ),
      ));

      // 새 delta 표시, 이전 delta 사라짐
      expect(find.text('-10'), findsOneWidget);
      expect(find.text('+15'), findsNothing);

      // 새 타이머 기준 1.5초 후 제거
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();

      expect(find.text('-10'), findsNothing);
    });
    // === Story 2-2: 사유 텍스트 표시 테스트 (Task 2.3) ===

    testWidgets('sameAction delta → "반복!" 사유 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 40,
        lastDelta: const MomentumDelta(
          value: -10,
          reason: MomentumChangeReason.sameAction,
        ),
      ));

      expect(find.text('반복!'), findsOneWidget);
      expect(find.text('연속 반복!'), findsNothing);
    });

    testWidgets('sameActionStreak delta → "연속 반복!" 사유 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 30,
        lastDelta: const MomentumDelta(
          value: -20,
          reason: MomentumChangeReason.sameActionStreak,
        ),
      ));

      expect(find.text('연속 반복!'), findsOneWidget);
      expect(find.text('반복!'), findsNothing);
    });

    testWidgets('actionSwitch delta → 사유 텍스트 미표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 15,
        lastDelta: const MomentumDelta(
          value: 15,
          reason: MomentumChangeReason.actionSwitch,
        ),
      ));

      expect(find.text('반복!'), findsNothing);
      expect(find.text('연속 반복!'), findsNothing);
    });

    testWidgets('none (첫 턴) delta → 사유 텍스트 미표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 0,
        lastDelta: const MomentumDelta(
          value: 0,
          reason: MomentumChangeReason.none,
        ),
      ));

      expect(find.text('반복!'), findsNothing);
      expect(find.text('연속 반복!'), findsNothing);
    });

    testWidgets('사유 텍스트 1.5초 후 사라짐', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 40,
        lastDelta: const MomentumDelta(
          value: -10,
          reason: MomentumChangeReason.sameAction,
        ),
      ));

      expect(find.text('반복!'), findsOneWidget);

      // 1.5초 경과 → 완전 제거
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(); // setState 반영

      expect(find.text('반복!'), findsNothing);
    });

    // === Story 2-2: 시각 에스컬레이션 테스트 (Task 3.2) ===

    testWidgets('sameAction 사유 텍스트 스타일: 기본 크기, 일반 두께', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 40,
        lastDelta: const MomentumDelta(
          value: -10,
          reason: MomentumChangeReason.sameAction,
        ),
      ));

      final reasonText = tester.widget<Text>(find.text('반복!'));
      expect(reasonText.style?.color, AppTheme.momentumPenaltyReasonColor);
      expect(reasonText.style?.fontWeight, FontWeight.normal);
      // 기본 크기 (1.0x) — scaledLabelSize 기준
      final baseFontSize = ResponsiveScale.scaleFontSize(
        tester.element(find.text('반복!')),
        12,
      );
      expect(reasonText.style?.fontSize, baseFontSize);
    });

    testWidgets('sameActionStreak 사유 텍스트 스타일: 1.2배 크기, 굵은 두께', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 30,
        lastDelta: const MomentumDelta(
          value: -20,
          reason: MomentumChangeReason.sameActionStreak,
        ),
      ));

      final reasonText = tester.widget<Text>(find.text('연속 반복!'));
      expect(reasonText.style?.color, AppTheme.momentumPenaltyReasonColor);
      expect(reasonText.style?.fontWeight, FontWeight.bold);
      // 1.2배 크기 — scaledLabelSize * 1.2 기준
      final baseFontSize = ResponsiveScale.scaleFontSize(
        tester.element(find.text('연속 반복!')),
        12,
      );
      expect(reasonText.style?.fontSize, baseFontSize * 1.2);
    });

    // === Story 2-3: 티어 레이블 테스트 (Task 3) ===

    testWidgets('low 티어 → "저" 레이블 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(momentum: 0));

      expect(find.text('저'), findsOneWidget);
    });

    testWidgets('high 티어 → "고" 레이블 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget(momentum: 80));

      expect(find.text('고'), findsOneWidget);
    });

    testWidgets('low→medium 전환 시 레이블 "저"→"중" 변경', (tester) async {
      // low 티어 (momentum=0)
      await tester.pumpWidget(buildTestWidget(momentum: 0));
      expect(find.text('저'), findsOneWidget);
      expect(find.text('중'), findsNothing);

      // medium 티어 (momentum=60)
      await tester.pumpWidget(buildTestWidget(momentum: 60));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('중'), findsOneWidget);
      expect(find.text('저'), findsNothing);
    });

    testWidgets('medium→high 전환 시 레이블 "중"→"고" 변경', (tester) async {
      // medium 티어 (momentum=65)
      await tester.pumpWidget(buildTestWidget(momentum: 65));
      expect(find.text('중'), findsOneWidget);
      expect(find.text('고'), findsNothing);

      // high 티어 (momentum=85)
      await tester.pumpWidget(buildTestWidget(momentum: 85));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('고'), findsOneWidget);
      expect(find.text('중'), findsNothing);
    });

    testWidgets('sameActionStreak delta 텍스트 스타일: sameAction과 동일 (AC3 검증)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        momentum: 30,
        lastDelta: const MomentumDelta(
          value: -20,
          reason: MomentumChangeReason.sameActionStreak,
        ),
      ));

      final deltaText = tester.widget<Text>(find.text('-20'));
      expect(deltaText.style?.color, AppTheme.momentumLossColor);
    });
  });
}
