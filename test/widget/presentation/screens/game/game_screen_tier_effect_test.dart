import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';
import '../../../../helpers/game_screen_test_helper.dart';

/// 테스트용 MomentumBloc: emit을 직접 호출하여 상태 설정 가능
class _TestMomentumBloc extends MomentumBloc {
  _TestMomentumBloc({required super.gameEventBus, required super.config});

  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  void forceState(MomentumState newState) => emit(newState);
}

/// 1턴 전투 헬퍼
CombatEncounter _oneTurnCombat(
    {EnemyActionType enemyAction = EnemyActionType.observe}) {
  return CombatEncounter(
    enemyName: '테스트 적',
    introText: '적이 나타났다!',
    turns: [
      CombatTurnData(
        turnNumber: 1,
        enemyAction: EnemyAction(
          type: enemyAction,
          previewText: '적이 행동을 준비한다',
        ),
        playerChoices: const [],
      ),
    ],
    victoryText: '적을 물리쳤다!',
    defeatText: '패배했다.',
  );
}

void main() {
  const config = MomentumConfig();

  Widget buildGameScreen({
    required MomentumBloc bloc,
    required CombatEncounter encounter,
    GameEventBus? eventBus,
  }) {
    final blocks = CombatFlowManager.toDynamicTextBlocks(encounter);
    final bus = eventBus ?? GameEventBus();
    return MultiBlocProvider(
      providers: [
        BlocProvider<MomentumBloc>.value(
          value: bloc,
        ),
        BlocProvider<ProgressionBloc>(
          create: (_) => ProgressionBloc(gameEventBus: bus),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: GameScreen(
          initialBlockData: blocks,
          initialEncounter: encounter,
          gameEventBus: bus,
          speed: TextSpeed.instant,
          momentumConfig: config,
          eventConfig: const EventConfig(),
        ),
      ),
    );
  }

  /// 전투 선택지 화면까지 내비게이션하는 헬퍼
  Future<void> navigateToChoices(WidgetTester tester) async {
    // intro → tap → auto-advance(turn divider) → auto-advance(combat preview) → 선택지 화면
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // combat preview auto-complete → tap to advance to choices
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  group('GameScreen tier effect text', () {
    testWidgets('기세 높음(≥80) + effective → "결정적 일격!" 표시',
        (tester) async {
      final eventBus = GameEventBus();
      final bloc = _TestMomentumBloc(gameEventBus: eventBus, config: config);

      // 적이 observe → 플레이어 attack = effective
      final encounter = _oneTurnCombat(enemyAction: EnemyActionType.observe);
      await tester.pumpWidget(buildGameScreen(
          bloc: bloc, encounter: encounter, eventBus: eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await navigateToChoices(tester);

      // 전투 시작 시 MomentumReset이 발행되므로, 선택지 도달 후 기세 상태 설정
      bloc.forceState(const MomentumUpdated(
        value: 90,
        tier: MomentumTier.high,
        lastDelta: MomentumDelta(value: 15, reason: MomentumChangeReason.actionSwitch),
        lastActionType: ActionType.attack,
      ));
      await tester.pump();

      // 공격 선택
      final attackChoice = find.textContaining('공격한다');
      expect(attackChoice, findsOneWidget);
      await tester.tap(attackChoice);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 높은 기세 + effective → "결정적 일격!"
      expect(find.text('결정적 일격!'), findsOneWidget);

      bloc.close();
    });

    testWidgets('기세 중간(60~79) + effective → 효과 텍스트 미표시',
        (tester) async {
      final eventBus = GameEventBus();
      final bloc = _TestMomentumBloc(gameEventBus: eventBus, config: config);

      final encounter = _oneTurnCombat(enemyAction: EnemyActionType.observe);
      await tester.pumpWidget(buildGameScreen(
          bloc: bloc, encounter: encounter, eventBus: eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await navigateToChoices(tester);

      // 전투 시작 시 MomentumReset이 발행되므로, 선택지 도달 후 기세 상태 설정
      bloc.forceState(const MomentumUpdated(
        value: 65,
        tier: MomentumTier.medium,
        lastDelta: MomentumDelta(value: 15, reason: MomentumChangeReason.actionSwitch),
        lastActionType: ActionType.attack,
      ));
      await tester.pump();

      final attackChoice = find.textContaining('공격한다');
      expect(attackChoice, findsOneWidget);
      await tester.tap(attackChoice);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 중간 기세 → 효과 텍스트 없음
      expect(find.text('결정적 일격!'), findsNothing);
      expect(find.text('밀어붙인다!'), findsNothing);
      expect(find.text('힘이 빠진다...'), findsNothing);
      expect(find.text('적이 반격한다!'), findsNothing);

      bloc.close();
    });

    testWidgets('기세 낮음(<60) + ineffective → "힘이 빠진다..." 표시',
        (tester) async {
      final eventBus = GameEventBus();
      final bloc = _TestMomentumBloc(gameEventBus: eventBus, config: config);

      // 기세 0(초기 = MomentumInitial) → low 티어
      // 적이 defend → 플레이어 attack = ineffective
      final encounter = _oneTurnCombat(enemyAction: EnemyActionType.defend);
      await tester.pumpWidget(buildGameScreen(
          bloc: bloc, encounter: encounter, eventBus: eventBus));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await navigateToChoices(tester);

      final attackChoice = find.textContaining('공격한다');
      expect(attackChoice, findsOneWidget);
      await tester.tap(attackChoice);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 낮은 기세 + ineffective → "힘이 빠진다..."
      expect(find.text('힘이 빠진다...'), findsOneWidget);

      bloc.close();
    });
  });
}
