import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/domain/dungeon/npc/npc_data.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/mystery/mystery_widget.dart';
import 'package:soul_dungeon/presentation/widgets/npc/npc_widget.dart';
import 'package:soul_dungeon/presentation/widgets/rest/rest_widget.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import 'helpers/integration_test_helper.dart';

void main() {
  IntegrationTestHelper.ensureInitialized();

  group('Room flows', () {
    testWidgets('미스터리 방 진입 → MysteryWidget 렌더링', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      const outcome = TreasureOutcome(
        narrativeText: '신비로운 상자를 발견했다.',
        goldReward: 10,
      );
      state.enterMysteryForTest(outcome);
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // MysteryWidget 렌더링 확인
      expect(find.byType(MysteryWidget), findsOneWidget);

      eventBus.dispose();
    });

    testWidgets('휴식 방 진입 → RestWidget 렌더링', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      state.enterRestForTest(withHp: 50, withMaxHp: 100);
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // RestWidget 렌더링 확인
      expect(find.byType(RestWidget), findsOneWidget);

      eventBus.dispose();
    });

    testWidgets('NPC 방 진입 → NpcWidget 렌더링', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      const npcData = NpcData(
        id: 'test_npc',
        name: '방랑 상인',
        npcType: NpcType.trader,
        greetingText: '무엇을 찾으시오?',
        dialogueText: '좋은 물건이 있소.',
        tradeItems: [],
        goldReward: 0,
      );
      state.enterNpcForTest(npcData);
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // NpcWidget 렌더링 확인
      expect(find.byType(NpcWidget), findsOneWidget);

      eventBus.dispose();
    });

    testWidgets('보스 방 진입 → 퍼마데스 경고 텍스트', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      state.enterBossForTest();
      await IntegrationTestHelper.pumpFrames(tester, 5);

      // 보스 인트로 (TypewriterWidget)에 퍼마데스 경고 포함
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('돌아올 수 없다'));

      eventBus.dispose();
    });
  });
}
