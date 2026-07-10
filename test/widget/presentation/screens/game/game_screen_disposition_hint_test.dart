import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

import '../../../../helpers/game_screen_test_helper.dart';

void main() {
  late GameEventBus gameEventBus;

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('GameScreen 성향 힌트', () {
    testWidgets('방 진입 + disposition 충분 → hint 표시', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // mercy 3 → threshold 충족
      gameState.applyDispositionForTest({DispositionAxis.mercy: 3});

      // 방 진입 시뮬레이션 (onRoomEntered + _tryShowDispositionHint)
      gameState.simulateRoomEnteredForTest();

      await tester.pump();

      final hintBlocks = gameState.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.dispositionHint)
          .toList();

      expect(hintBlocks, hasLength(1));
      expect(hintBlocks.first.text, contains('빛'));
    });

    testWidgets('disposition 부족 → 미표시', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // mercy 2 → threshold 미달 (기본 3)
      gameState.applyDispositionForTest({DispositionAxis.mercy: 2});

      gameState.simulateRoomEnteredForTest();

      await tester.pump();

      final hintBlocks = gameState.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.dispositionHint)
          .toList();

      expect(hintBlocks, isEmpty);
    });

    testWidgets('cooldown 중 미표시', (tester) async {
      await pumpGameScreen(
        tester,
        gameEventBus: gameEventBus,
        dispositionConfig: const DispositionConfig(hintCooldownRooms: 3),
        buildConfig: const BuildConfig(classChangeThreshold: 999),
      );

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // mercy 5 → threshold 충족
      gameState.applyDispositionForTest({DispositionAxis.mercy: 5});

      // 첫 방: 초기 roomsSinceLastHint=99 → 힌트 표시됨
      gameState.simulateRoomEnteredForTest();
      await tester.pump();

      final firstHints = gameState.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.dispositionHint)
          .toList();
      expect(firstHints, hasLength(1));

      // 두 번째 방: cooldown 3이라 미표시 (roomsSince=1)
      gameState.simulateRoomEnteredForTest();
      await tester.pump();

      final secondHints = gameState.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.dispositionHint)
          .toList();
      expect(secondHints, hasLength(1)); // 여전히 1개 (새로 추가 안 됨)
    });

    testWidgets('동점 → 미표시', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // mercy 3, shadow 3 → 동점 → null
      gameState.applyDispositionForTest({
        DispositionAxis.mercy: 3,
        DispositionAxis.shadow: 3,
      });

      gameState.simulateRoomEnteredForTest();
      await tester.pump();

      final hintBlocks = gameState.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.dispositionHint)
          .toList();

      expect(hintBlocks, isEmpty);
    });

    testWidgets('런 리셋 후 초기화 — hintIndex 0 복원 + 첫 방 힌트 표시',
        (tester) async {
      await pumpGameScreen(
        tester,
        gameEventBus: gameEventBus,
        buildConfig: const BuildConfig(classChangeThreshold: 999),
      );

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));

      // mercy 5 → threshold 충족
      gameState.applyDispositionForTest({DispositionAxis.mercy: 5});

      // 첫 힌트 (hintIndex=0 → 텍스트[0])
      gameState.simulateRoomEnteredForTest();
      await tester.pump();

      final firstHint = gameState.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.dispositionHint)
          .first
          .text;

      // 런 리셋 → roomsSinceLastHint=99, hintIndex=0, disposition 초기화
      gameState.resetRunForTest(100);
      gameState.setTextBlocks(['리셋']); // completedBlocks 초기화

      // 리셋 후 다시 mercy 5 설정
      gameState.applyDispositionForTest({DispositionAxis.mercy: 5});

      // 방 진입 → hintIndex=0이므로 첫 번째와 동일한 텍스트
      gameState.simulateRoomEnteredForTest();
      await tester.pump();

      final postResetHints = gameState.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.dispositionHint)
          .toList();
      expect(postResetHints, hasLength(1));
      expect(postResetHints.first.text, firstHint); // hintIndex 0 복원 확인
    });
  });
}
