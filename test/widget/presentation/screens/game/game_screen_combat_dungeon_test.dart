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
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_demo_encounter.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import '../../../../helpers/rich_text_finder.dart';
import '../../../../helpers/game_screen_test_helper.dart';

void main() {
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  Widget buildCombatGameScreen({
    CombatBalanceConfig combatConfig = const CombatBalanceConfig(),
  }) {
    final encounter = CombatDemoEncounter.create(combatConfig: combatConfig);
    final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
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
          initialBlockData: blocks,
          initialEncounter: encounter,
          gameEventBus: eventBus,
          combatConfig: combatConfig,
          economyConfig: const EconomyConfig(),
          speed: TextSpeed.instant,
          eventConfig: const EventConfig(),
        ),
      ),
    );
  }

  /// 0턴 일반 전투 encounter (threshold=0 → 즉시 승리)
  Widget buildZeroTurnVictoryScreen() {
    const encounter = CombatEncounter(
      enemyName: '허깨비',
      introText: '허깨비가 나타났다!',
      turns: [],
      victoryText: '허깨비가 사라졌다.',
      defeatText: '허깨비에게 졌다.',
    );
    final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
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
          initialBlockData: blocks,
          initialEncounter: encounter,
          gameEventBus: eventBus,
          combatConfig: const CombatBalanceConfig(),
          economyConfig: const EconomyConfig(),
          speed: TextSpeed.instant,
          eventConfig: const EventConfig(),
        ),
      ),
    );
  }

  /// 0턴 엘리트 전투 encounter (eliteVictoryThreshold=1, score=0 → 패배)
  Widget buildZeroTurnDefeatScreen() {
    const encounter = CombatEncounter(
      roomType: RoomType.elite,
      enemyName: '허깨비 엘리트',
      introText: '강한 허깨비가 나타났다!',
      turns: [],
      victoryText: '허깨비가 사라졌다.',
      defeatText: '허깨비에게 졌다.',
    );
    final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
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
          initialBlockData: blocks,
          initialEncounter: encounter,
          gameEventBus: eventBus,
          combatConfig: const CombatBalanceConfig(
            eliteVictoryThreshold: 1,
          ),
          economyConfig: const EconomyConfig(),
          speed: TextSpeed.instant,
          eventConfig: const EventConfig(),
        ),
      ),
    );
  }

  /// introText까지 진행
  Future<void> advancePastIntro(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // 환경 서술 블록 지나기
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // intro 블록 지나기
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  /// 0턴 전투 결과까지 진행
  Future<void> advanceToOutcomeZeroTurn(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // introText 블록 지나기
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // combatOutcome 블록 resolve
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  group('GameScreen combat dungeon integration', () {
    testWidgets('CombatDemoEncounter로 전투 블록이 렌더링됨', (tester) async {
      await tester.pumpWidget(buildCombatGameScreen());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 환경 서술 텍스트 확인
      expect(findRichText('좁은 통로'), findsOneWidget);

      // 진행 후 적 인트로 텍스트 확인
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(findRichText('떠도는 망령'), findsAtLeastNWidgets(1));
    });

    testWidgets('CombatDemoEncounter 전투 행동 선택지 표시', (tester) async {
      await tester.pumpWidget(buildCombatGameScreen());
      await advancePastIntro(tester);

      // 턴 구분자 지나기
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // 행동 예고 지나기
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 행동 선택지 표시
      expect(find.textContaining('공격한다'), findsOneWidget);
      expect(find.textContaining('방어한다'), findsOneWidget);
      expect(find.textContaining('관찰한다'), findsOneWidget);
    });

    testWidgets('0턴 일반 전투 승리 시 승리 텍스트 표시', (tester) async {
      await tester.pumpWidget(buildZeroTurnVictoryScreen());
      await advanceToOutcomeZeroTurn(tester);

      // 승리 텍스트 확인
      expect(find.textContaining('승리'), findsOneWidget);
      expect(find.textContaining('허깨비가 사라졌다'), findsOneWidget);
    });

    testWidgets('D-04: 0턴 엘리트 패배 시 자동 진행 (retry/retreat 없음)',
        (tester) async {
      await tester.pumpWidget(buildZeroTurnDefeatScreen());
      // 엘리트 경고 블록 + intro + outcome
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // 엘리트 경고 블록 지나기
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // intro 지나기
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // outcome resolve — CombatBloc이 패배 판정
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 패배 텍스트 확인
      expect(find.textContaining('패배'), findsOneWidget);

      // D-04: 비-퍼마데스 패배 → retry/retreat 선택지 없음 (자동 방 완료)
      expect(find.textContaining('다시 도전하기'), findsNothing);
      expect(find.textContaining('물러나기'), findsNothing);
    });
  });
}
