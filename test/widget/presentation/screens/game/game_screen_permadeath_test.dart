import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/permadeath_event.dart';
import 'package:soul_dungeon/core/events/player_damaged_event.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import '../../../../helpers/game_screen_test_helper.dart';

/// 0턴 전투 → 즉시 패배 (score=0, victoryThreshold=1)
const _defeatEncounter = CombatEncounter(
  roomType: RoomType.elite,
  enemyName: '그림자 기사',
  introText: '그림자 기사가 나타났다.',
  turns: [],
  victoryText: '승리!',
  defeatText: '패배했다...',
);

void main() {
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  Widget buildGameScreen({
    CombatEncounter encounter = _defeatEncounter,
    CombatBalanceConfig combatConfig = const CombatBalanceConfig(
      eliteVictoryThreshold: 1,
      eliteDefeatHpLoss: 50,
    ),
  }) {
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

  /// 0턴 전투 결과까지 진행:
  /// 엘리트는 eliteWarning(1) + introText(2) + combatOutcome(자동 resolve)
  /// 블록 순서: [eliteWarning, introText, combatOutcome(pending)]
  /// pumpAndSettle → introText 렌더 → tap → advance → eliteWarning 완료
  /// → tap → advance → introText 완료 → tap → advance → combatOutcome 자동 resolve
  Future<void> advanceToOutcome(
    WidgetTester tester, {
    bool isElite = true,
  }) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
    if (isElite) {
      // 엘리트 경고 블록 완료 후 진행
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
    }
    // introText 블록 완료 후 진행
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // combatOutcome 자동 resolve + 자동 완료
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  group('GameScreen permadeath', () {
    testWidgets('패배 시 HP 감소 + PlayerDamagedEvent 발행', (tester) async {
      PlayerDamagedEvent? receivedEvent;
      eventBus.on<PlayerDamagedEvent>().listen((e) => receivedEvent = e);

      await tester.pumpWidget(buildGameScreen());
      await advanceToOutcome(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      // 엘리트 패배: 50 HP 손실 (basePlayerHp=100 → 50 remaining)
      expect(state.playerRunStateForTest.currentHp, 50);
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.hpLost, 50);
      expect(receivedEvent!.remainingHp, 50);
    });

    testWidgets('D-04: 일반 패배 시 자동 진행 (재도전 없음)', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await advanceToOutcome(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      expect(state.playerRunStateForTest.currentHp, 50);

      // D-04: 재도전/물러나기 선택지 없음
      expect(find.textContaining('다시 도전하기'), findsNothing);
      expect(find.textContaining('물러나기'), findsNothing);
    });

    testWidgets('HP 0 도달 시 퍼마데스 발동 + PermadeathEvent 발행',
        (tester) async {
      PermadeathEvent? receivedEvent;
      eventBus.on<PermadeathEvent>().listen((e) => receivedEvent = e);

      // basePlayerHp=50, eliteDefeatHpLoss=50 → 한 번 패배로 퍼마데스
      await tester.pumpWidget(buildGameScreen(
        combatConfig: const CombatBalanceConfig(
          basePlayerHp: 50,
          eliteDefeatHpLoss: 50,
          eliteVictoryThreshold: 1,
        ),
      ));
      await advanceToOutcome(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      expect(state.playerRunStateForTest.currentHp, 0);
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.finalHp, 0);
      expect(receivedEvent!.defeatedBy, '그림자 기사');

      // HP 블록 + 퍼마데스 서술 블록 진행
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // 빈 텍스트 선택지 블록 (자동 진행)
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // '처음부터 다시 시작' 선택지 표시
      expect(find.textContaining('처음부터 다시 시작'), findsOneWidget);
      // '다시 도전하기'는 없어야 함
      expect(find.textContaining('다시 도전하기'), findsNothing);
    });

    testWidgets('재시작 선택지 표시', (tester) async {
      // basePlayerHp=50, eliteDefeatHpLoss=50 → 한 번 패배로 퍼마데스
      await tester.pumpWidget(buildGameScreen(
        combatConfig: const CombatBalanceConfig(
          basePlayerHp: 50,
          eliteDefeatHpLoss: 50,
          eliteVictoryThreshold: 1,
        ),
      ));
      await advanceToOutcome(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      expect(state.playerRunStateForTest.currentHp, 0);

      // HP 블록 + 퍼마데스 서술 블록 + 선택지 블록 진행
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // '처음부터 다시 시작' 선택지 표시 확인
      // (실제 재시작은 context.go('/')로 타이틀 복귀 — 위젯 테스트에서는 네비게이션 불가)
      expect(find.textContaining('처음부터 다시 시작'), findsOneWidget);
    });

    testWidgets('D-04: 일반 패배 → 재도전/물러나기 미표시 확인', (tester) async {
      await tester.pumpWidget(buildGameScreen());
      await advanceToOutcome(tester);

      // HP 블록 진행
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // D-04: 재도전/물러나기 선택지 없음 — 자동 진행
      expect(find.textContaining('다시 도전하기'), findsNothing);
      expect(find.textContaining('물러나기'), findsNothing);
    });
  });
}
