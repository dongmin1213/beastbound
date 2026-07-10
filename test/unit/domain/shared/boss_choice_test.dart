import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

void main() {
  group('BossChoice', () {
    test('생성 + 필드 확인', () {
      const choice = BossChoice(
        floor: 1,
        bossId: 'boss_fire',
        choiceType: BossChoiceType.slay,
      );
      expect(choice.floor, 1);
      expect(choice.bossId, 'boss_fire');
      expect(choice.choiceType, BossChoiceType.slay);
    });

    test('동일한 값 → 동등', () {
      const a = BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay);
      const b = BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('다른 floor → 비동등', () {
      const a = BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay);
      const b = BossChoice(floor: 2, bossId: 'boss_fire', choiceType: BossChoiceType.slay);
      expect(a, isNot(b));
    });

    test('다른 bossId → 비동등', () {
      const a = BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay);
      const b = BossChoice(floor: 1, bossId: 'boss_water', choiceType: BossChoiceType.slay);
      expect(a, isNot(b));
    });

    test('다른 choiceType → 비동등', () {
      const a = BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.slay);
      const b = BossChoice(floor: 1, bossId: 'boss_fire', choiceType: BossChoiceType.liberate);
      expect(a, isNot(b));
    });

    test('toString 포맷', () {
      const choice = BossChoice(floor: 3, bossId: 'boss_x', choiceType: BossChoiceType.coexist);
      expect(choice.toString(), contains('floor: 3'));
      expect(choice.toString(), contains('bossId: boss_x'));
      expect(choice.toString(), contains('BossChoiceType.coexist'));
    });
  });

  group('BossChoiceType', () {
    test('6가지 타입 존재', () {
      expect(BossChoiceType.values.length, 6);
    });

    test('displayName 한글', () {
      expect(BossChoiceType.slay.displayName, '처치');
      expect(BossChoiceType.liberate.displayName, '해방');
      expect(BossChoiceType.coexist.displayName, '공존');
      expect(BossChoiceType.study.displayName, '깨달음을 얻는다');
      expect(BossChoiceType.consume.displayName, '흡수한다');
      expect(BossChoiceType.protect.displayName, '봉인한다');
    });

    test('dispositionAxis 매핑', () {
      expect(BossChoiceType.slay.dispositionAxis, DispositionAxis.struggle);
      expect(BossChoiceType.liberate.dispositionAxis, DispositionAxis.mercy);
      expect(BossChoiceType.coexist.dispositionAxis, DispositionAxis.harmony);
      expect(BossChoiceType.study.dispositionAxis, DispositionAxis.wisdom);
      expect(BossChoiceType.consume.dispositionAxis, DispositionAxis.shadow);
      expect(BossChoiceType.protect.dispositionAxis, DispositionAxis.will);
    });

    test('6가지 타입이 6축 성향을 각각 커버', () {
      final axes = BossChoiceType.values.map((t) => t.dispositionAxis).toSet();
      expect(axes, containsAll(DispositionAxis.values));
    });

    group('endingCategory', () {
      test('slay → slay', () {
        expect(BossChoiceType.slay.endingCategory, BossChoiceType.slay);
      });

      test('consume → slay', () {
        expect(BossChoiceType.consume.endingCategory, BossChoiceType.slay);
      });

      test('liberate → liberate', () {
        expect(BossChoiceType.liberate.endingCategory, BossChoiceType.liberate);
      });

      test('protect → liberate', () {
        expect(BossChoiceType.protect.endingCategory, BossChoiceType.liberate);
      });

      test('coexist → coexist', () {
        expect(BossChoiceType.coexist.endingCategory, BossChoiceType.coexist);
      });

      test('study → coexist', () {
        expect(BossChoiceType.study.endingCategory, BossChoiceType.coexist);
      });
    });

    group('isAggressive', () {
      test('slay/consume은 공격적', () {
        expect(BossChoiceType.slay.isAggressive, isTrue);
        expect(BossChoiceType.consume.isAggressive, isTrue);
      });

      test('나머지는 온건', () {
        expect(BossChoiceType.liberate.isAggressive, isFalse);
        expect(BossChoiceType.protect.isAggressive, isFalse);
        expect(BossChoiceType.coexist.isAggressive, isFalse);
        expect(BossChoiceType.study.isAggressive, isFalse);
      });
    });
  });
}
