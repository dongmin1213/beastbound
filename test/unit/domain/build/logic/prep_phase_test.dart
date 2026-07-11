import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/build/logic/prep_phase.dart';

void main() {
  group('PrepPhaseData', () {
    test('getChoices returns 6 choices', () {
      final choices = PrepPhaseData.getChoices();
      expect(choices.length, 6);
    });

    test('각 선택지 ID가 prep_ 접두사', () {
      final choices = PrepPhaseData.getChoices();
      for (final choice in choices) {
        expect(choice.id, startsWith('prep_'));
      }
    });

    test('골드 보너스 선택지', () {
      final choices = PrepPhaseData.getChoices(startingGoldBonus: 25);
      final goldChoice = choices.firstWhere((c) => c.id == 'prep_gold');
      expect(goldChoice.bonusType, PrepBonusType.gold);
      expect(goldChoice.bonusValue, 25);
    });

    test('HP 보너스 선택지', () {
      final choices = PrepPhaseData.getChoices(startingHpBonus: 20);
      final hpChoice = choices.firstWhere((c) => c.id == 'prep_hp');
      expect(hpChoice.bonusType, PrepBonusType.hp);
      expect(hpChoice.bonusValue, 20);
    });

    test('축복 보너스 선택지', () {
      final choices = PrepPhaseData.getChoices(
        startingBlessingId: 'blessing_002',
      );
      final blessingChoice =
          choices.firstWhere((c) => c.id == 'prep_blessing');
      expect(blessingChoice.bonusType, PrepBonusType.blessing);
      expect(blessingChoice.blessingId, 'blessing_002');
    });

    test('유물 보너스 선택지', () {
      final choices = PrepPhaseData.getChoices(
        startingRelicId: 'relic_005',
      );
      final relicChoice = choices.firstWhere((c) => c.id == 'prep_relic');
      expect(relicChoice.bonusType, PrepBonusType.relic);
      expect(relicChoice.relicId, 'relic_005');
    });

    test('자비 HP 보너스 선택지', () {
      final choices = PrepPhaseData.getChoices(mercyHpBonus: 12);
      final mercyChoice = choices.firstWhere((c) => c.id == 'prep_mercy');
      expect(mercyChoice.bonusType, PrepBonusType.hp);
      expect(mercyChoice.bonusValue, 12);
    });

    test('균형 보너스 선택지', () {
      final choices = PrepPhaseData.getChoices(
        balancedGold: 15,
        balancedHp: 10,
      );
      final balancedChoice =
          choices.firstWhere((c) => c.id == 'prep_balanced');
      expect(balancedChoice.bonusType, PrepBonusType.balanced);
      expect(balancedChoice.bonusValue, 15); // gold
      expect(balancedChoice.secondaryValue, 10); // hp
    });

    test('기본값 사용', () {
      final choices = PrepPhaseData.getChoices();
      final goldChoice = choices.firstWhere((c) => c.id == 'prep_gold');
      expect(goldChoice.bonusValue, 20);

      final hpChoice = choices.firstWhere((c) => c.id == 'prep_hp');
      expect(hpChoice.bonusValue, 15);

      final blessingChoice =
          choices.firstWhere((c) => c.id == 'prep_blessing');
      expect(blessingChoice.blessingId, 'blessing_001');

      final relicChoice = choices.firstWhere((c) => c.id == 'prep_relic');
      expect(relicChoice.relicId, 'relic_001');

      final mercyChoice = choices.firstWhere((c) => c.id == 'prep_mercy');
      expect(mercyChoice.bonusValue, 10);

      final balancedChoice =
          choices.firstWhere((c) => c.id == 'prep_balanced');
      expect(balancedChoice.bonusValue, 10);
      expect(balancedChoice.secondaryValue, 8);
    });

    test('introText가 비어있지 않음', () {
      expect(PrepPhaseData.introText, isNotEmpty);
    });

    test('choicePromptText가 비어있지 않음', () {
      expect(PrepPhaseData.choicePromptText, isNotEmpty);
    });
  });

  group('PrepBonusType', () {
    test('5가지 보너스 유형', () {
      expect(PrepBonusType.values, hasLength(5));
    });
  });
}
