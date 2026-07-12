import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';

import '../../../../helpers/game_screen_test_helper.dart';
import '../../../../helpers/rich_text_finder.dart';

void main() {
  late GameEventBus gameEventBus;

  setUp(() {
    gameEventBus = GameEventBus();
  });

  tearDown(() {
    gameEventBus.dispose();
  });

  group('GameScreen 휴식 방 연동', () {
    testWidgets('진입 서술 텍스트 표시', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 60, withMaxHp: 100);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // AC 7: 진입 서술 텍스트 확인
      expect(findRichText('따뜻한 빛이 감도는 방이다.'), findsOneWidget);

      // RestWidget 렌더링 확인
      expect(find.text('휴식의 방'), findsOneWidget);
      expect(find.text('HP: 60 / 100'), findsOneWidget);
      expect(find.text('체력 회복'), findsOneWidget);
      expect(find.text('축복 강화'), findsOneWidget);
    });

    testWidgets('회복 선택 → HP 증가', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 60, withMaxHp: 100);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // 회복 선택
      await tester.tap(find.text('체력 회복'));
      await tester.pump(); // RestBloc ChooseHeal → RestClosed
      await tester.pump(); // BlocListener → _onRestClosed
      await tester.pump(); // setState + _appendFeedbackText
      await tester.pump(); // scroll

      // HP 업데이트 확인 (60 + 15 = 75, hpRecoveryPercent=0.15 → 100*0.15=15)
      expect(gameState.playerRunStateForTest.currentHp, 75);

      // 피드백 텍스트
      expect(findRichText('체력이 15 회복되었다!'), findsOneWidget);
    });

    testWidgets('강화 선택 → maxHp 증가', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 60, withMaxHp: 100);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // 강화 선택
      await tester.tap(find.text('축복 강화'));
      await tester.pump(); // RestBloc ChooseUpgrade → RestClosed
      await tester.pump(); // BlocListener → _onRestClosed
      await tester.pump(); // setState + _appendFeedbackText
      await tester.pump(); // scroll

      // maxHp 업데이트 확인 (100 + 3 = 103)
      expect(gameState.playerRunStateForTest.maxHp, 103);

      // 피드백 텍스트
      expect(findRichText('최대 체력이 3 증가했다!'), findsOneWidget);
    });

    testWidgets('full HP 회복 선택 → 피드백 "잠시 쉬어갔다."', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 100, withMaxHp: 100);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // full HP 전용 문구 확인
      expect(find.text('이미 최대 체력이지만, 잠시 쉬어갈 수 있다.'), findsOneWidget);

      // 회복 선택 (healAmount=0)
      await tester.tap(find.text('체력 회복'));
      await tester.pump(); // RestBloc ChooseHeal → RestClosed(0, 0)
      await tester.pump(); // BlocListener → _onRestClosed
      await tester.pump(); // setState + _appendFeedbackText
      await tester.pump(); // scroll

      // HP 변화 없음
      expect(gameState.playerRunStateForTest.currentHp, 100);
      expect(gameState.playerRunStateForTest.maxHp, 100);

      // 기본 피드백 텍스트
      expect(findRichText('잠시 쉬어갔다.'), findsOneWidget);
    });

    testWidgets('HP 캡핑 동작 확인 (거의 풀 HP)', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      // currentHp=95, maxHp=100 → rawHeal=15, missingHp=5 → healAmount=5
      gameState.enterRestForTest(withHp: 95, withMaxHp: 100);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // healAmount=5 표시 확인
      expect(find.text('+5 HP'), findsOneWidget);

      // 회복 선택
      await tester.tap(find.text('체력 회복'));
      await tester.pump(); // RestBloc ChooseHeal → RestClosed(5, 0)
      await tester.pump(); // BlocListener → _onRestClosed
      await tester.pump(); // setState + _appendFeedbackText
      await tester.pump(); // scroll

      // HP 업데이트 확인 (95 + 5 = 100)
      expect(gameState.playerRunStateForTest.currentHp, 100);

      // 피드백 텍스트
      expect(findRichText('체력이 5 회복되었다!'), findsOneWidget);
    });

    testWidgets('custom RestConfig 전파 확인', (tester) async {
      const customConfig = RestConfig(hpRecoveryPercent: 0.5, maxHpIncrease: 20);
      await pumpGameScreen(tester, gameEventBus: gameEventBus, restConfig: customConfig);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 60, withMaxHp: 100);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // 50% 회복: rawHeal=50, missingHp=40 → healAmount=40, upgradeAmount=20
      expect(find.text('+40 HP'), findsOneWidget);
      expect(find.text('+20 최대 HP'), findsOneWidget);
    });

    // === Story 3-7: 기세 초기화 피드백 ===

    testWidgets('회복 선택 → "야성이 초기화되었다" 피드백 + MomentumBloc 리셋', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      // M2: 기세 축적 후 리셋 검증 (end-to-end 통합)
      final momentumBloc =
          tester.element(find.byType(GameScreen)).read<MomentumBloc>();
      momentumBloc.add(const ActionPerformed(ActionType.attack));
      momentumBloc.add(const ActionPerformed(ActionType.defend));
      await tester.pump();
      await tester.pump();
      expect(momentumBloc.state, isA<MomentumUpdated>());

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 60, withMaxHp: 100);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('체력 회복'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(findRichText('야성이 초기화되었다'), findsOneWidget);
      // M2: MomentumBloc 실제 리셋 검증
      expect(momentumBloc.state, const MomentumInitial());
    });

    testWidgets('강화 선택 → "야성이 초기화되었다" 피드백 + MomentumBloc 리셋', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      // M2: 기세 축적 후 리셋 검증
      final momentumBloc =
          tester.element(find.byType(GameScreen)).read<MomentumBloc>();
      momentumBloc.add(const ActionPerformed(ActionType.attack));
      momentumBloc.add(const ActionPerformed(ActionType.defend));
      await tester.pump();
      await tester.pump();
      expect(momentumBloc.state, isA<MomentumUpdated>());

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 60, withMaxHp: 100);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('축복 강화'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(findRichText('야성이 초기화되었다'), findsOneWidget);
      expect(momentumBloc.state, const MomentumInitial());
    });

    testWidgets('full HP 회복 선택 → "잠시 쉬어갔다. 야성이 초기화되었다." 피드백', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      // M2: 기세 축적 후 리셋 검증
      final momentumBloc =
          tester.element(find.byType(GameScreen)).read<MomentumBloc>();
      momentumBloc.add(const ActionPerformed(ActionType.attack));
      momentumBloc.add(const ActionPerformed(ActionType.defend));
      await tester.pump();
      await tester.pump();
      expect(momentumBloc.state, isA<MomentumUpdated>());

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 100, withMaxHp: 100);

      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('체력 회복'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // 3번째 분기: hpRecovered=0, maxHpIncreased=0 → "잠시 쉬어갔다. 야성이 초기화되었다."
      expect(findRichText('잠시 쉬어갔다. 야성이 초기화되었다.'), findsOneWidget);
      expect(momentumBloc.state, const MomentumInitial());
    });

    testWidgets('휴식 완료 → 탐색 복귀 (위젯 사라짐)', (tester) async {
      await pumpGameScreen(tester, gameEventBus: gameEventBus);

      final gameState =
          tester.state<GameScreenState>(find.byType(GameScreen));
      gameState.enterRestForTest(withHp: 60, withMaxHp: 100);

      await tester.pump(); // rebuild
      await tester.pump(); // typewriter onComplete
      await tester.pump(); // rebuild after setState

      // RestWidget 표시 확인
      expect(find.text('휴식의 방'), findsOneWidget);

      // 회복 선택
      await tester.tap(find.text('체력 회복'));
      await tester.pump(); // RestBloc ChooseHeal → RestClosed
      await tester.pump(); // BlocListener → _onRestClosed
      await tester.pump(); // setState
      await tester.pump(); // rebuild

      // RestWidget 사라짐 확인
      expect(find.text('휴식의 방'), findsNothing);
    });
  });
}
