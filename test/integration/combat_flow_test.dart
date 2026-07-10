import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/combat_reward_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import 'helpers/integration_test_helper.dart';

void main() {
  IntegrationTestHelper.ensureInitialized();

  group('Combat flow', () {
    testWidgets('보스 전투 진입 → 인트로 텍스트 렌더링', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest();
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // 보스 인트로 텍스트 (TypewriterWidget)
      expect(find.byType(TypewriterWidget), findsOneWidget);

      eventBus.dispose();
    });

    testWidgets('보스 전투 진입 → 퍼마데스 경고 포함', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.enterBossForTest();
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // 보스 인트로에 퍼마데스 경고 텍스트
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('돌아올 수 없다'));

      eventBus.dispose();
    });

    testWidgets('앱 시작 → 초기 HP 100', (tester) async {
      await IntegrationTestHelper.launchApp(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      expect(state.playerRunStateForTest.currentHp, 100);
      expect(state.playerRunStateForTest.maxHp, 100);
    });

    testWidgets('CombatRewardEvent → 골드 반영', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final initialGold = state.playerRunStateForTest.gold;

      // 보상 이벤트 발행
      eventBus.emit(CombatRewardEvent(goldAmount: 50, rewardTag: 'test'));
      await IntegrationTestHelper.pumpFrames(tester, 5);

      expect(state.playerRunStateForTest.gold, initialGold + 50);

      eventBus.dispose();
    });
  });
}
