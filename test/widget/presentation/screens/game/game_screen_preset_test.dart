import 'package:flutter/material.dart' hide SelectAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/build/logic/prep_phase.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import '../../../../helpers/game_screen_test_helper.dart';

void main() {
  late GameEventBus eventBus;
  late DungeonGenerator dungeonGenerator;

  setUp(() {
    eventBus = GameEventBus();
    dungeonGenerator = DungeonGenerator(
      config: const DungeonBalanceConfig(),
      gameEventBus: eventBus,
    );
  });

  tearDown(() {
    eventBus.dispose();
  });

  Widget buildPrepScreen() {
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
          gameEventBus: eventBus,
          dungeonGenerator: dungeonGenerator,
          speed: TextSpeed.instant,
        ),
      ),
    );
  }

  /// 준비 페이즈 초기화 + 첫 블록 완료까지 대기.
  Future<void> pumpPrepPhase(WidgetTester tester) async {
    await tester.pumpWidget(buildPrepScreen());
    await tester.pump(); // build frame
    await tester.pump(); // postFrameCallback → onComplete
    await tester.pump(); // setState → rebuild
  }

  /// 인트로 블록 → 선택 프롬프트 블록으로 advance + 선택지 렌더 대기.
  Future<void> advanceToChoices(WidgetTester tester) async {
    await tapGameScreen(tester);
    await tester.pump(); // process tap → _advanceToNextBlock
    await tester.pump(); // postFrameCallback → block 1 TypewriterWidget build
    await tester.pump(); // postFrameCallback → onComplete (instant)
    await tester.pump(); // setState → _showingChoices = true, rebuild
  }

  group('GameScreen preset system', () {
    testWidgets('첫 런 → 프리셋 없이 3개 기본 선택지만 표시', (tester) async {
      await pumpPrepPhase(tester);
      await advanceToChoices(tester);

      // 6개 중 랜덤 3개 선택지 표시
      final allNames = [
        '노련한 탐험가의 주머니', '생명력의 부적', '선대 모험가의 축복',
        '고대의 유물', '치유사의 기도', '방랑자의 배낭',
      ];
      int visibleCount = 0;
      for (final name in allNames) {
        if (find.textContaining(name).evaluate().isNotEmpty) visibleCount++;
      }
      expect(visibleCount, 3, reason: '6개 중 3개 선택지가 표시되어야 함');

      // 프리셋 없음
      expect(find.textContaining('⚡'), findsNothing);
    });

    testWidgets('PrepPhaseData.getChoices → 6개 선택지 + config 반영', (tester) async {
      final choices = PrepPhaseData.getChoices(
        startingGoldBonus: 30,
        startingHpBonus: 25,
        startingBlessingId: 'test_blessing',
      );

      expect(choices.length, 6);
      expect(choices[0].id, 'prep_gold');
      expect(choices[0].bonusValue, 30);
      expect(choices[1].id, 'prep_hp');
      expect(choices[1].bonusValue, 25);
      expect(choices[2].id, 'prep_blessing');
      expect(choices[2].blessingId, 'test_blessing');
    });

    testWidgets('PrepConfig 기본값 → 선택지 텍스트에 반영', (tester) async {
      // 6개 전체 선택지의 description이 config 기본값을 반영하는지 검증 (데이터 레이어)
      final choices = PrepPhaseData.getChoices();
      expect(choices[0].description, contains('시작 골드 +20'));
      expect(choices[1].description, contains('시작 HP +15'));
      expect(choices[2].description, contains('시작 축복 1개 획득'));
      expect(choices[3].description, contains('유물 1개 획득'));
      expect(choices[4].description, contains('시작 HP +10'));
      expect(choices[5].description, contains('골드 +10'));
    });
  });
}
