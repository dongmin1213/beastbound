import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';

void main() {
  group('MomentumTier', () {
    test('enum values 3개 확인 (low, medium, high)', () {
      expect(MomentumTier.values.length, 3);
      expect(MomentumTier.values, contains(MomentumTier.low));
      expect(MomentumTier.values, contains(MomentumTier.medium));
      expect(MomentumTier.values, contains(MomentumTier.high));
    });

    test('displayName 정확성 (저, 중, 고)', () {
      expect(MomentumTier.low.displayName, '저');
      expect(MomentumTier.medium.displayName, '중');
      expect(MomentumTier.high.displayName, '고');
    });
  });

  group('MomentumDelta', () {
    test('== / hashCode 동등성', () {
      const a = MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );
      const b = MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('서로 다른 인스턴스 비동등성', () {
      const a = MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );
      const b = MomentumDelta(
        value: -10,
        reason: MomentumChangeReason.sameAction,
      );

      expect(a, isNot(equals(b)));
    });

    test('같은 value 다른 reason 비동등성', () {
      const a = MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.actionSwitch,
      );
      const b = MomentumDelta(
        value: 15,
        reason: MomentumChangeReason.none,
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('MomentumChangeReason', () {
    test('enum values 7개 확인', () {
      expect(MomentumChangeReason.values.length, 7);
      expect(MomentumChangeReason.values,
          contains(MomentumChangeReason.actionSwitch));
      expect(MomentumChangeReason.values,
          contains(MomentumChangeReason.sameAction));
      expect(MomentumChangeReason.values,
          contains(MomentumChangeReason.sameActionStreak));
      expect(MomentumChangeReason.values,
          contains(MomentumChangeReason.environmentAction));
      expect(MomentumChangeReason.values,
          contains(MomentumChangeReason.specialAction));
      expect(MomentumChangeReason.values,
          contains(MomentumChangeReason.cardTypeSwitch));
      expect(
          MomentumChangeReason.values, contains(MomentumChangeReason.none));
    });
  });
}
