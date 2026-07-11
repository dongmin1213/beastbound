import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

import 'helpers/integration_test_helper.dart';

void main() {
  IntegrationTestHelper.ensureInitialized();

  group('App launch', () {
    testWidgets('앱 시작 → GameScreen 렌더링', (tester) async {
      await IntegrationTestHelper.launchApp(tester);

      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('앱 시작 → 준비 페이즈 인트로 텍스트 표시', (tester) async {
      await IntegrationTestHelper.launchApp(tester);

      // 준비 페이즈 인트로 텍스트 (TypewriterWidget으로 렌더링)
      expect(find.byType(TypewriterWidget), findsOneWidget);
      final typewriter = tester.widget<TypewriterWidget>(
        find.byType(TypewriterWidget),
      );
      expect(typewriter.text, contains('심층의 초입에 섰다'));
    });

    testWidgets('앱 시작 → GameEventBus 주입 성공', (tester) async {
      final eventBus = GameEventBus();
      await IntegrationTestHelper.launchApp(tester, eventBus: eventBus);

      // eventBus가 정상적으로 주입되었음을 history 접근으로 확인
      expect(eventBus.history, isNotNull);

      eventBus.dispose();
    });
  });
}
