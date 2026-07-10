import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

void main() {
  void setTestScreenSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildGameScreen({
    List<TextBlockData>? blockData,
    TextSpeed speed = TextSpeed.instant,
    CombatEncounter? encounter,
  }) {
    final eventBus = GameEventBus();
    return MultiBlocProvider(
      providers: [
        BlocProvider<MomentumBloc>(
          create: (_) => MomentumBloc(
            gameEventBus: eventBus,
            config: const MomentumConfig(),
          ),
        ),
        BlocProvider<ProgressionBloc>(
          create: (_) => ProgressionBloc(gameEventBus: eventBus),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: GameScreen(
          initialBlockData: blockData,
          speed: speed,
          initialEncounter: encounter,
          eventConfig: const EventConfig(),
        ),
      ),
    );
  }

  group('GameScreen responsive layout', () {
    testWidgets('좁은 화면(320x568) 렌더링 정상 + 패딩 스케일링 검증',
        (tester) async {
      setTestScreenSize(tester, const Size(320, 568));
      await tester.pumpWidget(buildGameScreen(
        blockData: const [
          TextBlockData(text: '어두운 던전에 들어섰다.'),
        ],
      ));
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // SingleChildScrollView의 직접 부모 Padding(수평)이 스케일링된 값인지 확인
      final hPadding = tester.widget<Padding>(
        find.ancestor(
          of: find.byType(SingleChildScrollView).first,
          matching: find.byType(Padding),
        ).first,
      );
      final hInsets = hPadding.padding as EdgeInsets;
      // 320/375 * 20 = 17.07 → clamp 하한 20*0.85=17.0
      expect(hInsets.left, lessThanOrEqualTo(20.0));
      expect(hInsets.left, greaterThanOrEqualTo(17.0));
    });

    testWidgets('기준 화면(375x667) 렌더링 정상 + 기준 패딩 확인', (tester) async {
      setTestScreenSize(tester, const Size(375, 667));
      await tester.pumpWidget(buildGameScreen(
        blockData: const [
          TextBlockData(text: '어두운 던전에 들어섰다.'),
        ],
      ));
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 수평 패딩 (ScrollView 부모) + 수직 패딩 (ScrollView 자식) 분리 검증
      final hPadding = tester.widget<Padding>(
        find.ancestor(
          of: find.byType(SingleChildScrollView).first,
          matching: find.byType(Padding),
        ).first,
      );
      final hInsets = hPadding.padding as EdgeInsets;
      expect(hInsets.left, closeTo(20.0, 0.1));

      final vPadding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(SingleChildScrollView).first,
          matching: find.byType(Padding),
        ).first,
      );
      final vInsets = vPadding.padding as EdgeInsets;
      expect(vInsets.top, closeTo(16.0, 0.1));
    });

    testWidgets('넓은 화면(428x926) 렌더링 정상 + 패딩 증가 확인', (tester) async {
      setTestScreenSize(tester, const Size(428, 926));
      await tester.pumpWidget(buildGameScreen(
        blockData: const [
          TextBlockData(text: '어두운 던전에 들어섰다.'),
        ],
      ));
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 넓은 화면에서 패딩이 기준값(20px)보다 커야 함
      final padding = tester.widget<Padding>(
        find.ancestor(
          of: find.byType(SingleChildScrollView).first,
          matching: find.byType(Padding),
        ).first,
      );
      final edgeInsets = padding.padding as EdgeInsets;
      // 428/375 * 20 = 22.83
      expect(edgeInsets.left, greaterThan(20.0));
      expect(edgeInsets.left, lessThanOrEqualTo(26.0)); // clamp 상한 20*1.3
    });

    testWidgets('긴 비율(360x800, 20:9) 렌더링 정상', (tester) async {
      setTestScreenSize(tester, const Size(360, 800));
      await tester.pumpWidget(buildGameScreen(
        blockData: const [
          TextBlockData(text: '어두운 던전에 들어섰다.'),
        ],
      ));
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SafeArea 패딩 적용 확인', (tester) async {
      setTestScreenSize(tester, const Size(375, 667));
      await tester.pumpWidget(buildGameScreen(
        blockData: const [
          TextBlockData(text: '어두운 던전에 들어섰다.'),
        ],
      ));
      await tester.pump();

      // SafeArea 위젯이 존재하는지 확인
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('스크롤 동작 확인 — 다수 블록', (tester) async {
      setTestScreenSize(tester, const Size(360, 568)); // 16:9 짧은 화면

      final blocks = List.generate(
        10,
        (i) => TextBlockData(text: '블록 $i: 어두운 던전을 걷고 있다. 주변이 점점 어두워진다.'),
      );

      await tester.pumpWidget(buildGameScreen(
        blockData: blocks,
      ));
      await tester.pump();

      // 텍스트 영역 + 하단 선택지 영역 각각 SingleChildScrollView 사용
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('선택지 + 기세 게이지 동시 표시 — 좁은 화면', (tester) async {
      setTestScreenSize(tester, const Size(320, 568));

      final encounter = CombatEncounter(
        enemyName: '테스트 적',
        introText: '적이 나타났다!',
        victoryText: '승리!',
        defeatText: '패배...',
        turns: [
          CombatTurnData(
            turnNumber: 1,
            enemyAction: EnemyAction(
              type: EnemyActionType.attack,
              previewText: '적이 공격 준비를 한다',
            ),
            playerChoices: [
              ChoiceData(
                id: 'attack',
                text: '공격',
                resultTextBlocks: const [],
                actionType: 'attack',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(buildGameScreen(
        encounter: encounter,
        speed: TextSpeed.instant,
      ));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Android split-screen 시뮬레이션(360x400)', (tester) async {
      setTestScreenSize(tester, const Size(360, 400));
      await tester.pumpWidget(buildGameScreen(
        blockData: const [
          TextBlockData(text: '극단적으로 작은 화면에서도 동작한다.'),
        ],
      ));
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
