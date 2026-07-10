import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';

import '../../../../helpers/game_screen_test_helper.dart';

/// 0턴 엘리트 전투 → 즉시 패배 (eliteVictoryThreshold=1, score=0 < 1 → defeat)
const _eliteEncounterA = CombatEncounter(
  roomType: RoomType.elite,
  enemyName: '그림자 기사',
  introText: '그림자 기사가 나타났다.',
  turns: [],
  victoryText: '승리!',
  defeatText: '패배했다...',
);

const _eliteEncounterB = CombatEncounter(
  roomType: RoomType.elite,
  enemyName: '다크 슬라임',
  introText: '다크 슬라임이 나타났다.',
  turns: [],
  victoryText: '승리!',
  defeatText: '졌다.',
);

void main() {
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  /// 0턴 엘리트 전투 결과까지 진행
  Future<void> advanceToEliteOutcome(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // 엘리트 경고 블록
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // intro 블록
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // combatOutcome 자동 resolve
    await tapGameScreen(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  group('GameScreen HP integration', () {
    testWidgets(
        'D-04: HP 100→패배 30→자동 방 완료→새 encounter→패배 30→HP 40 검증',
        (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: CombatFlowManager.toDynamicTextBlocks(_eliteEncounterA),
        encounter: _eliteEncounterA,
        gameEventBus: eventBus,
        combatConfig: const CombatBalanceConfig(
          basePlayerHp: 100,
          eliteDefeatHpLoss: 30,
          eliteVictoryThreshold: 1,
        ),
      ));

      // 첫 패배: HP 100 → 70
      await advanceToEliteOutcome(tester);
      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      expect(state.playerRunStateForTest.currentHp, 70);

      // D-04: 비-퍼마데스 패배 → 재도전 선택지 없이 자동 진행
      // HP 손실 블록 진행
      await tapGameScreen(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 재도전 선택지가 없음을 확인 (D-04 변경)
      expect(find.textContaining('다시 도전하기'), findsNothing);

      // 새 encounter로 전환 (직접 setCombatEncounter 호출)
      state.setCombatEncounter(_eliteEncounterB);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 새 encounter 패배: HP 70 → 40
      await advanceToEliteOutcome(tester);
      expect(state.playerRunStateForTest.currentHp, 40);
    });

    testWidgets('연속 encounter 패배→퍼마데스 검증',
        (tester) async {
      await tester.pumpWidget(buildGameScreenWidget(
        blockData: CombatFlowManager.toDynamicTextBlocks(_eliteEncounterA),
        encounter: _eliteEncounterA,
        gameEventBus: eventBus,
        combatConfig: const CombatBalanceConfig(
          basePlayerHp: 100,
          eliteDefeatHpLoss: 50,
          eliteVictoryThreshold: 1,
        ),
      ));

      // 첫 패배: HP 100 → 50
      await advanceToEliteOutcome(tester);
      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      expect(state.playerRunStateForTest.currentHp, 50);

      // 새 encounter로 전환 (직접 setCombatEncounter)
      state.setCombatEncounter(_eliteEncounterB);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 두 번째 패배: HP 50 → 0 → 퍼마데스
      await advanceToEliteOutcome(tester);
      expect(state.playerRunStateForTest.currentHp, 0);
      expect(state.playerRunStateForTest.isAlive, false);

      // '처음부터 다시 시작' 선택지 확인
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

      expect(find.textContaining('처음부터 다시 시작'), findsOneWidget);
    });
  });
}
