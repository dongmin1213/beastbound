import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/combat_reward_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';

import '../../../../helpers/game_screen_test_helper.dart';

void main() {
  late GameEventBus eventBus;

  setUp(() {
    eventBus = GameEventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  group('Cross-domain event flows via GameEventBus', () {
    testWidgets('CombatRewardEvent → 골드 누적', (tester) async {
      await pumpGameScreen(tester, gameEventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final initialGold = state.playerRunStateForTest.gold;

      // CombatRewardEvent 발행 (GameEventBus 경유)
      eventBus.emit(CombatRewardEvent(goldAmount: 30, rewardTag: 'test'));
      await tester.pump();
      await tester.pump();

      // 골드 누적 확인
      expect(state.playerRunStateForTest.gold, initialGold + 30);
    });

    testWidgets('다중 CombatRewardEvent → 누적 합산', (tester) async {
      await pumpGameScreen(tester, gameEventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final initialGold = state.playerRunStateForTest.gold;

      eventBus.emit(CombatRewardEvent(goldAmount: 10, rewardTag: 'a'));
      await tester.pump();
      await tester.pump();

      eventBus.emit(CombatRewardEvent(goldAmount: 20, rewardTag: 'b'));
      await tester.pump();
      await tester.pump();

      expect(state.playerRunStateForTest.gold, initialGold + 30);
    });

    testWidgets('GameEventBus 히스토리 유지', (tester) async {
      await pumpGameScreen(tester, gameEventBus: eventBus);

      eventBus.emit(CombatRewardEvent(goldAmount: 5, rewardTag: 'hist'));
      await tester.pump();

      expect(eventBus.history, isNotEmpty);
      expect(
        eventBus.history.whereType<CombatRewardEvent>().first.goldAmount,
        5,
      );
    });
  });
}
