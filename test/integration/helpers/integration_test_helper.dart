import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/app.dart';
import 'package:soul_dungeon/audio/engine/sound_layer_manager.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';

/// 통합 테스트 공용 헬퍼.
///
/// SoulDungeonApp 직접 사용 (실제 DI 경로 검증).
/// pumpAndSettle 절대 금지 → pumpFrames 사용.
///
/// 디바이스(Xcode/에뮬레이터) 없이도 `flutter test integration_test/` 로 실행 가능.
/// 디바이스 연결 시 `IntegrationTestWidgetsFlutterBinding` 으로 전환 가능.
class IntegrationTestHelper {
  IntegrationTestHelper._();

  /// TestWidgetsFlutterBinding 초기화.
  static TestWidgetsFlutterBinding ensureInitialized() {
    return AutomatedTestWidgetsFlutterBinding.ensureInitialized();
  }

  /// 전체 앱 빌드 (기본 BalanceConfig, asset 로딩 불필요).
  /// [initialRoute] 지정 가능 — 기본 '/game' (통합 테스트는 GameScreen 직접 진입).
  static Widget buildApp({GameEventBus? eventBus, String initialRoute = '/game'}) {
    return SoulDungeonApp(
      balanceConfig: const BalanceConfig(),
      gameEventBus: eventBus,
      soundManager: NoOpSoundLayerManager(),
      initialRoute: initialRoute,
    );
  }

  /// N프레임 펌프 (pumpAndSettle 대체).
  /// [each] 지정 시 각 프레임 간 Duration 적용.
  static Future<void> pumpFrames(
    WidgetTester tester,
    int count, [
    Duration each = const Duration(milliseconds: 50),
  ]) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(each);
    }
  }

  /// 앱 시작 후 첫 화면 렌더링 대기.
  static Future<void> launchApp(WidgetTester tester, {GameEventBus? eventBus}) async {
    await tester.pumpWidget(buildApp(eventBus: eventBus));
    // 초기 빌드 + postFrameCallback + setState 완료 대기
    await pumpFrames(tester, 5);
  }
}
