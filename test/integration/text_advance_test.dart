import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import 'helpers/integration_test_helper.dart';
import '../helpers/game_screen_test_helper.dart';

void main() {
  IntegrationTestHelper.ensureInitialized();

  group('Text advance', () {
    testWidgets('인트로 텍스트 탭 → 선택 프롬프트 블록으로 진행', (tester) async {
      await IntegrationTestHelper.launchApp(tester);

      // 인트로 텍스트 렌더링 확인
      expect(find.byType(TypewriterWidget), findsOneWidget);

      // 인트로 텍스트 완료 대기 (normal speed → 애니메이션)
      await IntegrationTestHelper.pumpFrames(tester, 60); // 3초 대기

      // 탭 → advance
      await tapGameScreen(tester);
      await IntegrationTestHelper.pumpFrames(tester, 60); // 3초 대기

      // 두 번째 블록 (선택 프롬프트) 표시
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('무엇을 챙기겠는가'));
    });

    testWidgets('선택 프롬프트 완료 → 선택지 표시', (tester) async {
      await IntegrationTestHelper.launchApp(tester);

      // 인트로 완료 대기 + advance
      await IntegrationTestHelper.pumpFrames(tester, 60);
      await tapGameScreen(tester);
      await IntegrationTestHelper.pumpFrames(tester, 60);

      // 선택 프롬프트 완료 대기
      await IntegrationTestHelper.pumpFrames(tester, 60);

      // 6개 중 랜덤 3개 선택지가 표시됨
      final allNames = [
        '노련한 탐험가의 주머니', '생명력의 부적', '선대 모험가의 축복',
        '고대의 유물', '치유사의 기도', '방랑자의 배낭',
      ];
      int visibleCount = 0;
      for (final name in allNames) {
        if (find.textContaining(name).evaluate().isNotEmpty) visibleCount++;
      }
      expect(visibleCount, 3, reason: '6개 중 3개 선택지가 표시되어야 함');
    });

    testWidgets('선택지 탭 → 상태 변경', (tester) async {
      await IntegrationTestHelper.launchApp(tester);

      // 인트로 → advance → 선택 프롬프트 → 완료 → 선택지 표시
      await IntegrationTestHelper.pumpFrames(tester, 60);
      await tapGameScreen(tester);
      await IntegrationTestHelper.pumpFrames(tester, 120); // 선택 프롬프트 + 선택지

      // 6개 중 표시된 아무 선택지 탭
      final allNames = [
        '노련한 탐험가의 주머니', '생명력의 부적', '선대 모험가의 축복',
        '고대의 유물', '치유사의 기도', '방랑자의 배낭',
      ];
      Finder? choiceFinder;
      for (final name in allNames) {
        final f = find.textContaining(name);
        if (f.evaluate().isNotEmpty) {
          choiceFinder = f;
          break;
        }
      }
      expect(choiceFinder, isNotNull, reason: '선택지가 하나 이상 표시되어야 함');
      await tester.tap(choiceFinder!);
      await IntegrationTestHelper.pumpFrames(tester, 40);

      // 선택 후 상태 변경 확인 (골드/HP/축복/유물 중 하나)
      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final s = state.playerRunStateForTest;
      expect(
        s.gold > 0 || s.maxHp > 100 || s.ownedBlessingIds.isNotEmpty || s.ownedRelicIds.isNotEmpty,
        isTrue,
        reason: '선택 후 상태가 변경되어야 함',
      );
    });
  });
}
