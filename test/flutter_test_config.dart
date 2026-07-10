import 'dart:async';

import 'package:soul_dungeon/presentation/theme/app_theme.dart';

/// 전역 테스트 설정.
///
/// flutter_animate의 `_AnimateState.initState`가 zero-duration Timer를 생성하여
/// "A Timer is still pending" 에러를 유발한다.
/// 테스트 환경에서는 flutter_animate 기반 애니메이션이 불필요하므로 비활성화.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppTheme.enableAnimations = false;
  await testMain();
}
