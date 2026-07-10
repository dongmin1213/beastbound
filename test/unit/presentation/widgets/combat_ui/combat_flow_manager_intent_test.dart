import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';

void main() {
  group('CombatFlowManager.describeEnemyIntent', () {
    test('의도 공개 — 구체적 텍스트 반환', () {
      final result = CombatFlowManager.describeEnemyIntent(
        enemyName: '쥐',
        showIntent: true,
        intentText: '쥐이(가) 공격하려 한다 (8)',
      );
      expect(result, '쥐이(가) 공격하려 한다 (8)');
    });

    test('의도 비공개 — 숨김 텍스트 반환', () {
      final result = CombatFlowManager.describeEnemyIntent(
        enemyName: '고블린 족장',
        showIntent: false,
        intentText: '고블린 족장이(가) 공격하려 한다 (14)',
      );
      expect(result, contains('무언가를 준비'));
      expect(result, contains('고블린 족장'));
    });

    test('보스 의도 비공개', () {
      final result = CombatFlowManager.describeEnemyIntent(
        enemyName: '슬라임 킹',
        showIntent: false,
        intentText: '슬라임 킹이(가) 강공격을 준비한다! (20)',
      );
      expect(result, isNot(contains('강공격')));
      expect(result, contains('준비'));
    });
  });
}
