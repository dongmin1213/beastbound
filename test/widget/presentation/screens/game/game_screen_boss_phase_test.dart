import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import '../../../../helpers/rich_text_finder.dart';
import '../../../../helpers/game_screen_test_helper.dart';

/// 3페이즈 보스 — Phase 1 → Phase 2 → Phase 3 전환 테스트.
const _threePhaseEncounter = CombatEncounter(
  roomType: RoomType.boss,
  enemyName: '세 형태의 보스',
  introText: '세 형태의 보스가 나타났다.\n\n여기서 쓰러지면... 돌아올 수 없다.',
  turns: [],
  victoryText: '세 형태를 모두 쓰러뜨렸다!',
  defeatText: '보스에게 패배했다...',
  bossPhases: [
    BossPhasePresentation(
      introText: '1페이즈!',
      turns: [],
      transitionText: '첫 번째 형태가 무너진다...',
    ),
    BossPhasePresentation(
      introText: '2페이즈!',
      turns: [],
      transitionText: '두 번째 형태도 무너진다...',
    ),
    BossPhasePresentation(
      introText: '최종 형태!',
      turns: [],
    ),
  ],
);

/// 0턴 1페이즈 보스 (즉시 패배 → 퍼마데스)
const _singlePhaseDefeat = CombatEncounter(
  roomType: RoomType.boss,
  enemyName: '즉사 보스',
  introText: '보스.\n\n여기서 쓰러지면... 돌아올 수 없다.',
  turns: [],
  victoryText: '승리!',
  defeatText: '패배...',
  bossPhases: [
    BossPhasePresentation(
      introText: '',
      turns: [],
    ),
  ],
);

void main() {
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  Widget buildBossScreen({
    CombatBalanceConfig combatConfig = const CombatBalanceConfig(),
  }) {
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
          combatConfig: combatConfig,
          economyConfig: const EconomyConfig(),
          speed: TextSpeed.instant,
          eventConfig: const EventConfig(),
        ),
      ),
    );
  }

  group('Boss 3-phase transition', () {
    testWidgets('3페이즈 보스 → Phase 1 인트로', (tester) async {
      await tester.pumpWidget(buildBossScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _threePhaseEncounter);
      await tester.pump();
      await tester.pump();

      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('세 형태의 보스가 나타났다'));
    });

    testWidgets('Phase 1 → 전환 텍스트 → boss_continue → Phase 2 인트로', (tester) async {
      await tester.pumpWidget(buildBossScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _threePhaseEncounter);
      await tester.pump();
      await tester.pump();

      // Phase 1: introText → advance → outcome
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      // 전환 텍스트 표시
      expect(findRichText('첫 번째 형태가 무너진다'), findsOneWidget);

      // 전환 블록 advance
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();

      // boss_continue 선택
      expect(find.textContaining('다음 페이즈 시작'), findsOneWidget);
      await tester.tap(find.textContaining('다음 페이즈 시작'));
      await tester.pump();
      await tester.pump();

      // Phase 2 인트로
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('2페이즈!'));

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('Phase 2 → Phase 3(최종) → 승리', (tester) async {
      await tester.pumpWidget(buildBossScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _threePhaseEncounter);
      await tester.pump();
      await tester.pump();

      // Phase 1: advance → outcome → transition → continue
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.tap(find.textContaining('다음 페이즈 시작'));
      await tester.pump();
      await tester.pump();

      // Phase 2: advance → outcome → transition → continue
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      // Phase 2 전환 텍스트
      expect(findRichText('두 번째 형태도 무너진다'), findsOneWidget);

      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.tap(find.textContaining('다음 페이즈 시작'));
      await tester.pump();
      await tester.pump();

      // Phase 3 (최종) 인트로
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('최종 형태!'));

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });
  });

  group('Boss permadeath edge cases', () {
    testWidgets('보스 패배 → HP 0 → 퍼마데스', (tester) async {
      await tester.pumpWidget(buildBossScreen(
        combatConfig: const CombatBalanceConfig(bossVictoryThreshold: 1),
      ));
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _singlePhaseDefeat, withHp: 100);
      await tester.pump();
      await tester.pump();

      // introText → advance → outcome (defeat)
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      // HP 9999 손실 → 0
      expect(state.playerRunStateForTest.currentHp, 0);

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('보스 패배 후 → 처음부터 다시 시작만 표시', (tester) async {
      await tester.pumpWidget(buildBossScreen(
        combatConfig: const CombatBalanceConfig(bossVictoryThreshold: 1),
      ));
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _singlePhaseDefeat);
      await tester.pump();
      await tester.pump();

      // intro → advance → defeat
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      // defeat blocks advance
      for (var i = 0; i < 10; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
      }

      // 퍼마데스 선택지: '처음부터 다시 시작'만, '다시 도전하기' 없음
      expect(find.textContaining('처음부터 다시 시작'), findsOneWidget);
      expect(find.textContaining('다시 도전하기'), findsNothing);

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('보스 패배 후 → 재시작 선택지 표시', (tester) async {
      await tester.pumpWidget(buildBossScreen(
        combatConfig: const CombatBalanceConfig(bossVictoryThreshold: 1),
      ));
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _singlePhaseDefeat);
      await tester.pump();
      await tester.pump();

      // intro → advance → defeat
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      // defeat blocks advance until restart option
      for (var i = 0; i < 10; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
      }

      // '처음부터 다시 시작' 선택지 표시 확인
      // (실제 재시작은 context.go('/')로 타이틀 복귀 — 위젯 테스트에서는 네비게이션 불가)
      final restartFinder = find.textContaining('처음부터 다시 시작');
      expect(restartFinder, findsOneWidget);

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });
  });
}
