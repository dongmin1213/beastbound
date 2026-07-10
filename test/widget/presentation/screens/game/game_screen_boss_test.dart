import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/combat_reward_event.dart';
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

/// 0턴 2페이즈 보스 (즉시 phase1 승리 → BossPhaseTransition)
const _quickBossEncounter = CombatEncounter(
  roomType: RoomType.boss,
  enemyName: '테스트 보스',
  introText: '보스가 나타났다.\n\n여기서 쓰러지면... 돌아올 수 없다.',
  turns: [],
  victoryText: '보스를 쓰러뜨렸다!',
  defeatText: '보스에게 패배했다...',
  bossPhases: [
    BossPhasePresentation(
      introText: '',
      turns: [],
      transitionText: '보스가 형태를 바꾼다!',
    ),
    BossPhasePresentation(
      introText: '2페이즈 시작!',
      turns: [],
    ),
  ],
);

/// 0턴 보스 (bossVictoryThreshold=1 → 즉시 패배 → 퍼마데스)
const _defeatBossEncounter = CombatEncounter(
  roomType: RoomType.boss,
  enemyName: '패배 보스',
  introText: '패배 보스가 나타났다.\n\n여기서 쓰러지면... 돌아올 수 없다.',
  turns: [],
  victoryText: '보스를 쓰러뜨렸다!',
  defeatText: '보스에게 패배했다...',
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

  Widget buildBossGameScreen({
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

  group('GameScreen boss integration', () {
    testWidgets('보스 방 진입 → 인트로 텍스트(퍼마데스 경고 포함)', (tester) async {
      await tester.pumpWidget(buildBossGameScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest();
      await tester.pump();
      await tester.pump();

      // BossDemoEncounter 인트로에 퍼마데스 경고 포함
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('돌아올 수 없다'));
    });

    testWidgets('보스 페이즈 전환 → 전환 텍스트+HP 정보+계속 선택지', (tester) async {
      await tester.pumpWidget(buildBossGameScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _quickBossEncounter);
      await tester.pump();
      await tester.pump();

      // introText → tap to advance → combatOutcome(pending) auto-resolves
      await tapGameScreen(tester);
      await tester.pump(); // advance block
      await tester.pump(); // postFrameCallback → _resolvePendingOutcome
      await tester.pump(); // CombatBloc processes ResolveCombat → BossPhaseTransition
      await tester.pump(); // setState from _handleBossPhaseTransition

      // 전환 텍스트 + HP 정보가 표시됨
      expect(findRichText('보스가 형태를 바꾼다!'), findsOneWidget);
      expect(findRichText('HP:'), findsOneWidget);

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('boss_continue 선택 → Phase 2 인트로+턴 블록', (tester) async {
      await tester.pumpWidget(buildBossGameScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _quickBossEncounter);
      await tester.pump();
      await tester.pump();

      // introText → advance → combatOutcome auto-resolves → BossPhaseTransition
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 전환 텍스트 블록 advance
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();

      // boss_continue 선택지 표시 확인
      expect(find.textContaining('다음 페이즈 시작'), findsOneWidget);

      // boss_continue 선택
      await tester.tap(find.textContaining('다음 페이즈 시작'));
      await tester.pump();
      await tester.pump();

      // Phase 2 인트로 텍스트가 표시됨
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('2페이즈 시작!'));

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('보스 최종 승리 → 보상 이벤트 발행', (tester) async {
      CombatRewardEvent? receivedReward;
      eventBus.on<CombatRewardEvent>().listen((e) => receivedReward = e);

      await tester.pumpWidget(buildBossGameScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _quickBossEncounter);
      await tester.pump();
      await tester.pump();

      // Phase 1: introText → advance → outcome → BossPhaseTransition
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      // transition block advance
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();

      // boss_continue 선택
      await tester.tap(find.textContaining('다음 페이즈 시작'));
      await tester.pump();
      await tester.pump();

      // Phase 2: introText → advance → outcome → CombatResolved.victory
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      // 보스 보상 이벤트 발행 확인
      expect(receivedReward, isNotNull);
      expect(receivedReward!.goldAmount, 24); // baseGold(8) × 3.0
      expect(receivedReward!.rewardTag, 'boss_loot');

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('보스 패배 → 퍼마데스 플로우', (tester) async {
      await tester.pumpWidget(buildBossGameScreen(
        combatConfig: const CombatBalanceConfig(
          bossVictoryThreshold: 1, // score(0) < 1 → defeat
        ),
      ));
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _defeatBossEncounter);
      await tester.pump();
      await tester.pump();

      // introText → advance → outcome auto-resolves → CombatResolved.defeat
      await tapGameScreen(tester);
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      // HP 9999 손실 → 0 → 퍼마데스
      expect(state.playerRunStateForTest.currentHp, 0);

      // advance through defeat blocks
      for (var i = 0; i < 10; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
      }

      // 퍼마데스 → '처음부터 다시 시작' 선택지 (retry 없음)
      expect(find.textContaining('처음부터 다시 시작'), findsOneWidget);
      expect(find.textContaining('다시 도전하기'), findsNothing);

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('보스 페이즈 전환 시 기세 보존 (AC4)', (tester) async {
      await tester.pumpWidget(buildBossGameScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest(encounter: _quickBossEncounter);
      await tester.pump();
      await tester.pump();

      // Phase 1: introText → advance → combatOutcome auto-resolves → BossPhaseTransition
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // transition block advance
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();

      // boss_continue 선택지 표시됨
      expect(find.textContaining('다음 페이즈 시작'), findsOneWidget);

      // MomentumBloc에 기세 수동 설정 (Phase 1에서 기세 쌓인 상태 시뮬레이션)
      final ctx = tester.element(find.byType(GameScreen));
      final momentumBloc = ctx.read<MomentumBloc>();
      momentumBloc.add(ActionPerformed(ActionType.attack));
      await tester.pump();

      // 기세가 non-initial인지 확인
      expect(momentumBloc.state, isA<MomentumUpdated>());
      final momentumBefore = (momentumBloc.state as MomentumUpdated).value;

      // boss_continue 선택 → Phase 2 시작
      await tester.tap(find.textContaining('다음 페이즈 시작'));
      await tester.pump();
      await tester.pump();

      // 기세가 보존되었는지 확인 (MomentumReset 미발행)
      expect(momentumBloc.state, isA<MomentumUpdated>());
      expect((momentumBloc.state as MomentumUpdated).value, momentumBefore);

      // flutter_animate 타이머 드레인
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('비보스 방 진입 시 _bossEncounter 리셋', (tester) async {
      await tester.pumpWidget(buildBossGameScreen());
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      // 보스 방 진입
      state.enterBossForTest();
      await tester.pump();
      await tester.pump();

      // 보스 인카운터가 설정됨 확인 (TypewriterWidget 렌더링으로 간접 확인)
      expect(find.byType(TypewriterWidget), findsOneWidget);

      // 상점 방 진입 → 보스 상태 리셋됨
      state.enterShopForTest([]);
      await tester.pump();
      await tester.pump();

      // 상점 진입 텍스트 확인 (보스 인트로가 아님)
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('상점'));
    });
  });
}
