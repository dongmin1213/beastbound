import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

import '../../../../helpers/game_screen_test_helper.dart';

void main() {
  group('GameScreen — 직업 분화 (Story 4-3)', () {
    late GameEventBus gameEventBus;

    setUp(() {
      gameEventBus = GameEventBus();
    });

    tearDown(() {
      gameEventBus.dispose();
    });

    testWidgets('분화 텍스트 표시 — threshold 도달 시 classChange 블록 추가', (tester) async {
      await pumpGameScreen(
        tester,
        gameEventBus: gameEventBus,
        buildConfig: const BuildConfig(classChangeThreshold: 3),
      );

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      // threshold(3) 도달 — struggle:3
      state.applyDispositionForTest({DispositionAxis.struggle: 3});
      // simulateRoomEnteredForTest 대신 직접 방 진입 호출
      state.simulateRoomEnteredForTest();

      // BlocListener + pump + _onBuildStateChanged 100ms 타이머 소진
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // DungeonBloc 없이는 resumeAfterClassChange → setTextBlockData가
      // 호출되지 않아 pending 블록이 flush되지 않으므로 수동 flush
      state.flushPendingBlocksForTest();

      // classChange 블록이 completedBlocks에 존재
      final classChangeBlocks = state.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.classChange)
          .toList();
      expect(classChangeBlocks, isNotEmpty);
      expect(classChangeBlocks.first.text, contains('전사'));
    });

    testWidgets('threshold 미달 시 classChange 미표시', (tester) async {
      await pumpGameScreen(
        tester,
        gameEventBus: gameEventBus,
        buildConfig: const BuildConfig(classChangeThreshold: 8),
      );

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      // threshold(8) 미달 — struggle:5
      state.applyDispositionForTest({DispositionAxis.struggle: 5});
      state.simulateRoomEnteredForTest();

      await tester.pump();
      await tester.pump();

      final classChangeBlocks = state.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.classChange)
          .toList();
      expect(classChangeBlocks, isEmpty);
    });

    testWidgets('이미 분화된 상태에서 재트리거 안 함', (tester) async {
      await pumpGameScreen(
        tester,
        gameEventBus: gameEventBus,
        buildConfig: const BuildConfig(classChangeThreshold: 3),
      );

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      // 첫 번째 분화 — struggle:3
      state.applyDispositionForTest({DispositionAxis.struggle: 3});
      state.simulateRoomEnteredForTest();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      state.flushPendingBlocksForTest();

      final firstCount = state.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.classChange)
          .length;
      expect(firstCount, 1);

      // 두 번째 성향 추가 — mercy:3 (다른 축 threshold 도달)
      state.applyDispositionForTest({DispositionAxis.mercy: 3});
      state.simulateRoomEnteredForTest();
      await tester.pump();
      await tester.pump();
      state.flushPendingBlocksForTest();

      // 분화 블록 추가 안 됨 (이미 전사로 분화)
      final secondCount = state.completedBlocksForTest
          .where((b) => b.blockType == TextBlockType.classChange)
          .length;
      expect(secondCount, firstCount);
    });

    testWidgets('런 리셋 후 build 초기화', (tester) async {
      await pumpGameScreen(
        tester,
        gameEventBus: gameEventBus,
        buildConfig: const BuildConfig(classChangeThreshold: 3),
      );

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      // 분화 발생
      state.applyDispositionForTest({DispositionAxis.struggle: 3});
      state.simulateRoomEnteredForTest();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // currentJobId 확인
      expect(state.playerRunStateForTest.currentJobId, 'warrior');

      // 런 리셋
      state.resetRunForTest(100);
      await tester.pump();
      await tester.pump();

      // currentJobId가 null로 초기화
      expect(state.playerRunStateForTest.currentJobId, isNull);
    });
  });
}
