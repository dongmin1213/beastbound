import 'package:flutter/material.dart' hide SelectAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

/// GameScreen 위젯 빌드 — 동기, Widget 반환.
/// 모든 GameScreen 테스트에서 공용으로 사용.
Widget buildGameScreenWidget({
  List<TextBlockData>? blockData,
  CombatEncounter? encounter,
  GameEventBus? gameEventBus,
  MomentumConfig momentumConfig = const MomentumConfig(),
  CombatBalanceConfig combatConfig = const CombatBalanceConfig(),
  EconomyConfig economyConfig = const EconomyConfig(),
  RestConfig restConfig = const RestConfig(),
  EventConfig eventConfig = const EventConfig(),
  BuildConfig buildConfig = const BuildConfig(),
  DungeonBalanceConfig dungeonConfig = const DungeonBalanceConfig(),
  MysteryConfig mysteryConfig = const MysteryConfig(),
  NpcConfig npcConfig = const NpcConfig(),
  PrepConfig prepConfig = const PrepConfig(),
  RarityConfig rarityConfig = const RarityConfig(),
  FleeConfig fleeConfig = const FleeConfig(),
  DungeonGenerator? dungeonGenerator,
  TextSpeed speed = TextSpeed.instant,
  PlayerRunState? initialRunState,
}) {
  final eventBus = gameEventBus ?? GameEventBus();
  return MultiBlocProvider(
    providers: [
      BlocProvider<MomentumBloc>(
        create: (_) => MomentumBloc(
          gameEventBus: eventBus,
          config: momentumConfig,
        ),
      ),
      BlocProvider<ProgressionBloc>(
        create: (_) => ProgressionBloc(gameEventBus: eventBus),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: GameScreen(
        initialBlockData: blockData ?? [const TextBlockData(text: '테스트')],
        initialEncounter: encounter,
        gameEventBus: eventBus,
        dungeonGenerator: dungeonGenerator,
        speed: speed,
        momentumConfig: momentumConfig,
        combatConfig: combatConfig,
        economyConfig: economyConfig,
        restConfig: restConfig,
        eventConfig: eventConfig,
        buildConfig: buildConfig,
        dungeonConfig: dungeonConfig,
        mysteryConfig: mysteryConfig,
        npcConfig: npcConfig,
        prepConfig: prepConfig,
        rarityConfig: rarityConfig,
        fleeConfig: fleeConfig,
        initialRunState: initialRunState,
      ),
    ),
  );
}

/// GameScreen 위젯 펌프 — 비동기, pump 2회 포함.
/// pumpAndSettle 대신 명시적 pump 사용 (_scrollToBottom animateTo 무한 루프 방지).
Future<void> pumpGameScreen(
  WidgetTester tester, {
  List<TextBlockData>? blockData,
  CombatEncounter? encounter,
  GameEventBus? gameEventBus,
  MomentumConfig momentumConfig = const MomentumConfig(),
  CombatBalanceConfig combatConfig = const CombatBalanceConfig(),
  EconomyConfig economyConfig = const EconomyConfig(),
  RestConfig restConfig = const RestConfig(),
  EventConfig eventConfig = const EventConfig(),
  BuildConfig buildConfig = const BuildConfig(),
  DungeonBalanceConfig dungeonConfig = const DungeonBalanceConfig(),
  MysteryConfig mysteryConfig = const MysteryConfig(),
  NpcConfig npcConfig = const NpcConfig(),
  PrepConfig prepConfig = const PrepConfig(),
  RarityConfig rarityConfig = const RarityConfig(),
  FleeConfig fleeConfig = const FleeConfig(),
  DungeonGenerator? dungeonGenerator,
  TextSpeed speed = TextSpeed.instant,
  PlayerRunState? initialRunState,
}) async {
  await tester.pumpWidget(buildGameScreenWidget(
    blockData: blockData,
    encounter: encounter,
    gameEventBus: gameEventBus,
    momentumConfig: momentumConfig,
    combatConfig: combatConfig,
    economyConfig: economyConfig,
    restConfig: restConfig,
    eventConfig: eventConfig,
    buildConfig: buildConfig,
    dungeonConfig: dungeonConfig,
    mysteryConfig: mysteryConfig,
    npcConfig: npcConfig,
    prepConfig: prepConfig,
    rarityConfig: rarityConfig,
    fleeConfig: fleeConfig,
    dungeonGenerator: dungeonGenerator,
    speed: speed,
    initialRunState: initialRunState,
  ));
  await tester.pump(); // post-frame callback (onComplete)
  await tester.pump(); // rebuild after setState
}

/// GameScreen 메인 GestureDetector 탭 — 텍스트 진행용.
///
/// 레이아웃 변경 후 `find.byType(GestureDetector).first`가 하단 선택지의
/// GestureDetector를 잡는 문제 해결. Key 기반으로 메인 탭 영역을 명시적 탭.
Future<void> tapGameScreen(WidgetTester tester) async {
  final finder = find.byKey(const ValueKey('game_screen_tap_area'));
  final topLeft = tester.getTopLeft(finder);
  await tester.tapAt(topLeft + const Offset(50, 50));
}
