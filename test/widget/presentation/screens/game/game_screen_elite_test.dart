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
import 'package:soul_dungeon/presentation/widgets/combat_ui/elite_demo_encounter.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import '../../../../helpers/game_screen_test_helper.dart';

void main() {
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  Widget buildEliteGameScreen() {
    final encounter = EliteDemoEncounter.create();
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

  group('GameScreen elite integration', () {
    testWidgets('엘리트 데모 encounter가 전투 블록으로 변환되어 렌더링됨', (tester) async {
      await tester.pumpWidget(buildEliteGameScreen());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.setCombatEncounter(EliteDemoEncounter.create());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // setCombatEncounter 후 GameScreen이 전투 블록을 렌더링 시작
      expect(find.byType(TypewriterWidget), findsOneWidget);
    });

    testWidgets('전투 승리 시 CombatRewardEvent 발행됨', (tester) async {
      await tester.pumpWidget(buildEliteGameScreen());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // GameEventBus에서 CombatRewardEvent 구독
      CombatRewardEvent? receivedEvent;
      eventBus.on<CombatRewardEvent>().listen((event) {
        receivedEvent = event;
      });

      // GameScreenState를 직접 접근하여 setCombatEncounter 후 조작
      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      // 0턴 전투 (즉시 승리 — score=0, threshold=0인 일반 전투)로 빠르게 보상 이벤트 검증
      const quickEncounter = CombatEncounter(
        roomType: RoomType.combat,
        enemyName: '약한 적',
        introText: '약한 적이 나타났다.',
        turns: [],
        victoryText: '승리!',
        defeatText: '패배!',
      );
      state.setCombatEncounter(quickEncounter);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 0턴 전투: intro → outcome(pending → victory) 자동 진행
      // 모든 블록 진행
      for (var i = 0; i < 10; i++) {
        await tapGameScreen(tester);
        await tester.pump();
        await tester.pump();
        await tester.pump();
      }

      // 보상 이벤트가 발행되었는지 확인
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.goldAmount, 8); // 일반 전투: base gold
      expect(receivedEvent!.rewardTag, isNull);
    });
  });
}
