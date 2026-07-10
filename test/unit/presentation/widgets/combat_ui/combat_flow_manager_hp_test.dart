import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_defeat_handler.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

void main() {
  group('CombatFlowManager HP blocks', () {
    test('buildDefeatHpBlock generates healthy tier text', () {
      final block = CombatFlowManager.buildDefeatHpBlock(
        hpLost: 30,
        remainingHp: 70,
        maxHp: 100,
        tier: HpNarrationTier.healthy,
      );

      expect(block.text, '체력이 30 감소했다. (70/100)');
      expect(block.blockType, TextBlockType.normal);
      expect(block.metadata?['hpLoss'], true);
      expect(block.metadata?['hpLost'], 30);
      expect(block.metadata?['remainingHp'], 70);
    });

    test('buildDefeatHpBlock generates wounded tier text', () {
      final block = CombatFlowManager.buildDefeatHpBlock(
        hpLost: 30,
        remainingHp: 60,
        maxHp: 100,
        tier: HpNarrationTier.wounded,
      );

      expect(block.text, contains('숨이 거칠어진다.'));
      expect(block.text, contains('체력이 30 감소했다.'));
    });

    test('buildDefeatHpBlock generates critical tier text', () {
      final block = CombatFlowManager.buildDefeatHpBlock(
        hpLost: 30,
        remainingHp: 40,
        maxHp: 100,
        tier: HpNarrationTier.critical,
      );

      expect(block.text, contains('몸이 비틀거린다.'));
    });

    test('buildDefeatHpBlock generates danger tier text', () {
      final block = CombatFlowManager.buildDefeatHpBlock(
        hpLost: 30,
        remainingHp: 10,
        maxHp: 100,
        tier: HpNarrationTier.danger,
      );

      expect(block.text, contains('시야가 흐려진다.'));
    });

    test('buildDefeatHpBlock generates dead tier text', () {
      final block = CombatFlowManager.buildDefeatHpBlock(
        hpLost: 30,
        remainingHp: 0,
        maxHp: 100,
        tier: HpNarrationTier.dead,
      );

      expect(block.text, '마지막 체력이 소진되었다.');
    });

    test('buildPermadeathBlock creates permadeath narration', () {
      final block = CombatFlowManager.buildPermadeathBlock();

      expect(
        block.text,
        '어둠이 밀려온다. 마지막 힘이 빠져나가고... 의식이 흐려진다.',
      );
      expect(block.blockType, TextBlockType.normal);
      expect(block.metadata?['permadeath'], true);
    });

    test('buildPermadeathBlock metadata includes permadeath flag', () {
      final block = CombatFlowManager.buildPermadeathBlock();

      expect(block.metadata, isNotNull);
      expect(block.metadata!['permadeath'], true);
    });

    test('buildDefeatHpBlock metadata includes all HP info', () {
      final block = CombatFlowManager.buildDefeatHpBlock(
        hpLost: 50,
        remainingHp: 20,
        maxHp: 100,
        tier: HpNarrationTier.danger,
      );

      expect(block.metadata?['hpLoss'], true);
      expect(block.metadata?['hpLost'], 50);
      expect(block.metadata?['remainingHp'], 20);
    });
  });
}
